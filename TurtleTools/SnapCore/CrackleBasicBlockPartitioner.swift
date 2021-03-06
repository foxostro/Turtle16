//
//  CrackleBasicBlockPartitioner.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/27/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class CrackleBasicBlockPartitioner: NSObject {
    public var entireProgram = CrackleBasicBlock()
    public var allBasicBlocks: [CrackleBasicBlock] = []
    
    public func partition() {
        allBasicBlocks = []
        guard !entireProgram.instructions.isEmpty else {
            return
        }
        var basicBlock = CrackleBasicBlock()
        var instructions = entireProgram.instructions
        var mapSymbols = entireProgram.mapCrackleInstructionToSymbols
        var mapSources = entireProgram.mapCrackleInstructionToSource
        while !instructions.isEmpty {
            let ins = instructions.removeFirst()
            let symbols = mapSymbols.removeFirst()
            let sources = mapSources.removeFirst()
            
            if doesInstructionBeginABasicBlock(ins) {
                if !basicBlock.instructions.isEmpty {
                    allBasicBlocks.append(basicBlock)
                    basicBlock = CrackleBasicBlock()
                }
            }
            
            basicBlock.instructions.append(ins)
            basicBlock.mapCrackleInstructionToSymbols.append(symbols)
            basicBlock.mapCrackleInstructionToSource.append(sources)
            
            if doesInstructionEndABasicBlock(ins) {
                if !basicBlock.instructions.isEmpty {
                    allBasicBlocks.append(basicBlock)
                    basicBlock = CrackleBasicBlock()
                }
            }
        }
        allBasicBlocks.append(basicBlock)
    }
    
    fileprivate func doesInstructionBeginABasicBlock(_ instruction: CrackleInstruction) -> Bool {
        switch instruction {
        case .label:
            return true
            
        default:
            return false
        }
    }
    
    fileprivate func doesInstructionEndABasicBlock(_ instruction: CrackleInstruction) -> Bool {
        switch instruction {
        case .jmp, .jalr, .indirectJalr, .jz, .jnz, .leafRet, .ret, .hlt:
            return true
            
        default:
            return false
        }
    }
}
