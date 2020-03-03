//
//  TracingInterpretingVMTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 2/26/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class TracingInterpretingVMTests: XCTestCase {
    var microcodeGenerator: MicrocodeGenerator!
    
    override func setUp() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
    }
    
    let isVerboseLogging = false
    
    fileprivate func makeLogger() -> Logger {
        return isVerboseLogging ? ConsoleLogger() : NullLogger()
    }
    
    fileprivate func makeVM(program: String) -> TracingInterpretingVM {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let vm = TracingInterpretingVM(cpuState: CPUStateSnapshot(),
                                       microcodeGenerator: microcodeGenerator,
                                       peripherals: ComputerPeripherals(),
                                       dataRAM: Memory(),
                                       instructionMemory: VirtualMachineUtils.makeInstructionROM(program: program))
        vm.logger = makeLogger()
        return vm
    }
    
    fileprivate func runProgramViaStraightInterpretation(_ program: String) -> TracingInterpretingVM {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let interpretingVM = TracingInterpretingVM(cpuState: CPUStateSnapshot(),
                                                   microcodeGenerator: microcodeGenerator,
                                                   peripherals: ComputerPeripherals(),
                                                   dataRAM: Memory(),
                                                   instructionMemory: VirtualMachineUtils.makeInstructionROM(program: program))
        interpretingVM.logger = makeLogger()
        interpretingVM.allowsRunningTraces = false
        interpretingVM.shouldRecordStatesOverTime = true
        try! interpretingVM.runUntilHalted()
        return interpretingVM
    }
    
    func testExecuteProgram() {
        let vm = makeVM(program: "HLT")
        
        try! vm.runUntilHalted()
        
        XCTAssertEqual(vm.cpuState.pc.value, 4)
        XCTAssertEqual(vm.cpuState.controlWord.HLT, .active)
    }
    
    func testExecuteFromInstructionRAM() {
        let vm = makeVM(program: """
LI X, 0x80
LI Y, 0x00
JMP
NOP
NOP
""")
        vm.instructionMemory.store(value: 0x0100, to: 0x8000) // HLT
        try! vm.runUntilHalted()
        
        XCTAssertEqual(vm.cpuState.pc.value, 0x8003)
        XCTAssertEqual(vm.cpuState.controlWord.HLT, .active)
    }
    
    func testProfilerReportsInstructionIsNotHot() {
        let vm = makeVM(program: """
LI B, 1
ADD A
HLT
""")
        try! vm.runUntilHalted()
        
        XCTAssertFalse(vm.profiler.isHot(pc: 0x0001))
    }
    
    func testTracesAreRecordedForHotLoops() {
        let vm = makeVM(program: """
LXY loop
LI B, 1
loop:
ADD A
NOP
JNC
NOP
NOP
HLT
""")
        try! vm.runUntilHalted()
        
        XCTAssertTrue(vm.profiler.isHot(pc: 0x0004))
        XCTAssertTrue(vm.traceCache[0x0004] != nil)
        XCTAssertEqual(vm.traceCache[0x0004]!.description, """
0x0004: ADD A ; isBreakpoint=true
0x0005: NOP
0x0006: JNC ; guardAddress=0x0004 ; guardFlags={carryFlag: 1, equalFlag: 0}
0x0007: NOP
0x0008: NOP
""")
    }
        
    func testTracesAreRecordedForHotLoops_withNullLogger_toPlacateCodeCoverage() {
        let vm = makeVM(program: """
LXY loop
LI B, 1
loop:
ADD A
NOP
JNC
NOP
NOP
HLT
""")
        vm.logger = nil
        try! vm.runUntilHalted()
        
        XCTAssertTrue(vm.profiler.isHot(pc: 0x0004))
        XCTAssertTrue(vm.traceCache[0x0004] != nil)
        XCTAssertEqual(vm.traceCache[0x0004]!.description, """
0x0004: ADD A ; isBreakpoint=true
0x0005: NOP
0x0006: JNC ; guardAddress=0x0004 ; guardFlags={carryFlag: 1, equalFlag: 0}
0x0007: NOP
0x0008: NOP
""")
    }
    
    func testExecutionFollowsTheSameStateChangesAsRegularInterpretingVM() {
        let program = """
LXY loop
LI B, 1
loop:
ADD A
NOP
JNC
NOP
NOP
HLT
"""
        let interpretingVM = runProgramViaStraightInterpretation(program)
        
        let vm = makeVM(program: program)
        vm.allowsRunningTraces = true
        vm.shouldRecordStatesOverTime = true
        try! vm.runUntilHalted()
        
        // The number of calls to step() should be less when executing the
        // trace that was recorded for the hot loop.
        XCTAssertLessThan(vm.numberOfStepsExecuted, interpretingVM.numberOfStepsExecuted)
        
        // The state changes encountered while running the tracing-interpreting
        // should be exactly the same as when running the regular interpreting
        // VM. (This is not the case when the trace is compiled to native code
        // and executed that way.)
        XCTAssertTrue(VirtualMachineUtils.assertEquivalentStateProgressions(logger: vm.logger,
                                                                            expected: interpretingVM.recordedStatesOverTime,
                                                                            actual: vm.recordedStatesOverTime))
    }
    
    func testNestedLoopsGenerateMultipleTraces() {
        let program = """
LI V, 250 # outer loop counter
LI B, 1
outerLoop:
LI U, 250 # inner loop counter
innerLoop:
MOV A, U
ADD U
LXY innerLoop
JNC
NOP
NOP
MOV A, V
ADD V
LXY outerLoop
JNC
NOP
NOP
HLT
"""
        let interpretingVM = runProgramViaStraightInterpretation(program)
        
        let vm = makeVM(program: program)
        vm.allowsRunningTraces = true
        vm.shouldRecordStatesOverTime = true
        try! vm.runUntilHalted()
        
        // We expect one trace for the inner loop, and one for the outer loop.
        XCTAssertEqual(vm.traceCache.count, 2)
        
        // The number of calls to step() should be less when executing the
        // trace that was recorded for the hot loop.
        XCTAssertLessThan(vm.numberOfStepsExecuted, interpretingVM.numberOfStepsExecuted)
        
        // The state changes encountered while running the tracing-interpreting
        // should be exactly the same as when running the regular interpreting
        // VM. (This is not the case when the trace is compiled to native code
        // and executed that way.)
        XCTAssertTrue(VirtualMachineUtils.assertEquivalentStateProgressions(logger: vm.logger,
                                                                            expected: interpretingVM.recordedStatesOverTime,
                                                                            actual: vm.recordedStatesOverTime))
    }
}
