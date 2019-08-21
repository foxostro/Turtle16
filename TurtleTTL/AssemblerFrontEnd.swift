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
    typealias Token = AssemblerScanner.Token
    typealias TokenType = AssemblerScanner.TokenType
    var tokens: [Token] = []
    
    public override init() {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        backend = AssemblerBackEnd(codeGenerator: CodeGenerator(microcodeGenerator: microcodeGenerator))
    }
    
    public func compile(_ text: String) throws -> [Instruction] {
        let tokenizer = AssemblerScanner(withString: text)
        try tokenizer.scanTokens()
        tokens = tokenizer.tokens
        backend.begin()
        while tokens.count > 0 {
            try consumeInstruction()
        }
        try backend.end()
        return backend.instructions
    }
    
    func advance() {
        tokens.removeFirst()
    }
    
    func peek() -> Token? {
        return tokens.first
    }
    
    func accept(_ type: TokenType) -> Token? {
        if let token = peek() {
            if token.type == type {
                advance()
                return token
            }
        }
        return nil
    }
    
    func expect(type: TokenType, error: Error) throws {
        if nil == accept(type) {
            throw error
        }
    }
    
    func expect(types: [TokenType], error: Error) throws {
        for type in types {
            if nil != accept(type) {
                return
            }
        }
        throw error
    }
    
    func consumeInstruction() throws {
        if let instruction = accept(.nop) {
            try expect(types: [.newline, .eof],
                       error: zeroOperandsExpectedError(instruction))
            backend.nop()
        } else if let instruction = accept(.cmp) {
            try expect(types: [.newline, .eof],
                       error: zeroOperandsExpectedError(instruction))
            backend.cmp()
        } else if let instruction = accept(.hlt) {
            try expect(types: [.newline, .eof],
                       error: zeroOperandsExpectedError(instruction))
            backend.hlt()
        } else if nil != accept(.newline) {
            // do nothing
        } else if nil != accept(.eof) {
            // do nothing
        } else if let instruction = peek() {
            throw unrecognizedInstructionError(instruction)
        } else {
            throw AssemblerFrontEndError(line: -1, format: "unexpected end of input")
        }
    }
    
    func zeroOperandsExpectedError(_ instruction: Token) -> AssemblerFrontEndError {
        return AssemblerFrontEndError(line: instruction.lineNumber,
                                      format: "instruction takes no operands: `%@'",
                                      instruction.lexeme)
    }
    
    func unrecognizedInstructionError(_ instruction: Token) -> AssemblerFrontEndError {
        return AssemblerFrontEndError(line: instruction.lineNumber,
                                      format: "no such instruction: `%@'",
                                      instruction.lexeme)
    }
}
