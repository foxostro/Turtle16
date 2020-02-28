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
        // TODO: Is it a problem to allocate a state object every tick?
        let prevState = cpuState.copy() as! CPUStateSnapshot
        
        if shouldRecordStatesOverTime && recordedStatesOverTime.isEmpty {
            recordedStatesOverTime.append(prevState)
        }
        
        let pc = prevState.if_id.pc
        
        // If the program counter has come to the start of the trace again then
        // the loop has closed and recording should stop.
        if let traceRecorder = traceRecorder {
            if traceRecorder.trace.pc! == pc {
                let trace = traceRecorder.trace
                trace.appendGuard(pc: pc, fail: true)
                traceCache[pc.value] = trace
                self.traceRecorder = nil
                if let logger = logger {
                    logger.append("Finished recording trace for pc=\(trace.pc!):")
                    for line in trace.description.components(separatedBy: "\n") {
                        logger.append(line)
                    }
                    logger.append("===")
                }
            }
        }
        
        if let trace = traceCache[pc.value] {
            // If we have a trace for this instruction then retrieve and execute it.
            assert(traceRecorder == nil)
            if allowsRunningTraces {
                logger?.append("Running trace for pc=\(pc)...")
                runTrace(trace)
                logger?.append("...Finished running trace for pc=\(pc).")
            } else {
                doStep(prevState)
            }
        } else if profiler.isHot(pc: pc.value) {
            // Else, if the instruction is hot then begin recording.
            assert(traceRecorder == nil)
            traceRecorder = TraceRecorder()
            logger?.append("Beginning trace recording for for pc=\(pc)")
            doStep(prevState)
        } else {
            // Else, emulate a single clock tick.
            doStep(prevState)
        }
        
        logStateChanges(prevState)
        logger?.append("-----")
    }
    
    fileprivate func runTrace(_ trace: Trace) {
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
    
    fileprivate func doStep(_ prevState: CPUStateSnapshot) {
        interpreter.step()
        profile(prevState)
        record(prevState)
        if shouldRecordStatesOverTime {
            recordedStatesOverTime.append(cpuState)
        }
        numberOfStepsExecuted += 1
    }
    
    fileprivate func profile(_ prevState: CPUStateSnapshot) {
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
    
    fileprivate func record(_ prevState: CPUStateSnapshot) {
        // Update the trace if we're recording one now.
        if let traceRecorder = traceRecorder {
            logger?.append("recording: \(prevState.if_id)")
            traceRecorder.record(instruction: prevState.if_id,
                                 stateBefore: prevState)
        }
    }
    
    fileprivate func logStateChanges(_ prevState: CPUStateSnapshot) {
        if let logger = logger {
            CPUStateSnapshot.logChanges(logger: logger,
                                        prevState: prevState,
                                        nextState: cpuState)
        }
    }
}
