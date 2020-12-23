//
//  WriteBackStageTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 12/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class WriteBackStageTests: XCTestCase {
    func testZeroControlWordYieldsZeroForIndividualControlSignals() {
        let output = WriteBackStage().step(input: WriteBackStage.Input(ctl: 0))
        XCTAssertEqual(output.wrl, 0)
        XCTAssertEqual(output.wrh, 0)
        XCTAssertEqual(output.wben, 0)
    }
    
    func testWRLisTheEighteenthBitOfTheControlWord() {
        let output = WriteBackStage().step(input: WriteBackStage.Input(ctl: 1<<18))
        XCTAssertEqual(output.wrl, 1)
        XCTAssertEqual(output.wrh, 0)
        XCTAssertEqual(output.wben, 0)
    }
    
    func testWRLisTheNineteenthBitOfTheControlWord() {
        let output = WriteBackStage().step(input: WriteBackStage.Input(ctl: 1<<19))
        XCTAssertEqual(output.wrl, 0)
        XCTAssertEqual(output.wrh, 1)
        XCTAssertEqual(output.wben, 0)
    }
    
    func testWBENisTheRTwentiethBitOfTheControlWord() {
        let output = WriteBackStage().step(input: WriteBackStage.Input(ctl: 1<<20))
        XCTAssertEqual(output.wrl, 0)
        XCTAssertEqual(output.wrh, 0)
        XCTAssertEqual(output.wben, 1)
    }
    
    func testWriteBackSrcSelectsALUResult() {
        let output = WriteBackStage().step(input: WriteBackStage.Input(y: 0xabab, storeOp: 0xcdcd, ctl: ~UInt32(1<<17)))
        XCTAssertEqual(output.c, 0xabab)
    }
    
    func testWriteBackSrcSelectsStoreOp() {
        let output = WriteBackStage().step(input: WriteBackStage.Input(y: 0xabab, storeOp: 0xcdcd, ctl: UInt32(1<<17)))
        XCTAssertEqual(output.c, 0xcdcd)
    }
}
