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
            Production(symbol: TokenIdentifier.self, generator: { try self.consumeIdentifier($0 as! TokenIdentifier) })
        ]
    }
    
    func consumeIdentifier(_ identifier: TokenIdentifier) throws -> [AbstractSyntaxTreeNode] {
        if let token = peek(), type(of: token) == TokenColon.self {
            try expect(type: TokenColon.self, error: unrecognizedInstructionError(identifier))
            return [LabelDeclarationNode(identifier: identifier)]
        } else {
            let parameters = try consumeParameterList(instruction: identifier)
            let node = InstructionNode(instruction: identifier, parameters: parameters)
            return [node]
        }
    }
    
    func consumeParameterList(instruction: Token) throws -> ParameterListNode {
        var parameters = try consumeOneParameterOrTheEnd(instruction: instruction)
        var previousParameterCount = 0
        while parameters.count > previousParameterCount {
            previousParameterCount = parameters.count
            parameters = try consumeCommaSeparatedParameters(instruction: instruction, parameters: parameters)
        }
        return ParameterListNode(parameters: parameters)
    }
    
    func consumeOneParameterOrTheEnd(instruction: Token, parameters sofar: [Any] = []) throws -> [Any] {
        var parameters = sofar
            
        let maybeParameter = peek()
        try expect(types: [TokenRegister.self,
                           TokenNumber.self,
                           TokenIdentifier.self,
                           TokenNewline.self,
                           TokenEOF.self],
                   error: operandTypeMismatchError(instruction))
        
        if let _ = maybeParameter as? TokenNewline {
            return parameters
        }
        
        if let _ = maybeParameter as? TokenEOF {
            return parameters
        }
        
        parameters += [maybeParameter!]
        
        return parameters
    }
    
    func consumeCommaSeparatedParameters(instruction: Token, parameters sofar: [Any] = []) throws -> [Any] {
        var parameters = sofar
            
        let maybeComma = peek()
        try expect(types: [TokenComma.self,
                           TokenNewline.self,
                           TokenEOF.self],
                   error: operandTypeMismatchError(instruction))
        
        if let _ = maybeComma as? TokenComma {
            parameters = try consumeOneParameter(instruction: instruction, parameters: parameters)
        }
        
        return parameters
    }
    
    func consumeOneParameter(instruction: Token, parameters sofar: [Any] = []) throws -> [Any] {
        var parameters = sofar
            
        let maybeParameter = peek()
        try expect(types: [TokenRegister.self,
                           TokenNumber.self,
                           TokenIdentifier.self],
                   error: operandTypeMismatchError(instruction))
        
        parameters += [maybeParameter!]
        
        return parameters
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
}
