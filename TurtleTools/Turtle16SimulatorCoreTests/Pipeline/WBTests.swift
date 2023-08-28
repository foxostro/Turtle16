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
    
    func testEquality_Equal() throws {
        let stage1 = WB()
        stage1.associatedPC = 1
        
        let stage2 = WB()
        stage2.associatedPC = 1
        
        XCTAssertEqual(stage1, stage2)
        XCTAssertEqual(stage1.hash, stage2.hash)
    }
    
    func testEquality_NotEqual() throws {
        let stage1 = WB()
        stage1.associatedPC = 1
        
        let stage2 = WB()
        stage2.associatedPC = 2
        
        XCTAssertNotEqual(stage1, stage2)
        XCTAssertNotEqual(stage1.hash, stage2.hash)
    }
    
    func testEncodeDecodeRoundTrip() throws {
        let stage1 = WB()
        stage1.associatedPC = 1
        
        var data: Data! = nil
        XCTAssertNoThrow(data = try NSKeyedArchiver.archivedData(withRootObject: stage1, requiringSecureCoding: true))
        if data == nil {
            XCTFail()
            return
        }
        var stage2: WB! = nil
        XCTAssertNoThrow(stage2 = try WB.decode(from: data))
        XCTAssertEqual(stage1, stage2)
    }
}
