//
//  SnapCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore
import TurtleSimulatorCore

class SnapCompilerTests: XCTestCase {
    let kStaticStorageStartAddress = SnapToCrackleCompiler.kStaticStorageStartAddress
    
    func testCompileFailsDuringLexing() {
        let compiler = SnapCompiler()
        compiler.compile("@")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "@")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "unexpected character: `@'")
    }
    
    func testCompileFailsDuringParsing() {
        let compiler = SnapCompiler()
        compiler.compile(":")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, ":")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "operand type mismatch: `:'")
    }
    
    func testCompileFailsDuringCodeGeneration() {
        let compiler = SnapCompiler()
        compiler.compile("foo")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "foo")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `foo'")
    }
    
    func testEnsureDisassemblyWorks() {
        let compiler = SnapCompiler()
        compiler.compile("")
        XCTAssertFalse(compiler.hasError)
        XCTAssertGreaterThan(compiler.instructions.count, 0)
        XCTAssertEqual(compiler.instructions.first?.disassembly, "NOP")
    }
    
    func test_EndToEndIntegration_SimplestProgram() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let a = 42
""")
        XCTAssertEqual(computer.loadSymbolU8("a"), 42)
    }
    
    func test_EndToEndIntegration_ForIn_Range_1() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var a: u16 = 255
for i in 0..10 {
    a = i
}
""")
        XCTAssertEqual(computer.loadSymbolU16("a"), 9)
    }
    
    func test_EndToEndIntegration_ForIn_Range_2() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var a: u16 = 255
let range = 0..10
for i in range {
    a = i
}
""")
        XCTAssertEqual(computer.loadSymbolU16("a"), 9)
    }
    
    func test_EndToEndIntegration_ForIn_Range_SingleStatement() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var a: u16 = 255
for i in 0..10
    a = i
""")
        XCTAssertEqual(computer.loadSymbolU16("a"), 9)
    }
    
    func test_EndToEndIntegration_ForIn_String() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
var a = 255
for i in "hello" {
    a = i
}
""")
        XCTAssertEqual(computer.loadSymbolU8("a"), UInt8("o".utf8.first!))
    }
    
    func test_EndToEndIntegration_ForIn_ArrayOfU16() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
var a: u16 = 0xffff
for i in [_]u16{0x1000, 0x2000, 0x3000, 0x4000, 0x5000} {
    a = i
}
""")
        XCTAssertEqual(computer.loadSymbolU16("a"), UInt16(0x5000))
    }
    
    func test_EndToEndIntegration_ForIn_DynamicArray_1() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
var a: u16 = 0xffff
let arr = [_]u16{0x1000, 0x2000, 0x3000, 0x4000, 0x5000}
let slice: []u16 = arr
for i in slice {
    a = i
}
""")
        XCTAssertEqual(computer.loadSymbolU16("a"), UInt16(0x5000))
    }
    
    // TODO: This test fails. The problem seems to be binding the dynamic array to a temporary literal array. Is the failure expected, or is there a problem here?
    func DISABLED_test_EndToEndIntegration_ForIn_DynamicArray_2() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
var a: u16 = 0xffff
let slice: []u16 = [_]u16{0x1000, 0x2000, 0x3000, 0x4000, 0x5000}
for i in slice {
    a = i
}
""")
        XCTAssertEqual(computer.loadSymbolU16("a"), UInt16(0x5000))
    }
    
    func test_EndToEndIntegration_Fibonacci() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var a = 1
var b = 1
var fib = 0
for i in 0..10 {
    fib = b + a
    a = b
    b = fib
}
""")
        XCTAssertEqual(computer.loadSymbolU8("a"), 89)
        XCTAssertEqual(computer.loadSymbolU8("b"), 144)
    }
    
    func test_EndToEndIntegration_Fibonacci_ExercisingStaticKeyword() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var a = 1
var b = 1
for i in 0..10 {
    static var fib = b + a
    a = b
    b = fib
}
""")
        XCTAssertEqual(computer.loadSymbolU8("a"), 89)
        XCTAssertEqual(computer.loadSymbolU8("b"), 144)
    }
    
    func testLocalVariablesDoNotSurviveTheLocalScope() {
        let compiler = SnapCompiler()
        compiler.compile("""
{
    var a = 1
    a = 2
}
a = 3
""")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "a")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 4..<5)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `a'")
    }
    
    func testLocalVariablesDoNotSurviveTheLocalScope_ForLoop() {
        let compiler = SnapCompiler()
        compiler.compile("""
for i in 0..10 {
    var a = i
}
i = 3
""")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "i")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 3..<4)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `i'")
    }
    
    func test_EndToEndIntegration_StaticVarInAFunctionContextIsStoredInStaticDataArea() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() {
    static var a = 0xaa
}
foo()
""")
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xaa) // var a
    }
    
    // Local variables declared in a local scope are not necessarily associated
    // with a new stack frame. In many cases, these variables are allocated in
    // the same stack frame, or in the next slot of the static storage area.
    func test_EndToEndIntegration_BlocksAreNotStackFrames_0() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var a = 0xaa
{
    var b = 0xbb
    {
        var c = 0xcc
    }
}
""")
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+0), 0xaa) // var a
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+1), 0xbb) // var b
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+2), 0xcc) // var c
    }
    
    // Local variables declared in a local scope are not necessarily associated
    // with a new stack frame. In many cases, these variables are allocated in
    // the same stack frame, or in the next slot of the static storage area.
    func test_EndToEndIntegration_BlocksAreNotStackFrames_1() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var a = 0xaa
{
    var b = a
    {
        {
            {
                var c = b
            }
        }
    }
}
""")
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+0), 0xaa) // var a
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+1), 0xaa) // var b
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+2), 0xaa) // var c
    }
    
    func test_EndToEndIntegration_StoreLocalVariableDefinedSeveralScopesUp_StackFramesNotEqualToScopes() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> u8 {
    var b = 0xaa
    func bar() -> u8 {
        {
            return b
        }
    }
    return bar()
}
let a = foo()
""")
        
        XCTAssertEqual(computer.loadSymbolU8("a"), 0xaa) // var a
    }
    
    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU8() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> u8 {
    return 0xaa
}
let a = foo()
""")
        
        XCTAssertEqual(computer.loadSymbolU8("a"), 0xaa)
    }
    
    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU16() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> u16 {
    return 0xabcd
}
let a = foo()
""")
        
        XCTAssertEqual(computer.loadSymbolU16("a"), 0xabcd)
    }
    
    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU8PromotedToU16() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> u16 {
    return 0xaa
}
let a = foo()
""")
        
        XCTAssertEqual(computer.loadSymbolU16("a"), 0x00aa)
    }
    
    func test_EndToEndIntegration_NestedFunctionDeclarations() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> u8 {
    let val = 0xaa
    func bar() -> u8 {
        return val
    }
    return bar()
}
let a = foo()
""")
        
        XCTAssertEqual(computer.loadSymbolU8("a"), 0xaa)
    }
    
    func test_EndToEndIntegration_ReturnFromInsideIfStmt() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> u8 {
    if 1 + 1 == 2 {
        return 0xaa
    } else {
        return 0xbb
    }
}
let a = foo()
""")
        
        XCTAssertEqual(computer.loadSymbolU8("a"), 0xaa)
    }
    
    func testMissingReturn_1() {
        let compiler = SnapCompiler()
        compiler.compile("""
func foo() -> u8 {
}
""")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "foo")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "missing return in a function expected to return `u8'")
    }
    
    func testMissingReturn_2() {
        let compiler = SnapCompiler()
        compiler.compile("""
func foo() -> u8 {
    if false {
        return 1
    }
}
""")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "foo")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "missing return in a function expected to return `u8'")
    }
    
    func testUnexpectedNonVoidReturnValueInVoidFunction() {
        let compiler = SnapCompiler()
        compiler.compile("""
func foo() {
    return 1
}
""")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "1")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 1..<2)
        XCTAssertEqual(compiler.errors.first?.message, "unexpected non-void return value in void function")
    }
    
    func test_EndToEndIntegration_PromoteInAssignmentStatement() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var result = 0xabcd
