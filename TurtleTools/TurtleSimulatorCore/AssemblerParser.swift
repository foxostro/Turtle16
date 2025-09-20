//
//  AssemblerParser.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 5/16/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public class AssemblerParser: Parser {
    public override final func consumeStatement() throws -> [AbstractSyntaxTreeNode] {
        if accept(TokenEOF.self) != nil {
            return []
        }
        else if let token = accept(TokenIdentifier.self) {
            return try consumeIdentifier(token as! TokenIdentifier)
        }

        throw unexpectedEndOfInputError()
    }

    func consumeIdentifier(_ identifier: TokenIdentifier) throws -> [AbstractSyntaxTreeNode] {
        if let colon = accept(TokenColon.self) as? TokenColon {
            let sourceAnchor = identifier.sourceAnchor?.union(colon.sourceAnchor)
            return [LabelDeclaration(sourceAnchor: sourceAnchor, identifier: identifier.lexeme)]
        }

        let parameters = try consumeParameterList(instruction: identifier)
        let node = InstructionNode(
            sourceAnchor: identifier.sourceAnchor,
            instruction: identifier.lexeme,
            parameters: parameters
        )
        return [node]
    }

    func consumeParameterList(instruction _: Token) throws -> [Parameter] {
        var parameters: [Parameter] = []

        if accept(TokenEOF.self) != nil {
            return []
        }

        if accept(TokenNewline.self) != nil {
            return []
        }

        while true {
            let param = try consumeSingleParameter()
            parameters.append(param)

            if (peek() as? TokenEOF) != nil {
                break
            }
            else if (peek() as? TokenNewline) != nil {
                break
            }
            else {
                let err = operandTypeMismatchError(sourceAnchor: peek()?.sourceAnchor)
                try expect(type: TokenComma.self, error: err)
            }
        }

        return parameters
    }

    func consumeSingleParameter() throws -> Parameter {
        if let token = peek() as? TokenEOF {
            throw extraneousCommaError(sourceAnchor: token.sourceAnchor)
        }

        if let token = peek() as? TokenNewline {
            throw extraneousCommaError(sourceAnchor: token.sourceAnchor)
        }

        let param: Parameter
        if let tokenNumber = accept(TokenNumber.self) as? TokenNumber {
            let paramNumber = ParameterNumber(
                sourceAnchor: tokenNumber.sourceAnchor,
                value: tokenNumber.literal
            )
            if accept(TokenParenLeft.self) != nil {
                let identifier = try expect(
                    type: TokenIdentifier.self,
                    error: CompilerError(
                        sourceAnchor: peek()?.sourceAnchor,
                        message: "expected identifier"
                    )
                ) as! TokenIdentifier
                let rightParen = try expect(
                    type: TokenParenRight.self,
                    error: CompilerError(
                        sourceAnchor: peek()?.sourceAnchor,
                        message: "expected `)'"
                    )
                ) as! TokenParenRight
                let paramIdentifier = ParameterIdentifier(
                    sourceAnchor: identifier.sourceAnchor,
                    value: identifier.lexeme
                )
                let sourceAnchor = tokenNumber.sourceAnchor?.union(rightParen.sourceAnchor)
                param = ParameterAddress(
                    sourceAnchor: sourceAnchor,
                    offset: paramNumber,
                    identifier: paramIdentifier
                )
            }
            else {
                param = paramNumber
            }
        }
        else if let token = accept(TokenIdentifier.self) as? TokenIdentifier {
            param = ParameterIdentifier(sourceAnchor: token.sourceAnchor, value: token.lexeme)
        }
        else {
            throw operandTypeMismatchError(sourceAnchor: peek()?.sourceAnchor)
        }
        return param
    }

    func operandTypeMismatchError(sourceAnchor: SourceAnchor?) -> Error {
        CompilerError(sourceAnchor: sourceAnchor, message: "operand type mismatch")
    }

    func extraneousCommaError(sourceAnchor: SourceAnchor?) -> Error {
        CompilerError(sourceAnchor: sourceAnchor, message: "extraneous comma")
    }
}
