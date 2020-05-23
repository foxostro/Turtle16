//
//  MicrocodeGeneratorTests.swift
//  TurtleCoreTests
//
//  Created by Andrew Fox on 7/30/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore

class MicrocodeGeneratorTests: XCTestCase {
    func testNOP() {
        let generator = MicrocodeGenerator()
        generator.generate()
        
        let NOP = generator.getOpcode(withMnemonic: "NOP")!
        XCTAssertEqual(generator.microcode.load(opcode: NOP, carryFlag: 1, equalFlag: 1), UInt32(ControlWord().unsignedIntegerValue))
        XCTAssertEqual(generator.getMnemonic(withOpcode: NOP), Optional("NOP"))
    }
    
    func testHLT() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let HLT = generator.getOpcode(withMnemonic: "HLT")!
        
        let value = generator.microcode.load(opcode: HLT, carryFlag: 1, equalFlag: 1)
        let controlWord = ControlWord(withValue: UInt(value))
        
        XCTAssertEqual(.active, controlWord.HLT)
        XCTAssertEqual(generator.getMnemonic(withOpcode: HLT), Optional("HLT"))
    }
    
    func testGetOpcode() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let NOP = generator.getOpcode(withMnemonic: "NOP")!
        XCTAssertEqual(NOP, 0)
        XCTAssertEqual(generator.getMnemonic(withOpcode: NOP), Optional("NOP"))
    }
    
    func testJMP() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let JMP = generator.getOpcode(withMnemonic: "JMP")!
        
        let value = generator.microcode.load(opcode: JMP, carryFlag: 1, equalFlag: 1)
        let controlWord = ControlWord(withValue: UInt(value))
        
        XCTAssertEqual(.active, controlWord.J)
        XCTAssertEqual(generator.getMnemonic(withOpcode: JMP), Optional("JMP"))
    }
    
    func testJC() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let JC = generator.getOpcode(withMnemonic: "JC")!
        
        let controlWordOnBranchTaken = ControlWord(withValue: UInt(generator.microcode.load(opcode: JC, carryFlag: 0, equalFlag: 1)))
        XCTAssertEqual(.active, controlWordOnBranchTaken.J)
        
        let controlWordOnBranchNotTaken = ControlWord(withValue: UInt(generator.microcode.load(opcode: JC, carryFlag: 1, equalFlag: 1)))
        XCTAssertEqual(.inactive, controlWordOnBranchNotTaken.J)
        
        XCTAssertEqual(generator.getMnemonic(withOpcode: JC), Optional("JC"))
    }
    
    func testALU() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let ALU = generator.getOpcode(withMnemonic: "ALU")!
        XCTAssertEqual(generator.getMnemonic(withOpcode: ALU), Optional("ALU"))
    }
    
    func testIsUnconditionalJump() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let NOP = Instruction(opcode: generator.getOpcode(withMnemonic: "NOP")!, immediate: 0)
        let JALR = Instruction(opcode: generator.getOpcode(withMnemonic: "JALR")!, immediate: 0)
        let JC = Instruction(opcode: generator.getOpcode(withMnemonic: "JC")!, immediate: 0)
        let JNC = Instruction(opcode: generator.getOpcode(withMnemonic: "JNC")!, immediate: 0)
        let JE = Instruction(opcode: generator.getOpcode(withMnemonic: "JE")!, immediate: 0)
        let JNE = Instruction(opcode: generator.getOpcode(withMnemonic: "JNE")!, immediate: 0)
        let JG = Instruction(opcode: generator.getOpcode(withMnemonic: "JG")!, immediate: 0)
        let JLE = Instruction(opcode: generator.getOpcode(withMnemonic: "JLE")!, immediate: 0)
        let JL = Instruction(opcode: generator.getOpcode(withMnemonic: "JL")!, immediate: 0)
        let JGE = Instruction(opcode: generator.getOpcode(withMnemonic: "JGE")!, immediate: 0)
        let JMP = Instruction(opcode: generator.getOpcode(withMnemonic: "JMP")!, immediate: 0)
        XCTAssertFalse(generator.isUnconditionalJump(NOP))
        XCTAssertTrue(generator.isUnconditionalJump(JALR))
        XCTAssertFalse(generator.isUnconditionalJump(JC))
        XCTAssertFalse(generator.isUnconditionalJump(JNC))
        XCTAssertFalse(generator.isUnconditionalJump(JE))
        XCTAssertFalse(generator.isUnconditionalJump(JNE))
        XCTAssertFalse(generator.isUnconditionalJump(JG))
        XCTAssertFalse(generator.isUnconditionalJump(JLE))
        XCTAssertFalse(generator.isUnconditionalJump(JL))
        XCTAssertFalse(generator.isUnconditionalJump(JGE))
        XCTAssertTrue(generator.isUnconditionalJump(JMP))
    }
    
    func testIsConditionalJump() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let NOP = Instruction(opcode: generator.getOpcode(withMnemonic: "NOP")!, immediate: 0)
        let JALR = Instruction(opcode: generator.getOpcode(withMnemonic: "JALR")!, immediate: 0)
        let JC = Instruction(opcode: generator.getOpcode(withMnemonic: "JC")!, immediate: 0)
        let JNC = Instruction(opcode: generator.getOpcode(withMnemonic: "JNC")!, immediate: 0)
        let JE = Instruction(opcode: generator.getOpcode(withMnemonic: "JE")!, immediate: 0)
        let JNE = Instruction(opcode: generator.getOpcode(withMnemonic: "JNE")!, immediate: 0)
        let JG = Instruction(opcode: generator.getOpcode(withMnemonic: "JG")!, immediate: 0)
        let JLE = Instruction(opcode: generator.getOpcode(withMnemonic: "JLE")!, immediate: 0)
        let JL = Instruction(opcode: generator.getOpcode(withMnemonic: "JL")!, immediate: 0)
        let JGE = Instruction(opcode: generator.getOpcode(withMnemonic: "JGE")!, immediate: 0)
        let JMP = Instruction(opcode: generator.getOpcode(withMnemonic: "JMP")!, immediate: 0)
        XCTAssertFalse(generator.isConditionalJump(NOP))
        XCTAssertFalse(generator.isConditionalJump(JALR))
        XCTAssertTrue(generator.isConditionalJump(JC))
        XCTAssertTrue(generator.isConditionalJump(JNC))
        XCTAssertTrue(generator.isConditionalJump(JE))
        XCTAssertTrue(generator.isConditionalJump(JNE))
        XCTAssertTrue(generator.isConditionalJump(JG))
        XCTAssertTrue(generator.isConditionalJump(JLE))
        XCTAssertTrue(generator.isConditionalJump(JL))
        XCTAssertTrue(generator.isConditionalJump(JGE))
        XCTAssertFalse(generator.isConditionalJump(JMP))
    }
    
    func testDCA() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let DCA = generator.getOpcode(withMnemonic: "DCA")!
        XCTAssertEqual(generator.getMnemonic(withOpcode: DCA), Optional("DCA"))
    }
}
