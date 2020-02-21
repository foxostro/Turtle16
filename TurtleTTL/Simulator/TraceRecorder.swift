//
//  TraceRecorder.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class TraceRecorder: NSObject {
    public let trace = Trace()
    
    public func record(pc: UInt16,
                       instruction: Instruction,
                       stateBefore: CPUStateSnapshot,
                       stateAfter: CPUStateSnapshot) {
        trace.append(pc: pc, instruction: instruction)
    }
}
