//
//  AssemblerParser.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerParser: Parser {
    public init(tokens: [Token]) {
        super.init()
        self.tokens = tokens
        self.productions = [
            Production(symbol: TokenEOF.self,        generator: { _ in [] }),
            Production(symbol: TokenNewline.self,    generator: { _ in [] }),
            Production(symbol: TokenNOP.self,        generator: { try self.consumeNOP($0 as! TokenNOP) }),
            Production(symbol: TokenCMP.self,        generator: { try self.consumeCMP($0 as! TokenCMP) }),
            Production(symbol: TokenHLT.self,        generator: { try self.consumeHLT($0 as! TokenHLT) }),
            Production(symbol: TokenLXY.self,        generator: { try self.consumeLXY($0 as! TokenLXY) }),
            Production(symbol: TokenJALR.self,       generator: { try self.consumeJALR($0 as! TokenJALR) }),
            Production(symbol: TokenJMP.self,        generator: { try self.consumeJMP($0 as! TokenJMP) }),
            Production(symbol: TokenJC.self,         generator: { try self.consumeJC($0 as! TokenJC) }),
            Production(symbol: TokenADD.self,        generator: { try self.consumeADD($0 as! TokenADD) }),
            Production(symbol: TokenLI.self,         generator: { try self.consumeLI($0 as! TokenLI) }),
            Production(symbol: TokenSTORE.self,      generator: { try self.consumeSTORE($0 as! TokenSTORE) }),
            Production(symbol: TokenLOAD.self,       generator: { try self.consumeLOAD($0 as! TokenLOAD) }),
            Production(symbol: TokenMOV.self,        generator: { try self.consumeMOV($0 as! TokenMOV) }),
            Production(symbol: TokenIdentifier.self, generator: { try self.consumeIdentifier($0 as! TokenIdentifier) })
        ]
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
    
    func consumeLXY(_ instruction: TokenLXY) throws -> [AbstractSyntaxTreeNode] {
        if let identifier = accept(TokenIdentifier.self) as? TokenIdentifier {
            try expect(types: [TokenNewline.self, TokenEOF.self],
                       error: operandTypeMismatchError(instruction))
            return [LXYWithLabelNode(token: identifier)]
        } else if let address = accept(TokenNumber.self) as? TokenNumber {
            try expect(types: [TokenNewline.self, TokenEOF.self],
                       error: operandTypeMismatchError(instruction))
            return [LXYWithAddressNode(address: address.literal)]
        }
        throw operandTypeMismatchError(instruction)
    }
    
    func consumeJALR(_ instruction: TokenJALR) throws -> [AbstractSyntaxTreeNode] {
        if let identifier = accept(TokenIdentifier.self) as? TokenIdentifier {
            try expect(types: [TokenNewline.self, TokenEOF.self],
                       error: operandTypeMismatchError(instruction))
            return [JALRNode(token: identifier)]
        }
        throw operandTypeMismatchError(instruction)
    }
    
    func consumeJMP(_ instruction: TokenJMP) throws -> [AbstractSyntaxTreeNode] {
        if let identifier = accept(TokenIdentifier.self) as? TokenIdentifier {
            try expect(types: [TokenNewline.self, TokenEOF.self],
                       error: operandTypeMismatchError(instruction))
            return [JMPToLabelNode(token: identifier)]
        } else if let address = accept(TokenNumber.self) as? TokenNumber {
            try expect(types: [TokenNewline.self, TokenEOF.self],
                       error: operandTypeMismatchError(instruction))
            return [JMPToAddressNode(address: address.literal)]
        } else {
            try expect(types: [TokenNewline.self, TokenEOF.self],
                       error: zeroOperandsExpectedError(instruction))
            return [JMPNode()]
        }
    }
    
    func consumeJC(_ instruction: TokenJC) throws -> [AbstractSyntaxTreeNode] {
        if let identifier = accept(TokenIdentifier.self) as? TokenIdentifier {
            try expect(types: [TokenNewline.self, TokenEOF.self],
                       error: operandTypeMismatchError(instruction))
            return [JCToLabelNode(token: identifier)]
        } else if let address = accept(TokenNumber.self) as? TokenNumber {
            try expect(types: [TokenNewline.self, TokenEOF.self],
                       error: operandTypeMismatchError(instruction))
            return [JCToAddressNode(address: address.literal)]
        } else {
            try expect(types: [TokenNewline.self, TokenEOF.self],
                       error: zeroOperandsExpectedError(instruction))
            return [JCNode()]
       }
    }
    
    func consumeADD(_ instruction: TokenADD) throws -> [AbstractSyntaxTreeNode] {
        guard let register = accept(TokenRegister.self) as? TokenRegister else {
            throw operandTypeMismatchError(instruction)
        }
        try expectRegisterCanBeUsedAsDestination(register)
        try expect(types: [TokenNewline.self, TokenEOF.self],
                   error: operandTypeMismatchError(instruction))
        return [ADDNode(destination: register.literal)]
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
        return [LINode(destination: destination.literal, immediate: source)]
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
            return [StoreNode(destinationAddress: destination, source: source.literal)]
        }
        else if let source = accept(TokenNumber.self) as? TokenNumber {
            try expect(types: [TokenNewline.self, TokenEOF.self],
                       error: operandTypeMismatchError(instruction))
            return [StoreImmediateNode(destinationAddress: destination, immediate: source.literal)]
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
        return [LoadNode(destination: destination.literal, sourceAddress: source)]
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
        return [MOVNode(destination: destination.literal,
                        source: source.literal)]
    }
    
    func consumeIdentifier(_ identifier: TokenIdentifier) throws -> [AbstractSyntaxTreeNode] {
        try expect(type: TokenColon.self, error: unrecognizedInstructionError(identifier))
        return [LabelDeclarationNode(identifier: identifier)]
    }
    
    func expectRegisterCanBeUsedAsDestination(_ register: TokenRegister) throws {
        if register.literal == .E || register.literal == .C {
            throw badDestinationError(register)
        }
    }
    
    func expectRegisterCanBeUsedAsSource(_ register: TokenRegister) throws {
        if register.literal == .D {
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
