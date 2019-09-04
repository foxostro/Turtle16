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
    
    func testContentsModifiable() {
        let value: UInt16 = 32767
        let memory = InstructionROM().withStore(value: value, to: 0)
        XCTAssertEqual(memory.load(from: 0).value, value)
    }
}
