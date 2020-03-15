//
//  InstructionDecoderTests.swift
//  SimulatorTests
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class InstructionDecoderTests: XCTestCase {
    func testContentsInitializedToZero() {
        let decoder = InstructionDecoder()
        XCTAssertEqual(decoder.size, 131072)
        XCTAssertEqual(decoder.load(from: 0), 0)
    }
    
    func testContentsModifiable() {
        let value: UInt32 = 0xffffffff
        let decoder = InstructionDecoder()
        decoder.store(value: value, to: 0)
        XCTAssertEqual(decoder.load(from: 0), value)
    }
}
