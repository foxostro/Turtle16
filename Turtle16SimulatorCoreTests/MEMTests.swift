//
//  MEMTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 12/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class MEMTests: XCTestCase {
    func testRDYisHigh() {
        let mem = MEM()
        let input = MEM.Input(rdy: 1, y: 0xabab, storeOp: 0xcdcd, selC: 3, ctl: 0)
        let output = mem.step(input: input)
        XCTAssertEqual(output.y, input.y)
        XCTAssertEqual(output.storeOp, 0)
        XCTAssertEqual(output.selC, input.selC)
        XCTAssertEqual(output.ctl, input.ctl)
    }
    
    func testStore() {
        let mem = MEM()
        var storeValue: UInt16? = nil
        var storeAddress: UInt16? = nil
        mem.store = {(value: UInt16, addr: UInt16) in
            storeValue = value
            storeAddress = addr
        }
        let ctl = ~UInt((1<<15) | (1<<16))
        let input = MEM.Input(rdy: 0, y: 0xabab, storeOp: 0xcdcd, selC: 3, ctl: ctl)
        let output = mem.step(input: input)
        XCTAssertEqual(output.y, input.y)
        XCTAssertEqual(output.storeOp, input.storeOp)
        XCTAssertEqual(output.selC, input.selC)
        XCTAssertEqual(output.ctl, input.ctl)
        XCTAssertEqual(storeValue, 0xcdcd)
        XCTAssertEqual(storeAddress, 0xabab)
    }
    
    func testLoad() {
        let mem = MEM()
        mem.load = {(addr: UInt16) in
            return ~addr
        }
        let ctl = ~UInt(1<<14)
        let input = MEM.Input(rdy: 0, y: 0xabab, storeOp: 0xcdcd, selC: 3, ctl: ctl)
        let output = mem.step(input: input)
        XCTAssertEqual(output.y, input.y)
        XCTAssertEqual(output.storeOp, ~0xabab)
        XCTAssertEqual(output.selC, input.selC)
        XCTAssertEqual(output.ctl, input.ctl)
    }
}
