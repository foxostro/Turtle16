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
        trace.append(pc: ProgramCounter(withValue: 0), instruction: Instruction(opcode: 1, immediate: 1))
        XCTAssertEqual(trace.elements.count, 1)
        switch trace.elements.first! {
        case .instruction(let pc, let ins):
            XCTAssertEqual(pc.value, 0)
            XCTAssertEqual(ins, Instruction(opcode: 1, immediate: 1))
        default:
            XCTFail()
        }
    }
        
    func testAppendGuardConditionFlags() {
        let trace = Trace()
        trace.appendGuard(pc: ProgramCounter(withValue: 0), flags: Flags(1, 1))
        switch trace.elements.first! {
        case .guardFlags(let pc, let flags):
            XCTAssertEqual(pc.value, 0)
            XCTAssertEqual(flags, Flags(1, 1))
        default:
            XCTFail()
        }
    }
        
    func testAppendGuardConditionAddressRegister() {
        let trace = Trace()
        trace.appendGuard(pc: ProgramCounter(withValue: 0), address: 0xFFFF)
        switch trace.elements.first! {
        case .guardAddress(let pc, let address):
            XCTAssertEqual(pc.value, 0)
            XCTAssertEqual(address, 0xFFFF)
        default:
            XCTFail()
        }
    }
    
    func testLogTrace() {
        let trace = Trace()
        trace.append(pc: ProgramCounter(withValue: 0), instruction: makeNOP())
        trace.appendGuard(pc: ProgramCounter(withValue: 1), flags: Flags(1, 1))
        trace.appendGuard(pc: ProgramCounter(withValue: 1), address: 0xFFFF)
        XCTAssertEqual(trace.description, """
0x0000:\tNOP
guard:\tflags={carryFlag: 1, equalFlag: 1}, traceExitingPC=0x0001
guard:\taddress=0xffff, traceExitingPC=0x0001
""")
    }
    
    fileprivate func makeNOP() -> Instruction {
        return Instruction(opcode: 0, immediate: 0, disassembly: "NOP")
    }
}
