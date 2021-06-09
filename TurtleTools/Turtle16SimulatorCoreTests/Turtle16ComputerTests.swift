//
//  Turtle16ComputerTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class Turtle16ComputerTests: XCTestCase {
    func testFlagsAreZeroAfterREset() throws {
        let cpu = SchematicLevelCPUModel()
        let computer = Turtle16Computer(cpu)
        computer.reset()
        XCTAssertEqual(computer.timeStamp, 0)
        XCTAssertEqual(computer.carry, 0)
        XCTAssertEqual(computer.z, 0)
        XCTAssertEqual(computer.ovf, 0)
    }
    
    func testDisassemblyOfInstructionMemory() throws {
        let cpu = SchematicLevelCPUModel()
        let computer = Turtle16Computer(cpu)
        
        computer.instructions = [
            0b1010011111111110, // JMP -2
        ]
        XCTAssertEqual(computer.disassembly.entries, [Disassembler.Entry(address: 0x0000, word: 0b1010011111111110, label: "L0", mnemonic: "JMP L0")])
        
        computer.instructions = [
            0x0000, // NOP
        ]
        XCTAssertEqual(computer.disassembly.entries, [Disassembler.Entry(address: 0x0000, word: 0x0000, label: nil, mnemonic: "NOP")])
    }
}
