//
//  Patcher.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 8/29/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCore

// Rewrites instructions, replacing placeholder immediate values with final
// values determined from the symbol table.
public class Patcher: NSObject {
    let resolve: (SourceAnchor?, String) throws -> Int
    let inputInstructions: [Instruction]
    let base: Int
    
    // For some given instruction (given by index), specify a symbol through
    // which to determine the the new immediate value to use.
    public typealias Action = (index: Int, sourceAnchor: SourceAnchor?, symbol: String, shift: Int)
    let actions: [Action]
    
    public required init(inputInstructions: [Instruction],
                         resolver: @escaping (SourceAnchor?, String) throws -> Int,
                         actions: [Action],
                         base: Int) {
        self.inputInstructions = inputInstructions
        self.resolve = resolver
        self.actions = actions
        self.base = base
    }
    
    public func patch() throws -> [Instruction] {
        var instructions = inputInstructions
        for action in actions {
            let oldInstruction = instructions[action.index]
            let symbolValue = try resolve(action.sourceAnchor, action.symbol) + base
            let immediate: UInt8 = UInt8((symbolValue >> action.shift) & 0xff)
            let newInstruction = Instruction(opcode: oldInstruction.opcode,
                                             immediate: immediate)
            instructions[action.index] = newInstruction
        }
        return instructions
    }
}
