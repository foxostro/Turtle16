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
        XCTAssertTrue(trace.instructions.isEmpty)
    }
    
    func testAppendInstruction() {
        let trace = Trace()
        trace.append(instruction: Instruction(opcode: 1, immediate: 1))
        XCTAssertEqual(trace.instructions.count, 1)
        let ins = trace.fetchInstruction(from: ProgramCounter())
        XCTAssertEqual(ins!.pc, ProgramCounter())
        XCTAssertEqual(ins, Instruction(opcode: 1, immediate: 1))
    }
        
    func testAppendGuardConditionFlags() {
        let trace = Trace()
        trace.appendGuard(instruction: Instruction.makeNOP(),
                          flags: Flags(1, 1),
                          address: 0xcafe)
        XCTAssertEqual(trace.instructions.count, 1)
        let ins = trace.fetchInstruction(from: ProgramCounter())
        XCTAssertEqual(ins!.pc.value, 0)
        XCTAssertEqual(ins!.guardFlags, Flags(1, 1))
        XCTAssertEqual(ins!.guardAddress, 0xcafe)
    }
        
    func testAppendGuardConditionAddressRegister() {
        let trace = Trace()
        trace.appendGuard(instruction: Instruction.makeNOP(),
                          address: 0xcafe)
        XCTAssertEqual(trace.instructions.count, 1)
        let ins = trace.fetchInstruction(from: ProgramCounter())
        XCTAssertEqual(ins!.pc.value, 0)
        XCTAssertEqual(ins!.guardAddress, 0xcafe)
    }
    
    func testLogTrace() {
        let trace = Trace()
        trace.append(instruction: Instruction.makeNOP())
        trace.appendGuard(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 1)), flags: Flags(1, 1), address: 0xFFFF)
        XCTAssertEqual(trace.description, """
0x0000: NOP
0x0001: NOP ; guardAddress=0xffff ; guardFlags={carryFlag: 1, equalFlag: 1}
""")
    }
        
    func testTraceRecordsInitialProgramCounter() {
        let trace = Trace()
        trace.append(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 0xffff)))
        XCTAssertEqual(trace.pc, ProgramCounter(withValue: 0xffff))
    }
        
    func testCopyIsTheSame() {
        let traceA = Trace()
        traceA.append(instruction: Instruction.makeNOP())
        traceA.appendGuard(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 1)), flags: Flags(1, 1), address: 0xFFFF)
        let traceB = traceA.copy() as! Trace
        XCTAssertEqual(traceA, traceB)
    }
        
    func testDifferentTracesAreNotEqual() {
        let traceA = Trace()
        traceA.append(instruction: Instruction.makeNOP())
        traceA.appendGuard(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 1)), flags: Flags(1, 1), address: 0xFFFF)
        let traceB = Trace()
        XCTAssertNotEqual(traceA, traceB)
        XCTAssertNotEqual([traceA], [traceB])
        XCTAssertNotEqual([traceA as NSObject], [1 as NSObject])
    }
}
