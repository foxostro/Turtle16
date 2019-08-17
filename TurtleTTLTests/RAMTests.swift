//
//  RAMTests.swift
//  SimulatorTests
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class RAMTests: XCTestCase {
    func testContentsInitializedToZero() {
        let memory = RAM()
        for i in 0..<memory.size {
            XCTAssertEqual(memory.load(from: i), 0)
        }
    }
    
    func testContentsModifiable() {
        var memory = RAM()
        let value: UInt8 = 127
        for i in 0..<memory.size {
            memory = memory.withStore(value: value, to: i)
        }
        for i in 0..<memory.size {
            XCTAssertEqual(memory.load(from: i), value)
        }
    }
}
