//
//  InstructionROMTests.swift
//  SimulatorTests
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class InstructionROMTests: XCTestCase {
    func testContentsInitializedToZero() {
        let memory = InstructionROM()
        XCTAssertEqual(memory.size, 131072)
        XCTAssertEqual(memory.load(from: 0).value, 0)
    }
    
    func testStoreUInt16() {
        let expected: UInt16 = 32767
        let memory = InstructionROM()
        memory.store(value: expected, to: 0)
        let ins = memory.load(from: 0)
        let actual = ins.value
        XCTAssertEqual(actual, expected)
    }
    
    func testStoreInstruction() {
        let expected = Instruction(opcode: 0xff, immediate: 0xff)
        let memory = InstructionROM()
        memory.store(instruction: expected, to: 0)
        let actual = memory.load(from: 0)
        XCTAssertEqual(actual, expected)
    }
}
