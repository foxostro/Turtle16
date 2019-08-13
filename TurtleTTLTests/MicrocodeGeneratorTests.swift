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
        
        let NOP = generator.getOpcode(withMnemonic: "NOP")
        XCTAssertEqual(generator.microcode.load(opcode: NOP!, carryFlag: 1, equalFlag: 1), ControlWord().contents)
    }
    
    func testHLT() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let HLT = generator.getOpcode(withMnemonic: "HLT")
        
        let controlWord = ControlWord()
        controlWord.contents = generator.microcode.load(opcode: HLT!, carryFlag: 1, equalFlag: 1);
        
        XCTAssertFalse(controlWord.HLT)
    }
    
    func testGetOpcode() {
        let generator = MicrocodeGenerator()
        generator.generate()
        XCTAssertEqual(generator.getOpcode(withMnemonic: "NOP")!, 0)
    }
    
    func testJMP() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let JMP = generator.getOpcode(withMnemonic: "JMP")
        
        let controlWord = ControlWord()
        controlWord.contents = generator.microcode.load(opcode: JMP!, carryFlag: 1, equalFlag: 1);
        
        XCTAssertFalse(controlWord.J)
    }
    
    func testJC() {
        let generator = MicrocodeGenerator()
        generator.generate()
        let JC = generator.getOpcode(withMnemonic: "JC")
        
        let controlWordOnBranchTaken = ControlWord()
        controlWordOnBranchTaken.contents = generator.microcode.load(opcode: JC!, carryFlag: 0, equalFlag: 1);
        XCTAssertFalse(controlWordOnBranchTaken.J)
        
        let controlWordOnBranchNotTaken = ControlWord()
        controlWordOnBranchNotTaken.contents = generator.microcode.load(opcode: JC!, carryFlag: 1, equalFlag: 1);
        XCTAssertTrue(controlWordOnBranchNotTaken.J)
    }
}
