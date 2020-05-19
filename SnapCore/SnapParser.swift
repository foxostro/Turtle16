//
//  SnapParser.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class SnapParser: Parser {
    public init(tokens: [Token]) {
        super.init()
        self.tokens = tokens
        self.productions = [
            Production(symbol: TokenEOF.self,        generator: { _ in [] }),
            Production(symbol: TokenNewline.self,    generator: { _ in [] }),
            Production(symbol: TokenIdentifier.self, generator: { try self.consumeIdentifier($0 as! TokenIdentifier) }),
            Production(symbol: TokenLet.self,        generator: { try self.consumeLet($0 as! TokenLet) }),
            Production(symbol: TokenReturn.self,     generator: { try self.consumeReturn($0 as! TokenReturn) })
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
    
    func consumeLet(_ letToken: TokenLet) throws -> [AbstractSyntaxTreeNode] {
        let identifier = try expect(type: TokenIdentifier.self,
                                    error: CompilerError(line: letToken.lineNumber,
                                                          format: "expected to find an identifier in constant declaration",
                                                          letToken.lexeme)) as! TokenIdentifier
        try expect(type: TokenEqual.self,
                   error: CompilerError(line: letToken.lineNumber,
                                         format: "constants must be assigned a value",
                                         letToken.lexeme))
        let numberToken = peek()
        if (numberToken == nil) || (type(of: numberToken!) == TokenNewline.self) || (type(of: numberToken!) == TokenEOF.self) {
            throw CompilerError(line: letToken.lineNumber,
                                 format: "expected value after '='",
                                 letToken.lexeme)
        }
        let number = try expect(type: TokenNumber.self,
                                error: operandTypeMismatchError(numberToken!)) as! TokenNumber
        try expect(types: [TokenNewline.self, TokenEOF.self],
                   error: operandTypeMismatchError(peek()!))
        
        return [ConstantDeclarationNode(identifier: identifier, number: number)]
    }
    
    func consumeReturn(_ returnToken: TokenReturn) throws -> [AbstractSyntaxTreeNode] {
        if accept([TokenNewline.self, TokenEOF.self]) != nil {
            return [Return(token: returnToken, expression: nil)]
        } else {
            let expression = try consumeExpression()
            try expect(types: [TokenNewline.self, TokenEOF.self], error: operandTypeMismatchError(returnToken))
            return [Return(token: returnToken, expression: expression)]
        }
    }
    
    func consumeExpression() throws -> Expression {
        return try consumePrimary()
    }
    
    func consumePrimary() throws -> Expression {
        if let numberToken = accept(TokenNumber.self) as? TokenNumber {
            return Expression.Literal(number: numberToken)
        }
        throw operandTypeMismatchError(peek()!)
    }
    
    func zeroOperandsExpectedError(_ instruction: Token) -> Error {
        return CompilerError(line: instruction.lineNumber,
                              format: "instruction takes no operands: `%@'",
                              instruction.lexeme)
    }
    
    func operandTypeMismatchError(_ instruction: Token) -> Error {
        return CompilerError(line: instruction.lineNumber,
                              format: "operand type mismatch: `%@'",
                              instruction.lexeme)
    }
    
    func unrecognizedInstructionError(_ instruction: Token) -> Error {
        return CompilerError(line: instruction.lineNumber,
                              format: "no such instruction: `%@'",
                              instruction.lexeme)
    }
}
