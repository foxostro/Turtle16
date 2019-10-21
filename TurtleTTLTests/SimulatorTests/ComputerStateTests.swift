//
//  ComputerStateTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 10/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class ComputerStateTests: XCTestCase {
    func testIncrementXY() {
        let state = ComputerState()
            .withRegisterX(0)
            .withRegisterY(0)
            .incrementXY()
        XCTAssertEqual(state.registerX.value, 0)
        XCTAssertEqual(state.registerY.value, 1)
    }
    
    func testIncrementXY_CarryFromYToX() {
        let state = ComputerState()
            .withRegisterX(0)
            .withRegisterY(255)
            .incrementXY()
        XCTAssertEqual(state.registerX.value, 1)
        XCTAssertEqual(state.registerY.value, 0)
    }
    
    func testIncrementXY_Overflow() {
        let state = ComputerState()
            .withRegisterX(255)
            .withRegisterY(255)
            .incrementXY()
        XCTAssertEqual(state.registerX.value, 0)
        XCTAssertEqual(state.registerY.value, 0)
    }
    
    func testIncrementUV() {
        let state = ComputerState()
            .withRegisterU(0)
            .withRegisterV(0)
            .incrementUV()
        XCTAssertEqual(state.registerU.value, 0)
        XCTAssertEqual(state.registerV.value, 1)
    }
    
    func testIncrementUV_CarryFromVToU() {
        let state = ComputerState()
            .withRegisterU(0)
            .withRegisterV(255)
            .incrementUV()
        XCTAssertEqual(state.registerU.value, 1)
        XCTAssertEqual(state.registerV.value, 0)
    }
    
    func testIncrementUV_Overflow() {
        let state = ComputerState()
            .withRegisterU(255)
            .withRegisterV(255)
            .incrementUV()
        XCTAssertEqual(state.registerU.value, 0)
        XCTAssertEqual(state.registerV.value, 0)
    }
}