result = 42
""")
        
        XCTAssertEqual(computer.loadSymbolU16("result"), 42)
    }
    
    func test_EndToEndIntegration_PromoteParameterInCall() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var result = 0xabcd
func foo(n: u16) {
    result = n
}
foo(42)
""")
        
        XCTAssertEqual(computer.loadSymbolU16("result"), 42)
    }
    
    func test_EndToEndIntegration_PromoteReturnValue() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo(n: u8) -> u16 {
    return n
}
let result = foo(42)
""")
        
        XCTAssertEqual(computer.loadSymbolU16("result"), 42)
    }
    
func test_EndToEndIntegration_MutuallyRecursiveFunctions() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func isEven(n: u8) -> bool {
    if n == 0 {
        return true
    } else {
        return isOdd(n - 1)
    }
}

func isOdd(n: u8) -> bool {
    if n == 0 {
        return false
    } else {
        return isEven(n - 1)
    }
}

let a = isOdd(7)
""")
        
        XCTAssertEqual(computer.loadSymbolBool("a"), true)
    }
    
    func test_EndToEndIntegration_MutuallyRecursiveFunctions_u16() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func isEven(n: u16) -> bool {
    if n == 0 {
        return true
    } else {
        return isOdd(n - 1)
    }
}

func isOdd(n: u16) -> bool {
    if n == 0 {
        return false
    } else {
        return isEven(n - 1)
    }
}

let a = isOdd(3)
""")
        
        XCTAssertEqual(computer.loadSymbolBool("a"), true)
    }
    
    func test_EndToEndIntegration_RecursiveFunctions_u8() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var count = 0
func foo(n: u8) {
    if n > 0 {
        count = count + 1
        foo(n - 1)
    }
}
foo(10)
""")
        
        XCTAssertEqual(computer.loadSymbolU8("count"), 10)
    }
    
    func test_EndToEndIntegration_RecursiveFunctions_u16() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var count = 0
func foo(n: u16) {
    if n > 0 {
        count = count + 1
        foo(n - 1)
    }
}
foo(10)
""")
        
        XCTAssertEqual(computer.loadSymbolU8("count"), 10)
    }
    
    func test_EndToEndIntegration_FunctionCallsInExpression() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo(n: u8) -> u8 {
    return n
}
let r = foo(2) + 1
""")
        
        XCTAssertEqual(computer.loadSymbolU8("r"), 3)
    }
    
    func test_EndToEndIntegration_RecursiveFunctions_() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo(n: u8) -> u8 {
    if n == 0 {
        return 0
    }
    return foo(n - 1) + 1
}
let count = foo(1)
""")
        XCTAssertEqual(computer.loadSymbolU8("count"), 1)
    }
        
    func test_EndToEndIntegration_ReturnInVoidFunction() {
        let executor = SnapExecutor()
        let _ = try! executor.execute(program: """
