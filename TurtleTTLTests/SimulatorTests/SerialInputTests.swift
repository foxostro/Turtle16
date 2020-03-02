//
//  SerialInputTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 3/1/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class SerialInputTests: XCTestCase {
    func testInit() {
        let serialInput = SerialInput()
        XCTAssertEqual(serialInput.bytes, [])
        XCTAssertEqual(serialInput.count, 0)
    }
    
    func testProvide() {
        let serialInput = SerialInput()
        serialInput.provide(bytes: [1])
        XCTAssertEqual(serialInput.bytes, [1])
        XCTAssertEqual(serialInput.count, 1)
    }
    
    func testClear() {
        let serialInput = SerialInput()
        serialInput.provide(bytes: [1])
        serialInput.clear()
        XCTAssertEqual(serialInput.bytes, [])
    }
    
    func testRemoveFirst_Empty() {
        let serialInput = SerialInput()
        let byte = serialInput.removeFirst()
        XCTAssertNil(byte)
    }
    
    func testRemoveFirst_NotEmpty() {
        let serialInput = SerialInput()
        serialInput.provide(bytes: [1, 2])
        let byte = serialInput.removeFirst()
        XCTAssertEqual(byte, 1)
        XCTAssertEqual(serialInput.bytes, [2])
    }
}
