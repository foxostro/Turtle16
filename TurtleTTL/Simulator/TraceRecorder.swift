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
    public let microcodeGenerator: MicrocodeGenerator
    
    public init(microcodeGenerator: MicrocodeGenerator) {
        self.microcodeGenerator = microcodeGenerator
    }
    
    public func record(instruction: Instruction, stateBefore: ProcessorState) {
        let flags = stateBefore.flags
        let address = UInt16(stateBefore.valueOfXYPair())
        var instruction = instruction
        if trace.instructions.isEmpty {
            instruction = instruction.withBreakpoint(true)
        }
        if microcodeGenerator.isUnconditionalJump(instruction) {
            instruction = instruction.withGuard(address: address)
        } else if microcodeGenerator.isConditionalJump(instruction) {
            instruction = instruction.withGuard(address: address).withGuard(flags: flags)
        }
        trace.append(instruction)
    }
}