func foo() {
    return
}
foo()
""")
    }
        
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_Let() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let foo: u16 = 0xffff
""")
        
        XCTAssertEqual(computer.loadSymbolU16("foo"), 0xffff)
    }
        
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_Var() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var foo: u16 = 0xffff
""")
        
        XCTAssertEqual(computer.loadSymbolU16("foo"), 0xffff)
    }
        
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_PromoteU8ToU16() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let foo: u16 = 10
""")
        
        XCTAssertEqual(computer.loadSymbolU16("foo"), 10)
    }
        
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_Bool() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let foo: bool = true
""")
        
        XCTAssertEqual(computer.loadSymbolBool("foo"), true)
    }
        
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_CannotConvertU16ToBool() {
        let compiler = SnapCompiler()
        compiler.compile("""
let foo: bool = 0xffff
""")
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "0xffff")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "cannot assign value of type `integer constant 65535' to type `const bool'")
    }
    
    func test_EndToEndIntegration_CastU16DownToU8() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var foo: u16 = 1
let bar: u8 = foo as u8
""")
        
        XCTAssertEqual(computer.loadSymbolU16("foo"), 1)
        XCTAssertEqual(computer.loadSymbolU8("bar"), 1)
    }
        
    func test_EndToEndIntegration_PokeMemory() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
pokeMemory(0xab, \(kStaticStorageStartAddress))
""")
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xab)
    }
    
    func test_EndToEndIntegration_PeekMemory() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let a = 0xab
let b = peekMemory(\(kStaticStorageStartAddress))
""")
        
        XCTAssertEqual(computer.loadSymbolU8("a"), 0xab)
        XCTAssertEqual(computer.loadSymbolU8("b"), 0xab)
    }
        
    func test_EndToEndIntegration_PokePeripheral() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
pokePeripheral(0xab, 0xffff, 1)
pokePeripheral(0xcd, 0xffff, 0)
""")
        
        // There's a hardware bug in Rev 2 where the bits of the instruction
        // RAM port connected to the data bus are in reverse order.
        XCTAssertEqual(computer.lowerInstructionRAM.load(from: 0xffff), UInt8(0xab).reverseBits())
        XCTAssertEqual(computer.upperInstructionRAM.load(from: 0xffff), UInt8(0xcd).reverseBits())
    }
        
    func test_EndToEndIntegration_PeekPeripheral() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let a = peekPeripheral(0, 0)
let b = peekPeripheral(0, 1)
""")
        
        XCTAssertEqual(computer.lowerInstructionRAM.load(from: 0), 0)
        XCTAssertEqual(computer.upperInstructionRAM.load(from: 0), 0)
        XCTAssertEqual(computer.loadSymbolU8("a"), 0)
        XCTAssertEqual(computer.loadSymbolU8("b"), 0)
    }
        
    func test_EndToEndIntegration_Hlt() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
pokeMemory(0xab, \(kStaticStorageStartAddress))
hlt()
pokeMemory(0xcd, \(kStaticStorageStartAddress))
""")
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xab)
    }
    
    func test_EndToEndIntegration_DeclareArrayType_InferredType() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let arr = [_]u8{1, 2, 3}
""")
        XCTAssertEqual(computer.loadSymbolArrayOfU8(3, "arr"), [1, 2, 3])
    }
    
    func test_EndToEndIntegration_DeclareArrayType_ExplicitType() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let arr: [_]u8 = [_]u8{1, 2, 3}
""")
        XCTAssertEqual(computer.loadSymbolArrayOfU8(3, "arr"), [1, 2, 3])
    }
    
    func test_EndToEndIntegration_FailToAssignScalarToArray() {
        let compiler = SnapCompiler()
        compiler.compile("""
let arr: [_]u8 = 1
""")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "1")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "cannot assign value of type `integer constant 1' to type `[_]const u8'")
    }
            
    func test_EndToEndIntegration_FailToAssignFunctionToArray() {
        let compiler = SnapCompiler()
        compiler.compile("""
func foo(bar: u8, baz: u16) -> bool {
    return false
}
let arr: [_]u16 = foo
""")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "foo")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 3..<4)
        XCTAssertEqual(compiler.errors.first?.message, "inappropriate use of a function type (Try taking the function's address instead.)")
    }
    
    func test_EndToEndIntegration_CannotAddArrayToInteger() {
        let compiler = SnapCompiler()
        compiler.compile("""
let foo = [_]u8{1, 2, 3}
let bar = 1 + foo
""")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "1 + foo")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 1..<2)
        XCTAssertEqual(compiler.errors.first?.message, "binary operator `+' cannot be applied to operands of types `integer constant 1' and `[3]const u8'")
    }
    
    func test_EndToEndIntegration_ArrayOfIntegerConstantsConvertedToArrayOfU16OnInitialAssignment() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let arr: [_]u16 = [_]u16{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
""")
        XCTAssertEqual(computer.loadSymbolArrayOfU16(10, "arr"), [100, 101, 102, 103, 104, 105, 106, 107, 108, 109])
    }
    
    func test_EndToEndIntegration_ArrayOfU8ConvertedToArrayOfU16OnInitialAssignment() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let arr: [_]u16 = [_]u16{42 as u8}
""")
        XCTAssertEqual(computer.loadSymbolArrayOfU16(1, "arr"), [42])
    }
    
    func test_EndToEndIntegration_ReadArrayElement_U16() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
var result: u16 = 0
let arr: [_]u16 = [_]u16{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
result = arr[0]
""")
        XCTAssertEqual(computer.loadSymbolU16("result"), 100)
    }
    
    func test_EndToEndIntegration_CastArrayLiteralFromArrayOfU8ToArrayOfU16() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let foo = [_]u8{1, 2, 3} as [_]u16
