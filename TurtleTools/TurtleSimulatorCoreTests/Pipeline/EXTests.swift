//
//  EXTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 12/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleSimulatorCore
import XCTest

final class EXTests: XCTestCase {
    func testSplitOutSelC_000() {
        let ex = EX()
        let selC = ex.splitOutSelC(input: EX.Input(ins: 0b11111000_11111111))
        XCTAssertEqual(selC, 0)
    }

    func testSplitOutSelC_111() {
        let ex = EX()
        let selC = ex.splitOutSelC(input: EX.Input(ins: 0b00000111_00000000))
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
        let input = EX.Input(ctl: ~(1 << 12))
        let output = ex.step(input: input)
        XCTAssertEqual(output.j, 0)
    }

    func testJ_1() {
        let ex = EX()
        let input = EX.Input(ctl: 1 << 12)
        let output = ex.step(input: input)
        XCTAssertEqual(output.j, 1)
    }

    func testJABS_0() {
        let ex = EX()
        let input = EX.Input(ctl: ~(1 << 13))
        let output = ex.step(input: input)
        XCTAssertEqual(output.jabs, 0)
    }

    func testJABS_1() {
        let ex = EX()
        let input = EX.Input(ctl: 1 << 13)
        let output = ex.step(input: input)
        XCTAssertEqual(output.jabs, 1)
    }

    func testControlWordPassesThrough() {
        let ex = EX()
        let input = EX.Input(ctl: 0xdead_beef)
        let output = ex.step(input: input)
        XCTAssertEqual(output.ctl, 0xdead_beef)
    }

    func testSelectRightOperand_0() {
        let ex = EX()
        let input = EX.Input(ins: 0b00000000_00000000, b: 0xcafe, ctl: 0)
        let right = ex.selectRightOperand(input: input)
        XCTAssertEqual(right, 0xcafe)
    }

    func testSelectRightOperand_1_signExtended() {
        let ex = EX()
        let input = EX.Input(ins: 0b00000000_00010000, b: 0, ctl: 0b01 << 3)
        let right = ex.selectRightOperand(input: input)
        XCTAssertEqual(right, 0b11111111_11110000)
    }

    func testSelectRightOperand_1_notExtended() {
        let ex = EX()
        let input = EX.Input(ins: 0b00000000_00001111, b: 0, ctl: 0b01 << 3)
        let right = ex.selectRightOperand(input: input)
        XCTAssertEqual(right, 0b01111)
    }

    func testSelectRightOperand_2_notExtended() {
        let ex = EX()
        let input = EX.Input(ins: 0b00000011_00000011, b: 0, ctl: 0b10 << 3)
        let right = ex.selectRightOperand(input: input)
        XCTAssertEqual(right, 0b01111)
    }

    func testSelectRightOperand_2_signExtended() {
        let ex = EX()
        let input = EX.Input(ins: 0b00000111_00000011, b: 0, ctl: 0b10 << 3)
        let right = ex.selectRightOperand(input: input)
        XCTAssertEqual(right, 0xffff)
    }

    func testSelectRightOperand_3_signExtended() {
        let ex = EX()
        let input = EX.Input(ins: 0b00000111_11111110, b: 0, ctl: 0b11 << 3)
        let right = ex.selectRightOperand(input: input)
        XCTAssertEqual(right, 0xfffe)
    }

    func testSelectRightOperand_3_signExtended_2() {
        let ex = EX()
        let input = EX.Input(ins: 0b00000111_11011010, b: 0, ctl: 0b11 << 3)
        let right = ex.selectRightOperand(input: input)
        XCTAssertEqual(Int(right), 65536 - 38)
    }

    func testSelectRightOperand_3_notExtended() {
        let ex = EX()
        let input = EX.Input(ins: 0b00000011_11111111, b: 0, ctl: 0b11 << 3)
        let right = ex.selectRightOperand(input: input)
        XCTAssertEqual(right, 0b11_11111111)
    }

