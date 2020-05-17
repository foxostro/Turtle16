//
//  AtomicBooleanFlagTests.swift
//  TurtleCoreTests
//
//  Created by Andrew Fox on 3/1/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore

class AtomicBooleanFlagTests: XCTestCase {
    func testInit() {
        XCTAssertFalse(AtomicBooleanFlag().value)
        XCTAssertFalse(AtomicBooleanFlag(false).value)
        XCTAssertTrue(AtomicBooleanFlag(true).value)
    }
    
    func testSetTrue() {
        let flag = AtomicBooleanFlag()
        flag.value = true
        XCTAssertTrue(flag.value)
    }
}
