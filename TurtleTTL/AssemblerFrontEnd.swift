//
//  AssemblerFrontEnd.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/18/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerFrontEnd: NSObject {
    public struct AssemblerFrontEndError: Error {
        public let line: Int
        public let message: String
        
        public init(line: Int, format: String, _ args: CVarArg...) {
            self.line = line
            message = String(format:format, arguments:args)
        }
    }
    
    let backend: AssemblerBackEnd
    
    public override init() {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        backend = AssemblerBackEnd(codeGenerator: CodeGenerator(microcodeGenerator: microcodeGenerator))
    }
    
    public func compile(_ text: String) throws -> [Instruction] {
        let tokenizer = AssemblerTokenizer(withText: text)
        try tokenizer.tokenize()
        var tokens = tokenizer.tokens
        backend.begin()
        while tokens.count > 0 {
            try consumeLine(&tokens)
        }
        try backend.end()
        return backend.instructions
    }
    
    func consumeLine(_ tokens: inout [AssemblerTokenizer.Token]) throws {
        try consumeNOP(&tokens)
        try consumeHLT(&tokens)
        try consumeCMP(&tokens)
        
        // At this point, we expect the end of the line.
        if let token = tokens.first {
            if token.type == .newline {
                tokens.removeFirst()
            } else {
                throw unrecognizedInstructionError(token.lineNumber, instruction: token.string)
            }
        }
    }
    
    func consumeNOP(_ tokens: inout [AssemblerTokenizer.Token]) throws {
        try consumeZeroOperandInstruction(&tokens, instruction: "NOP") {
            backend.nop()
        }
    }
    
    func consumeHLT(_ tokens: inout [AssemblerTokenizer.Token]) throws {
        try consumeZeroOperandInstruction(&tokens, instruction: "HLT") {
            backend.hlt()
        }
    }
    
    func consumeCMP(_ tokens: inout [AssemblerTokenizer.Token]) throws {
        try consumeZeroOperandInstruction(&tokens, instruction: "CMP") {
            backend.cmp()
        }
    }
    
    func consumeZeroOperandInstruction(_ tokens: inout [AssemblerTokenizer.Token], instruction: String, closure: () -> Void) throws {
        guard tokens.count > 0 else { return }
        let token = tokens.first!
        guard token.type == .token && token.string.caseInsensitiveCompare(instruction) == .orderedSame else { return }
        tokens.removeFirst()
        if (tokens.count > 0 && tokens.first!.type != .newline) {
            throw zeroOperandsExpectedError(token.lineNumber, instruction)
        } else {
            closure()
        }
    }
    
    func zeroOperandsExpectedError(_ lineNumber: Int, _ instruction: String) -> AssemblerFrontEndError {
        return AssemblerFrontEndError(line: lineNumber,
                                      format: "instruction takes no operands: `%@'",
                                      instruction)
    }
    
    func unrecognizedInstructionError(_ lineNumber: Int, instruction: String) -> AssemblerFrontEndError {
        return AssemblerFrontEndError(line: lineNumber,
                                      format: "no such instruction: `%@'",
                                      instruction)
    }
}
