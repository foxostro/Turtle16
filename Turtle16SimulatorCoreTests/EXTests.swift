//
//  EXTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 12/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class EXTests: XCTestCase {
    func testSplitOutSelC_000() {
        let ex = EX()
        let selC = ex.splitOutSelC(input: EX.Input(ins: 0b1111100011111111))
        XCTAssertEqual(selC, 0)
    }
    
    func testSplitOutSelC_111() {
        let ex = EX()
        let selC = ex.splitOutSelC(input: EX.Input(ins: 0b0000011100000000))
        XCTAssertEqual(selC, 7)
    }
    
    func testHalt_0() {
        let ex = EX()
        let input = EX.Input(ctl: ~1)
        let output = ex.step(input: input)
        XCTAssertEqual(output.hlt, 0)
    }
    
    func testHalt_1() {
        let ex = EX()
        let input = EX.Input(ctl: 1)
        let output = ex.step(input: input)
        XCTAssertEqual(output.hlt, 1)
    }
    
    func testJ_0() {
        let ex = EX()
        let input = EX.Input(ctl: ~(1<<12))
        let output = ex.step(input: input)
        XCTAssertEqual(output.j, 0)
    }
    
    func testJ_1() {
        let ex = EX()
        let input = EX.Input(ctl: 1<<12)
        let output = ex.step(input: input)
        XCTAssertEqual(output.j, 1)
    }
    
    func testJABS_0() {
        let ex = EX()
        let input = EX.Input(ctl: ~(1<<13))
        let output = ex.step(input: input)
        XCTAssertEqual(output.jabs, 0)
    }
    
    func testJABS_1() {
        let ex = EX()
        let input = EX.Input(ctl: 1<<13)
        let output = ex.step(input: input)
        XCTAssertEqual(output.jabs, 1)
    }
    
    func testControlWordPassesThrough() {
        let ex = EX()
        let input = EX.Input(ctl: 0xdeadbeef)
        let output = ex.step(input: input)
        XCTAssertEqual(output.ctl, 0xdeadbeef)
    }
    
    func testSelectRightOperand_0() {
        let ex = EX()
        let input = EX.Input(ins: 0b0000000000000000, b: 0xcafe, ctl: 0)
        let right = ex.selectRightOperand(input: input)
        XCTAssertEqual(right, 0xcafe)
    }
    
    func testSelectRightOperand_1_signExtended() {
        let ex = EX()
        let input = EX.Input(ins: 0b0000000000010000, b: 0, ctl: 0b01 << 3)
        let right = ex.selectRightOperand(input: input)
        XCTAssertEqual(right, 0b1111111111110000)
    }
    
    func testSelectRightOperand_1_notExtended() {
        let ex = EX()
        let input = EX.Input(ins: 0b0000000000001111, b: 0, ctl: 0b01 << 3)
        let right = ex.selectRightOperand(input: input)
        XCTAssertEqual(right, 0b01111)
    }
    
    func testSelectRightOperand_2_notExtended() {
        let ex = EX()
        let input = EX.Input(ins: 0b0000001100000011, b: 0, ctl: 0b10 << 3)
        let right = ex.selectRightOperand(input: input)
        XCTAssertEqual(right, 0b01111)
    }
    
    func testSelectRightOperand_2_signExtended() {
        let ex = EX()
        let input = EX.Input(ins: 0b0000011100000011, b: 0, ctl: 0b10 << 3)
        let right = ex.selectRightOperand(input: input)
        XCTAssertEqual(right, 0xffff)
    }
    
    func testSelectRightOperand_3_signExtended() {
        let ex = EX()
        let input = EX.Input(ins: 0b0000011111111110, b: 0, ctl: 0b11 << 3)
        let right = ex.selectRightOperand(input: input)
        XCTAssertEqual(right, 0xfffe)
    }
    
    func testSelectRightOperand_3_notExtended() {
        let ex = EX()
        let input = EX.Input(ins: 0b0000001111111111, b: 0, ctl: 0b11 << 3)
        let right = ex.selectRightOperand(input: input)
        XCTAssertEqual(right, 0b1111111111)
    }
    
    func testSelectStoreOperand_0() {
        let ex = EX()
        let input = EX.Input(ins: 0b0000000000000000, b: 0xcd, pc: 0, ctl: 0b00<<1)
        let storeOp = ex.selectStoreOperand(input: input)
        XCTAssertEqual(storeOp, 0x00cd)
    }
    
    func testSelectStoreOperand_1() {
        let ex = EX()
        let input = EX.Input(ins: 0b0000000000000000, b: 0, pc: 0xbeef, ctl: 0b01<<1)
        let storeOp = ex.selectStoreOperand(input: input)
        XCTAssertEqual(storeOp, 0xbeef)
    }
    
    func testSelectStoreOperand_2_notExtended() {
        let ex = EX()
        let input = EX.Input(ins: 0b00000000001111111, b: 0, pc: 0, ctl: 0b10<<1)
        let storeOp = ex.selectStoreOperand(input: input)
        XCTAssertEqual(storeOp, 127)
    }
    
    func testSelectStoreOperand_2_signExtended() {
        let ex = EX()
        let input = EX.Input(ins: 0b00000000011111111, b: 0, pc: 0, ctl: 0b10<<1)
        let storeOp = ex.selectStoreOperand(input: input)
        XCTAssertEqual(storeOp, 0xffff)
    }
    
    func testSelectStoreOperand_3() {
        let ex = EX()
        let input = EX.Input(ins: 0b0000000011001101, b: 0, pc: 0, ctl: 0b11<<1)
        let storeOp = ex.selectStoreOperand(input: input)
        XCTAssertEqual(storeOp, 0xcd00)
    }
    
    func testAdd() {
        let ex = EX()
        let input = EX.Input(a: 1, b: 1, ctl: 0b110110<<6)
        let output = ex.step(input: input)
        XCTAssertEqual(output.y, 2)
        XCTAssertEqual(output.carry, 0)
        XCTAssertEqual(output.z, 0)
        XCTAssertEqual(output.ovf, 0)
    }
    
    func testAddWithCarryOutput() {
        let ex = EX()
        let input = EX.Input(a: 0xffff, b: 1, ctl: 0b110110<<6)
        let output = ex.step(input: input)
        XCTAssertEqual(output.y, 0x0000)
        XCTAssertEqual(output.carry, 1)
        XCTAssertEqual(output.z, 1)
        XCTAssertEqual(output.ovf, 0)
    }
    
    func testAddWithSignedOverflow() {
        let ex = EX()
        let input = EX.Input(a: 0x7fff, b: 1, ctl: 0b110110<<6)
        let output = ex.step(input: input)
        XCTAssertEqual(output.y, 0x8000)
        XCTAssertEqual(output.carry, 0)
        XCTAssertEqual(output.z, 0)
        XCTAssertEqual(output.ovf, 1)
    }
}
