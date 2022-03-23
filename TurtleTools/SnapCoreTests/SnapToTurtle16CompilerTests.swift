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
    
    func testFib() throws {
        // Compile a simple fibonacci program. Note that the generated program
        // has a lot of seemingly superfluous instructions because it wants to
        // use u8 for all the integer types.
        // TODO: The compiler should default to the u16 type instead of u8.
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
            var a = 1
            var b = 1
            for i in 0..10 {
                var fib = b + a
                a = b
                b = fib
            }
            """)
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(AssemblerListingMaker().makeListing(try compiler.assembly.get()), """
            NOP
            LI r0, 16
            LUI r0, 1
            LI r1, 1
            STORE r1, r0
            LI r0, 17
            LUI r0, 1
            LI r1, 1
            STORE r1, r0
            LI r0, 18
            LUI r0, 1
            ADDI r1, r0, 0
            LI r0, 0
            STORE r0, r1
            LI r0, 18
            LUI r0, 1
            ADDI r1, r0, 1
            LI r0, 10
            STORE r0, r1
            LI r0, 20
            LUI r0, 1
            LI r1, 18
            LUI r1, 1
            LOAD r2, r1, 1
            STORE r2, r0
            LI r0, 21
            LUI r0, 1
            LI r1, 0
            STORE r1, r0
            .L0:
            LI r0, 20
            LUI r0, 1
            LOAD r1, r0
            LI r0, 21
            LUI r0, 1
            LOAD r2, r0
            CMP r2, r1
            LI r0, 1
            BNE .LL0
            LI r0, 0
            .LL0:
            CMPI r0, 0
            BEQ .L1
            LI r0, 22
            LUI r0, 1
            LI r1, 16
            LUI r1, 1
            LOAD r2, r1
            LI r1, 17
            LUI r1, 1
            LOAD r3, r1
            ADD r1, r3, r2
            LI r2, 128
            LUI r2, 0
            LUI r1, 0
            XOR r1, r1, r2
            SUB r1, r1, r2
            STORE r1, r0
            LI r0, 16
            LUI r0, 1
            LI r1, 17
            LUI r1, 1
            LOAD r2, r1
            STORE r2, r0
            LI r0, 17
            LUI r0, 1
            LI r1, 22
            LUI r1, 1
            LOAD r2, r1
            STORE r2, r0
            LI r0, 21
            LUI r0, 1
            LI r1, 1
            LI r2, 21
            LUI r2, 1
            LOAD r3, r2
            ADD r2, r3, r1
            STORE r2, r0
            JMP .L0
            .L1:
            NOP
            HLT
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
}
