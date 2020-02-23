//
//  TraceRecorder.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class TraceRecorder: NSObject {
    let microcodeGenerator: MicrocodeGenerator
    public let trace = Trace()
    
    public init(microcodeGenerator: MicrocodeGenerator) {
        self.microcodeGenerator = microcodeGenerator
    }
    
    public func record(instruction: Instruction,
                       stateBefore: CPUStateSnapshot,
                       stateAfter: CPUStateSnapshot) {
        if instruction.disassembly == "JMP" {
            trace.appendGuard(pc: stateBefore.pc.value, address: UInt16(stateAfter.valueOfXYPair()))
        } else {
            trace.append(pc: stateBefore.pc.value, instruction: instruction)
        }
    }
}
