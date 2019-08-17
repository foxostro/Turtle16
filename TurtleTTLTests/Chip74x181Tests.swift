//
//  Chip74x181Tests.swift
//  SimulatorTests
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class Chip74x181Tests: XCTestCase {
    // Can use this online circuit simulator to verify that test cases actually
    // reflect reality: https://lodev.org/logicemu/#id=74181
    
    func testNotA() {
        let alu = Chip74x181()
        alu.a = 0b1010
        alu.b = 0
        alu.s = 0b0000
        alu.mode = 1
        alu.carryIn = 1
        alu.update()
        XCTAssertEqual(alu.result, 0b0101)
        XCTAssertEqual(alu.carryOut, 1)
    }
    
    func testIdentityA() {
        let alu = Chip74x181()
        alu.a = 0b1010
        alu.b = 0
        alu.s = 0b0000
        alu.mode = 0
        alu.carryIn = 1
        alu.update()
        XCTAssertEqual(alu.result, 0b1010)
        XCTAssertEqual(alu.carryOut, 1)
    }
    
    func testAPlusOne() {
        let alu = Chip74x181()
        alu.a = 0b1010
        alu.b = 0
        alu.s = 0b0000
        alu.mode = 0
        alu.carryIn = 0
        alu.update()
        XCTAssertEqual(alu.result, 0b1011)
        XCTAssertEqual(alu.carryOut, 1)
    }
    
    func testAXorB() {
        let alu = Chip74x181()
        alu.a = 0b0101
        alu.b = 0b0011
        alu.s = 0b0110
        alu.mode = 1
        alu.update()
        XCTAssertEqual(alu.result, 0b0110)
    }
    
    func testAMinusBMinusOne() {
        let alu = Chip74x181()
        alu.a = 15
        alu.b = 14
        alu.s = 0b0110
        alu.mode = 0
        alu.carryIn = 1
        alu.update()
        XCTAssertEqual(alu.result, 0)
        XCTAssertEqual(alu.carryOut, 0)
    }
    
    func testAMinusB() {
        let alu = Chip74x181()
        alu.a = 3
        alu.b = 1
        alu.s = 0b0110
        alu.mode = 0
        alu.carryIn = 0
        alu.update()
        XCTAssertEqual(alu.result, 2)
        XCTAssertEqual(alu.carryOut, 0)
    }
    
    func testAMinusB_underflow() {
        let alu = Chip74x181()
        alu.a = 0
        alu.b = 1
        alu.s = 0b0110
        alu.mode = 0
        alu.carryIn = 0
        alu.update()
        XCTAssertEqual(alu.result, 15)
        XCTAssertEqual(alu.carryOut, 1)
        XCTAssertEqual(alu.equalOut, 1)
    }
    
    func testXor2() {
        let alu = Chip74x181()
        XCTAssertEqual(alu.xor2(false, false), false)
        XCTAssertEqual(alu.xor2(false, true), true)
        XCTAssertEqual(alu.xor2(true, false), true)
        XCTAssertEqual(alu.xor2(true, true), false)
    }
    
    func testNand3() {
        let alu = Chip74x181()
        XCTAssertEqual(alu.nand3(false, false, false), true)
        XCTAssertEqual(alu.nand3(false, false, true),  true)
        XCTAssertEqual(alu.nand3(false, true,  false), true)
        XCTAssertEqual(alu.nand3(false, true,  true),  true)
        XCTAssertEqual(alu.nand3(true,  false, false), true)
        XCTAssertEqual(alu.nand3(true,  false, true),  true)
        XCTAssertEqual(alu.nand3(true,  true,  false), true)
        XCTAssertEqual(alu.nand3(true,  true,  true),  false)
    }
}
