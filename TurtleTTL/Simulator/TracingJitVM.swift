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
    
    public override func step() {
        logger?.append("\(String(describing: type(of: self))): step")
        let prevState = super.singleStep()
        recordBackwardsJumps(prevState)
    }
    
    fileprivate func recordBackwardsJumps(_ prevState: CPUStateSnapshot) {
        // Record backwards jumps.
        let oldPC = prevState.pc.value
        let newPC = cpuState.pc.value
        if newPC < oldPC {
            let hasBecomeHot = profiler.hit(pc: newPC)
            if hasBecomeHot {
                logger?.append("\(String(describing: type(of: self))): Jump destination \(cpuState.pc) has become hot.")
            }
        }
    }
}
