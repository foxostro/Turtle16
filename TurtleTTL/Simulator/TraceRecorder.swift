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
    public enum State {
        case recording
        case complete
        case abandoned
    }
    public private(set) var state: State = .recording
    
    public init(microcodeGenerator: MicrocodeGenerator) {
        self.microcodeGenerator = microcodeGenerator
    }
    
    public func record(instruction: Instruction,
                       stateBefore: CPUStateSnapshot,
                       stateAfter: CPUStateSnapshot) {
        if instruction.disassembly == "HLT" {
            state = .abandoned
        } else if instruction.disassembly == "JMP" {
            let xy: UInt16 = UInt16(stateAfter.registerX.integerValue<<8 | stateAfter.registerY.integerValue)
            trace.appendGuard(pc: stateBefore.pc.value, address: xy)
        } else {
            trace.append(pc: stateBefore.pc.value, instruction: instruction)
        }
    }
}
