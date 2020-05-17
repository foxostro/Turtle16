//
//  TraceExecutorTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 2/24/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL
import TurtleCore

class TraceExecutorTests: XCTestCase {
    let isVerboseLogging = false
    var microcodeGenerator: MicrocodeGenerator!
    
    override func setUp() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
    }
    
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
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 0x0100)).withGuard(fail: true))
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
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 0)))
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 1)))
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 2)))
        let executor = TraceExecutor(trace: trace, cpuState: state)
        executor.shouldRecordStatesOverTime = true
        executor.logger = makeLogger()
        executor.run()
        XCTAssertEqual(state.pc.value, 3)
        XCTAssertEqual(executor.recordedStatesOverTime.count, 3)
    }
    
    func testRunTraceWhichRetiresNopsAndsPassesTheFailGuard() {
        // If the executor runs out of instructions in the trace then it will
        // leave the CPU in a state where continued interpretation would
        // immediately begin executing the instruction which follows the final
        // instruction in the trace.
        let state = CPUStateSnapshot()
        let trace = Trace()
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 0)))
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 1)).withGuard(fail: false))
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 2)))
        let executor = TraceExecutor(trace: trace, cpuState: state)
        executor.logger = makeLogger()
        executor.run()
        XCTAssertEqual(state.pc.value, 3)
    }
    
    func testRunTraceWhichRetiresNopsAndsFailsTheFailGuard() {
        let state = CPUStateSnapshot()
        let trace = Trace()
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 0)))
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 1)).withGuard(fail: true))
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 2)))
        let executor = TraceExecutor(trace: trace, cpuState: state)
        executor.logger = makeLogger()
        executor.run()
        XCTAssertEqual(state.pc.value, 1)
    }
    
    func testRunTraceWhichPassesTheAddressGuard() {
        let state = CPUStateSnapshot()
        let trace = Trace()
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 0)))
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 1)).withGuard(address: 0))
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 2)).withGuard(fail: true))
        let executor = TraceExecutor(trace: trace, cpuState: state)
        executor.logger = makeLogger()
        executor.run()
        XCTAssertEqual(state.pc.value, 2)
    }
    
    func testRunTraceWhichFailsTheAddressGuard() {
        let state = CPUStateSnapshot()
        let trace = Trace()
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 0)))
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 1)).withGuard(address: 0xffff))
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 2)).withGuard(fail: true))
        let executor = TraceExecutor(trace: trace, cpuState: state)
        executor.logger = makeLogger()
        executor.run()
        XCTAssertEqual(state.pc.value, 1)
    }
    
    func testRunTraceWhichPassesTheFlagsGuard() {
        let state = CPUStateSnapshot()
        let trace = Trace()
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 0)))
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 1)).withGuard(address: 0).withGuard(flags: Flags(0, 0)))
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 2)).withGuard(fail: true))
        let executor = TraceExecutor(trace: trace, cpuState: state)
        executor.logger = makeLogger()
        executor.run()
        XCTAssertEqual(state.pc.value, 2)
    }
    
    func testRunTraceWhichFailsTheFlagsGuard() {
        let state = CPUStateSnapshot()
        let trace = Trace()
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 0)))
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 1)).withGuard(address: 0).withGuard(flags: Flags(1, 1)))
        trace.append(Instruction.makeNOP(pc: ProgramCounter(withValue: 2)).withGuard(fail: true))
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
            trace.append(ins.withProgramCounter(pc))
            pc = pc.increment()
        }
        let executor = TraceExecutor(trace: trace, cpuState: state)
        executor.logger = makeLogger()
        executor.run()
        XCTAssertEqual(state.pc.value, 2)
        XCTAssertEqual(state.registerA.value, 0xff)
    }
    
    func testRunTraceModifiesStateAndFailsTheAddressGuard() {
        let trace = TraceUtils.recordTraceForProgram(microcodeGenerator: microcodeGenerator, """
loop:
LI B, 1
ADD _
ADD A
CMP
CMP
LXY loop
JE
""")
        let cpuState = CPUStateSnapshot()
        cpuState.registerA = Register(withValue: 2)
        
        let executor = TraceExecutor(trace: trace, cpuState: cpuState)
        executor.logger = makeLogger()
        executor.run()
        
        // We expect execution of the trace to fail the guard at 0x0007, which
        // was recorded in place of the conditional jump, "JE".
        XCTAssertEqual(cpuState.pc.value, 0x0007)
    }
    
    func testRunTraceWhichAccessesRAM() {
        let trace = TraceUtils.recordTraceForProgram(microcodeGenerator: microcodeGenerator, """
loop:
LI B, 1
LI U, 0
LI V, 0
MOV A, M
ADD _
ADD A
MOV M, A
CMP
CMP
LXY loop
JE
""")
        let cpuState = CPUStateSnapshot()
        let dataRAM = Memory()
        
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
        
        // We expect execution of the trace to fail the guard at 0x000b, which
        // was recorded in place of the conditional jump, "JE".
        XCTAssertEqual(cpuState.pc.value, 0x000b)
    }
    
    func testRunThrowsExceptionIfTooManySteps() {
        let trace = TraceUtils.recordTraceForProgram(microcodeGenerator: microcodeGenerator, """
JMP
NOP
NOP
""")
        let executor = TraceExecutor(trace: trace, cpuState: CPUStateSnapshot())
        executor.logger = makeLogger()
        XCTAssertThrowsError(try executor.run(maxSteps: 10))
    }
    
    func testRunTraceAndStopAtTheBreakpoint() {
        let trace = TraceUtils.recordTraceForProgram(microcodeGenerator: microcodeGenerator, """
JMP
NOP
NOP
""")
        let executor = TraceExecutor(trace: trace, cpuState: CPUStateSnapshot())
        executor.logger = makeLogger()
        executor.flagBreak.value = true
        XCTAssertNoThrow(try executor.run(maxSteps: 10))
        XCTAssertEqual(executor.cpuState.pc.value, 0)
    }
}
