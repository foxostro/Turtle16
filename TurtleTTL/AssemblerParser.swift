//
//  AssemblerParser.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerParser: NSObject {
    public struct AssemblerParserError: Error {
        public let line: Int?
        public let message: String
        
        public init(line: Int, format: String, _ args: CVarArg...) {
            self.line = line
            message = String(format:format, arguments:args)
        }
        
        public init(format: String, _ args: CVarArg...) {
            self.line = nil
            message = String(format:format, arguments:args)
        }
    }
    
    let backend: AssemblerBackEnd
    public typealias Token = AssemblerScanner.Token
    typealias TokenType = AssemblerScanner.TokenType
    var tokens: [Token] = []
    
    public required init(backend: AssemblerBackEnd, tokens: [Token]) {
        self.backend = backend
        self.tokens = tokens
        super.init()
    }
    
    public func parse() throws {
        while tokens.count > 0 {
            try consumeInstruction()
        }
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
        } else if let identifier = accept(.identifier) {
            if nil != accept(.colon) {
                do {
                    try backend.label(identifier.lexeme)
                } catch let error as AssemblerBackEnd.AssemblerBackEndError {
                    throw AssemblerParserError(line: identifier.lineNumber, format: error.message)
                }
            } else {
                throw unrecognizedInstructionError(identifier)
            }
        } else {
            throw AssemblerParserError(format: "unexpected end of input")
        }
    }
    
    func zeroOperandsExpectedError(_ instruction: Token) -> Error {
        return AssemblerParserError(line: instruction.lineNumber,
                                    format: "instruction takes no operands: `%@'",
                                    instruction.lexeme)
    }
    
    func unrecognizedInstructionError(_ instruction: Token) -> Error {
        return AssemblerParserError(line: instruction.lineNumber,
                                    format: "no such instruction: `%@'",
                                    instruction.lexeme)
    }
}
