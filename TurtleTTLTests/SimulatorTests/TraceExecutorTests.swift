//
//  TraceExecutorTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 2/24/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class TraceExecutorTests: XCTestCase {
    let isVerboseLogging = false
    
    fileprivate func makeLogger() -> Logger {
        return isVerboseLogging ? ConsoleLogger() : NullLogger()
    }
    
    func testRunEmptyTrace() {
        let state = CPUStateSnapshot()
        let prevState = state.copy() as! CPUStateSnapshot
        let trace = Trace()
        let executor = TraceExecutor(trace: trace, cpuState: state)
        let logger: Logger = makeLogger()
        executor.logger = logger
        executor.run()
        if state != prevState {
            CPUStateSnapshot.logChanges(logger: logger, prevState: state, nextState: prevState)
        }
        XCTAssertEqual(state, prevState)
    }
    
    func testRunTraceWithOnlyFailGuard() {
        let state = CPUStateSnapshot()
        let trace = Trace()
        trace.appendGuard(pc: ProgramCounter(withValue: 0x0100), fail: true)
        let executor = TraceExecutor(trace: trace, cpuState: state)
        executor.logger = makeLogger()
        executor.run()
        XCTAssertEqual(state.pc, trace.pc!)
    }
    
    func testRunTraceWhichRetiresNopsAndsRunsOffTheBottom() {
        // If the executor runs out of instructions in the trace then it will
        // leave the CPU in a state where continued interpretation would
        // immediately begin executing the instruction which follows the final
        // instruction in the trace.
        let state = CPUStateSnapshot()
        let trace = Trace()
        trace.append(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 0)))
        trace.append(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 1)))
        trace.append(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 2)))
        let executor = TraceExecutor(trace: trace, cpuState: state)
        executor.logger = makeLogger()
        executor.run()
        XCTAssertEqual(state.pc.value, 3)
    }
    
    func testRunTraceWhichRetiresNopsAndsPassesTheFailGuard() {
        // If the executor runs out of instructions in the trace then it will
        // leave the CPU in a state where continued interpretation would
        // immediately begin executing the instruction which follows the final
        // instruction in the trace.
        let state = CPUStateSnapshot()
        let trace = Trace()
        trace.append(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 0)))
        trace.appendGuard(pc: ProgramCounter(withValue: 1), fail: false)
        trace.append(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 2)))
        let executor = TraceExecutor(trace: trace, cpuState: state)
        executor.logger = makeLogger()
        executor.run()
        XCTAssertEqual(state.pc.value, 3)
    }
    
    func testRunTraceWhichRetiresNopsAndsFailsTheFailGuard() {
        let state = CPUStateSnapshot()
        let trace = Trace()
        trace.append(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 0)))
        trace.appendGuard(pc: ProgramCounter(withValue: 1), fail: true)
        trace.append(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 2)))
        let executor = TraceExecutor(trace: trace, cpuState: state)
        executor.logger = makeLogger()
        executor.run()
        XCTAssertEqual(state.pc.value, 1)
    }
    
    func testRunTraceWhichPassesTheAddressGuard() {
        let state = CPUStateSnapshot()
        let trace = Trace()
        trace.append(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 0)))
        trace.appendGuard(pc: ProgramCounter(withValue: 1), address: 0)
        trace.appendGuard(pc: ProgramCounter(withValue: 2), fail: true)
        let executor = TraceExecutor(trace: trace, cpuState: state)
        executor.logger = makeLogger()
        executor.run()
        XCTAssertEqual(state.pc.value, 2)
    }
    
    func testRunTraceWhichFailsTheAddressGuard() {
        let state = CPUStateSnapshot()
        let trace = Trace()
        trace.append(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 0)))
        trace.appendGuard(pc: ProgramCounter(withValue: 1), address: 0xffff)
        trace.appendGuard(pc: ProgramCounter(withValue: 2), fail: true)
        let executor = TraceExecutor(trace: trace, cpuState: state)
        executor.logger = makeLogger()
        executor.run()
        XCTAssertEqual(state.pc.value, 1)
    }
    
    func testRunTraceWhichPassesTheFlagsGuard() {
        let state = CPUStateSnapshot()
        let trace = Trace()
        trace.append(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 0)))
        trace.appendGuard(pc: ProgramCounter(withValue: 1), flags: Flags(), address: 0)
        trace.appendGuard(pc: ProgramCounter(withValue: 2), fail: true)
        let executor = TraceExecutor(trace: trace, cpuState: state)
        executor.logger = makeLogger()
        executor.run()
        XCTAssertEqual(state.pc.value, 2)
    }
    
    func testRunTraceWhichFailsTheFlagsGuard() {
        let state = CPUStateSnapshot()
        let trace = Trace()
        trace.append(instruction: Instruction.makeNOP(pc: ProgramCounter(withValue: 0)))
        trace.appendGuard(pc: ProgramCounter(withValue: 1), flags: Flags(1, 1), address: 0)
        trace.appendGuard(pc: ProgramCounter(withValue: 2), fail: true)
        let executor = TraceExecutor(trace: trace, cpuState: state)
        executor.logger = makeLogger()
        executor.run()
        XCTAssertEqual(state.pc.value, 1)
    }
    
    func testRunTraceWhichActuallyModifiesState_NoGuards() {
        let instructions = TraceUtils.assemble("""
LI A, 0xff
""")
        let state = CPUStateSnapshot()
        let trace = Trace()
        var pc = ProgramCounter()
        for ins in instructions {
            trace.append(instruction: ins.withProgramCounter(pc))
            pc = pc.increment()
        }
        let executor = TraceExecutor(trace: trace, cpuState: state)
        executor.logger = makeLogger()
        executor.run()
        XCTAssertEqual(state.pc.value, 2)
        XCTAssertEqual(state.registerA.value, 0xff)
    }
    
    func testRunTraceModifiesStateAndFailsTheAddressGuard() {
        let trace = TraceUtils.recordTraceForProgram("""
loop:
LI B, 1
ADD A
CMP
LXY loop
JE
""")
        let cpuState = CPUStateSnapshot()
        cpuState.registerA = Register(withValue: 2)
        
        let executor = TraceExecutor(trace: trace, cpuState: cpuState)
        executor.logger = makeLogger()
        executor.run()
        
        // We expect execution of the trace to fail the guard at 0x0005, which
        // was recorded in place of the conditional jump, "JE".
        XCTAssertEqual(cpuState.pc.value, 0x0005)
    }
    
    func testRunTraceWhichAccessesRAM() {
        let trace = TraceUtils.recordTraceForProgram("""
loop:
LI B, 1
LI U, 0
LI V, 0
MOV A, M
ADD A
MOV M, A
CMP
LXY loop
JE
""")
        let cpuState = CPUStateSnapshot()
        let dataRAM = RAM()
        
        let executor = TraceExecutor(trace: trace,
                                     cpuState: cpuState,
                                     peripherals: ComputerPeripherals(),
                                     dataRAM: dataRAM)
        executor.logger = makeLogger()
        
        // The trace will fail the flags guard because the value of A retrieved
        // from memory address 0x0000 will be different than that observed
        // during the original recording of the trace.
        dataRAM.store(value: 2, to: 0x0000)
        
        executor.run()
        
        // We expect execution of the trace to fail the guard at 0x0009, which
        // was recorded in place of the conditional jump, "JE".
        XCTAssertEqual(cpuState.pc.value, 0x0009)
    }
}
