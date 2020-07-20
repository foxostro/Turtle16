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
    func testCompileFailsDuringLexing() {
        let compiler = SnapCompiler()
        compiler.compile("@")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.line, Optional<Int>(1))
        XCTAssertEqual(compiler.errors.first?.message, Optional<String>("unexpected character: `@'"))
    }
    
    func testCompileFailsDuringParsing() {
        let compiler = SnapCompiler()
        compiler.compile(":")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.line, Optional<Int>(1))
        XCTAssertEqual(compiler.errors.first?.message, Optional<String>("operand type mismatch: `:'"))
    }
    
    func testCompileFailsDuringCodeGeneration() {
        let compiler = SnapCompiler()
        compiler.compile("foo")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.line, Optional<Int>(1))
        XCTAssertEqual(compiler.errors.first?.message, Optional<String>("use of unresolved identifier: `foo'"))
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
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 42)
    }
    
    func test_EndToEndIntegration_ForLoop() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var a = 255
for var i = 0; i < 10; i = i + 1 {
    a = i
}
""")
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 9)
    }
    
    func test_EndToEndIntegration_ForLoop_SingleStatement() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var a = 255
for var i = 0; i < 10; i = i + 1
    a = i
""")
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 9)
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
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 89)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0011), 144)
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
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 89)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0011), 144)
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
        XCTAssertEqual(compiler.errors.first?.line, 5)
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
        XCTAssertEqual(compiler.errors.first?.line, 4)
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
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xaa) // var a
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
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xaa) // var a
        XCTAssertEqual(computer.dataRAM.load(from: 0x0011), 0xbb) // var b
        XCTAssertEqual(computer.dataRAM.load(from: 0x0012), 0xcc) // var c
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
        
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xaa) // var a
        XCTAssertEqual(computer.dataRAM.load(from: 0x0011), 0xaa) // var b
        XCTAssertEqual(computer.dataRAM.load(from: 0x0012), 0xaa) // var c
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
        
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xaa) // var a
    }
    
    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU8() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> u8 {
    return 0xaa
}
let a = foo()
""")
        
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xaa)
    }
    
    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU16() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> u16 {
    return 0xabcd
}
let a = foo()
""")
        
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0010), 0xabcd)
    }
    
    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU8PromotedToU16() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo() -> u16 {
    return 0xaa
}
let a = foo()
""")
        
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0010), 0x00aa)
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
        
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xaa)
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
        
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xaa)
    }
    
    func testMissingReturn_1() {
        let compiler = SnapCompiler()
        compiler.compile("""
func foo() -> u8 {
}
""")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
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
        XCTAssertEqual(compiler.errors.first?.message, "missing return in a function expected to return `u8'")
    }
    
    func test_EndToEndIntegration_PromoteInAssignmentStatement() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var result = 0xabcd
result = 42
""")
        
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0010), 42)
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
        
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0010), 42)
    }
    
    func test_EndToEndIntegration_PromoteReturnValue() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo(n: u8) -> u16 {
    return n
}
let result = foo(42)
""")
        
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0010), 42)
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
        
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 1)
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
        
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 1)
    }
    
    func test_EndToEndIntegration_RecursiveFunctions_u8() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var count = 0
func foo(n: u8) {
    if n > 0 {
        count = count + 1
        return foo(n - 1)
    }
}
foo(10)
""")
        
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 10)
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
        
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 10)
    }
    
    func test_EndToEndIntegration_FunctionCallsInExpression() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
func foo(n: u8) -> u8 {
    return n
}
let r = foo(2) + 1
""")
        
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 3)
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
        
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 1)
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
        
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0010), 0xffff)
    }
        
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_Var() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var foo: u16 = 0xffff
""")
        
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0010), 0xffff)
    }
        
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_PromoteU8ToU16() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let foo: u16 = 10
""")
        
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0010), 10)
    }
        
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_Bool() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let foo: bool = true
""")
        
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 1)
    }
        
    func test_EndToEndIntegration_DeclareVariableWithExplicitType_CannotConvertU16ToBool() {
        let compiler = SnapCompiler()
        compiler.compile("""
let foo: bool = 0xffff
""")
        
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.first?.message, "cannot assign value of type `u16' to type `bool'")
    }
    
    func test_EndToEndIntegration_CastU16DownToU8() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
var foo: u16 = 1
let bar: u8 = foo as u8
""")
        
        XCTAssertEqual(computer.dataRAM.load16(from: 0x0010), 1)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0012), 1)
    }
        
    func test_EndToEndIntegration_PokeMemory() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
pokeMemory(0xab, 0x0010)
""")
        
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xab)
    }
    
    func test_EndToEndIntegration_PeekMemory() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let a = 0xab
let b = peekMemory(0x0010)
""")
        
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xab)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0011), 0xab)
    }
        
    func test_EndToEndIntegration_PokePeripheral() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
pokePeripheral(0xab, 0xffff, 1)
pokePeripheral(0xcd, 0xffff, 0)
""")
        
        // There's a hardware bug in Rev 2 where the bits of the instruction
        // RAM port connected to the data bus are in reverse order.
        XCTAssertEqual(computer.lowerInstructionRAM.load(from: 0xffff), reverseBits(0xab))
        XCTAssertEqual(computer.upperInstructionRAM.load(from: 0xffff), reverseBits(0xcd))
    }
    
    private func reverseBits(_ value: UInt8) -> UInt8 {
        var n = value
        var result: UInt8 = 0
        while (n > 0) {
            result <<= 1
            if ((n & 1) == 1) {
                result ^= 1
            }
            n >>= 1
        }
        return result
    }
        
    func test_EndToEndIntegration_PeekPeripheral() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let a = peekPeripheral(0, 0)
let b = peekPeripheral(0, 1)
""")
        
        XCTAssertEqual(computer.lowerInstructionRAM.load(from: 0), 0)
        XCTAssertEqual(computer.upperInstructionRAM.load(from: 0), 0)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0011), 0)
    }
    
    func test_EndToEndIntegration_DeclareArrayType_InferredType() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let arr = [1, 2, 3]
""")
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 1)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0011), 2)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0012), 3)
    }
    
    func test_EndToEndIntegration_DeclareArrayType_ExplicitType() {
        let executor = SnapExecutor()
        let computer = try! executor.execute(program: """
let arr: [u8] = [1, 2, 3]
""")
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 1)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0011), 2)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0012), 3)
    }
}
