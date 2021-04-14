//
//  MicrocodeGeneratorTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 7/30/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleSimulatorCore

class MicrocodeGeneratorTests: XCTestCase {
    func testNOP() {
        let generator = MicrocodeGenerator()
        generator.generate()
        
        let NOP = generator.getOpcode(mnemonic: "NOP")!
        XCTAssertEqual(generator.microcode.load(opcode: NOP, carryFlag: 1, equalFlag: 1), UInt32(ControlWord().unsignedIntegerValue))
        XCTAssertEqual(generator.getMnemonic(opcode: NOP), Optional("NOP"))
    }
    
    func testHLT() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let HLT = generator.getOpcode(mnemonic: "HLT")!
        
        let value = generator.microcode.load(opcode: HLT, carryFlag: 1, equalFlag: 1)
        let controlWord = ControlWord(withValue: UInt(value))
        
        XCTAssertEqual(.active, controlWord.HLT)
        XCTAssertEqual(generator.getMnemonic(opcode: HLT), Optional("HLT"))
    }
    
    func testGetOpcode() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let NOP = generator.getOpcode(mnemonic: "NOP")!
        XCTAssertEqual(NOP, 0)
        XCTAssertEqual(generator.getMnemonic(opcode: NOP), Optional("NOP"))
    }
    
    func testJMP() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let JMP = generator.getOpcode(mnemonic: "JMP")!
        
        let value = generator.microcode.load(opcode: JMP, carryFlag: 1, equalFlag: 1)
        let controlWord = ControlWord(withValue: UInt(value))
        
        XCTAssertEqual(.active, controlWord.J)
        XCTAssertEqual(generator.getMnemonic(opcode: JMP), Optional("JMP"))
    }
    
    func testJC() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let JC = generator.getOpcode(mnemonic: "JC")!
        
        let controlWordOnBranchTaken = ControlWord(withValue: UInt(generator.microcode.load(opcode: JC, carryFlag: 0, equalFlag: 1)))
        XCTAssertEqual(.active, controlWordOnBranchTaken.J)
        
        let controlWordOnBranchNotTaken = ControlWord(withValue: UInt(generator.microcode.load(opcode: JC, carryFlag: 1, equalFlag: 1)))
        XCTAssertEqual(.inactive, controlWordOnBranchNotTaken.J)
        
        XCTAssertEqual(generator.getMnemonic(opcode: JC), Optional("JC"))
    }
    
    func testALU() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let ALU = generator.getOpcode(mnemonic: "ALUwoC")!
        XCTAssertEqual(generator.getMnemonic(opcode: ALU), Optional("ALUwoC"))
    }
    
    func testIsUnconditionalJump() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let NOP = Instruction(opcode: generator.getOpcode(mnemonic: "NOP")!, immediate: 0)
        let JALR = Instruction(opcode: generator.getOpcode(mnemonic: "JALR")!, immediate: 0)
        let JC = Instruction(opcode: generator.getOpcode(mnemonic: "JC")!, immediate: 0)
        let JNC = Instruction(opcode: generator.getOpcode(mnemonic: "JNC")!, immediate: 0)
        let JE = Instruction(opcode: generator.getOpcode(mnemonic: "JE")!, immediate: 0)
        let JNE = Instruction(opcode: generator.getOpcode(mnemonic: "JNE")!, immediate: 0)
        let JG = Instruction(opcode: generator.getOpcode(mnemonic: "JG")!, immediate: 0)
        let JLE = Instruction(opcode: generator.getOpcode(mnemonic: "JLE")!, immediate: 0)
        let JL = Instruction(opcode: generator.getOpcode(mnemonic: "JL")!, immediate: 0)
        let JGE = Instruction(opcode: generator.getOpcode(mnemonic: "JGE")!, immediate: 0)
        let JMP = Instruction(opcode: generator.getOpcode(mnemonic: "JMP")!, immediate: 0)
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
        let NOP = Instruction(opcode: generator.getOpcode(mnemonic: "NOP")!, immediate: 0)
        let JALR = Instruction(opcode: generator.getOpcode(mnemonic: "JALR")!, immediate: 0)
        let JC = Instruction(opcode: generator.getOpcode(mnemonic: "JC")!, immediate: 0)
        let JNC = Instruction(opcode: generator.getOpcode(mnemonic: "JNC")!, immediate: 0)
        let JE = Instruction(opcode: generator.getOpcode(mnemonic: "JE")!, immediate: 0)
        let JNE = Instruction(opcode: generator.getOpcode(mnemonic: "JNE")!, immediate: 0)
        let JG = Instruction(opcode: generator.getOpcode(mnemonic: "JG")!, immediate: 0)
        let JLE = Instruction(opcode: generator.getOpcode(mnemonic: "JLE")!, immediate: 0)
        let JL = Instruction(opcode: generator.getOpcode(mnemonic: "JL")!, immediate: 0)
        let JGE = Instruction(opcode: generator.getOpcode(mnemonic: "JGE")!, immediate: 0)
        let JMP = Instruction(opcode: generator.getOpcode(mnemonic: "JMP")!, immediate: 0)
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
    
    func testCALUwoC() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let CALUwoC = generator.getOpcode(mnemonic: "CALUwoC")!
        XCTAssertEqual(generator.getMnemonic(opcode: CALUwoC), Optional("CALUwoC"))
    }
    
    func testALUxC() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let ALUxC = generator.getOpcode(mnemonic: "ALUxC")!
        XCTAssertEqual(generator.getMnemonic(opcode: ALUxC), Optional("ALUxC"))
    }
}
