//
//  TraceTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleSimulatorCore
import TurtleCore

class TraceTests: XCTestCase {
    func testTraceIsInitiallyEmpty() {
        let trace = Trace()
        XCTAssertTrue(trace.instructions.isEmpty)
    }
    
    func testAppendInstruction() {
        let trace = Trace()
        trace.append(Instruction(opcode: 1, immediate: 1))
        XCTAssertEqual(trace.instructions.count, 1)
        let ins = trace.fetchInstruction(from: ProgramCounter())
        XCTAssertEqual(ins!.pc, ProgramCounter())
        XCTAssertEqual(ins, Instruction(opcode: 1, immediate: 1))
    }
        
    func testAppendGuardUnconditionalFail() {
        let trace = Trace()
        trace.append(Instruction.makeNOP().withGuard(fail: true))
        XCTAssertEqual(trace.instructions.count, 1)
        let ins = trace.fetchInstruction(from: ProgramCounter())
        XCTAssertEqual(ins!.pc.value, 0)
        XCTAssertEqual(ins!.guardFail, true)
    }
        
    func testAppendGuardConditionFlags() {
        let trace = Trace()
        trace.append(Instruction.makeNOP().withGuard(flags: Flags(1, 1)).withGuard(address: 0xcafe))
        XCTAssertEqual(trace.instructions.count, 1)
        let ins = trace.fetchInstruction(from: ProgramCounter())
        XCTAssertEqual(ins!.pc.value, 0)
        XCTAssertEqual(ins!.guardFlags, Flags(1, 1))
        XCTAssertEqual(ins!.guardAddress, 0xcafe)
    }
        
    func testAppendGuardConditionAddressRegister() {
        let trace = Trace()
        trace.append(Instruction.makeNOP().withGuard(address: 0xcafe))
        XCTAssertEqual(trace.instructions.count, 1)
        let ins = trace.fetchInstruction(from: ProgramCounter())
        XCTAssertEqual(ins!.pc.value, 0)
        XCTAssertEqual(ins!.guardAddress, 0xcafe)
    }
        
    func testFetchInstructionFromEmptyTrace() {
        let trace = Trace()
        let ins = trace.fetchInstruction(from: ProgramCounter())
        XCTAssertEqual(ins, nil)
    }
        
    func testFetchInstructionFromInvalidPC() {
        let trace = Trace()
        trace.append(Instruction.makeNOP())
        let ins = trace.fetchInstruction(from: ProgramCounter(withValue: 0xffff))
        XCTAssertEqual(ins, nil)
    }
    
    func testLogTrace() {
        let trace = Trace()
        trace.append(Instruction.makeNOP())
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 1)).withGuard(flags: Flags(1, 1)).withGuard(address: 0xFFFF))
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 2)).withGuard(fail: true))
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 3)).withBreakpoint(true))
        XCTAssertEqual(trace.description, """
0x0000: NOP
0x0001: NOP ; guardAddress=0xffff ; guardFlags={carryFlag: 1, equalFlag: 1}
0x0002: NOP ; guardFail=true
0x0003: NOP ; isBreakpoint=true
""")
    }
        
    func testTraceRecordsInitialProgramCounter() {
        let trace = Trace()
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 0xffff)))
        XCTAssertEqual(trace.pc, ProgramCounter(withValue: 0xffff))
    }
        
    func testCopyIsTheSame() {
        let traceA = Trace()
        traceA.append(Instruction.makeNOP())
        traceA.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 1)).withGuard(address: 0xffff).withGuard(flags: Flags(1, 1)))
        let traceB = traceA.copy() as! Trace
        XCTAssertEqual(traceA, traceB)
    }
        
    func testDifferentTracesAreNotEqual() {
        let traceA = Trace()
        traceA.append(Instruction.makeNOP())
        traceA.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 1)).withGuard(address: 0xffff).withGuard(flags: Flags(1, 1)))
        let traceB = Trace()
        XCTAssertNotEqual(traceA, traceB)
        XCTAssertNotEqual([traceA], [traceB])
        XCTAssertNotEqual([traceA as NSObject], [1 as NSObject])
    }
}
