//
//  AssemblerParser.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerParser: NSObject {
    public typealias Token = AssemblerScanner.Token
    typealias TokenType = AssemblerScanner.TokenType
    
    struct Production {
        typealias Generator = (AssemblerParser,Token) throws -> [AbstractSyntaxTreeNode]?
        let symbol: TokenType
        let generator: Generator
    }
    
    let productions: [Production] = [
        Production(symbol: .eof,        generator: { _,_ in [] }),
        Production(symbol: .newline,    generator: { _,_ in [] }),
        Production(symbol: .nop,        generator: { try $0.consumeNOP($1) }),
        Production(symbol: .cmp,        generator: { try $0.consumeCMP($1) }),
        Production(symbol: .hlt,        generator: { try $0.consumeHLT($1) }),
        Production(symbol: .jmp,        generator: { try $0.consumeJMP($1) }),
        Production(symbol: .jc,         generator: { try $0.consumeJC($1) }),
        Production(symbol: .add,        generator: { try $0.consumeADD($1) }),
        Production(symbol: .li,         generator: { try $0.consumeLI($1) }),
        Production(symbol: .mov,        generator: { try $0.consumeMOV($1) }),
        Production(symbol: .identifier, generator: { try $0.consumeIdentifier($1) })
    ]
    var tokens: [Token] = []
    
    public required init(tokens: [Token]) {
        self.tokens = tokens
        super.init()
    }
    
    public func parse() throws -> AbstractSyntaxTreeNode {
        var statements: [AbstractSyntaxTreeNode] = []
        while tokens.count > 0 {
            statements += try consumeStatement()
        }
        return AbstractSyntaxTreeNode(children: statements)
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
    
    func consumeStatement() throws -> [AbstractSyntaxTreeNode] {
        for production in productions {
            guard let symbol = accept(production.symbol) else { continue }
            if let statements = try production.generator(self, symbol) {
                return statements
            }
        }
        throw AssemblerError(format: "unexpected end of input")
    }
    
    func consumeNOP(_ instruction: Token) throws -> [AbstractSyntaxTreeNode] {
        try expect(types: [.newline, .eof],
                   error: zeroOperandsExpectedError(instruction))
        return [NOPNode()]
    }
    
    func consumeCMP(_ instruction: Token) throws -> [AbstractSyntaxTreeNode] {
        try expect(types: [.newline, .eof],
                   error: zeroOperandsExpectedError(instruction))
        return [CMPNode()]
    }
    
    func consumeHLT(_ instruction: Token) throws -> [AbstractSyntaxTreeNode] {
        try expect(types: [.newline, .eof],
                   error: zeroOperandsExpectedError(instruction))
        return [HLTNode()]
    }
    
    func consumeJMP(_ instruction: Token) throws -> [AbstractSyntaxTreeNode] {
        if let identifier = accept(.identifier) {
            try expect(types: [.newline, .eof],
                       error: operandTypeMismatchError(instruction))
            return [JMPToLabelNode(token: identifier)]
        } else if let address = accept(.number) {
            try expect(types: [.newline, .eof],
                       error: operandTypeMismatchError(instruction))
            return [JMPToAddressNode(address: address.literal as! Int)]
        }
        throw operandTypeMismatchError(instruction)
    }
    
    func consumeJC(_ instruction: Token) throws -> [AbstractSyntaxTreeNode] {
        guard let identifier = accept(.identifier) else {
            throw operandTypeMismatchError(instruction)
        }
        try expect(types: [.newline, .eof],
                   error: operandTypeMismatchError(instruction))
        return [JCToLabelNode(token: identifier)]
    }
    
    func consumeADD(_ instruction: Token) throws -> [AbstractSyntaxTreeNode] {
        guard let register = accept(.register) else {
            throw operandTypeMismatchError(instruction)
        }
        try expectRegisterCanBeUsedAsDestination(register)
        try expect(types: [.newline, .eof],
                   error: operandTypeMismatchError(instruction))
        return [ADDNode(destination: register.literal as! String)]
    }
    
    func consumeLI(_ instruction: Token) throws -> [AbstractSyntaxTreeNode] {
        guard let destination = accept(.register) else {
            throw operandTypeMismatchError(instruction)
        }
        try expectRegisterCanBeUsedAsDestination(destination)
        try expect(type: .comma, error: operandTypeMismatchError(instruction))
        guard let source = accept(.number) else {
            throw operandTypeMismatchError(instruction)
        }
        try expect(types: [.newline, .eof],
                   error: operandTypeMismatchError(instruction))
        return [LINode(destination: destination.literal as! String, immediate: source)]
    }
    
    func consumeMOV(_ instruction: Token) throws -> [AbstractSyntaxTreeNode] {
        guard let destination = accept(.register) else {
            throw operandTypeMismatchError(instruction)
        }
        try expect(type: .comma, error: operandTypeMismatchError(instruction))
        try expectRegisterCanBeUsedAsDestination(destination)
        guard let source = accept(.register) else {
            throw operandTypeMismatchError(instruction)
        }
        try expectRegisterCanBeUsedAsSource(source)
        try expect(types: [.newline, .eof],
                   error: operandTypeMismatchError(instruction))
        return [MOVNode(destination: destination.literal as! String,
                        source: source.literal as! String)]
    }
    
    func consumeIdentifier(_ identifier: Token) throws -> [AbstractSyntaxTreeNode] {
        try expect(type: .colon, error: unrecognizedInstructionError(identifier))
        return [LabelDeclarationNode(identifier: identifier)]
    }
    
    func expectRegisterCanBeUsedAsDestination(_ register: Token) throws {
        if register.literal as! String == "E" || register.literal as! String == "C" {
            throw badDestinationError(register)
        }
    }
    
    func expectRegisterCanBeUsedAsSource(_ register: Token) throws {
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
