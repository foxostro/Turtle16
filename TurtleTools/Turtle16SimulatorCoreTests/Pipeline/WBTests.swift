//
//  WBTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 12/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class WBTests: XCTestCase {
    func testZeroControlWordYieldsZeroForIndividualControlSignals() {
        let output = WB().step(input: WB.Input(ctl: 0))
        XCTAssertEqual(output.wrl, 0)
        XCTAssertEqual(output.wrh, 0)
        XCTAssertEqual(output.wben, 0)
    }
    
    func testWRLisTheEighteenthBitOfTheControlWord() {
        let output = WB().step(input: WB.Input(ctl: 1<<18))
        XCTAssertEqual(output.wrl, 1)
        XCTAssertEqual(output.wrh, 0)
        XCTAssertEqual(output.wben, 0)
    }
    
    func testWRLisTheNineteenthBitOfTheControlWord() {
        let output = WB().step(input: WB.Input(ctl: 1<<19))
        XCTAssertEqual(output.wrl, 0)
        XCTAssertEqual(output.wrh, 1)
        XCTAssertEqual(output.wben, 0)
    }
    
    func testWBENisTheRTwentiethBitOfTheControlWord() {
        let output = WB().step(input: WB.Input(ctl: 1<<20))
        XCTAssertEqual(output.wrl, 0)
        XCTAssertEqual(output.wrh, 0)
        XCTAssertEqual(output.wben, 1)
    }
    
    func testWriteBackSrcSelectsALUResult() {
        let output = WB().step(input: WB.Input(y: 0xabab, storeOp: 0xcdcd, ctl: ~(1<<17)))
        XCTAssertEqual(output.c, 0xabab)
    }
    
    func testWriteBackSrcSelectsStoreOp() {
        let output = WB().step(input: WB.Input(y: 0xabab, storeOp: 0xcdcd, ctl: 1<<17))
        XCTAssertEqual(output.c, 0xcdcd)
    }
}
