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
    let inputInstructions: [Instruction]
    let symbols: SymbolTable
    let base: Int
    
    // For some given instruction (given by index), specify a symbol through
    // which to determine the the new immediate value to use.
    public typealias Action = (index: Int, symbol: TokenIdentifier, shift: Int)
    let actions: [Action]
    
    public required init(inputInstructions: [Instruction],
                         symbols: SymbolTable,
                         actions: [Action],
                         base: Int) {
        self.inputInstructions = inputInstructions
        self.symbols = symbols
        self.actions = actions
        self.base = base
    }
    
    public func patch() throws -> [Instruction] {
        var instructions = inputInstructions
        for action in actions {
            let oldInstruction = instructions[action.index]
            let symbolValue = try resolve(identifier: action.symbol) + base
            let immediate: UInt8 = UInt8((symbolValue >> action.shift) & 0xff)
            let newInstruction = Instruction(opcode: oldInstruction.opcode,
                                             immediate: immediate)
            instructions[action.index] = newInstruction
        }
        return instructions
    }
    
    private func resolve(identifier: TokenIdentifier) throws -> Int {
        let symbol = try symbols.resolve(identifierToken: identifier)
        switch symbol {
        case .constantAddress(let address):
            return address.value
        case .constantWord(let word):
            return Int(word.value)
        case .staticWord(_):
            // TODO: Perhaps `MustBeCompileTimeConstantError' should be in some other namespace other than `Expression'.
            throw Expression.MustBeCompileTimeConstantError(line: identifier.lineNumber)
        }
    }
}
