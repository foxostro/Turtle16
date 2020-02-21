//
//  TraceTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class TraceTests: XCTestCase {
    func testTraceIsInitiallyEmpty() {
        let trace = Trace()
        XCTAssertEqual(trace.elements.count, 0)
    }
    
    func testAppendInstruction() {
        let trace = Trace()
        trace.append(instruction: Instruction(opcode: 1, immediate: 1))
        XCTAssertEqual(trace.elements.count, 1)
        switch trace.elements.first! {
        case .instruction(let ins):
            XCTAssertEqual(ins, Instruction(opcode: 1, immediate: 1))
        default:
            XCTFail()
        }
    }
        
    func testAppendGuardConditionFlags() {
        let trace = Trace()
        trace.appendGuard(flags: Flags(1, 1))
        switch trace.elements.first! {
        case .guardFlags(let flags):
            XCTAssertEqual(flags, Flags(1, 1))
        default:
            XCTFail()
        }
    }
        
    func testAppendGuardConditionAddressRegister() {
        let trace = Trace()
        trace.appendGuard(address: 0xFFFF)
        switch trace.elements.first! {
        case .guardAddress(let address):
            XCTAssertEqual(address, 0xFFFF)
        default:
            XCTFail()
        }
    }
}