    func testSelectStoreOperand_0() {
        let ex = EX()
        let input = EX.Input(ins: 0b00000000_00000000, b: 0xcd, pc: 0, ctl: 0b00 << 1)
        let storeOp = ex.selectStoreOperand(input: input)
        XCTAssertEqual(storeOp, 0x00cd)
    }

    func testSelectStoreOperand_1() {
        let ex = EX()
        let input = EX.Input(ins: 0b00000000_00000000, b: 0, pc: 0xbeef, ctl: 0b01 << 1)
        let storeOp = ex.selectStoreOperand(input: input)
        XCTAssertEqual(storeOp, 0xbeef)
    }

    func testSelectStoreOperand_2_notExtended() {
        let ex = EX()
        let input = EX.Input(ins: 0b0_00000000_01111111, b: 0, pc: 0, ctl: 0b10 << 1)
        let storeOp = ex.selectStoreOperand(input: input)
        XCTAssertEqual(storeOp, 127)
    }

    func testSelectStoreOperand_2_signExtended() {
        let ex = EX()
        let input = EX.Input(ins: 0b0_00000000_11111111, b: 0, pc: 0, ctl: 0b10 << 1)
        let storeOp = ex.selectStoreOperand(input: input)
        XCTAssertEqual(storeOp, 0xffff)
    }

    func testSelectStoreOperand_3() {
        let ex = EX()
        let input = EX.Input(ins: 0b00000000_11001101, b: 0, pc: 0, ctl: 0b11 << 1)
        let storeOp = ex.selectStoreOperand(input: input)
        XCTAssertEqual(storeOp, 0xcd00)
    }

    func testAdd() {
        let ex = EX()
        let input = EX.Input(a: 1, b: 1, ctl: 0b110110 << 6)
        let output = ex.step(input: input)
        XCTAssertEqual(output.y, 2)
        XCTAssertEqual(output.n, 0)
        XCTAssertEqual(output.c, 0)
        XCTAssertEqual(output.z, 0)
        XCTAssertEqual(output.v, 0)
    }

    func testAddWithCarryOutput() {
        let ex = EX()
        let input = EX.Input(a: 0xffff, b: 1, ctl: 0b110110 << 6)
        let output = ex.step(input: input)
        XCTAssertEqual(output.y, 0x0000)
        XCTAssertEqual(output.n, 0)
        XCTAssertEqual(output.c, 1)
        XCTAssertEqual(output.z, 1)
        XCTAssertEqual(output.v, 0)
    }

    func testAddWithSignedOverflow() {
        let ex = EX()
        let input = EX.Input(a: 0x7fff, b: 1, ctl: 0b110110 << 6)
        let output = ex.step(input: input)
        XCTAssertEqual(output.y, 0x8000)
        XCTAssertEqual(output.n, 1)
        XCTAssertEqual(output.c, 0)
        XCTAssertEqual(output.z, 0)
        XCTAssertEqual(output.v, 1)
    }

    func testEquality_Equal() throws {
        let stage1 = EX()
        stage1.associatedPC = 1

        let stage2 = EX()
        stage2.associatedPC = 1

        XCTAssertEqual(stage1, stage2)
        XCTAssertEqual(stage1.hash, stage2.hash)
    }

    func testEquality_NotEqual() throws {
        let stage1 = EX()
        stage1.associatedPC = 1

        let stage2 = EX()
        stage2.associatedPC = 2

        XCTAssertNotEqual(stage1, stage2)
        XCTAssertNotEqual(stage1.hash, stage2.hash)
    }

    func testEncodeDecodeRoundTrip() throws {
        let stage1 = EX()
        stage1.associatedPC = 1

        var data: Data! = nil
        XCTAssertNoThrow(
            data = try NSKeyedArchiver.archivedData(
                withRootObject: stage1,
                requiringSecureCoding: true
            )
        )
        if data == nil {
            XCTFail()
            return
        }
        var stage2: EX! = nil
        XCTAssertNoThrow(stage2 = try EX.decode(from: data))
        XCTAssertEqual(stage1, stage2)
    }
}