""")
        XCTAssertEqual(computer.loadSymbolArrayOfU16(3, "foo"), [1, 2, 3])
    }
    
    func test_EndToEndIntegration_FailToCastIntegerLiteralToArrayOfU8BecauseOfOverflow() {
        let compiler = SnapCompiler()
        compiler.compile("""
let foo = [_]u8{0x1001, 0x1002, 0x1003} as [_]u8
""")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "0x1001")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "integer constant `4097' overflows when stored into `u8'")
    }
    
    func test_EndToEndIntegration_CastArrayOfU16ToArrayOfU8() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let foo = [_]u16{0x1001 as u16, 0x1002 as u16, 0x1003 as u16} as [_]u8
""")
        XCTAssertEqual(computer.loadSymbolArrayOfU8(3, "foo"), [1, 2, 3])
    }
    
    func test_EndToEndIntegration_ReassignArrayContentsWithLiteralArray() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var arr: [_]u16 = [_]u16{0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff}
arr = [_]u16{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
""")
        XCTAssertEqual(computer.loadSymbolArrayOfU16(10, "arr"), [100, 101, 102, 103, 104, 105, 106, 107, 108, 109])
    }
    
    func test_EndToEndIntegration_ReassignArrayContentsWithArrayIdentifier() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
var a: [_]u16 = [_]u16{0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff}
let b: [_]u16 = [_]u16{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
a = b
""")
        XCTAssertEqual(computer.loadSymbolArrayOfU16(10, "a"), [100, 101, 102, 103, 104, 105, 106, 107, 108, 109])
    }
    
    func test_EndToEndIntegration_ReassignArrayContents_ConvertingFromArrayOfU8ToArrayOfU16() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
var a: [_]u16 = [_]u16{0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff}
let b = [_]u8{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
a = b
""")
        XCTAssertEqual(computer.loadSymbolArrayOfU16(10, "a"), [100, 101, 102, 103, 104, 105, 106, 107, 108, 109])
    }
    
    func test_EndToEndIntegration_AccessVariableInFunction_U8() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> u8 {
    let result: u8 = 42
    return result
}
let bar = foo()
""")
        XCTAssertEqual(computer.loadSymbolU8("bar"), 42)
    }
    
    func test_EndToEndIntegration_AccessVariableInFunction_U16() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> u16 {
    let result: u16 = 42
    return result
}
let bar: u16 = foo()
""")
        XCTAssertEqual(computer.loadSymbolU16("bar"), 42)
    }
    
    func test_EndToEndIntegration_SumLoop() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func sum() -> u8 {
    var accum = 0
    for i in 0..3 {
        accum = accum + 1
    }
    return accum
}
let foo = sum()
""")
        XCTAssertEqual(computer.loadSymbolU8("foo"), 3)
    }
    
    func test_EndToEndIntegration_PassArrayAsFunctionParameter_1() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
func sum(a: [3]u16) -> u16 {
    return a[0] + a[1] + a[2]
}
let foo = sum([3]u16{1, 2, 3})
""")
        XCTAssertEqual(computer.loadSymbolU16("foo"), 6)
    }
    
    func test_EndToEndIntegration_PassArrayAsFunctionParameter_2() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
func sum(a: [3]u16) -> u16 {
    var accum: u16 = 0
    for i in 0..3 {
        accum = accum + a[i]
    }
    return accum
}
let foo = sum([_]u16{1, 2, 3})
""")
        XCTAssertEqual(computer.loadSymbolU16("foo"), 6)
    }
    
    func test_EndToEndIntegration_ReturnArrayByValue_U8() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func makeArray() -> [3]u8 {
    return [_]u8{1, 2, 3}
}
let foo = makeArray()
""")
        XCTAssertEqual(computer.loadSymbolArrayOfU8(3, "foo"), [1, 2, 3])
    }
    
    func test_EndToEndIntegration_ReturnArrayByValue_U16() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func makeArray() -> [3]u16 {
    return [_]u16{0x1234, 0x5678, 0x9abc}
}
let foo = makeArray()
""")
        XCTAssertEqual(computer.loadSymbolArrayOfU16(3, "foo"), [0x1234, 0x5678, 0x9abc])
    }
    
    func test_EndToEndIntegration_PassTwoArraysAsFunctionParameters_1() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
func sum(a: [3]u8, b: [3]u8, c: u8) -> u8 {
    return (a[0] + b[0] + a[1] + b[1] + a[2] + b[2]) * c
}
let foo = sum([_]u8{1, 2, 3}, [_]u8{4, 5, 6}, 2)
""")
        XCTAssertEqual(computer.loadSymbolU8("foo"), 42)
    }
    
    func test_EndToEndIntegration_PassArraysAsFunctionArgumentsAndReturnArrayValue() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
func sum(a: [3]u8, b: [3]u8, c: u8) -> [3]u8 {
    var result = [_]u8{0, 0, 0}
    for i in 0..3 {
        result[i] = (a[i] + b[i]) * c
    }
    return result
}
let foo = sum([_]u8{1, 2, 3}, [_]u8{4, 5, 6}, 2)
""")
        XCTAssertEqual(computer.loadSymbolArrayOfU8(3, "foo"), [10, 14, 18])
    }
    
    func test_EndToEndIntegration_PassArraysAsFunctionArgumentsAndReturnArrayValue_U16() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
