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
    func testContentsInitializedTo255() {
        let memory = InstructionROM()
        XCTAssertEqual(memory.size, 131072)
        XCTAssertEqual(memory.load(address: 0).value, 0xffff)
    }
    
    func testContentsModifiable() {
        let memory = InstructionROM()
        let value: UInt16 = 32767
        memory.store(address: 0, value: value)
        XCTAssertEqual(memory.load(address: 0).value, value)
    }
}
