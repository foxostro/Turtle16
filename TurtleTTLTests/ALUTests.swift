//
//  ALUTests.swift
//  SimulatorTests
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class ALUTests: XCTestCase {
    func testNotA() {
        let alu = ALU()
        alu.a = 0b10101010
        alu.b = 0
        alu.s = 0b0000
        alu.mode = 1
        alu.update()
        XCTAssertEqual(alu.result, ~alu.a)
    }
    
    func testIdentityA() {
        let alu = ALU()
        alu.a = 0b10101010
        alu.b = 0
        alu.s = 0b0000
        alu.mode = 0
        alu.carryIn = 1
        alu.update()
        XCTAssertEqual(alu.result, alu.a)
        XCTAssertEqual(alu.carryFlag, 1)
    }
    
    func testAPlusOne() {
        let alu = ALU()
        alu.a = 255
        alu.b = 0
        alu.s = 0b0000
        alu.mode = 0
        alu.carryIn = 0
        alu.update()
        XCTAssertEqual(alu.result, 0)
        XCTAssertEqual(alu.carryFlag, 0)
    }
    
    ////////////////////////////////////////////////////////////////////////////
    
    func testNotAOrB() {
        let alu = ALU()
        alu.a = 0b10101010
        alu.b = 0b01010101
        alu.s = 0b0001
        alu.mode = 1
        alu.update()
        XCTAssertEqual(alu.result, ~(alu.a | alu.b))
    }
    
    func testAOrB() {
        let alu = ALU()
        alu.a = 0b10101010
        alu.b = 0b01010101
        alu.s = 0b0001
        alu.mode = 0
        alu.carryIn = 1
        alu.update()
        XCTAssertEqual(alu.result, alu.a | alu.b)
        XCTAssertEqual(alu.carryFlag, 1)
    }
    
    func testAOrBPlusOne() {
        let alu = ALU()
        alu.a = 0b10101010
        alu.b = 0b01010101
        alu.s = 0b0001
        alu.mode = 0
        alu.carryIn = 0
        alu.update()
        XCTAssertEqual(alu.result, 0b00000000)
        XCTAssertEqual(alu.carryFlag, 0)
    }
    
    ////////////////////////////////////////////////////////////////////////////
    
    func testNotAAndB() {
        let alu = ALU()
        alu.a = 0b00000000
        alu.b = 0b11111111
        alu.s = 0b0010
        alu.mode = 1
        alu.update()
        XCTAssertEqual(alu.result, 0b11111111)
    }
    
    func testAOrNotB() {
        let alu = ALU()
        alu.a = 0b10101010
        alu.b = 0b00000000
        alu.s = 0b0010
        alu.mode = 0
        alu.carryIn = 1
        alu.update()
        XCTAssertEqual(alu.result, alu.a | ~alu.b)
    }
    
    func testAOrNotBPlusOne() {
        let alu = ALU()
        alu.a = 0b10101010
        alu.b = 0b10101010
        alu.s = 0b0010
        alu.mode = 0
        alu.carryIn = 0
        alu.update()
        XCTAssertEqual(alu.result, 0)
        XCTAssertEqual(alu.carryFlag, 0)
    }
    
    ////////////////////////////////////////////////////////////////////////////
    
    func testLogicZero() {
        let alu = ALU()
        alu.a = 0b11111111
        alu.b = 0b11111111
        alu.s = 0b0011
        alu.mode = 1
        alu.update()
        XCTAssertEqual(alu.result, 0)
    }
    
    func testMinusOne() {
        let alu = ALU()
        alu.a = 0b00000000
        alu.b = 0b00000000
        alu.s = 0b0011
        alu.mode = 0
        alu.carryIn = 1
        alu.update()
        XCTAssertEqual(alu.result, 0b11111111)
    }
    
    func testArithmeticZero() {
        let alu = ALU()
        alu.a = 0b11111111
        alu.b = 0b11111111
        alu.s = 0b0011
        alu.mode = 0
        alu.carryIn = 0
        alu.update()
        XCTAssertEqual(alu.result, 0)
    }
    
    ////////////////////////////////////////////////////////////////////////////
    
    func testNotAAndNotB() {
        let alu = ALU()
        alu.a = 0b10101010
        alu.b = 0b10101010
        alu.s = 0b0100
        alu.mode = 1
        alu.update()
        XCTAssertEqual(alu.result, ~alu.a & ~alu.b)
    }
    
    func testAPlusAAndNotB() {
        let alu = ALU()
        alu.a = 0b10101010
        alu.b = 0b10101010
        alu.s = 0b0101
        alu.mode = 0
        alu.carryIn = 1
        alu.update()
        XCTAssertEqual(alu.result, alu.a + (alu.a & ~alu.b))
    }
    
    func testAPlusAAndNotBPlusOne() {
        let alu = ALU()
        alu.a = 0b11111111
        alu.b = 0b00000000
        alu.s = 0b0100
        alu.mode = 0
        alu.carryIn = 0
        alu.update()
        XCTAssertEqual(alu.result, 0b11111111)
    }
    
    ////////////////////////////////////////////////////////////////////////////
    
    func testNotB() {
        let alu = ALU()
        alu.a = 0b00000000
        alu.b = 0b10101010
        alu.s = 0b0101
        alu.mode = 1
        alu.update()
        XCTAssertEqual(alu.result, 0b01010101)
    }
    
    func testAAndNotBPlusAOrB() {
        let alu = ALU()
        alu.a = 0b10101010
        alu.b = 0b10101010
        alu.s = 0b0101
        alu.mode = 0
        alu.carryIn = 1
        alu.update()
        XCTAssertEqual(alu.result, 170)
    }
    
    func testAAndBPlusAOrBPlusOne() {
        let alu = ALU()
        alu.a = 0b10101010
        alu.b = 0b10101010
        alu.s = 0b0101
        alu.mode = 0
        alu.carryIn = 0
        alu.update()
        XCTAssertEqual(alu.result, 171)
    }
    
    ////////////////////////////////////////////////////////////////////////////
    
    func testAXorB() {
        let alu = ALU()
        alu.a = 0b01010101
        alu.b = 0b00110011
        alu.s = 0b0110
        alu.mode = 1
        alu.update()
        XCTAssertEqual(alu.result, 0b01100110)
    }
    
    func testAMinusBMinusOne() {
        let alu = ALU()
        alu.a = 3
        alu.b = 1
        alu.s = 0b0110
        alu.mode = 0
        alu.carryIn = 1
        alu.update()
        XCTAssertEqual(alu.result, 1)
        XCTAssertEqual(alu.carryFlag, 0)
    }
    
    func testAMinusB() {
        let alu = ALU()
        alu.a = 2
        alu.b = 1
        alu.s = 0b0110
        alu.mode = 0
        alu.carryIn = 0
        alu.update()
        XCTAssertEqual(alu.result, 1)
        XCTAssertEqual(alu.carryFlag, 0)
        XCTAssertEqual(alu.equalFlag, 0)
    }
}