func sum(a: [3]u16, b: [3]u16, c: u16) -> [3]u16 {
    var result = [_]u16{0, 0, 0}
    for i in 0..3 {
        result[i] = (a[i] + b[i]) * c
    }
    return result
}
let foo = sum([_]u8{1, 2, 3}, [_]u8{4, 5, 6}, 2)
""")
        XCTAssertEqual(computer.loadSymbolArrayOfU16(3, "foo"), [10, 14, 18])
    }
    
    func test_EndToEndIntegration_BugWhenStackVariablesAreDeclaredAfterForLoop() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> u16 {
    for i in 0..3 {
    }
    let a = 42
    return a
}
let b = foo()
""")
        
        XCTAssertEqual(computer.loadSymbolU16("b"), 42)
    }
    
    func testSerialOutput_HelloWorld() {
        var serialOutput = ""
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        executor.configure = { computer in
            computer.didUpdateSerialOutput = {
                serialOutput = $0
            }
        }
        let computer = try! executor.execute(program: """
puts("Hello, World!")
""")
        XCTAssertEqual(serialOutput, "Hello, World!")
        print("total running time: \(computer.cpuState.uptime) cycles")
    }
    
    func testSerialOutput_Panic() {
        var serialOutput = ""
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        executor.configure = { computer in
            computer.didUpdateSerialOutput = {
                serialOutput = $0
            }
        }
        _ = try! executor.execute(program: """
panic("oops!")
puts("Hello, World!")
""")
        XCTAssertEqual(serialOutput, "PANIC: oops!")
    }
    
    func testArrayOutOfBoundsError() {
        var serialOutput = ""
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        executor.configure = { computer in
            computer.didUpdateSerialOutput = {
                serialOutput = $0
            }
        }
        _ = try! executor.execute(program: """
let arr = "Hello"
let foo = arr[10]
""")
        XCTAssertEqual(serialOutput, "PANIC: array access is out of bounds: `arr[10]' on line 2")
    }
    
    func test_EndToEndIntegration_ReadAndWriteToStructMember() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var result: u8 = 0
struct Foo {
    bar: u8
}
var foo: Foo = undefined
foo.bar = 42
result = foo.bar
""")
        
        XCTAssertEqual(computer.loadSymbolU8("result"), 42)
    }
    
    func test_EndToEndIntegration_StructInitialization() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
struct Foo {
    bar: u8
}
let foo = Foo { .bar = 42 }
""")
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 42)
    }
    
    func test_EndToEndIntegration_AssignStructInitializerToStructInstance() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
struct Foo {
    bar: u8
}
var foo: Foo = undefined
foo = Foo { .bar = 42 }
""")
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 42)
    }
    
    func test_EndToEndIntegration_ReadStructMembersThroughPointer() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
struct Foo { x: u8, y: u8, z: u8 }
var r: u8 = 0
var foo = Foo { .x = 1, .y = 2, .z = 3 }
var bar = &foo
r = bar.x
""")
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress + 0), 1)
    }
    
    func test_EndToEndIntegration_WriteStructMembersThroughPointer() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
struct Foo { x: u8, y: u8, z: u8 }
var foo = Foo { .x = 1, .y = 2, .z = 3 }
var bar = &foo
bar.x = 2
""")
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress + 0), 2)
    }
    
    func test_EndToEndIntegration_PassPointerToStructAsFunctionParameter() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
struct Foo { x: u8, y: u8, z: u8 }
var r: u8 = 0
var bar = Foo { .x = 1, .y = 2, .z = 3 }
func doTheThing(foo: *Foo) -> u8 {
    return foo.x + foo.y + foo.z
}
r = doTheThing(&bar)
""")
        
        XCTAssertEqual(computer.loadSymbolU8("r"), 6)
    }
    
    func test_EndToEndIntegration_CannotMakeMutatingPointerFromConstant_1() {
        let compiler = SnapCompiler()
        let program = """
let foo: u16 = 0xabcd
var bar: *u16 = &foo
"""
        compiler.compile(program: program, base: 0)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot assign value of type `*const u16' to type `*u16'")
    }
    
    func test_EndToEndIntegration_CannotMakeMutatingPointerFromConstant_2() {
        let compiler = SnapCompiler()
        let program = """
struct Foo { x: u8, y: u8, z: u8 }
let bar = Foo { .x = 1, .y = 2, .z = 3 }
func doTheThing(foo: *Foo) {
    foo.x = foo.y * foo.z
}
doTheThing(&bar)
"""
        compiler.compile(program: program, base: 0)
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot convert value of type `*const Foo' to expected argument type `*Foo' in call to `doTheThing'")
    }
    
    func test_EndToEndIntegration_MutateThePointeeThroughAPointer() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
struct Foo { x: u8, y: u8, z: u8 }
var bar = Foo { .x = 1, .y = 2, .z = 3 }
func doTheThing(foo: *Foo) {
    foo.x = foo.y * foo.z
}
doTheThing(&bar)
""")
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress + 0), 6)
    }
    
    func test_EndToEndIntegration_FunctionReturnsPointerToStruct_Right() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
struct Foo { x: u8, y: u8, z: u8 }
var r: u8 = 0
var foo = Foo { .x = 1, .y = 2, .z = 3 }
func doTheThing(foo: *Foo) -> *Foo {
    return foo
}
r = doTheThing(&foo).x
""")
        XCTAssertEqual(computer.loadSymbolU8("r"), 1)
    }
    
    func test_EndToEndIntegration_FunctionReturnsPointerToStruct_Left() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
