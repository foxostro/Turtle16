//
//  Linker.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/29/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class Linker: NSObject {
    let inputInstructions: [Instruction]
    let symbols: SymbolTable
    
    // For some given instruction (given by index), specify a symbol through
    // which to determine the the new immediate value to use.
    public typealias Action = (index: Int, symbol: String)
    let actions: [Action]
    
    public required init(inputInstructions: [Instruction],
                         symbols: SymbolTable,
                         actions: [Action]) {
        self.inputInstructions = inputInstructions
        self.symbols = symbols
        self.actions = actions
    }
    
    public func link() throws -> [Instruction] {
        var instructions = inputInstructions
        for action in actions {
            let oldInstruction = instructions[action.index]
            let newInstruction = Instruction(opcode: Int(oldInstruction.opcode),
                                             immediate: try resolve(symbol: action.symbol))
            instructions[action.index] = newInstruction
        }
        return instructions
    }
    
    func resolve(symbol: String) throws -> Int {
        if let value = symbols[symbol] {
            return value
        } else {
            throw AssemblerError(format: "unresolved symbol: `%@'", symbol)
        }
    }
    
//    let codeGenerator: CodeGenerator
//
//    // Maps from the symbol name to the symbol value.
//    public private(set) var symbols: [String:Int] = [:]
//
//    // Maps from the index of the instruction to the name of the unresolved
//    // symbol. The instruction must be rewritten to use the actual value for
//    // this symbol.
//    public private(set) var unresolvedSymbols: [Int:String] = [:]
//
//    public required init(codeGenerator: CodeGenerator) {
//        self.codeGenerator = codeGenerator
//    }
//
//    public func compile(_ root: AbstractSyntaxTreeNode) throws -> [Instruction] {
//        codeGenerator.begin()
//        try root.iterate {
//            try $0.accept(visitor: self)
//        }
//        codeGenerator.end()
//        return link(inputInstructions: codeGenerator.instructions)
//    }
}
