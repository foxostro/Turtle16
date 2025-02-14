//
//  IDT7381Tests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 12/23/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleSimulatorCore

final class IDT7381Tests: XCTestCase {
    func testOutputCanBeDisabled() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 0,
                                  b: 0,
                                  c0: 0,
                                  i0: 0,
                                  i1: 0,
                                  i2: 0,
                                  rs0: 0,
                                  rs1: 0,
                                  ena: 0,
                                  enb: 0,
                                  enf: 0,
                                  ftab: 0,
                                  ftf: 0,
                                  oe: 1)
        let output = alu.step(input: input)
        XCTAssertNil(output.f)
    }
    
    func testCombinatorialOperationFequalZero() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 0,
                                  b: 0,
                                  c0: 0,
                                  i0: 0,
                                  i1: 0,
                                  i2: 0,
                                  rs0: 0,
                                  rs1: 0,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 0)
        let output = alu.step(input: input)
        XCTAssertEqual(output.f, 0)
    }
    
    func testCombinatorialOperationNotRplusS() {
        let c0: UInt = 1
        let alu = IDT7381()
        let input = IDT7381.Input(a: 1,
                                  b: 2,
                                  c0: c0,
                                  i0: 1,
                                  i1: 0,
                                  i2: 0,
                                  rs0: 1,
                                  rs1: 1,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 0)
        let output = alu.step(input: input)
        let r = alu.rmux(input: input)
        let s = alu.smux(input: input)
        let expected = ~r &+ s &+ UInt16(c0)
        let actual = output.f
        XCTAssertEqual(expected, actual)
    }
    
    func testCombinatorialOperationRplusNotS() {
        let c0: UInt = 1
        let alu = IDT7381()
        let input = IDT7381.Input(a: 1,
                                  b: 2,
                                  c0: c0,
                                  i0: 0,
                                  i1: 1,
                                  i2: 0,
                                  rs0: 1,
                                  rs1: 1,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 0)
        let output = alu.step(input: input)
        let r = alu.rmux(input: input)
        let s = alu.smux(input: input)
        let expected = r &+ ~s &+ UInt16(c0)
        let actual = output.f
        XCTAssertEqual(expected, actual)
    }
    
    func testCombinatorialOperationRplusS() {
        let c0: UInt = 1
        let alu = IDT7381()
        let input = IDT7381.Input(a: 1,
                                  b: 2,
                                  c0: c0,
                                  i0: 1,
                                  i1: 1,
                                  i2: 0,
                                  rs0: 1,
                                  rs1: 1,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 0)
        let output = alu.step(input: input)
        let r = alu.rmux(input: input)
        let s = alu.smux(input: input)
        let expected = r &+ s &+ UInt16(c0)
        let actual = output.f
        XCTAssertEqual(expected, actual)
    }
    
    func testCombinatorialOperationRxorS() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 1,
                                  b: 2,
                                  c0: 0,
                                  i0: 0,
                                  i1: 0,
                                  i2: 1,
                                  rs0: 1,
                                  rs1: 1,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 0)
        let output = alu.step(input: input)
        let r = alu.rmux(input: input)
        let s = alu.smux(input: input)
        let expected = r ^ s
        let actual = output.f
        XCTAssertEqual(expected, actual)
    }
    
    func testCombinatorialOperationRorS() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 1,
                                  b: 2,
                                  c0: 0,
                                  i0: 1,
                                  i1: 0,
                                  i2: 1,
                                  rs0: 1,
                                  rs1: 1,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 0)
        let output = alu.step(input: input)
        let r = alu.rmux(input: input)
        let s = alu.smux(input: input)
        let expected = r | s
        let actual = output.f
        XCTAssertEqual(expected, actual)
    }
    
    func testCombinatorialOperationRandS() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 1,
                                  b: 2,
                                  c0: 0,
                                  i0: 0,
                                  i1: 1,
                                  i2: 1,
                                  rs0: 1,
                                  rs1: 1,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 0)
        let output = alu.step(input: input)
        let r = alu.rmux(input: input)
        let s = alu.smux(input: input)
        let expected = r & s
        let actual = output.f
        XCTAssertEqual(expected, actual)
    }
    
    func testCombinatorialOperationFequalOnes() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 0,
                                  b: 0,
                                  c0: 0,
                                  i0: 1,
                                  i1: 1,
                                  i2: 1,
                                  rs0: 0,
                                  rs1: 0,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 0)
        let output = alu.step(input: input)
        XCTAssertEqual(output.f, 0xffff)
    }
    
    func testRS00() {
        let alu = IDT7381()
        alu.f = 0xffff
        let input = IDT7381.Input(a: 0xaaaa,
                                  b: 0xbbbb,
                                  c0: 0,
                                  i0: 0,
                                  i1: 0,
                                  i2: 0,
                                  rs0: 0,
                                  rs1: 0,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 0)
        let r = alu.rmux(input: input)
        let s = alu.smux(input: input)
        XCTAssertEqual(r, 0xaaaa)
        XCTAssertEqual(s, 0xffff)
    }
    
    func testRS01() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 0xaaaa,
                                  b: 0xbbbb,
                                  c0: 0,
                                  i0: 0,
                                  i1: 0,
                                  i2: 0,
                                  rs0: 1,
                                  rs1: 0,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 0)
        let r = alu.rmux(input: input)
        let s = alu.smux(input: input)
        XCTAssertEqual(r, 0xaaaa)
        XCTAssertEqual(s, 0x0000)
    }
    
    func testRS10() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 0xaaaa,
                                  b: 0xbbbb,
                                  c0: 0,
                                  i0: 0,
                                  i1: 0,
                                  i2: 0,
                                  rs0: 0,
                                  rs1: 1,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 0)
        let r = alu.rmux(input: input)
        let s = alu.smux(input: input)
        XCTAssertEqual(r, 0x0000)
        XCTAssertEqual(s, 0xbbbb)
    }
    
    func testRS11() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 0xaaaa,
                                  b: 0xbbbb,
                                  c0: 0,
                                  i0: 0,
                                  i1: 0,
                                  i2: 0,
                                  rs0: 1,
                                  rs1: 1,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 0)
        let r = alu.rmux(input: input)
        let s = alu.smux(input: input)
        XCTAssertEqual(r, 0xaaaa)
        XCTAssertEqual(s, 0xbbbb)
    }
    
    func testFTABaffectsFlowThroughForAandB() {
        let alu = IDT7381()
        alu.a = 0xcccc
        alu.b = 0xdddd
        let input = IDT7381.Input(a: 0xaaaa,
                                  b: 0xbbbb,
                                  c0: 0,
                                  i0: 0,
                                  i1: 0,
                                  i2: 0,
                                  rs0: 1,
                                  rs1: 1,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 0,
                                  ftf: 1,
                                  oe: 0)
        let r = alu.rmux(input: input)
        let s = alu.smux(input: input)
        XCTAssertEqual(r, 0xcccc)
        XCTAssertEqual(s, 0xdddd)
    }
    
    func testFTFaffectsFlowThroughForF() {
        let alu = IDT7381()
        alu.f = 0xaaaa
        let input = IDT7381.Input(a: 0,
                                  b: 0,
                                  c0: 0,
                                  i0: 1,
                                  i1: 1,
                                  i2: 1,
                                  rs0: 0,
                                  rs1: 0,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 0,
                                  oe: 0)
        let f = alu.fmux(input: input)
        XCTAssertEqual(f, 0xaaaa)
    }
    
    func testRegisterOnlyUpdateWhenEnabled() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 0xaaaa,
                                  b: 0xbbbb,
                                  c0: 0,
                                  i0: 1,
                                  i1: 1,
                                  i2: 1,
                                  rs0: 0,
                                  rs1: 0,
                                  ena: 0,
                                  enb: 0,
                                  enf: 0,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 1)
        let _ = alu.step(input: input)
        XCTAssertEqual(alu.a, 0xaaaa)
        XCTAssertEqual(alu.b, 0xbbbb)
        XCTAssertEqual(alu.f, 0xffff)
    }
    
    func testAdditionWhichDoesNotRaiseTheCarryFlag() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 1,
                                  b: 1,
                                  c0: 0,
                                  i0: 1,
                                  i1: 1,
                                  i2: 0,
                                  rs0: 1,
                                  rs1: 1,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 1)
        let output = alu.step(input: input)
        XCTAssertEqual(output.c16, 0)
    }
    
    func testAdditionWhichDoesRaiseTheCarryFlag() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 0xffff,
                                  b: 1,
                                  c0: 0,
                                  i0: 1,
                                  i1: 1,
                                  i2: 0,
                                  rs0: 1,
                                  rs1: 1,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 1)
        let output = alu.step(input: input)
        XCTAssertEqual(output.c16, 1)
    }
    
    func testAdditionWhichDoesRaiseTheCarryFlag_notR() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 0,
                                  b: 1,
                                  c0: 0,
                                  i0: 1,
                                  i1: 0,
                                  i2: 0,
                                  rs0: 1,
                                  rs1: 1,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 1)
        let output = alu.step(input: input)
        XCTAssertEqual(output.c16, 1)
    }
    
    func testAdditionWhichDoesRaiseTheCarryFlag_notS() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 1,
                                  b: 0,
                                  c0: 0,
                                  i0: 0,
                                  i1: 1,
                                  i2: 0,
                                  rs0: 1,
                                  rs1: 1,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 1)
        let output = alu.step(input: input)
        XCTAssertEqual(output.c16, 1)
    }
    
    func testSubtractionYieldingZeroRaisesTheZFlag() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 42,
                                  b: 42,
                                  c0: 1,
                                  i0: 0,
                                  i1: 1,
                                  i2: 0,
                                  rs0: 1,
                                  rs1: 1,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 0)
        let output = alu.step(input: input)
        XCTAssertEqual(output.f, 0)
        XCTAssertEqual(output.z, 1)
    }
    
    func testAdditionResultingInTwosComplementArithmeticOverflow() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 0x7fff,
                                  b: 1,
                                  c0: 0,
                                  i0: 1,
                                  i1: 1,
                                  i2: 0,
                                  rs0: 1,
                                  rs1: 1,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 0)
        let output = alu.step(input: input)
        XCTAssertEqual(output.f, 0x8000)
        XCTAssertEqual(output.ovf, 1)
    }
    
    func testSubtractionResultingInTwosComplementArithmeticOverflow() {
        let alu = IDT7381()
        let input = IDT7381.Input(a: 0x8000, // -32768
                                  b: 1,
                                  c0: 1,
                                  i0: 0,
                                  i1: 1,
                                  i2: 0,
                                  rs0: 1,
                                  rs1: 1,
                                  ena: 1,
                                  enb: 1,
                                  enf: 1,
                                  ftab: 1,
                                  ftf: 1,
                                  oe: 0)
        let output = alu.step(input: input)
        XCTAssertEqual(output.f, 0x7FFF)
        XCTAssertEqual(output.ovf, 1)
    }
    
    func testEquality_Equal() throws {
        let alu1 = IDT7381()
        alu1.a = 1
        
        let alu2 = IDT7381()
        alu2.a = 1
        
        XCTAssertEqual(alu1, alu2)
        XCTAssertEqual(alu1.hash, alu2.hash)
    }
    
    func testEquality_NotEqual() throws {
        let alu1 = IDT7381()
        alu1.a = 1
        
        let alu2 = IDT7381()
        alu2.a = 2
        
        XCTAssertNotEqual(alu1, alu2)
        XCTAssertNotEqual(alu1.hash, alu2.hash)
    }
    
    func testEncodeDecodeRoundTrip() throws {
        let alu1 = IDT7381()
        alu1.a = 1
        
        var data: Data! = nil
        XCTAssertNoThrow(data = try NSKeyedArchiver.archivedData(withRootObject: alu1, requiringSecureCoding: true))
        if data == nil {
            XCTFail()
            return
        }
        var alu2: IDT7381! = nil
        XCTAssertNoThrow(alu2 = try IDT7381.decode(from: data))
        XCTAssertEqual(alu1, alu2)
    }
}