struct Foo { x: u8, y: u8, z: u8 }
var foo = Foo { .x = 1, .y = 2, .z = 3 }
func doTheThing(foo: *Foo) -> *Foo {
    return foo
}
doTheThing(&foo).x = 42
""")
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress + 0), 42)
    }
    
    func test_EndToEndIntegration_GetArrayCountThroughAPointer() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var r: u16 = 0
let arr = [_]u8{ 1, 2, 3, 4 }
let ptr = &arr
r = ptr.count
""")
        XCTAssertEqual(computer.loadSymbolU16("r"), 4)
    }
    
    func test_EndToEndIntegration_GetDynamicArrayCountThroughAPointer() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var r: u16 = 0
let arr = [_]u8{ 1, 2, 3, 4 }
let dyn: []u8 = arr
let ptr = &dyn
r = ptr.count
""")
        XCTAssertEqual(computer.loadSymbolU16("r"), 4)
    }
    
    func test_EndToEndIntegration_GetPointeeOfAPointerThroughAPointer() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var r: u16 = 0
let foo: u16 = 0xcafe
let bar = &foo
let baz = &bar
r = baz.pointee.pointee
""")
        XCTAssertEqual(computer.loadSymbolU16("r"), 0xcafe)
    }
    
    func test_EndToEndIntegration_FunctionParameterIsPointerToConstType() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
struct Foo { x: u8, y: u8, z: u8 }
var r = 0
var foo = Foo { .x = 1, .y = 2, .z = 3 }
func doTheThing(foo: *const Foo) -> *const Foo {
    return foo
}
r = doTheThing(&foo).x
""")
        XCTAssertEqual(computer.loadSymbolU8("r"), 1)
    }
    
    func test_EndToEndIntegration_CallAStructMemberFunction_1() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var r: u8 = 0
struct Foo {
}
impl Foo {
    func bar() -> u8 {
        return 42
    }
}
r = Foo.bar()
""")
        XCTAssertEqual(computer.loadSymbolU8("r"), 42)
    }
    
    func test_EndToEndIntegration_CallAStructMemberFunction_2() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var r: u8 = 0
struct Foo {
    aa: u8
}
impl Foo {
    func bar(self: *const Foo, offset: u8) -> u8 {
        return self.aa + offset
    }
}
let foo = Foo {
    .aa = 41
}
r = foo.bar(1)
""")
        XCTAssertEqual(computer.loadSymbolU8("r"), 42)
    }
    
    func test_EndToEndIntegration_CallAStructMemberFunction_3() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var r: u8 = 0
struct Foo {
    aa: u8
}
impl Foo {
    func bar(offset: u8) -> u8 {
        return offset
    }
}
let foo = Foo {
    .aa = 41
}
r = foo.bar(42)
""")
        XCTAssertEqual(computer.loadSymbolU8("r"), 42)
    }
    
    func test_EndToEndIntegration_LinkedList() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
var r: u8 | None = none
struct LinkedList {
    next: *const LinkedList | None,
    key: u8,
    value: u8
}
let c = LinkedList {
    .next = none,
    .key = 2,
    .value = 42
}
let b = LinkedList {
    .next = &c,
    .key = 1,
    .value = 0
}
let a = LinkedList {
    .next = &b,
    .key = 0,
    .value = 0
}
impl LinkedList {
    func lookup(self: *const LinkedList, key: u8) -> u8 | None {
        if self.key == key {
            return self.value
        }
        else match self.next {
            (next: *const LinkedList) -> {
                return next.lookup(key)
            },
            else -> {
                return none
            }
        }
    }
}
r = a.lookup(2)
""")
        guard let symbol = computer.lookupSymbol("r") else {
            XCTFail()
            return
        }
        XCTAssertEqual(computer.dataRAM.load16(from: symbol.offset), 0x002a)
    }
    
    func test_EndToEndIntegration_Match_WithExtraneousClause() {
        let compiler = SnapCompiler()
        compiler.compile("""
var r: u8 = 0
var a: u8 = 0
match a {
    (foo: u8) -> {
        a = 1
    },
    (foo: bool) -> {
        a = 2
    },
    else -> {
        a = 3
    }
}
""")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "foo: bool")
        XCTAssertEqual(compiler.errors.first?.message, "extraneous clause in match statement: bool")
    }
    
    func test_EndToEndIntegration_Match_WithMissingClause() {
        let compiler = SnapCompiler()
        compiler.compile("""
var r: u8 = 0
var a: u8 | bool = 0
match a {
    (foo: u8) -> {
        a = 1
    }
}
""")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "a")
        XCTAssertEqual(compiler.errors.first?.message, "match statement is not exhaustive. Missing clause: bool")
    }
    
    func testFunctionReturnsConstValue() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> const u8 {
    return 42
}
let r = foo()
""")
        XCTAssertEqual(computer.loadSymbolU8("r"), 42)
    }
    
    func testAssignmentExpressionItselfHasAValue() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var foo: u8 = 0
var bar: u8 = (foo = 42)
""")
        XCTAssertEqual(computer.loadSymbolU8("foo"), 42)
        XCTAssertEqual(computer.loadSymbolU8("bar"), 42)
    }
    
    func testArraySlice() {
        var serialOutput = ""
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        executor.configure = { computer in
            computer.didUpdateSerialOutput = {
                serialOutput = $0
            }
        }
        _ = try! executor.execute(program: """
let helloWorld = "Hello, World!"
let helloComma = helloWorld[0..6]
let hello = helloComma[0..(helloComma.count-1)]
puts(hello)
""")
        XCTAssertEqual(serialOutput, "Hello")
    }
    
    func testArraySlice_PanicDueToArrayBoundsException() {
        var serialOutput = ""
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        executor.configure = { computer in
            computer.didUpdateSerialOutput = {
                serialOutput = $0
            }
        }
        _ = try! executor.execute(program: """
