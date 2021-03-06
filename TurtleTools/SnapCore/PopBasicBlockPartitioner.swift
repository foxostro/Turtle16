//
//  PopBasicBlockPartitioner.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public typealias PopBasicBlock = Array<PopInstruction>

public class PopBasicBlockPartitioner: NSObject {
    public var entireProgram: [PopInstruction] = []
    public var allBasicBlocks: [PopBasicBlock] = []
    
    public func partition() {
        allBasicBlocks = []
        guard !entireProgram.isEmpty else {
            return
        }
        var basicBlock = PopBasicBlock()
        var instructions = entireProgram
        while !instructions.isEmpty {
            let ins = instructions.removeFirst()
            if doesInstructionBeginABasicBlock(ins) {
                if !basicBlock.isEmpty {
                    allBasicBlocks.append(basicBlock)
                    basicBlock = PopBasicBlock()
                }
            }
            
            basicBlock.append(ins)
            
            if doesInstructionEndABasicBlock(ins) {
                if !basicBlock.isEmpty {
                    allBasicBlocks.append(basicBlock)
                    basicBlock = PopBasicBlock()
                }
            }
        }
        allBasicBlocks.append(basicBlock)
    }
    
    fileprivate func doesInstructionBeginABasicBlock(_ instruction: PopInstruction) -> Bool {
        switch instruction {
        case .label:
            return true
            
        default:
            return false
        }
    }
    
    fileprivate func doesInstructionEndABasicBlock(_ instruction: PopInstruction) -> Bool {
        switch instruction {
        case .hlt, .jalr, .explicitJalr, .jmp, .explicitJmp, .jc, .jnc, .je, .jne, .jg, .jle, .jl, .jge:
            return true
            
        default:
            return false
        }
    }
}
