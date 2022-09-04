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
    func testFlagsAreZeroAfterReset() throws {
        let cpu = SchematicLevelCPUModel()
        let computer = Turtle16Computer(cpu)
        computer.reset()
        XCTAssertEqual(computer.timeStamp, 0)
        XCTAssertEqual(computer.n, 0)
        XCTAssertEqual(computer.c, 0)
        XCTAssertEqual(computer.z, 0)
        XCTAssertEqual(computer.v, 0)
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
    
    func testEquality_Equal() throws {
        let computer1 = Turtle16Computer(SchematicLevelCPUModel())
        computer1.instructions = [0x000, 0x0800]
        computer1.reset()
        computer1.run()
        
        let computer2 = Turtle16Computer(SchematicLevelCPUModel())
        computer2.instructions = [0x000, 0x0800]
        computer2.reset()
        computer2.run()
        
        XCTAssertEqual(computer1, computer2)
        XCTAssertEqual(computer1.hash, computer2.hash)
    }
    
    func testEquality_NotEqual() throws {
        let computer1 = Turtle16Computer(SchematicLevelCPUModel())
        computer1.instructions = [0x000, 0x0800]
        computer1.reset()
        computer1.run()
        
        let computer2 = Turtle16Computer(SchematicLevelCPUModel())
        computer2.instructions = [0x000, 0x000, 0x0800]
        computer2.reset()
        computer2.run()
        
        XCTAssertNotEqual(computer1, computer2)
        XCTAssertNotEqual(computer1.hash, computer2.hash)
    }
    
    func testEncodeDecodeRoundTrip() throws {
        let computer1 = Turtle16Computer(SchematicLevelCPUModel())
        computer1.instructions = [0x000, 0x0800]
        computer1.reset()
        computer1.run()
        var data: Data! = nil
        XCTAssertNoThrow(data = try NSKeyedArchiver.archivedData(withRootObject: computer1, requiringSecureCoding: true))
        if data == nil {
            XCTFail()
            return
        }
        var computer2: Turtle16Computer! = nil
        XCTAssertNoThrow(computer2 = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Turtle16Computer)
        XCTAssertEqual(computer1, computer2)
    }
    
    func testSaveRestoreSnapshot() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.instructions = [0x000, 0x0800]
        computer.reset()
        let snapshot = computer.snapshot()
        computer.run()
        computer.restore(from: snapshot)
        XCTAssertEqual(computer.pc, 0)
    }
}
