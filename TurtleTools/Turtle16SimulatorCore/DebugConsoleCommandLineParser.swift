//
//  DebugConsoleCommandLineParser.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

public class DebugConsoleCommandLineParser: Parser {
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
        else {
            throw unexpectedEndOfInputError()
        }
    }
    
    func consumeIdentifier(_ identifier: TokenIdentifier) throws -> [AbstractSyntaxTreeNode] {
        let parameters = try consumeParameterList(instruction: identifier)
        let node = InstructionNode(sourceAnchor: identifier.sourceAnchor, instruction: identifier.lexeme, parameters: parameters)
        return [node]
    }
    
    func consumeParameterList(instruction: Token) throws -> ParameterList {
        var parameters = try consumeOneParameterOrTheEnd(instruction: instruction)
        var previousParameterCount = 0
        while parameters.count > previousParameterCount {
            previousParameterCount = parameters.count
            parameters = try consumeWhiteSpaceSeparatedParameters(instruction: instruction, parameters: parameters)
        }
        return ParameterList(sourceAnchor: instruction.sourceAnchor, parameters: parameters)
    }
    
    func consumeOneParameterOrTheEnd(instruction: Token, parameters sofar: [Parameter] = []) throws -> [Parameter] {
        var parameters = sofar
        let nextToken = peek()
        switch nextToken {
        case is TokenForwardSlash:
            parameters += [try consumeParameterSlashed()]
        case is TokenLiteralString:
            parameters += [try consumeParameterString()]
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
    
    func consumeWhiteSpaceSeparatedParameters(instruction: Token, parameters sofar: [Parameter] = []) throws -> [Parameter] {
        var parameters = sofar
        if nil == accept(TokenEOF.self) {
            parameters = try consumeOneParameter(instruction: instruction, parameters: parameters)
        }
        return parameters
    }
    
    func consumeOneParameter(instruction: Token, parameters sofar: [Parameter] = []) throws -> [Parameter] {
        var parameters = sofar
        let nextToken = peek()
        switch nextToken {
        case is TokenForwardSlash:
            parameters += [try consumeParameterSlashed()]
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
    
    func consumeParameterSlashed() throws -> Parameter {
        var maybeParameter: Parameter? = nil
        let slash = try expect(type: TokenForwardSlash.self, error: operandTypeMismatchError(sourceAnchor: previous?.sourceAnchor, instruction: previous?.lexeme ?? "unknown"))
        let nextToken = peek()
        switch nextToken {
        case is TokenNumber:
            maybeParameter = try consumeParameterNumber()
        case is TokenIdentifier:
            maybeParameter = try consumeParameterIdentifier()
        default:
            break
        }
        guard let parameter = maybeParameter else  {
            throw operandTypeMismatchError(sourceAnchor: previous?.sourceAnchor,
                                           instruction: previous?.lexeme ?? "unknown")
        }
        return ParameterSlashed(sourceAnchor: slash.sourceAnchor?.union(parameter.sourceAnchor), child: parameter)
    }
    
    func consumeParameterString() throws -> Parameter {
        let error = operandTypeMismatchError(sourceAnchor: peek()?.sourceAnchor, instruction: peek()?.lexeme ?? "unknown")
        let token = try expect(type: TokenLiteralString.self, error: error) as! TokenLiteralString
        return ParameterString(sourceAnchor: token.sourceAnchor, value: token.literal)
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
    
    func zeroOperandsExpectedError(sourceAnchor: SourceAnchor?, instruction: String) -> Error {
        return CompilerError(sourceAnchor: sourceAnchor, message: "instruction takes no operands: `\(instruction)'")
    }
    
    func operandTypeMismatchError(sourceAnchor: SourceAnchor?, instruction: String) -> Error {
        return CompilerError(sourceAnchor: sourceAnchor, message: "operand type mismatch: `\(instruction)'")
    }
}
