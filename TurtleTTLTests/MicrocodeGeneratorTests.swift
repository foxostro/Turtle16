//
//  MicrocodeGeneratorTests.swift
//  SimulatorTests
//
//  Created by Andrew Fox on 7/30/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

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
}
