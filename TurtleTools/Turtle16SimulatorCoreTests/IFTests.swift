//
//  IFTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 12/23/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class IFTests: XCTestCase {
    func testFlushOnJumpByIssuingNOP() {
        let ifetch = IF()
        let input = IF.Input(stall: 0, y: 0xffff, jabs: 1, j: 0, rst: 1)
        let output1 = ifetch.step(input: input)
        XCTAssertEqual(output1.pc, 0xffff)
        XCTAssertEqual(output1.ins, 0)
    }
    
    func testProgramCounterRollsOverToZero() {
        let ifetch = IF()
        ifetch.alu.a = 0xffff
        ifetch.prevPC = 0xffff
        let input = IF.Input(stall: 0, y: 0, jabs: 1, j: 1, rst: 1)
        let output = ifetch.step(input: input)
        XCTAssertEqual(output.pc, 0)
    }
    
    func testProgramCounterResetsToZero() {
        let ifetch = IF()
        ifetch.load = {(addr: UInt16) in
            return addr &+ 0xabcd
        }
        ifetch.prevPC = 0xffff
        ifetch.alu.a = 0xffff
        ifetch.alu.b = 0xffff
        ifetch.alu.f = 0xffff
        let input = IF.Input(stall: 0, y: 0, jabs: 1, j: 1, rst: 0)
        let _ = ifetch.step(input: input)
        let output = ifetch.step(input: input)
        XCTAssertEqual(output.pc, 0)
        XCTAssertEqual(output.ins, 0xabcd)
    }
    
    func testPerformAbsoluteJump() {
        let ifetch = IF()
        ifetch.load = {(addr: UInt16) in
            return addr
        }
        ifetch.alu.a = 0x1000
        ifetch.prevPC = 0x1000
        let input = IF.Input(stall: 0, y: 0x2000, jabs: 0, j: 0, rst: 1)
        let output = ifetch.step(input: input)
        
        // Jump target is set to the specified absolute address.
        XCTAssertEqual(output.pc, 0x2000)
        
        // We must issue a NOP in order to flush the IF stage of the pipeline when a jump occurs.
        XCTAssertEqual(output.ins, 0)
    }
    
    func testPerformRelativeJump() {
        let ifetch = IF()
        ifetch.load = {(addr: UInt16) in
            return addr
        }
        ifetch.alu.a = 0x1000
        ifetch.prevPC = 0x1000
        let input = IF.Input(stall: 0, y: 0x2000, jabs: 1, j: 0, rst: 1)
        let output = ifetch.step(input: input)
        
        // Jump target is an offset from the current PC.
        XCTAssertEqual(output.pc, 0x3000)
        
        // We must issue a NOP in order to flush the IF stage of the pipeline when a jump occurs.
        XCTAssertEqual(output.ins, 0)
    }
    
    func testStallTheProgramCounterToPreventIfFromUpdating() {
        let ifetch = IF()
        ifetch.alu.a = 0x1000
        ifetch.prevPC = 0x1000
        ifetch.prevIns = 0xffff
        let output = ifetch.step(input: IF.Input(stall: 1, y: 0, jabs: 1, j: 1, rst: 1))
        XCTAssertEqual(output.pc, 0x1000)
        XCTAssertEqual(output.ins, 0xffff) // Fetch the next instruction. In this case, it returns a bogus value of 0xffff.
    }
    
    func testFetchTheNextInstructionFromMemory() {
        let ifetch = IF()
        ifetch.load = {(addr: UInt16) in
            return addr
        }
        let input = IF.Input(stall: 0, y: 0, jabs: 1, j: 1, rst: 1)
        let output = ifetch.step(input: input)
        XCTAssertEqual(output.pc, 1)
        XCTAssertEqual(output.ins, 0)
    }
}