let helloWorld = "Hello, World!"
let helloComma = helloWorld[0..6]
let hello = helloComma[0..1000]
puts(hello)
""")
        XCTAssertEqual(serialOutput, "PANIC: array access is out of bounds: `helloComma[0..1000]' on line 3")
    }
    
    func testAssertionFailed() {
        var serialOutput = ""
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        executor.configure = { computer in
            computer.didUpdateSerialOutput = {
                serialOutput = $0
            }
        }
        _ = try! executor.execute(program: """
assert(1 == 2)
""")
        XCTAssertEqual(serialOutput, "PANIC: assertion failed: `1 == 2' on line 1")
    }
    
    func testRunTests_AllTestsPassed() {
        var serialOutput = ""
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        executor.shouldRunTests = true
        executor.configure = { computer in
            computer.didUpdateSerialOutput = {
                serialOutput = $0
            }
        }
        _ = try! executor.execute(program: """
test "foo" {
}
""")
        XCTAssertEqual(serialOutput, "All Tests Passed.")
    }
    
    func testRunTests_FailingAssertMentionsFailingTestByName() {
        var serialOutput = ""
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        executor.shouldRunTests = true
        executor.configure = { computer in
            computer.didUpdateSerialOutput = {
                serialOutput = $0
            }
        }
        _ = try! executor.execute(program: """
test "foo" {
    assert(1 == 2)
}
""")
        XCTAssertEqual(serialOutput, "PANIC: assertion failed: `1 == 2' on line 2 in test \"foo\"")
    }
    
    func testImportModule() {
        let executor = SnapExecutor()
        executor.injectModule(name: "MyModule", sourceCode: """
public func foo() {
}
""")
        _ = try! executor.execute(program: """
import MyModule
foo()
""")
    }
    
    func testBasicFunctionPointerDemonstration() {
        var serialOutput = ""
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        executor.configure = { computer in
            computer.didUpdateSerialOutput = {
                serialOutput = $0
            }
        }
        _ = try! executor.execute(program: """
let ptr = &puts
ptr("Hello, World!")
""")
        XCTAssertEqual(serialOutput, "Hello, World!")
    }
    
    func testRebindAFunctionPointerAtRuntime() {
        var serialOutput = ""
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        executor.configure = { computer in
            computer.didUpdateSerialOutput = {
                serialOutput = $0
            }
        }
        _ = try! executor.execute(program: """
public func fakePuts(s: []const u8) {
    puts("fake")
}
var ptr = &puts
ptr = &fakePuts
ptr("Hello, World!")
""")
        XCTAssertEqual(serialOutput, "fake")
    }
    
    func testFunctionPointerStructMemberCanBeCalledLikeAFunctionMemberCanBeCalled_1() {
        var serialOutput = ""
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        executor.configure = { computer in
            computer.didUpdateSerialOutput = {
                serialOutput = $0
            }
        }
        _ = try! executor.execute(program: """
struct Serial {
    puts: func ([]const u8) -> void
}
let serial = Serial {
    .puts = &puts
}
serial.puts("Hello, World!")
""")
        XCTAssertEqual(serialOutput, "Hello, World!")
    }
    
    func testFunctionPointerStructMemberCanBeCalledLikeAFunctionMemberCanBeCalled_2() {
        var serialOutput = ""
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        executor.configure = { computer in
            computer.didUpdateSerialOutput = {
                serialOutput = $0
            }
        }
        _ = try! executor.execute(program: """
struct Foo {
    bar: func (*const Foo, []const u8) -> void
}
func baz(self: *const Foo, s: []const u8) -> void {
    puts(s)
}
let foo = Foo {
    .bar = &baz
}
foo.bar("Hello, World!")
""")
        XCTAssertEqual(serialOutput, "Hello, World!")
    }
    
    func testStructInitializerCanHaveExplicitUndefinedValue() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        var computer: Computer? = nil
        XCTAssertNoThrow(computer = try executor.execute(program: """
struct Foo {
    arr: [64]u8
}
var foo = Foo {
    .arr = undefined
}
"""))
        let arr = computer?.lookupSymbol("foo")
        XCTAssertNotNil(arr)
    }
    
    func testSubscriptStructMemberThatIsAnArray() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        var computer: Computer? = nil
        XCTAssertNoThrow(computer = try executor.execute(program: """
struct Foo {
    arr: [64]u8
}
var foo: Foo = undefined
foo.arr[0] = 42
let baz = foo.arr[0]
"""))
        XCTAssertEqual(computer?.loadSymbolU8("baz"), 42)
    }
    
    func testSubscriptStructMemberThatIsADynamicArray() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        var computer: Computer? = nil
        XCTAssertNoThrow(computer = try executor.execute(program: """
let backing: [64]u8 = undefined
struct Foo {
    arr: []u8
}
var foo = Foo {
    .arr = backing
}
foo.arr[0] = 42
let baz = foo.arr[0]
"""))
        XCTAssertEqual(computer?.loadSymbolU8("baz"), 42)
    }
    
    func testBugWithCompilerTemporaryPushedTwiceInDynamicArrayBoundsCheck() {
        var serialOutput = ""
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        executor.shouldRunTests = true
        executor.configure = { computer in
            computer.didUpdateSerialOutput = {
                serialOutput = $0
            }
        }
        XCTAssertNoThrow(try executor.execute(program: """
