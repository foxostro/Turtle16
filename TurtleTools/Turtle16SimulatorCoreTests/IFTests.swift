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
    func testStallIFIsActive() {
        let ifetch = IF()
        let input = IF.Input(stallPC: 0, stallIF: 0, y: 0, jabs: 1, j: 1, rst: 1)
        let output = ifetch.step(input: input)
        XCTAssertEqual(output.pc, 1)
        XCTAssertEqual(output.ins, 0)
    }
    
    func testContinuesToIssueNopWhileStallIFIsActive() {
        let ifetch = IF()
        let input = IF.Input(stallPC: 0, stallIF: 0, y: 0, jabs: 1, j: 1, rst: 1)
        let output1 = ifetch.step(input: input)
        XCTAssertEqual(output1.pc, 1)
        XCTAssertEqual(output1.ins, 0)
        
        let output2 = ifetch.step(input: input)
        XCTAssertEqual(output2.pc, 2)
        XCTAssertEqual(output2.ins, 0)
        
        let output3 = ifetch.step(input: input)
        XCTAssertEqual(output3.pc, 3)
        XCTAssertEqual(output3.ins, 0)
    }
    
    func testProgramCounterRollsOverToZero() {
        let ifetch = IF()
        ifetch.load = {(addr: UInt16) in
            return addr + 0xabcd
        }
        ifetch.alu.a = 0xffff
        ifetch.prevOutput = 0xffff
        let input = IF.Input(stallPC: 0, stallIF: 1, y: 0, jabs: 1, j: 1, rst: 1)
        let output = ifetch.step(input: input)
        XCTAssertEqual(output.pc, 0)
        XCTAssertEqual(output.ins, 0xabcd)
    }
    
    func testProgramCounterResetsToZero() {
        let ifetch = IF()
        ifetch.load = {(addr: UInt16) in
            return addr + 0xabcd
        }
        ifetch.alu.a = 1
        let input = IF.Input(stallPC: 0, stallIF: 1, y: 0, jabs: 1, j: 1, rst: 0)
        let _ = ifetch.step(input: input)
        XCTAssertEqual(ifetch.alu.f, 0)
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
        ifetch.prevOutput = 0x1000
        let input = IF.Input(stallPC: 0, stallIF: 1, y: 0x2000, jabs: 0, j: 0, rst: 1)
        let output = ifetch.step(input: input)
        XCTAssertEqual(output.pc, 0x2000)
        XCTAssertEqual(output.ins, 0x2000)
    }
    
    func testPerformRelativeJump() {
        let ifetch = IF()
        ifetch.load = {(addr: UInt16) in
            return addr
        }
        ifetch.alu.a = 0x1000
        ifetch.prevOutput = 0x1000
        let input = IF.Input(stallPC: 0, stallIF: 1, y: 0x2000, jabs: 1, j: 0, rst: 1)
        let output = ifetch.step(input: input)
        XCTAssertEqual(output.pc, 0x3000)
        XCTAssertEqual(output.ins, 0x3000)
    }
    
    func testStallTheProgramCounterToPreventIfFromUpdating() {
        let ifetch = IF()
        ifetch.alu.a = 0x1000
        ifetch.prevOutput = 0x1000
        let output = ifetch.step(input: IF.Input(stallPC: 1, stallIF: 0, y: 0, jabs: 1, j: 1, rst: 1))
        XCTAssertEqual(output.pc, 0x1000)
        XCTAssertEqual(output.ins, 0)
    }
    
    func testFetchTheNextInstructionFromMemory() {
        let ifetch = IF()
        ifetch.load = {(addr: UInt16) in
            return addr
        }
        let input = IF.Input(stallPC: 0, stallIF: 1, y: 0, jabs: 1, j: 1, rst: 1)
        let output = ifetch.step(input: input)
        XCTAssertEqual(output.pc, 1)
        XCTAssertEqual(output.ins, 1)
    }
}
