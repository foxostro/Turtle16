//
//  TracingJitVM.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/26/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

public class TracingJitVM: InterpretingVM {
    public let profiler = TraceProfiler()
    public var traceCache : [UInt16:Trace] = [:]
    var traceRecorder: TraceRecorder? = nil
    
    public override func step() {
        // TODO: Is it a problem to allocate a state object every tick?
        let prevState = cpuState.copy() as! CPUStateSnapshot
        maybeStartOrStopRecording(prevState)
        interpreter.step()
        logStateChanges(prevState)
        profile(prevState)
        record(prevState)
        logger?.append("-----")
    }
    
    fileprivate func maybeStartOrStopRecording(_ prevState: CPUStateSnapshot) {
        let pc = prevState.if_id.pc
        
        // If the program counter has come to the start of the trace again then
        // the loop has closed and recording should stop.
        if let traceRecorder = traceRecorder {
            if traceRecorder.trace.pc! == pc {
                let trace = traceRecorder.trace
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
        
        // If the instruction is hot and we do not have an existing trace then
        // begin recording.
        if profiler.isHot(pc: pc.value) && nil == traceCache[pc.value] {
            assert(traceRecorder == nil)
            traceRecorder = TraceRecorder()
            logger?.append("Beginning trace recording for for pc=\(pc)")
        }
    }
    
    fileprivate func logStateChanges(_ prevState: CPUStateSnapshot) {
        if let logger = logger {
            CPUStateSnapshot.logChanges(logger: logger,
                                        prevState: prevState,
                                        nextState: cpuState)
        }
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
}
