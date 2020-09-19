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
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 42)
    }
    
    func test_EndToEndIntegration_ForLoop() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var a = 255
for var i = 0; i < 10; i = i + 1 {
    a = i
}
""")
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 9)
    }
    
    func test_EndToEndIntegration_ForLoop_SingleStatement() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var a = 255
for var i = 0; i < 10; i = i + 1
    a = i
""")
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 9)
    }
    
    func test_EndToEndIntegration_Fibonacci() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var a = 1
var b = 1
var fib = 0
for var i = 0; i < 10; i = i + 1 {
    fib = b + a
    a = b
    b = fib
}
""")
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+0), 89)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+1), 144)
    }
    
    func test_EndToEndIntegration_Fibonacci_ExercisingStaticKeyword() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var a = 1
var b = 1
for var i = 0; i < 10; i = i + 1 {
    static var fib = b + a
    a = b
    b = fib
}
""")
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+0), 89)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+1), 144)
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
for var i = 0; i < 10; i = i + 1 {
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
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xaa) // var a
    }
    
    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU8() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> u8 {
    return 0xaa
}
let a = foo()
""")
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xaa)
    }
    
    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU16() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> u16 {
    return 0xabcd
}
let a = foo()
""")
        
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 0xabcd)
    }
    
    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU8PromotedToU16() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> u16 {
    return 0xaa
}
let a = foo()
""")
        
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 0x00aa)
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
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xaa)
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
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 0xaa)
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
        
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 42)
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
        
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 42)
    }
    
    func test_EndToEndIntegration_PromoteReturnValue() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo(n: u8) -> u16 {
    return n
}
let result = foo(42)
""")
        
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 42)
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
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 1)
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
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 1)
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
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 10)
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
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 10)
    }
    
    func test_EndToEndIntegration_FunctionCallsInExpression() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo(n: u8) -> u8 {
    return n
}
let r = foo(2) + 1
""")
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 3)
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
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 1)
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
        
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 0xffff)
    }
        
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_Var() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var foo: u16 = 0xffff
""")
        
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 0xffff)
    }
        
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_PromoteU8ToU16() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let foo: u16 = 10
""")
        
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 10)
    }
        
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_Bool() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let foo: bool = true
""")
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 1)
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
        
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0), 1)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+2), 1)
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
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+0), 0xab)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+1), 0xab)
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
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+0), 0)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+1), 0)
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
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+0), 1)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+1), 2)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+2), 3)
    }
    
    func test_EndToEndIntegration_DeclareArrayType_ExplicitType() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let arr: [_]u8 = [_]u8{1, 2, 3}
""")
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+0), 1)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+1), 2)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+2), 3)
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
        XCTAssertEqual(compiler.errors.first?.message, "cannot assign value of type `(u8, u16) -> bool' to type `[_]const u16'")
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
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x00), 100)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x02), 101)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x04), 102)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x06), 103)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x08), 104)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x0a), 105)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x0c), 106)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x0e), 107)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x10), 108)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x12), 109)
    }
    
    func test_EndToEndIntegration_ArrayOfU8ConvertedToArrayOfU16OnInitialAssignment() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let arr: [_]u16 = [_]u16{42 as u8}
""")
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 42)
    }
    
    func test_EndToEndIntegration_ReadArrayElement_U16() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
var result: u16 = 0
let arr: [_]u16 = [_]u16{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
result = arr[0]
""")
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 100)
    }
    
    func test_EndToEndIntegration_CastArrayLiteralFromArrayOfU8ToArrayOfU16() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let foo = [_]u8{1, 2, 3} as [_]u16
""")
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x0), 1)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x2), 2)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x4), 3)
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
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+0), 1)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+1), 2)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+2), 3)
    }
    
    func test_EndToEndIntegration_ReassignArrayContentsWithLiteralArray() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var arr: [_]u16 = [_]u16{0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff}
