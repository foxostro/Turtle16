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
        nop = UInt8(microcodeGenerator.getOpcode(mnemonic: "NOP")!)
        hlt = UInt8(microcodeGenerator.getOpcode(mnemonic: "HLT")!)
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
        XCTAssertThrowsError(try assembler.instruction(mnemonic: "", immediate: 0))
    }
    
    func testInstructionWithInvalidMnemonicThrowsUsingToken() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        XCTAssertThrowsError(try assembler.instruction(mnemonic: "", token:TokenNumber(literal: 0)))
    }
    
    func testInstructionWithNegativeImmediateThrows() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        XCTAssertThrowsError(try assembler.instruction(mnemonic: "NOP", immediate: -1))
    }
    
    func testInstructionWithNegativeImmediateThrowsUsingToken() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        XCTAssertThrowsError(try assembler.instruction(mnemonic: "NOP", token: TokenNumber(literal: -1)))
    }
    
    func testInstructionWithTooLargeImmediateThrows() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        XCTAssertThrowsError(try assembler.instruction(mnemonic: "NOP", immediate: 256))
    }
    
    func testInstructionWithTooLargeImmediateThrowsUsingToken() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        XCTAssertThrowsError(try assembler.instruction(mnemonic: "NOP", token: TokenNumber(literal: 256)))
    }
    
    func testMovFromScratch() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.instruction(mnemonic: "MOV D, C", immediate: 42)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 42)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "MOV D, C")!))
    }
    
    func testGenericMovWithImmediate() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.mov(.D, .C, 42)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 42)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "MOV D, C")!))
    }
    
    func testLoadImmediate() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.li(.D, 42)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 42)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "MOV D, C")!))
    }
    
    func testAdd() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.add(.D)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 0b1001)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "ALUwoC D")!))
    }
    
    func testSub() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.sub(.A)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 0b0110)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "ALUwC A")!))
    }
    
    func testADC() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.adc(.D)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 0b1001)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "ALUxC D")!))
    }
    
    func testSBC() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.sbc(.A)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 0b0110)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "ALUxC A")!))
    }
    
    func testDEA() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.dea(.A)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 0b1111)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "ALUwoC A")!))
    }
    
    func testDCA() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.dca(.A)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 0b1111)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "CALUwoC A")!))
    }
    
    func testJmp() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        assembler.jmp()
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "JMP")!))
    }
    
    func testJC() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        assembler.jc()
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "JC")!))
    }
    
    func testCMP() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        assembler.cmp()
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "ALUwoC")!))
    }
    
    func testBLT() {
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        assembler.begin()
        try! assembler.instruction(mnemonic: "BLT P, M", immediate: 0)
        assembler.end()
        let instructions = assembler.instructions
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].immediate, 0)
        XCTAssertEqual(instructions[0].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "BLT P, M")!))
    }
}