let slice: []const u8 = "test"
assert(slice[0] == 't')
"""))
        XCTAssertEqual(serialOutput, "All Tests Passed.")
    }
    
    func testBugWhenConvertingStringLiteralToDynamicArrayInFunctionParameter() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        var computer: Computer? = nil
        XCTAssertNoThrow(computer = try executor.execute(program: """
public struct Foo {
}

impl Foo {
    func bar(self: *Foo, s: []const u8) -> u8 {
        return s[0]
    }
}

var foo: Foo = undefined
let baz = foo.bar("t")
"""))
        XCTAssertEqual(computer?.loadSymbolU8("baz"), 116)
    }
    
    func testVtableDemo() {
        var serialOutput = ""
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        executor.shouldRunTests = true
        executor.configure = { computer in
            computer.didUpdateSerialOutput = {
                serialOutput = $0
            }
        }
        XCTAssertNoThrow(try executor.execute(program: """
public struct Serial {
    print: func (*Serial, []const u8) -> void
}

public struct SerialFake {
    vtable: Serial,
    buffer: [64]u8,
    cursor: u16
}

impl SerialFake {
    func init() -> SerialFake {
        var serial: SerialFake = undefined
        serial.cursor = 0
        for i in 0..(serial.buffer.count) {
            serial.buffer[i] = 0
        }
        serial.vtable.print = &serial.print_ bitcastAs func (*Serial, []const u8) -> void
        return serial
    }

    func asSerial(self: *SerialFake) -> *Serial {
        return self bitcastAs *Serial
    }

    func print_(self: *SerialFake, s: []const u8) {
        for i in 0..(s.count) {
            self.buffer[cursor + i] = s[i]
        }
        self.cursor = self.cursor + s.count
    }
}

test "call through vtable pseudo-interface" {
    var serialFake = SerialFake.init()
    let serial = serialFake.asSerial()
    serial.print("test")
    assert(serialFake.cursor == 4)
    assert(serialFake.buffer[0] == 't')
    assert(serialFake.buffer[1] == 'e')
    assert(serialFake.buffer[2] == 's')
    assert(serialFake.buffer[3] == 't')
}

"""))
        XCTAssertEqual(serialOutput, "All Tests Passed.")
    }
    
    func testTraitsDemo() {
        var serialOutput = ""
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        executor.shouldRunTests = true
        executor.configure = { computer in
            computer.didUpdateSerialOutput = {
                serialOutput = $0
            }
        }
        XCTAssertNoThrow(try executor.execute(program: """
trait Serial {
    func puts(self: *Serial, s: []const u8)
}

struct SerialFake {
    buffer: [64]u8,
    cursor: u16
}

impl SerialFake {
    func init() -> SerialFake {
        var serial: SerialFake = undefined
        serial.cursor = 0
        for i in 0..(serial.buffer.count) {
            serial.buffer[i] = 0
        }
        return serial
    }
}

impl Serial for SerialFake {
    func puts(self: *SerialFake, s: []const u8) {
        for i in 0..(s.count) {
            self.buffer[cursor + i] = s[i]
        }
        self.cursor = self.cursor + s.count
    }
}

test "call through trait interface" {
    var serialFake = SerialFake.init()
    let serial: Serial = &serialFake
    serial.puts("test")
    assert(serialFake.cursor == 4)
    assert(serialFake.buffer[0] == 't')
    assert(serialFake.buffer[1] == 'e')
    assert(serialFake.buffer[2] == 's')
    assert(serialFake.buffer[3] == 't')
}

"""))
        XCTAssertEqual(serialOutput, "All Tests Passed.")
    }
    
    func testTraitsFailToCompileBecauseTraitNotImplementedAppropriately() {
        let compiler = SnapCompiler()
        compiler.compile("""
trait Serial {
    func puts(self: *Serial, s: []const u8)
}

struct SerialFake {
    buffer: [64]u8,
    cursor: u16
}

impl SerialFake {
    func init() -> SerialFake {
        var serial: SerialFake = undefined
        serial.cursor = 0
        for i in 0..(serial.buffer.count) {
            serial.buffer[i] = 0
        }
        return serial
    }
}

impl Serial for SerialFake {
    func puts(self: *SerialFake) {
    }
}

test "call through trait interface" {
    var serialFake = SerialFake.init()
    let serial: Serial = &serialFake
    serial.puts("test")
    assert(serialFake.cursor == 4)
    assert(serialFake.buffer[0] == 't')
    assert(serialFake.buffer[1] == 'e')
    assert(serialFake.buffer[2] == 's')
    assert(serialFake.buffer[3] == 't')
}

""")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "impl Serial for SerialFake {")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 20..<21)
        XCTAssertEqual(compiler.errors.first?.message, "`SerialFake' method `puts' has 1 parameter but the declaration in the `Serial' trait has 2.")
    }
    
    func testBugWhereUnableToAllocateTemporaryWhenReturningLargeStructByValue() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        XCTAssertNoThrow(try executor.execute(program: """
struct Foo {
    buffer: [1000]u8
}

var foo: Foo = undefined

func init() -> Foo {
    return foo
}
"""))
    }
    
    func testBugWhereConstRangeCannotBeUsedToSubscriptAString() {
        var serialOutput = ""
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        executor.configure = { computer in
            computer.didUpdateSerialOutput = {
                serialOutput = $0
            }
        }
        _ = try! executor.execute(program: """
let helloWorld = "Hello, World!"
let range = 0..6
let helloComma = helloWorld[range]
let hello = helloComma[0..(helloComma.count-1)]
puts(hello)
""")
        XCTAssertEqual(serialOutput, "Hello")
    }
}
