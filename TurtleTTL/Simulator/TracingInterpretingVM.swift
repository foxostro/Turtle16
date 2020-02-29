//
//  TracingInterpretingVM.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/26/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

public class TracingInterpretingVM: VirtualMachine {
    public let profiler = TraceProfiler()
    public var traceCache : [UInt16:Trace] = [:]
    public var allowsRunningTraces = true
    public var shouldRecordStatesOverTime = false
    public var recordedStatesOverTime: [CPUStateSnapshot] = []
    public var numberOfStepsExecuted = 0
    var traceRecorder: TraceRecorder? = nil
    var prevState = CPUStateSnapshot()
    let interpreter: Interpreter
    
    public override init(cpuState: CPUStateSnapshot,
                         instructionDecoder: InstructionDecoder,
                         peripherals: ComputerPeripherals,
                         dataRAM: Memory,
                         instructionMemory: InstructionMemory) {
        interpreter = Interpreter(cpuState: cpuState,
                                  peripherals: peripherals,
                                  dataRAM: dataRAM,
                                  instructionDecoder: instructionDecoder)
        super.init(cpuState: cpuState,
                   instructionDecoder: instructionDecoder,
                   peripherals: peripherals,
                   dataRAM: dataRAM,
                   instructionMemory: instructionMemory)
        interpreter.delegate = self
    }
    
    public override func step() {
        prevState = cpuState.copy() as! CPUStateSnapshot // TODO: Is it a problem to allocate a state object every tick?
        maybeAddInitialRecordedState()
        
        let pc = prevState.if_id.pc
        maybeStopTraceRecording(pc)
        
        if traceRecorder == nil, let trace = traceCache[pc.value] {
            // If we have a trace for this PC then execute it.
            runTrace(trace)
        } else if traceRecorder == nil && profiler.isHot(pc: pc.value) {
            // Else, if the instruction is hot, and we're not already recording,
            // then begin recording now.
            beginRecordingAndStep(pc)
        } else {
            // Else, emulate a single clock tick.
            doStep()
        }
        
        logStateChanges()
        logger?.append("-----")
    }
    
    fileprivate func maybeAddInitialRecordedState() {
        if shouldRecordStatesOverTime && recordedStatesOverTime.isEmpty {
            recordedStatesOverTime.append(prevState)
        }
    }
    
    fileprivate func maybeStopTraceRecording(_ pc: ProgramCounter) {
        guard let traceRecorder = traceRecorder else { return }
        
        if traceRecorder.trace.pc! == pc {
            // If the program counter has come to the start of the trace again then
            // the loop has closed and recording should stop.
            let trace = traceRecorder.trace
            assert(traceCache[pc.value] == nil)
            traceCache[trace.pc!.value] = trace
            self.traceRecorder = nil
            logger?.append("Finished recording trace at pc=\(trace.pc!) because the loop has closed.")
            logTrace(trace)
//        } else if let existingTrace = traceCache[pc.value] {
//            // If the program counter is aready associated with another trace
//            // then stop recording. The VM will continue on to execute this
//            // trace next.
//            let trace = traceRecorder.trace
//            trace.appendGuard(pc: pc, fail: true)
//            trace.append(instruction: Instruction.makeNOP(pc: pc))
//            trace.append(instruction: Instruction.makeNOP(pc: pc))
//            assert(traceCache[trace.pc!.value] == nil)
//            traceCache[trace.pc!.value] = trace
//            self.traceRecorder = nil
//            logger?.append("Finished recording trace at pc=\(trace.pc!) because it connects to an existing trace at pc=\(existingTrace.pc!).")
//            logTrace(trace)
        }
    }
    
    fileprivate func logTrace(_ trace: Trace) {
        guard let logger = logger else { return }
        logger.append("Listing trace at pc=\(trace.pc!):")
        for line in trace.description.components(separatedBy: "\n") {
            logger.append(line)
        }
        logger.append("===")
    }
    
    fileprivate func runTrace(_ trace: Trace) {
        assert(traceRecorder == nil)
        let pc = trace.pc!
        if allowsRunningTraces {
            logger?.append("Running trace for pc=\(pc)...")
            actuallyRunTrace(trace)
            logger?.append("...Finished running trace for pc=\(pc).")
        } else {
            doStep()
        }
    }
    
    fileprivate func actuallyRunTrace(_ trace: Trace) {
        let executor = TraceExecutor(trace: trace,
                                     cpuState: cpuState,
                                     peripherals: peripherals,
                                     dataRAM: dataRAM,
                                     instructionDecoder: instructionDecoder)
        executor.logger = logger
        executor.delegate = self
        executor.shouldRecordStatesOverTime = shouldRecordStatesOverTime
        executor.run()
        if shouldRecordStatesOverTime {
            recordedStatesOverTime += executor.recordedStatesOverTime
        }
        
        // Flush the pipeline so we immediately begin executing the continuing
        // instruction after the trace.
        let pc = cpuState.pc
        cpuState.if_id = fetchInstruction(from: pc)
        cpuState.pc = pc.increment().increment()
        cpuState.pc_if = pc.increment()
    }
    
    fileprivate func beginRecordingAndStep(_ pc: ProgramCounter) {
        logger?.append("Beginning trace recording for pc=\(pc)")
        assert(traceRecorder == nil)
        traceRecorder = TraceRecorder()
        doStep()
    }
    
    fileprivate func doStep() {
        interpreter.step()
        profile()
        record()
        maybeAddAnotherRecordedState()
        numberOfStepsExecuted += 1
    }
    
    fileprivate func maybeAddAnotherRecordedState() {
        if shouldRecordStatesOverTime {
            recordedStatesOverTime.append(cpuState)
        }
    }
    
    fileprivate func profile() {
        // Record backwards jumps.
        let oldPC = prevState.pc.value
        let newPC = cpuState.pc.value
        if newPC < oldPC {
            let hasBecomeHot = profiler.hit(pc: newPC)
            if hasBecomeHot {
                logger?.append("Jump destination \(cpuState.pc) has become hot.")
            }
        }
    }
    
    fileprivate func record() {
        // Update the trace if we're recording one now.
        if let traceRecorder = traceRecorder {
            logger?.append("recording: \(prevState.if_id)")
            traceRecorder.record(instruction: prevState.if_id,
                                 stateBefore: prevState)
        }
    }
    
    fileprivate func logStateChanges() {
        if let logger = logger {
            CPUStateSnapshot.logChanges(logger: logger,
                                        prevState: prevState,
                                        nextState: cpuState)
        }
    }
}
