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
        let flags = stateBefore.flags
        let address = UInt16(stateBefore.valueOfXYPair())
        if isUnconditionalJump(instruction) {
            trace.append(instruction.withGuard(address: address))
        } else if isConditionalJump(instruction) {
            trace.append(instruction.withGuard(address: address).withGuard(flags: flags))
        } else {
            trace.append(instruction)
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
