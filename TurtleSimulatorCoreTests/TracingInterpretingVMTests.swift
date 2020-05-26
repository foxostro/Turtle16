//
//  TracingInterpretingVMTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 2/26/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleSimulatorCore
import TurtleCore

class TracingInterpretingVMTests: XCTestCase {
    var microcodeGenerator: MicrocodeGenerator!
    
    override func setUp() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
    }
    
    let isVerboseLogging = false
    
    private func makeLogger() -> Logger {
        return isVerboseLogging ? ConsoleLogger() : NullLogger()
    }
    
    private func makeVM(program: String) -> TracingInterpretingVM {
        let cpuState = CPUStateSnapshot()
        
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        
        let peripherals = ComputerPeripherals()
        let dataRAM = Memory()
        
        let upperInstructionRAM = Memory()
        let lowerInstructionRAM = Memory()
        let instructionMemory = InstructionMemoryRev1(instructionROM: InstructionROM(),
                                                      upperInstructionRAM: upperInstructionRAM,
                                                      lowerInstructionRAM: lowerInstructionRAM,
                                                      instructionFormatter: InstructionFormatter())
        instructionMemory.store(instructions: TraceUtils.assemble(program))
        
        let interpreter = Interpreter(cpuState: cpuState,
                                      peripherals: peripherals,
                                      dataRAM: dataRAM,
                                      instructionDecoder: microcodeGenerator.microcode)
        
        let vm = TracingInterpretingVM(cpuState: cpuState,
                                       microcodeGenerator: microcodeGenerator,
                                       peripherals: peripherals,
                                       dataRAM: dataRAM,
                                       instructionMemory: instructionMemory,
                                       flagBreak: AtomicBooleanFlag(),
                                       interpreter: interpreter)
        vm.logger = makeLogger()
        let storeUpperInstructionRAM = {(_ value: UInt8, _ address: Int) -> Void in
            upperInstructionRAM.store(value: value, to: address)
            vm.didModifyInstructionMemory()
        }
        let loadUpperInstructionRAM = {(_ address: Int) -> UInt8 in
             return upperInstructionRAM.load(from: address)
        }
        let storeLowerInstructionRAM = {(_ value: UInt8, _ address: Int) -> Void in
            lowerInstructionRAM.store(value: value, to: address)
            vm.didModifyInstructionMemory()
        }
        let loadLowerInstructionRAM = {(_ address: Int) -> UInt8 in
            return lowerInstructionRAM.load(from: address)
        }
        peripherals.populate(storeUpperInstructionRAM,
                             loadUpperInstructionRAM,
                             storeLowerInstructionRAM,
                             loadLowerInstructionRAM)
        return vm
    }
    
    private func runProgramViaStraightInterpretation(_ program: String) -> TracingInterpretingVM {
        let cpuState = CPUStateSnapshot()
        
        let dataRAM = Memory()
        
        let peripherals = ComputerPeripherals()
        
        let interpreter = Interpreter(cpuState: cpuState,
                                      peripherals: peripherals,
                                      dataRAM: dataRAM)
        
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        
        let interpretingVM = TracingInterpretingVM(cpuState: cpuState,
                                                   microcodeGenerator: microcodeGenerator,
                                                   peripherals: peripherals,
                                                   dataRAM: dataRAM,
                                                   instructionMemory: VirtualMachineUtils.makeInstructionROM(program: program),
                                                   flagBreak: AtomicBooleanFlag(),
                                                   interpreter: interpreter)
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
ADD _
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
ADD _
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
0x0004: ADD ; isBreakpoint=true
0x0005: ADD A
0x0006: NOP
0x0007: JNC ; guardAddress=0x0004 ; guardFlags={carryFlag: 1, equalFlag: 0}
0x0008: NOP
0x0009: NOP
""")
    }
        
    func testTracesAreRecordedForHotLoops_withNullLogger_toPlacateCodeCoverage() {
        let vm = makeVM(program: """
LXY loop
LI B, 1
loop:
ADD _
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
0x0004: ADD ; isBreakpoint=true
0x0005: ADD A
0x0006: NOP
0x0007: JNC ; guardAddress=0x0004 ; guardFlags={carryFlag: 1, equalFlag: 0}
0x0008: NOP
0x0009: NOP
""")
    }
    
    func testExecutionFollowsTheSameStateChangesAsRegularInterpretingVM() {
        let program = """
LXY loop
LI B, 1
loop:
ADD _
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
ADD _
ADD U
LXY innerLoop
JNC
NOP
NOP
MOV A, V
ADD _
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
    
    func testTraceCacheIsClearedAfterWritingToUpperInstructionMemory() {
        let vm = makeVM(program: """
LXY loop
LI B, 1
loop:
ADD _
ADD A
NOP
JNC
NOP
NOP
LI X, 0x80
LI Y, 0x00
LI D, 0
LI P, 0
HLT
""")
        try! vm.runUntilHalted()
        
        XCTAssertFalse(vm.profiler.isHot(pc: 0x0004))
        XCTAssertNil(vm.traceCache[0x0004])
    }
    
    func testTraceCacheIsClearedAfterWritingToLowerInstructionMemory() {
        let vm = makeVM(program: """
LXY loop
LI B, 1
loop:
ADD _
ADD A
NOP
JNC
NOP
NOP
LI X, 0x80
LI Y, 0x00
LI D, 1
LI P, 0
HLT
""")
        try! vm.runUntilHalted()
        
        XCTAssertFalse(vm.profiler.isHot(pc: 0x0004))
        XCTAssertNil(vm.traceCache[0x0004])
    }
        
    func testAbortTraceRecordingIfInstructionMemoryIsModified() {
        let program = """
LI X, 0x80
LI Y, 0x00
JMP
NOP
NOP
"""
        
        let userProgram = """
loop:
LI B, 1
ADD _
ADD A

LI U, 255

LI B, 4
CMP
CMP
LXY skip
JL
NOP
NOP

LI X, 0x00
LI Y, 0x04
LI D, 1
LI P, 42

skip:

LI B, 5
CMP
CMP
LXY loop
JL
NOP
NOP
HLT
"""
        
        let vm = makeVM(program: program)
        vm.instructionMemory.store(instructions: TraceUtils.assemble(program: userProgram, base: 0x8000), at: 0x8000)
        
        try! vm.runUntilHalted()
        
        XCTAssertEqual(vm.cpuState.registerU.value, 21) // Reverse the bits of 42 and get 21. This happens due to a hardware bug in Rev 2.
        XCTAssertFalse(vm.profiler.isHot(pc: 0x0001))
        XCTAssertNil(vm.traceCache[0x0001])
    }
}
