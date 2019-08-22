//
//  AssemblerParser.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerParser: NSObject {
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
        if try consumeNOP() {
            // do nothing
        } else if try consumeCMP() {
            // do nothing
        } else if try consumeHLT() {
            // do nothing
        } else if try consumeJMP() {
            // do nothing
        } else if try consumeJC() {
            // do nothing
        } else if try consumeADD() {
            // do nothing
        } else if try consumeLI() {
            // do nothing
        } else if try consumeMOV() {
            // do nothing
        } else if try consumeNewline() {
            // do nothing
        } else if try consumeEOF() {
            // do nothing
        } else if try consumeIdentifier() {
            // do nothing
        } else {
            throw AssemblerError(format: "unexpected end of input")
        }
    }
    
    func consumeNOP() throws -> Bool {
        guard let instruction = accept(.nop) else { return false }
        try expect(types: [.newline, .eof],
                   error: zeroOperandsExpectedError(instruction))
        backend.nop()
        return true
    }
    
    func consumeCMP() throws -> Bool {
        guard let instruction = accept(.cmp) else { return false }
        try expect(types: [.newline, .eof],
                   error: zeroOperandsExpectedError(instruction))
        backend.cmp()
        return true
    }
    
    func consumeHLT() throws -> Bool {
        guard let instruction = accept(.hlt) else { return false }
        try expect(types: [.newline, .eof],
                   error: zeroOperandsExpectedError(instruction))
        backend.hlt()
        return true
    }
    
    func consumeJMP() throws -> Bool {
        guard let instruction = accept(.jmp) else { return false }
        guard let identifier = accept(.identifier) else {
            throw operandTypeMismatchError(instruction)
        }
        try expect(types: [.newline, .eof],
                   error: operandTypeMismatchError(instruction))
        try backend.jmp(token: identifier)
        return true
    }
    
    func consumeJC() throws -> Bool {
        guard let instruction = accept(.jc) else { return false }
        guard let identifier = accept(.identifier) else {
            throw operandTypeMismatchError(instruction)
        }
        try expect(types: [.newline, .eof],
                   error: operandTypeMismatchError(instruction))
        try backend.jc(token: identifier)
        return true
    }
    
    func consumeADD() throws -> Bool {
        guard let instruction = accept(.add) else { return false }
        guard let register = accept(.register) else {
            throw operandTypeMismatchError(instruction)
        }
        try checkRegisterCanBeUsedAsDestination(register)
        try expect(types: [.newline, .eof],
                   error: operandTypeMismatchError(instruction))
        try backend.add(register.literal as! String)
        return true
    }
    
    func consumeLI() throws -> Bool {
        guard let instruction = accept(.li) else { return false }
        guard let destination = accept(.register) else {
            throw operandTypeMismatchError(instruction)
        }
        try checkRegisterCanBeUsedAsDestination(destination)
        try expect(type: .comma, error: operandTypeMismatchError(instruction))
        guard let source = accept(.number) else {
            throw operandTypeMismatchError(instruction)
        }
        try expect(types: [.newline, .eof],
                   error: operandTypeMismatchError(instruction))
        try backend.li(destination.literal as! String, token: source)
        return true
    }
    
    func consumeMOV() throws -> Bool {
        guard let instruction = accept(.mov) else { return false }
        guard let destination = accept(.register) else {
            throw operandTypeMismatchError(instruction)
        }
        try expect(type: .comma, error: operandTypeMismatchError(instruction))
        try checkRegisterCanBeUsedAsDestination(destination)
        guard let source = accept(.register) else {
            throw operandTypeMismatchError(instruction)
        }
        try checkRegisterCanBeUsedAsSource(source)
        try expect(types: [.newline, .eof],
                   error: operandTypeMismatchError(instruction))
        try backend.mov(destination.literal as! String, source.literal as! String)
        return true
    }
    
    func consumeNewline() throws -> Bool {
        return nil != accept(.newline)
    }
    
    func consumeEOF() throws -> Bool {
        return nil != accept(.eof)
    }
    
    func consumeIdentifier() throws -> Bool {
        guard let identifier = accept(.identifier) else { return false }
        try expect(type: .colon, error: unrecognizedInstructionError(identifier))
        try backend.label(token: identifier)
        return true
    }
    
    func checkRegisterCanBeUsedAsDestination(_ register: Token) throws {
        if register.literal as! String == "E" || register.literal as! String == "C" {
            throw badDestinationError(register)
        }
    }
    
    func checkRegisterCanBeUsedAsSource(_ register: Token) throws {
        if register.literal as! String == "D" {
            throw badSourceError(register)
        }
    }
    
    func zeroOperandsExpectedError(_ instruction: Token) -> Error {
        return AssemblerError(line: instruction.lineNumber,
                              format: "instruction takes no operands: `%@'",
                              instruction.lexeme)
    }
    
    func operandTypeMismatchError(_ instruction: Token) -> Error {
        return AssemblerError(line: instruction.lineNumber,
                              format: "operand type mismatch: `%@'",
                              instruction.lexeme)
    }
    
    func unrecognizedInstructionError(_ instruction: Token) -> Error {
        return AssemblerError(line: instruction.lineNumber,
                              format: "no such instruction: `%@'",
                              instruction.lexeme)
    }
    
    func badDestinationError(_ register: Token) -> Error {
        return AssemblerError(line: register.lineNumber,
                              format: "register cannot be used as a destination: `%@'",
                              register.lexeme)
    }
    
    func badSourceError(_ register: Token) -> Error {
        return AssemblerError(line: register.lineNumber,
                              format: "register cannot be used as a source: `%@'",
                              register.lexeme)
    }
}
