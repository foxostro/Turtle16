//
//  IDTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 12/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class IDTests: XCTestCase {
    func testWriteBackSixteenBits() throws {
        let id = ID()
        id.registerFile[0] = 0xcdcd
        id.writeBack(input: ID.WriteBackInput(c: 0xabcd,
                                              wrh: 0,
                                              wrl: 0,
                                              wben: 0,
                                              selC_WB: 0))
        XCTAssertEqual(id.registerFile[0], 0xabcd)
    }
    
    func testWriteBackButDisabled() throws {
        let id = ID()
        id.registerFile[0] = 0xcdcd
        id.writeBack(input: ID.WriteBackInput(c: 0xabcd,
                                              wrh: 0,
                                              wrl: 0,
                                              wben: 1,
                                              selC_WB: 0))
        XCTAssertEqual(id.registerFile[0], 0xcdcd)
    }
    
    func testWriteBackUpperHalf() throws {
        let id = ID()
        id.registerFile[0] = 0xcdcd
        id.writeBack(input: ID.WriteBackInput(c: 0xabcd,
                                              wrh: 0,
                                              wrl: 0,
                                              wben: 1,
                                              selC_WB: 0))
        XCTAssertEqual(id.registerFile[0], 0xcdcd)
    }
    
    func testWriteBackLower() throws {
        let id = ID()
        id.registerFile[0] = 0xccdd
        id.writeBack(input: ID.WriteBackInput(c: 0xaabb,
                                              wrh: 1,
                                              wrl: 0,
                                              wben: 0,
                                              selC_WB: 0))
        XCTAssertEqual(id.registerFile[0], 0xccbb)
    }
    
    func testWriteBackUpper() throws {
        let id = ID()
        id.registerFile[0] = 0xccdd
        id.writeBack(input: ID.WriteBackInput(c: 0xaabb,
                                              wrh: 0,
                                              wrl: 1,
                                              wben: 0,
                                              selC_WB: 0))
        XCTAssertEqual(id.registerFile[0], 0xaadd)
    }
    
    func testPassThroughLowerElevenBitsOfInstruction() throws {
        let id = ID()
        let output = id.step(input: ID.Input(ins: 0xffff))
        XCTAssertEqual(output.ins, 0x07ff)
    }
    
    func testOutputNopDuringResetRegardlessOfInstructionWord() throws {
        let id = ID()
        let output = id.step(input: ID.Input(ins: 0xffff, rst: 0))
        XCTAssertEqual(output.ctl_EX, 0b111111111111111111111) // no active control lines
    }
    
    func testDecodeControlWordForNOP() throws {
        let id = ID()
        let output = id.step(input: ID.Input(ins: 0))
        XCTAssertEqual(output.ctl_EX, 0b111111111111111111111) // no active control lines
    }
    
    func testReadRegisterA() throws {
        let id = ID()
        id.registerFile[7] = 0xabcd
        let output = id.step(input: ID.Input(ins: 0b0000000011100000))
        XCTAssertEqual(output.a, 0xabcd)
    }
    
    func testReadRegisterB() throws {
        let id = ID()
        id.registerFile[7] = 0xabcd
        let output = id.step(input: ID.Input(ins: 0b0000000000011100))
        XCTAssertEqual(output.b, 0xabcd)
    }
    
    func testDecodeHaltInstruction() throws {
        let id = ID()
        let hltOpcode: UInt = 1
        let entry: UInt = (1<<8) + hltOpcode
        id.opcodeDecodeROM[Int(entry)] = 1
        let ins: UInt16 = UInt16(hltOpcode << 11)
        let output = id.step(input: ID.Input(ins: ins))
        XCTAssertEqual(~output.ctl_EX & 1, 1) // HLT control line is active
    }
}