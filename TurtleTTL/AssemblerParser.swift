//
//  AssemblerParser.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerParser: NSObject {
    struct Production {
        typealias Generator = (AssemblerParser,Token) throws -> [AbstractSyntaxTreeNode]?
        let symbol: Token.Type
        let generator: Generator
    }
    
    let productions: [Production] = [
        Production(symbol: TokenEOF.self,        generator: { _,_ in [] }),
        Production(symbol: TokenNewline.self,    generator: { _,_ in [] }),
        Production(symbol: TokenNOP.self,        generator: { try $0.consumeNOP($1 as! TokenNOP) }),
        Production(symbol: TokenCMP.self,        generator: { try $0.consumeCMP($1 as! TokenCMP) }),
        Production(symbol: TokenHLT.self,        generator: { try $0.consumeHLT($1 as! TokenHLT) }),
        Production(symbol: TokenJMP.self,        generator: { try $0.consumeJMP($1 as! TokenJMP) }),
        Production(symbol: TokenJC.self,         generator: { try $0.consumeJC($1 as! TokenJC) }),
        Production(symbol: TokenADD.self,        generator: { try $0.consumeADD($1 as! TokenADD) }),
        Production(symbol: TokenLI.self,         generator: { try $0.consumeLI($1 as! TokenLI) }),
        Production(symbol: TokenSTORE.self,      generator: { try $0.consumeSTORE($1 as! TokenSTORE) }),
        Production(symbol: TokenLOAD.self,       generator: { try $0.consumeLOAD($1 as! TokenLOAD) }),
        Production(symbol: TokenMOV.self,        generator: { try $0.consumeMOV($1 as! TokenMOV) }),
        Production(symbol: TokenIdentifier.self, generator: { try $0.consumeIdentifier($1 as! TokenIdentifier) })
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
    
    func accept(_ typeInQuestion: AnyClass) -> Any? {
        if let token = peek() {
            if typeInQuestion == type(of: token) {
                advance()
                return token
            }
        }
        return nil
    }
    
    func expect(type: AnyClass, error: Error) throws {
        if nil == accept(type) {
            throw error
        }
    }
    
    func expect(types: [AnyClass], error: Error) throws {
        for t in types {
            if nil != accept(t) {
                return
            }
        }
        throw error
    }
    
    func consumeStatement() throws -> [AbstractSyntaxTreeNode] {
        for production in productions {
            guard let symbol = accept(production.symbol) as? Token else { continue }
            if let statements = try production.generator(self, symbol) {
                return statements
            }
        }
        throw AssemblerError(format: "unexpected end of input")
    }
    
    func consumeNOP(_ instruction: TokenNOP) throws -> [AbstractSyntaxTreeNode] {
        try expect(types: [TokenNewline.self, TokenEOF.self],
                   error: zeroOperandsExpectedError(instruction))
        return [NOPNode()]
    }
    
    func consumeCMP(_ instruction: TokenCMP) throws -> [AbstractSyntaxTreeNode] {
        try expect(types: [TokenNewline.self, TokenEOF.self],
                   error: zeroOperandsExpectedError(instruction))
        return [CMPNode()]
    }
    
    func consumeHLT(_ instruction: TokenHLT) throws -> [AbstractSyntaxTreeNode] {
        try expect(types: [TokenNewline.self, TokenEOF.self],
                   error: zeroOperandsExpectedError(instruction))
        return [HLTNode()]
    }
    
    func consumeJMP(_ instruction: TokenJMP) throws -> [AbstractSyntaxTreeNode] {
        if let identifier = accept(TokenIdentifier.self) as? TokenIdentifier {
            try expect(types: [TokenNewline.self, TokenEOF.self],
                       error: operandTypeMismatchError(instruction))
            return [JMPToLabelNode(token: identifier)]
        } else if let address = accept(TokenNumber.self) as? TokenNumber {
            try expect(types: [TokenNewline.self, TokenEOF.self],
                       error: operandTypeMismatchError(instruction))
            return [JMPToAddressNode(address: address.literal as! Int)]
        }
        throw operandTypeMismatchError(instruction)
    }
    
    func consumeJC(_ instruction: TokenJC) throws -> [AbstractSyntaxTreeNode] {
        if let identifier = accept(TokenIdentifier.self) as? TokenIdentifier {
            try expect(types: [TokenNewline.self, TokenEOF.self],
                       error: operandTypeMismatchError(instruction))
            return [JCToLabelNode(token: identifier)]
        } else if let address = accept(TokenNumber.self) as? TokenNumber {
            try expect(types: [TokenNewline.self, TokenEOF.self],
                       error: operandTypeMismatchError(instruction))
            return [JCToAddressNode(address: address.literal as! Int)]
        }
        throw operandTypeMismatchError(instruction)
    }
    
    func consumeADD(_ instruction: TokenADD) throws -> [AbstractSyntaxTreeNode] {
        guard let register = accept(TokenRegister.self) as? TokenRegister else {
            throw operandTypeMismatchError(instruction)
        }
        try expectRegisterCanBeUsedAsDestination(register)
        try expect(types: [TokenNewline.self, TokenEOF.self],
                   error: operandTypeMismatchError(instruction))
        return [ADDNode(destination: register.literal as! String)]
    }
    
    func consumeLI(_ instruction: TokenLI) throws -> [AbstractSyntaxTreeNode] {
        guard let destination = accept(TokenRegister.self) as? TokenRegister else {
            throw operandTypeMismatchError(instruction)
        }
        try expectRegisterCanBeUsedAsDestination(destination)
        try expect(type: TokenComma.self, error: operandTypeMismatchError(instruction))
        guard let source = accept(TokenNumber.self) as? TokenNumber else {
            throw operandTypeMismatchError(instruction)
        }
        try expect(types: [TokenNewline.self, TokenEOF.self],
                   error: operandTypeMismatchError(instruction))
        return [LINode(destination: destination.literal as! String, immediate: source)]
    }
    
    func consumeSTORE(_ instruction: TokenSTORE) throws -> [AbstractSyntaxTreeNode] {
        guard let destination = accept(TokenNumber.self) as? TokenNumber else {
            throw operandTypeMismatchError(instruction)
        }
        try expect(type: TokenComma.self, error: operandTypeMismatchError(instruction))
        if let source = accept(TokenRegister.self) as? TokenRegister {
            try expectRegisterCanBeUsedAsSource(source)
            try expect(types: [TokenNewline.self, TokenEOF.self],
                       error: operandTypeMismatchError(instruction))
            return [StoreNode(destinationAddress: destination, source: source.literal as! String)]
        }
        else if let source = accept(TokenNumber.self) as? TokenNumber {
            try expect(types: [TokenNewline.self, TokenEOF.self],
                       error: operandTypeMismatchError(instruction))
            return [StoreImmediateNode(destinationAddress: destination, immediate: source.literal as! Int)]
        }
        else {
            throw operandTypeMismatchError(instruction)
        }
    }
    
    func consumeLOAD(_ instruction: TokenLOAD) throws -> [AbstractSyntaxTreeNode] {
        guard let destination = accept(TokenRegister.self) as? TokenRegister else {
            throw operandTypeMismatchError(instruction)
        }
        try expectRegisterCanBeUsedAsDestination(destination)
        try expect(type: TokenComma.self, error: operandTypeMismatchError(instruction))
        guard let source = accept(TokenNumber.self) as? TokenNumber else {
            throw operandTypeMismatchError(instruction)
        }
        try expect(types: [TokenNewline.self, TokenEOF.self],
                   error: operandTypeMismatchError(instruction))
        return [LoadNode(destination: destination.literal as! String, sourceAddress: source)]
    }
    
    func consumeMOV(_ instruction: TokenMOV) throws -> [AbstractSyntaxTreeNode] {
        guard let destination = accept(TokenRegister.self) as? TokenRegister else {
            throw operandTypeMismatchError(instruction)
        }
        try expect(type: TokenComma.self, error: operandTypeMismatchError(instruction))
        try expectRegisterCanBeUsedAsDestination(destination)
        guard let source = accept(TokenRegister.self) as? TokenRegister else {
            throw operandTypeMismatchError(instruction)
        }
        try expectRegisterCanBeUsedAsSource(source)
        try expect(types: [TokenNewline.self, TokenEOF.self],
                   error: operandTypeMismatchError(instruction))
        return [MOVNode(destination: destination.literal as! String,
                        source: source.literal as! String)]
    }
    
    func consumeIdentifier(_ identifier: TokenIdentifier) throws -> [AbstractSyntaxTreeNode] {
        try expect(type: TokenColon.self, error: unrecognizedInstructionError(identifier))
        return [LabelDeclarationNode(identifier: identifier)]
    }
    
    func expectRegisterCanBeUsedAsDestination(_ register: TokenRegister) throws {
        if register.literal as! String == "E" || register.literal as! String == "C" {
            throw badDestinationError(register)
        }
    }
    
    func expectRegisterCanBeUsedAsSource(_ register: TokenRegister) throws {
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
    
    func badDestinationError(_ register: TokenRegister) -> Error {
        return AssemblerError(line: register.lineNumber,
                              format: "register cannot be used as a destination: `%@'",
                              register.lexeme)
    }
    
    func badSourceError(_ register: TokenRegister) -> Error {
        return AssemblerError(line: register.lineNumber,
                              format: "register cannot be used as a source: `%@'",
                              register.lexeme)
    }
}
