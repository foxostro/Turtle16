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
            XCTAssertEqual(memory.contents[i], 0)
        }
    }
    
    func testContentsModifiable() {
        let memory = RAM()
        let value: UInt8 = 127
        for i in 0..<memory.size {
            memory.contents[i] = value
        }
        for i in 0..<memory.size {
            XCTAssertEqual(memory.contents[i], value)
        }
    }
}
