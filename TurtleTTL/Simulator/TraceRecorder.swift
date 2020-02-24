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
    
    public func record(instruction: Instruction,
                       stateBefore: CPUStateSnapshot,
                       stateAfter: CPUStateSnapshot) {
        let pc = instruction.pc
        if isUnconditionalJump(instruction) {
            trace.appendGuard(pc: pc, address: Trace.Address(stateAfter.valueOfXYPair()))
        } else if isConditionalJump(instruction) {
            trace.appendGuard(pc: pc, flags: stateBefore.flags)
            trace.appendGuard(pc: pc, address: Trace.Address(stateAfter.valueOfXYPair()))
        } else {
            trace.append(pc: pc, instruction: instruction)
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
