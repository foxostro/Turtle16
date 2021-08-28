//
//  AssemblerParser.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCore

public class AssemblerParser: Parser {
    public final override func consumeStatement() throws -> [AbstractSyntaxTreeNode] {
        if nil != accept(TokenEOF.self) {
            return []
        }
        else if nil != accept(TokenNewline.self) {
            return []
        }
        else if let token = accept(TokenIdentifier.self) {
            return try consumeIdentifier(token as! TokenIdentifier)
        }
        else if let token = accept(TokenLet.self) {
            return try consumeLet(token as! TokenLet)
        }
        else {
            throw unexpectedEndOfInputError()
        }
    }
    
    func consumeIdentifier(_ identifier: TokenIdentifier) throws -> [AbstractSyntaxTreeNode] {
        if let token = peek(), type(of: token) == TokenColon.self {
            try expect(type: TokenColon.self, error: unrecognizedInstructionError(sourceAnchor: identifier.sourceAnchor, instruction: identifier.lexeme))
            return [LabelDeclaration(sourceAnchor: identifier.sourceAnchor, identifier: identifier.lexeme)]
        } else {
            let parameters = try consumeParameterList(instruction: identifier)
            let node = InstructionNode(sourceAnchor: identifier.sourceAnchor, instruction: identifier.lexeme, parameters: parameters)
            return [node]
        }
    }
    
    func consumeParameterList(instruction: Token) throws -> [Parameter] {
        var parameters = try consumeOneParameterOrTheEnd(instruction: instruction)
        var previousParameterCount = 0
        while parameters.count > previousParameterCount {
            previousParameterCount = parameters.count
            parameters = try consumeCommaSeparatedParameters(instruction: instruction, parameters: parameters)
        }
        return parameters
    }
    
    func consumeOneParameterOrTheEnd(instruction: Token, parameters sofar: [Parameter] = []) throws -> [Parameter] {
        var parameters = sofar
        let nextToken = peek()
        switch nextToken {
        case is TokenRegister:
            parameters += [try consumeParameterRegister()]
        case is TokenNumber:
            parameters += [try consumeParameterNumber()]
        case is TokenIdentifier:
            parameters += [try consumeParameterIdentifier()]
        case is TokenNewline:
            advance()
        case is TokenEOF:
            advance()
        default:
            throw operandTypeMismatchError(sourceAnchor: nextToken?.sourceAnchor,
                                           instruction: nextToken?.lexeme ?? "unknown")
        }
        return parameters
    }
    
    func consumeCommaSeparatedParameters(instruction: Token, parameters sofar: [Parameter] = []) throws -> [Parameter] {
        var parameters = sofar
            
        let maybeComma = peek()
        try expect(types: [TokenComma.self,
                           TokenNewline.self,
                           TokenEOF.self],
                   error: operandTypeMismatchError(sourceAnchor: instruction.sourceAnchor,
                                                   instruction: instruction.lexeme))
        
        if let _ = maybeComma as? TokenComma {
            parameters = try consumeOneParameter(instruction: instruction, parameters: parameters)
        }
        
        return parameters
    }
    
    func consumeOneParameter(instruction: Token, parameters sofar: [Parameter] = []) throws -> [Parameter] {
        var parameters = sofar
        let nextToken = peek()
        switch nextToken {
        case is TokenRegister:
            parameters += [try consumeParameterRegister()]
        case is TokenNumber:
            parameters += [try consumeParameterNumber()]
        case is TokenIdentifier:
            parameters += [try consumeParameterIdentifier()]
        default:
            throw operandTypeMismatchError(sourceAnchor: previous?.sourceAnchor,
                                           instruction: previous?.lexeme ?? "unknown")
        }
        return parameters
    }
    
    func consumeParameterRegister() throws -> Parameter {
        let error = operandTypeMismatchError(sourceAnchor: peek()?.sourceAnchor, instruction: peek()?.lexeme ?? "unknown")
        let token = try expect(type: TokenRegister.self, error: error) as! TokenRegister
        return ParameterRegister(sourceAnchor: token.sourceAnchor, value: token.literal)
    }
    
    func consumeParameterNumber() throws -> Parameter {
        let error = operandTypeMismatchError(sourceAnchor: peek()?.sourceAnchor, instruction: peek()?.lexeme ?? "unknown")
        let token = try expect(type: TokenNumber.self, error: error) as! TokenNumber
        return ParameterNumber(sourceAnchor: token.sourceAnchor, value: token.literal)
    }
    
    func consumeParameterIdentifier() throws -> Parameter {
        let error = operandTypeMismatchError(sourceAnchor: peek()?.sourceAnchor, instruction: peek()?.lexeme ?? "unknown")
        let token = try expect(type: TokenIdentifier.self, error: error) as! TokenIdentifier
        return ParameterIdentifier(sourceAnchor: token.sourceAnchor, value: token.lexeme)
    }
    
    func consumeLet(_ letToken: TokenLet) throws -> [AbstractSyntaxTreeNode] {
        let identifier = try expect(type: TokenIdentifier.self, error: CompilerError(sourceAnchor: letToken.sourceAnchor, format: "expected to find an identifier in constant declaration")) as! TokenIdentifier
        let equalToken = try expect(type: TokenEqual.self, error: CompilerError(sourceAnchor: identifier.sourceAnchor, message: "constants must be assigned a value"))
        let numberToken = peek()
        if (numberToken == nil) || (type(of: numberToken!) == TokenNewline.self) || (type(of: numberToken!) == TokenEOF.self) {
            throw CompilerError(sourceAnchor: equalToken.sourceAnchor, message: "expected value after `='")
        }
        let number = try expect(type: TokenNumber.self,
                                error: operandTypeMismatchError(sourceAnchor: numberToken!.sourceAnchor, instruction: numberToken!.lexeme)) as! TokenNumber
        try expect(types: [TokenNewline.self, TokenEOF.self],
                   error: operandTypeMismatchError(sourceAnchor: peek()!.sourceAnchor, instruction: peek()!.lexeme))
        
        let sourceAnchor = letToken.sourceAnchor?.union(number.sourceAnchor)
        return [ConstantDeclaration(sourceAnchor: sourceAnchor, identifier: identifier.lexeme, value: number.literal)]
    }
    
    func zeroOperandsExpectedError(sourceAnchor: SourceAnchor?, instruction: String) -> Error {
        return CompilerError(sourceAnchor: sourceAnchor, message: "instruction takes no operands: `\(instruction)'")
    }
    
    func operandTypeMismatchError(sourceAnchor: SourceAnchor?, instruction: String) -> Error {
        return CompilerError(sourceAnchor: sourceAnchor, message: "operand type mismatch: `\(instruction)'")
    }
    
    func unrecognizedInstructionError(sourceAnchor: SourceAnchor?, instruction: String) -> Error {
        return CompilerError(sourceAnchor: sourceAnchor, message: "no such instruction: `\(instruction)'")
    }
}
