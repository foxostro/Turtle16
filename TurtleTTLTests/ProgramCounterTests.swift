//
//  ProgramCounterTests.swift
//  SimulatorTests
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class ProgramCounterTests: XCTestCase {
    func testInitializedToZero() {
        let pc = ProgramCounter()
        XCTAssertEqual(pc.contents, 0)
    }
    
    func testIncrement() {
        let pc = ProgramCounter()
        pc.increment()
        XCTAssertEqual(pc.contents, 1)
    }
}
