//
//  SnapToTurtle16CompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 11/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import Turtle16SimulatorCore
import TurtleCore

class SnapToTurtle16CompilerTests: XCTestCase {
    func testEmptyProgram() throws {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: "")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(Disassembler().disassembleToText(compiler.instructions), """
            NOP
            HLT
            """)
    }
    
    func testCompileFailsDuringLexing() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: "@")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "@")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "unexpected character: `@'")
    }
    
    func testCompileFailsDuringParsing() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: ":")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, ":")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "operand type mismatch: `:'")
    }
    
    func testCompileFailsDuringCodeGeneration() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: "foo")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.text, "foo")
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `foo'")
    }
    
    func testSimpleProgram() throws {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
let a = 1
""")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(Disassembler().disassembleToText(compiler.instructions), """
            NOP
            LI r0, 16
            LUI r0, 1
            LI r1, 1
            STORE r1, r0, 0
            NOP
            HLT
            """)
    }
    
    func testFunctionDefinition() throws {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
func foo() {
    let a = 1
}
""")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(AssemblerListingMaker().makeListing(try compiler.assembly.get()), """
            NOP
            HLT
            foo:
            ENTER 1
            SUBI r0, fp, 1
            LI r1, 1
            STORE r1, r0
            LEAVE
            RET
            """)
    }
    
    fileprivate func makeDebugger(program: String) -> SnapDebugConsole? {
        let compiler = SnapToTurtle16Compiler()
        compiler.isBoundsCheckEnabled = false
        compiler.compile(program: program)
        XCTAssertFalse(compiler.hasError)
        guard !compiler.hasError else {
            let error = CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors)
            print("compile error: \(error.message)")
            return nil
        }
        
//        print(AssemblerListingMaker().makeListing(try! compiler.assembly.get()))
//        print((try! compiler.tack.get() as! Seq).makeChildDescriptions())
        
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.cpu.store = {(value: UInt16, addr: MemoryAddress) in
            computer.ram[addr.value] = value
        }
        computer.cpu.load = {(addr: MemoryAddress) in
            return computer.ram[addr.value]
        }
        
        computer.instructions = compiler.instructions
        computer.reset()
        
        let debugger = SnapDebugConsole(computer: computer)
        debugger.logger = PrintLogger()
        debugger.symbols = compiler.symbolTableRoot
        
        return debugger
    }
    
    fileprivate func run(program: String) -> SnapDebugConsole? {
        guard let debugger = makeDebugger(program: program) else {
            return nil
        }
        debugger.interpreter.runOne(instruction: .run)
        return debugger
    }
    
    func test_EndToEndIntegration_SimplestProgram() {
        let debugger = run(program: """
            let a = 42
            """)
        let a = debugger?.loadSymbolU8("a")
        XCTAssertEqual(a, 42)
    }
    
    func test_EndToEndIntegration_ForIn_Range_1() {
        let debugger = run(program: """
            var a: u16 = 100
            for i in 0..10 {
                a = i
            }
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, 9)
    }
    
    func test_EndToEndIntegration_ForIn_Range_2() {
        let debugger = run(program: """
            var a: u16 = 255
            let range = 0..10
            for i in range {
                a = i
            }
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, 9)
    }
    
    func test_EndToEndIntegration_ForIn_Range_SingleStatement() {
        let debugger = run(program: """
            var a: u16 = 255
            for i in 0..10
                a = i
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, 9)
    }
    
    func test_EndToEndIntegration_AssignLiteral255ToU16Variable() {
        let debugger = run(program: """
            let a: u16 = 255
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, 255)
    }
    
    func test_EndToEndIntegration_AssignLiteral255ToU8Variable() {
        let debugger = run(program: """
            var a: u8 = 255
            """)
        let a = debugger?.loadSymbolU8("a")
        XCTAssertEqual(a, 255)
    }
    
    func test_EndToEndIntegration_ForIn_String() {
        let debugger = run(program: """
            var a = 255
            for i in "hello" {
                a = i
            }
            """)
        let a = debugger?.loadSymbolU8("a")
        XCTAssertEqual(a, UInt8("o".utf8.first!))
    }
    
    func test_EndToEndIntegration_ForIn_ArrayOfU16() {
        let debugger = run(program: """
            var a: u16 = 0xffff
            for i in [_]u16{0x1000, 0x2000, 0x3000, 0x4000, 0x5000} {
                a = i
            }
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, UInt16(0x5000))
    }
    
    func test_EndToEndIntegration_SubscriptArray() {
        let debugger = run(program: """
            let arr = [_]u16{0x1000}
            let a: u16 = arr[0]
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, UInt16(0x1000))
    }
    
    func test_EndToEndIntegration_SubscriptSlice() {
        let debugger = run(program: """
            let arr = [_]u16{0x1000}
            let slice: []u16 = arr
            let a: u16 = slice[0]
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, UInt16(0x1000))
    }
    
    func test_EndToEndIntegration_ForIn_DynamicArray_1() {
        let debugger = run(program: """
            var a: u16 = 0xffff
            let arr = [_]u16{0x1000}
            let slice: []u16 = arr
            for i in slice {
                a = i
            }
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, UInt16(0x1000))
    }
    
    func test_EndToEndIntegration_ForIn_DynamicArray_2() {
        let debugger = run(program: """
            var a: u16 = 0xffff
            let arr = [_]u16{1, 2}
            let slice: []u16 = arr
            for i in slice {
                a = i
            }
            """)
        let a = debugger?.loadSymbolU16("a")
        XCTAssertEqual(a, UInt16(2))
    }
    
    func test_EndToEndIntegration_Fibonacci() {
        let debugger = run(program: """
            var a: u16 = 1
            var b: u16 = 1
            var fib: u16 = 0
            for i in 0..10 {
                fib = b + a
                a = b
                b = fib
            }
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("a"), 89)
        XCTAssertEqual(debugger?.loadSymbolU16("b"), 144)
    }
    
    func test_EndToEndIntegration_Fibonacci_ExercisingStaticKeyword() {
        let debugger = run(program: """
            var a: u16 = 1
            var b: u16 = 1
            for i in 0..10 {
                static var fib: u16 = b + a
                a = b
                b = fib
            }
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("a"), 89)
        XCTAssertEqual(debugger?.loadSymbolU16("b"), 144)
    }
    
    func test_EndToEndIntegration_Fibonacci_U8_1() {
        let debugger = run(program: """
            var a: u8 = 1
            var b: u8 = 1
            var fib: u8 = 0
            for i in 0..9 {
                fib = b + a
                a = b
                b = fib
            }
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("a"), 55)
        XCTAssertEqual(debugger?.loadSymbolU8("b"), 89)
    }
    
    func test_EndToEndIntegration_Fibonacci_U8_2() {
        // TODO: The u8 type should always use unsigned arithmetic. Add new i8 and i16 types to the compiler for signed arithmetic.
        // If we do 0..10 then b will be 144 which exceeds the maximum value of
        // 127 for a signed eight-bit integer. The compiler doesn't draw a good
        // enough distinction between signed and unsigned numbers which leads
        // this value to being sign-extended in memory to sixteen bits wide.
        // While this allows for efficient conversion from u8 to u16 by simply
        // reinterpreting the in-memory value, it is definitely not the behavior
        // we expect from a u8 type.
        let debugger = run(program: """
            var a: u8 = 1
            var b: u8 = 1
            var fib: u8 = 0
            for i in 0..10 {
                fib = b + a
                a = b
                b = fib
            }
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("a"), 89)
        XCTAssertEqual(debugger?.loadSymbolU8("b"), 144)
    }
    
    func testLocalVariablesDoNotSurviveTheLocalScope() {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
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
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
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
    
    func test_EndToEndIntegration_SimpleFunctionCall() {
        let debugger = run(program: """
            var a: u16 = 0
            func foo() {
                a = 0xaa
            }
            foo()
            """)
        XCTAssertEqual(debugger?.loadSymbolU16("a"), 0xaa)
    }
    
    func test_EndToEndIntegration_StaticVarInAFunctionContextIsStoredInStaticDataArea() {
        let debugger = run(program: """
            func foo() {
                static var a: u16 = 0xaa
            }
            foo()
            """)
        let word = debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress]
        XCTAssertEqual(word, 0xaa) // var a
    }
    
    // Local variables declared in a local scope are not necessarily associated
    // with a new stack frame. In many cases, these variables are allocated in
    // the same stack frame, or in the next slot of the static storage area.
    func test_EndToEndIntegration_BlocksAreNotStackFrames_0() {
        let debugger = run(program: """
            var a = 0xaa
            {
                var b = 0xbb
                {
                    var c = 0xcc
                }
            }
            """)
        XCTAssertEqual(debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress+0], 0xaa) // var a
        XCTAssertEqual(debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress+1], 0xbb) // var b
        XCTAssertEqual(debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress+2], 0xcc) // var c
    }
    
    // Local variables declared in a local scope are not necessarily associated
    // with a new stack frame. In many cases, these variables are allocated in
    // the same stack frame, or in the next slot of the static storage area.
    func test_EndToEndIntegration_BlocksAreNotStackFrames_1() {
        let debugger = run(program: """
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
        
        XCTAssertEqual(debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress+0], 0xaa) // var a
        XCTAssertEqual(debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress+1], 0xaa) // var b
        XCTAssertEqual(debugger?.computer.ram[SnapCompilerMetrics.kStaticStorageStartAddress+2], 0xaa) // var c
    }
    
    func test_EndToEndIntegration_StoreLocalVariableDefinedSeveralScopesUp_StackFramesNotEqualToScopes() {
        let debugger = run(program: """
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
        
        XCTAssertEqual(debugger?.loadSymbolU8("a"), 0xaa)
    }
    
    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU8() {
        let debugger = run(program: """
            func foo() -> u8 {
                return 42
            }
            let a = foo()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("a"), 42)
    }
    
    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU16() {
        let debugger = run(program: """
            func foo() -> u16 {
                return 0xabcd
            }
            let a = foo()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("a"), 0xabcd)
    }
    
    func test_EndToEndIntegration_FunctionCall_NoArgs_ReturnU8PromotedToU16() {
        let debugger = run(program: """
            func foo() -> u16 {
                return 0xaa
            }
            let a = foo()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU16("a"), 0x00aa)
    }
    
    func test_EndToEndIntegration_NestedFunctionDeclarations() {
        let debugger = run(program: """
            func foo() -> u8 {
                let val = 0xaa
                func bar() -> u8 {
                    return val
                }
                return bar()
            }
            let a = foo()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("a"), 0xaa)
    }
    
    func test_EndToEndIntegration_ReturnFromInsideIfStmt() {
        let debugger = run(program: """
            func foo() -> u8 {
                if 1 + 1 == 2 {
                    return 0xaa
                } else {
                    return 0xbb
                }
            }
            let a = foo()
            """)
        
        XCTAssertEqual(debugger?.loadSymbolU8("a"), 0xaa)
    }
}
