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
    
    public func record(instruction: Instruction, stateBefore: CPUStateSnapshot) {
        let pc = instruction.pc
        let flags = stateBefore.flags
        let address = UInt16(stateBefore.valueOfXYPair())
        if isUnconditionalJump(instruction) {
            trace.appendGuard(pc: pc, address: address)
        } else if isConditionalJump(instruction) {
            trace.appendGuard(pc: pc, flags: flags, address: address)
        } else {
            trace.append(instruction: instruction)
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
