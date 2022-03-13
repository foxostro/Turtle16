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
            LIU r0, 16
            LUI r0, 1
            LI r1, 1
            STORE r1, r0
            LIU r0, 17
            LUI r0, 1
            LI r1, 1
            STORE r1, r0
            LIU r0, 18
            LUI r0, 1
            ADDI r1, r0, 0
            LI r0, 0
            STORE r0, r1
            LIU r0, 18
            LUI r0, 1
            ADDI r1, r0, 1
            LI r0, 10
            STORE r0, r1
            LIU r0, 20
            LUI r0, 1
            LIU r1, 18
            LUI r1, 1
            LOAD r2, r1, 1
            STORE r2, r0
            LIU r0, 21
            LUI r0, 1
            LI r1, 0
            STORE r1, r0
            .L0:
            LIU r0, 20
            LUI r0, 1
            LOAD r1, r0
            LIU r0, 21
            LUI r0, 1
            LOAD r2, r0
            SUB r0, r2, r1
            ANDI r0, r0, 1
            CMPI r0, 0
            BEQ .L1
            LIU r0, 22
            LUI r0, 1
            LIU r1, 16
            LUI r1, 1
            LOAD r2, r1
            LIU r1, 17
            LUI r1, 1
            LOAD r3, r1
            ADD r1, r3, r2
            LIU r2, 128
            LUI r2, 0
            LUI r1, 0
            XOR r1, r1, r2
            SUB r1, r1, r2
            STORE r1, r0
            LIU r0, 16
            LUI r0, 1
            LIU r1, 17
            LUI r1, 1
            LOAD r2, r1
            STORE r2, r0
            LIU r0, 17
            LUI r0, 1
            LIU r1, 22
            LUI r1, 1
            LOAD r2, r1
            STORE r2, r0
            LIU r0, 21
            LUI r0, 1
            LI r1, 1
            LIU r2, 21
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
    
    func test_EndToEndIntegration_SimplestProgram() {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.cpu.store = {(value: UInt16, addr: MemoryAddress) in
            computer.ram[addr.value] = value
        }
        computer.cpu.load = {(addr: MemoryAddress) in
            return computer.ram[addr.value]
        }
        
        let compiler = SnapToTurtle16Compiler()
        
        compiler.compile(program: """
let a = 42
""")
        XCTAssertFalse(compiler.hasError)
        guard !compiler.hasError else {
            return
        }
        
        computer.instructions = compiler.instructions
        computer.reset()
        computer.run()
            
        guard let offset = compiler.lookupSymbols(line: 1)?.maybeResolve(identifier: "a")?.offset else {
            XCTFail("failed to resolve symbol \"a\"")
            return
        }
        
        XCTAssertEqual(computer.ram[offset], 42)
    }
}
