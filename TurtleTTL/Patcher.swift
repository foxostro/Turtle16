//
//  Patcher.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/29/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Rewrites instructions, replacing placeholder immediate values with final
// values determined from the symbol table.
public class Patcher: NSObject {
    let inputInstructions: [Instruction]
    let symbols: SymbolTable
    
    // For some given instruction (given by index), specify a symbol through
    // which to determine the the new immediate value to use.
    public typealias Action = (index: Int, symbol: String, shift: Int)
    let actions: [Action]
    
    public required init(inputInstructions: [Instruction],
                         symbols: SymbolTable,
                         actions: [Action]) {
        self.inputInstructions = inputInstructions
        self.symbols = symbols
        self.actions = actions
    }
    
    public func patch() throws -> [Instruction] {
        var instructions = inputInstructions
        for action in actions {
            let oldInstruction = instructions[action.index]
            let symbolValue = try resolveSymbol(name: action.symbol)
            let immediate: UInt8 = UInt8((symbolValue >> action.shift) & 0xff)
            let newInstruction = Instruction(opcode: oldInstruction.opcode,
                                             immediate: immediate)
            instructions[action.index] = newInstruction
        }
        return instructions
    }
    
    func resolveSymbol(name: String) throws -> Int {
        if let value = symbols[name] {
            return value
        }
        throw AssemblerError(format: "unresolved symbol: `%@'", name)
    }
}
