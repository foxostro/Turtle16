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
    
    public func recordPrologue(pc: ProgramCounter) {
        recordPipelineFlush(pc: pc)
    }
    
    public func recordEpilogue(pc: ProgramCounter) {
        recordPipelineFlush(pc: pc)
        trace.appendGuard(pc: pc, fail: true)
    }
    
    fileprivate func recordPipelineFlush(pc: ProgramCounter) {
        // Record two NOPs to ensure the pipeline drains.
        trace.append(instruction: Instruction.makeNOP(pc: pc))
        trace.append(instruction: Instruction.makeNOP(pc: pc))
    }
    
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
