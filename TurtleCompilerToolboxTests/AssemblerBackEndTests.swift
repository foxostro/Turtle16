//
//  AssemblerBackEndTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 7/30/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleAssemblerCore
import TurtleCompilerToolbox
import TurtleCore

class AssemblerBackEndTests: XCTestCase {
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
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 0)
    }
    
    func testNop() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        assembler.nop()
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].opcode, nop)
    }
    
    func testHlt() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        assembler.hlt()
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].opcode, hlt)
    }
    
    func testInstructionWithInvalidMnemonicThrows() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        XCTAssertThrowsError(try assembler.instruction(withMnemonic: "", immediate: 0))
    }
    
    func testInstructionWithInvalidMnemonicThrowsUsingToken() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        XCTAssertThrowsError(try assembler.instruction(withMnemonic: "", token:TokenNumber(lineNumber: 1, lexeme: "0", literal: 0)))
    }
    
    func testInstructionWithNegativeImmediateThrows() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        XCTAssertThrowsError(try assembler.instruction(withMnemonic: "NOP", immediate: -1))
    }
    
    func testInstructionWithNegativeImmediateThrowsUsingToken() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        XCTAssertThrowsError(try assembler.instruction(withMnemonic: "NOP", token: TokenNumber(lineNumber: 1, lexeme: "0xffffffff", literal: -1)))
    }
    
    func testInstructionWithTooLargeImmediateThrows() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        XCTAssertThrowsError(try assembler.instruction(withMnemonic: "NOP", immediate: 256))
    }
    
    func testInstructionWithTooLargeImmediateThrowsUsingToken() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        XCTAssertThrowsError(try assembler.instruction(withMnemonic: "NOP", token: TokenNumber(lineNumber: 1, lexeme: "256", literal: 256)))
    }
    
    func testMovFromScratch() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.instruction(withMnemonic: "MOV D, C", immediate: 42)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 42)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV D, C")!))
    }
    
    func testGenericMovWithImmediate() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.mov(.D, .C, 42)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 42)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV D, C")!))
    }
    
    func testLoadImmediate() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.li(.D, 42)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 42)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV D, C")!))
    }
    
    func testAdd() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.add(.D)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 0b1001)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "ALU D")!))
    }
    
    func testSub() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.sub(.A)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 0b0110)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "ALUC A")!))
    }
    
    func testDEA() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.dea(.A)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 0b1111)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "ALU A")!))
    }
    
    func testJmp() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        assembler.jmp()
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "JMP")!))
    }
    
    func testJC() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        assembler.jc()
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "JC")!))
    }
    
    func testCMP() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        assembler.cmp()
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "ALU")!))
    }
    
    func testBLT() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.instruction(withMnemonic: "BLT P, M", immediate: 0)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 0)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "BLT P, M")!))
    }
}