arr = [_]u16{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
""")
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x00), 100)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x02), 101)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x04), 102)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x06), 103)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x08), 104)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x0a), 105)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x0c), 106)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x0e), 107)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x10), 108)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x12), 109)
    }
    
    func test_EndToEndIntegration_ReassignArrayContentsWithArrayIdentifier() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
var a: [_]u16 = [_]u16{0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff}
let b: [_]u16 = [_]u16{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
a = b
""")
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x00), 100)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x02), 101)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x04), 102)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x06), 103)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x08), 104)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x0a), 105)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x0c), 106)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x0e), 107)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x10), 108)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x12), 109)
    }
    
    func test_EndToEndIntegration_ReassignArrayContents_ConvertingFromArrayOfU8ToArrayOfU16() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
var a: [_]u16 = [_]u16{0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff}
let b = [_]u8{100, 101, 102, 103, 104, 105, 106, 107, 108, 109}
a = b
""")
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x00), 100)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x02), 101)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x04), 102)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x06), 103)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x08), 104)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x0a), 105)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x0c), 106)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x0e), 107)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x10), 108)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0x12), 109)
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
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 42)
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
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 42)
    }
    
    func test_EndToEndIntegration_SumLoop() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func sum() -> u8 {
    var accum = 0
    for var i = 0; i < 3; i = i + 1 {
        accum = accum + 1
    }
    return accum
}
let foo = sum()
""")
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 3)
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
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 6)
    }
    
    func test_EndToEndIntegration_PassArrayAsFunctionParameter_2() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
func sum(a: [3]u16) -> u16 {
    var accum: u16 = 0
    for var i = 0; i < 3; i = i + 1 {
        accum = accum + a[i]
    }
    return accum
}
let foo = sum([_]u16{1, 2, 3})
""")
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 6)
    }
    
    func test_EndToEndIntegration_ReturnArrayByValue_U8() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func makeArray() -> [3]u8 {
    return [_]u8{1, 2, 3}
}
let foo = makeArray()
""")
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+0), 1)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+1), 2)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+2), 3)
    }
    
    func test_EndToEndIntegration_ReturnArrayByValue_U16() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func makeArray() -> [3]u16 {
    return [_]u16{0x1234, 0x5678, 0x9abc}
}
let foo = makeArray()
""")
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0), 0x1234)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+2), 0x5678)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+4), 0x9abc)
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
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 42)
    }
    
    func test_EndToEndIntegration_PassArraysAsFunctionArgumentsAndReturnArrayValue() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
func sum(a: [3]u8, b: [3]u8, c: u8) -> [3]u8 {
    var result = [_]u8{0, 0, 0}
    for var i = 0; i < 3; i = i + 1 {
        result[i] = (a[i] + b[i]) * c
    }
    return result
}
let foo = sum([_]u8{1, 2, 3}, [_]u8{4, 5, 6}, 2)
""")
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+0), 10)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+1), 14)
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress+2), 18)
    }
    
    func test_EndToEndIntegration_PassArraysAsFunctionArgumentsAndReturnArrayValue_U16() {
        let executor = SnapExecutor()
        executor.isUsingStandardLibrary = true
        let computer = try! executor.execute(program: """
func sum(a: [3]u16, b: [3]u16, c: u16) -> [3]u16 {
    var result = [_]u16{0, 0, 0}
    for var i = 0; i < 3; i = i + 1 {
        result[i] = (a[i] + b[i]) * c
    }
    return result
}
let foo = sum([_]u8{1, 2, 3}, [_]u8{4, 5, 6}, 2)
""")
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+0), 10)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+2), 14)
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress+4), 18)
    }
    
    func test_EndToEndIntegration_BugWhenStackVariablesAreDeclaredAfterForLoop() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> u16 {
    for var i = 0; i < 3; i = i + 1 {
    }
    let a = 42
    return a
}
let b = foo()
""")
        
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress), 42)
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
        XCTAssertEqual(serialOutput, "PANIC: array access is out of bounds: `arr[10]' on line 1")
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
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress), 42)
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
        
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress + 0), 6)
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
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress + 0), 1)
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
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress + 0), 4)
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
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress + 0), 4)
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
        XCTAssertEqual(computer.dataRAM.load16(from: kStaticStorageStartAddress + 0), 0xcafe)
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
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress + 0), 1)
    }
    
    func test_EndToEndIntegration_ForRangeLoop() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var r = 0
forRange i in 0..10 {
    r = i
}
""")
        XCTAssertEqual(computer.dataRAM.load(from: kStaticStorageStartAddress + 0), 9)
    }
}
