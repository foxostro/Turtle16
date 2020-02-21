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
    
    public func record(pc: UInt16, instruction: Instruction) {
        if instruction.disassembly == "HLT" {
            state = .abandoned
        } else {
            trace.append(pc: pc, instruction: instruction)
        }
    }
}
