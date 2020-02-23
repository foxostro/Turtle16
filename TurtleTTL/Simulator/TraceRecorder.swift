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
        if isUnconditionalJump(instruction) {
            trace.appendGuard(pc: stateBefore.pc.value, address: UInt16(stateAfter.valueOfXYPair()))
        } else if isConditionalJump(instruction) {
            trace.appendGuard(pc: stateBefore.pc.value, flags: stateBefore.flags)
            trace.appendGuard(pc: stateBefore.pc.value, address: UInt16(stateAfter.valueOfXYPair()))
        } else {
            trace.append(pc: stateBefore.pc.value, instruction: instruction)
        }
    }
    
    fileprivate func isUnconditionalJump(_ instruction: Instruction) -> Bool {
        return instruction.disassembly == "JMP"
    }
    
    fileprivate func isConditionalJump(_ instruction: Instruction) -> Bool {
        let disassembly = instruction.disassembly
        return disassembly == "JC"
            || disassembly == "JNC"
            || disassembly == "JE"
            || disassembly == "JNE"
            || disassembly == "JG"
            || disassembly == "JLE"
            || disassembly == "JL"
            || disassembly == "JGE"
    }
}
