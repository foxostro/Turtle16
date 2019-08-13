//
//  ControlWordTests.swift
//  SimulatorTests
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class ControlWordTests: XCTestCase {
    func testNOPDoesNotHalt() {
        let controlWord = ControlWord()
        XCTAssertEqual(controlWord.HLT, true)
    }
    func testModifyCOBit() {
        let controlWord = ControlWord()
        controlWord.CO = false
        XCTAssertEqual(controlWord.contents, 0b1111111111111110)
    }
    func testSettingContentsSetsHLTSignal() {
        let controlWord = ControlWord()
        controlWord.contents = 1<<15
        XCTAssertEqual(controlWord.HLT, true)
    }
}
