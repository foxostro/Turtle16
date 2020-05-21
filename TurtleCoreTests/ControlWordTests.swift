//
//  ControlWordTests.swift
//  TurtleCoreTests
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore

class ControlWordTests: XCTestCase {
    func testNOPDoesNotHalt() {
        let controlWord = ControlWord()
        XCTAssertEqual(controlWord.HLT, .inactive)
    }
    
    func testModifyCOBit() {
        let controlWord = ControlWord().withCO(.active)
        XCTAssertEqual(controlWord.unsignedIntegerValue, 0b11111111111101111110111111101111)
    }
    
    func testSettingContentsSetsHLTSignal() {
        let controlWord = ControlWord(withValue: 1<<31)
        XCTAssertEqual(controlWord.HLT, .inactive)
    }
    
    func testControlWordStringIsPaddedOutToLength() {
        let hlt = ControlWord().withHLT(.active)
        XCTAssertEqual(hlt.stringValue, "01111111111101111110111111111111")
    }
    
    func testHash() {
        XCTAssertEqual(ControlWord().withCO(.active).hashValue,
                       ControlWord().withCO(.active).hashValue)
    }
}
