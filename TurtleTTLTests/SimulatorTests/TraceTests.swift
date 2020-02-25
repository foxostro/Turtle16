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
        XCTAssertEqual(trace.instructions.first?.pc.value, Optional(0))
        XCTAssertEqual(trace.instructions.first, Optional(Instruction(opcode: 1, immediate: 1)))
    }
        
    func testAppendGuardConditionFlags() {
        let trace = Trace()
        trace.appendGuard(pc: ProgramCounter(withValue: 0),
                          flags: Flags(1, 1),
                          address: 0xcafe)
        XCTAssertEqual(trace.instructions.count, 1)
        XCTAssertEqual(trace.instructions.first?.pc.value, Optional(0))
        XCTAssertEqual(trace.instructions.first?.guardFlags, Optional(Flags(1, 1)))
        XCTAssertEqual(trace.instructions.first?.guardAddress, Optional(0xcafe))
    }
        
    func testAppendGuardConditionAddressRegister() {
        let trace = Trace()
        trace.appendGuard(pc: ProgramCounter(withValue: 0),
                          address: 0xcafe)
        XCTAssertEqual(trace.instructions.count, 1)
        XCTAssertEqual(trace.instructions.first?.pc.value, Optional(0))
        XCTAssertEqual(trace.instructions.first?.guardAddress, Optional(0xcafe))
    }
    
    func testLogTrace() {
        let trace = Trace()
        trace.append(instruction: Instruction.makeNOP())
        trace.appendGuard(pc: ProgramCounter(withValue: 1), flags: Flags(1, 1), address: 0xFFFF)
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
        traceA.appendGuard(pc: ProgramCounter(withValue: 1), flags: Flags(1, 1), address: 0xFFFF)
        let traceB = traceA.copy() as! Trace
        XCTAssertEqual(traceA, traceB)
    }
        
    func testDifferentTracesAreNotEqual() {
        let traceA = Trace()
        traceA.append(instruction: Instruction.makeNOP())
        traceA.appendGuard(pc: ProgramCounter(withValue: 1), flags: Flags(1, 1), address: 0xFFFF)
        let traceB = Trace()
        XCTAssertNotEqual(traceA, traceB)
        XCTAssertNotEqual([traceA], [traceB])
        XCTAssertNotEqual([traceA as NSObject], [1 as NSObject])
    }
        
    func testTraceFinalPC() {
        let trace = Trace()
        trace.append(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 0x0100)))
        trace.append(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 0x0101)))
        XCTAssertEqual(trace.finalPC, ProgramCounter(withValue: 0x0101))
    }
}
