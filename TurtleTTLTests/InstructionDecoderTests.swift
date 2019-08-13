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
    func testContentsInitializedTo255() {
        let decoder = InstructionDecoder()
        XCTAssertEqual(decoder.size, 131072)
        XCTAssertEqual(decoder.load(address: 0), 0xffff)
    }
    
    func testContentsModifiable() {
        let decoder = InstructionDecoder()
        let value: UInt16 = 1234
        decoder.store(address: 0, value: value)
        XCTAssertEqual(decoder.load(address: 0), value)
    }
}
