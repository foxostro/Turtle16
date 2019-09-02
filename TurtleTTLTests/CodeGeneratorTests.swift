//
//  CodeGeneratorTests.swift
//  SimulatorTests
//
//  Created by Andrew Fox on 7/30/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class CodeGeneratorTests: XCTestCase {
    var microcodeGenerator = MicrocodeGenerator()
    var nop: UInt8 = 0
    var hlt: UInt8 = 0
    
    override func setUp() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        nop = UInt8(microcodeGenerator.getOpcode(withMnemonic: "NOP")!)
        hlt = UInt8(microcodeGenerator.getOpcode(withMnemonic: "HLT")!)
    }
    
    func testEmptyProgram() {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        codeGen.begin()
        codeGen.end()
        let instructions = codeGen.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].opcode, nop)
    }
    
    func testNop() {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        codeGen.begin()
        codeGen.nop()
        codeGen.end()
        let instructions = codeGen.instructions
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, nop)
    }
    
    func testHlt() {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        codeGen.begin()
        codeGen.hlt()
        codeGen.end()
        let instructions = codeGen.instructions
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, hlt)
    }
    
    func testInstructionWithInvalidMnemonicThrows() {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.instruction(withMnemonic: "", immediate: 0))
    }
    
    func testInstructionWithInvalidMnemonicThrowsUsingToken() {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.instruction(withMnemonic: "", token:TokenNumber(lineNumber: 1, lexeme: "0", literal: 0)))
    }
    
    func testInstructionWithNegativeImmediateThrows() {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.instruction(withMnemonic: "NOP", immediate: -1))
    }
    
    func testInstructionWithNegativeImmediateThrowsUsingToken() {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.instruction(withMnemonic: "NOP", token: TokenNumber(lineNumber: 1, lexeme: "0xffffffff", literal: -1)))
    }
    
    func testInstructionWithTooLargeImmediateThrows() {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.instruction(withMnemonic: "NOP", immediate: 256))
    }
    
    func testInstructionWithTooLargeImmediateThrowsUsingToken() {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.instruction(withMnemonic: "NOP", token: TokenNumber(lineNumber: 1, lexeme: "256", literal: 256)))
    }
    
    func testMovFromScratch() {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        codeGen.begin()
        try! codeGen.instruction(withMnemonic: "MOV D, C", immediate: 42)
        codeGen.end()
        let instructions = codeGen.instructions
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].immediate, 42)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV D, C")!))
    }
    
    func testGenericMovWithImmediate() {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        codeGen.begin()
        try! codeGen.mov("D", "C", 42)
        codeGen.end()
        let instructions = codeGen.instructions
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].immediate, 42)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV D, C")!))
    }
    
    func testLoadImmediate() {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        codeGen.begin()
        try! codeGen.li("D", 42)
        codeGen.end()
        let instructions = codeGen.instructions
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].immediate, 42)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV D, C")!))
    }
    
    func testAdd() {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        codeGen.begin()
        try! codeGen.add("D")
        codeGen.end()
        let instructions = codeGen.instructions
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].immediate, 0b011001)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "ALU D")!))
    }
    
    func testJmp() {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        codeGen.begin()
        codeGen.jmp()
        codeGen.end()
        let instructions = codeGen.instructions
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "JMP")!))
    }
    
    func testJC() {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        codeGen.begin()
        codeGen.jc()
        codeGen.end()
        let instructions = codeGen.instructions
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "JC")!))
    }
    
    func testCMP() {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        codeGen.begin()
        codeGen.cmp()
        codeGen.end()
        let instructions = codeGen.instructions
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "ALU")!))
    }
}
