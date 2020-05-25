//
//  SnapParser.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class SnapParser: ParserBase {
    public init(tokens: [Token]) {
        super.init()
        self.tokens = tokens
        self.productions = [
            Production(symbol: TokenEOF.self,        generator: { _ in [] }),
            Production(symbol: TokenNewline.self,    generator: { _ in [] }),
            Production(symbol: TokenIdentifier.self, generator: { try self.consumeIdentifier($0 as! TokenIdentifier) }),
            Production(symbol: TokenLet.self,        generator: { try self.consumeLet($0 as! TokenLet) }),
            Production(symbol: TokenEval.self,       generator: { try self.consumeEval($0 as! TokenEval) })
        ]
    }
    
    fileprivate func consumeIdentifier(_ identifier: TokenIdentifier) throws -> [AbstractSyntaxTreeNode] {
        try expect(type: TokenColon.self, error: useOfUnresolvedIdentifierError(identifier))
        try expectEndOfStatement()
        return [LabelDeclarationNode(identifier: identifier)]
    }
    
    fileprivate func consumeLet(_ letToken: TokenLet) throws -> [AbstractSyntaxTreeNode] {
        let identifier = try expect(type: TokenIdentifier.self,
                                    error: CompilerError(line: letToken.lineNumber,
                                                          format: "expected to find an identifier in constant declaration",
                                                          letToken.lexeme)) as! TokenIdentifier
        let equal = try expect(type: TokenEqual.self,
                               error: CompilerError(line: letToken.lineNumber,
                                                    format: "constants must be assigned a value",
                                                    letToken.lexeme))
        
        if nil != acceptEndOfStatement() {
            throw CompilerError(line: equal.lineNumber,
                                format: "expected value after '%@'",
                                equal.lexeme)
        }
        
        let expression = try consumeExpression()
        
        try expectEndOfStatement()
        
        return [ConstantDeclaration(identifier: identifier, expression: expression)]
    }
    
    fileprivate func consumeEval(_ evalToken: TokenEval) throws -> [AbstractSyntaxTreeNode] {
        if nil != acceptEndOfStatement() {
            throw CompilerError(line: evalToken.lineNumber,
                                format: "expected to find an expression following `%@' statement",
                                evalToken.lexeme)
        }
        let expression = try consumeExpression()
        try expectEndOfStatement()
        return [EvalStatement(token: evalToken, expression: expression)]
    }
    
    fileprivate func acceptEndOfStatement() -> Token? {
        return accept([TokenNewline.self, TokenEOF.self])
    }
    
    fileprivate func expectEndOfStatement() throws {
        try expect(types: [TokenNewline.self, TokenEOF.self],
                          error: expectedEndOfStatementError(peek()!))
    }
    
    fileprivate func expectedEndOfStatementError(_ token: Token) -> Error {
        return CompilerError(line: token.lineNumber,
                              format: "expected to find the end of the statement: `%@'",
                              token.lexeme)
    }
    
    fileprivate func consumeExpression() throws -> Expression {
        return try consumeAddition()
    }
    
    fileprivate func consumeAddition() throws -> Expression {
        var expression = try consumeMultiplication()
        while let tokenOperator = accept(operators: [.plus, .minus]) {
            let right = try consumeMultiplication()
            expression = Expression.Binary(op: tokenOperator, left: expression, right: right)
        }
        return expression
    }
    
    fileprivate func consumeMultiplication() throws -> Expression {
        var expression = try consumeUnary()
        while let tokenOperator = accept(operators: [.multiply, .divide, .modulus]) {
            let right = try consumeUnary()
            expression = Expression.Binary(op: tokenOperator, left: expression, right: right)
        }
        return expression
    }
    
    fileprivate func consumeUnary() throws -> Expression {
        if let token = accept(operator: .minus) {
            let right = try consumeUnary()
            return Expression.Unary(op: token, expression: right)
        }
        
        return try consumePrimary()
    }
    
    fileprivate func consumePrimary() throws -> Expression {
        if let numberToken = accept(TokenNumber.self) as? TokenNumber {
            return Expression.Literal(number: numberToken)
        }
        
        if let identifierToken = accept(TokenIdentifier.self) as? TokenIdentifier {
            return Expression.Identifier(identifier: identifierToken)
        }
        
        if let leftParen = accept(TokenParenLeft.self) as? TokenParenLeft {
            let expression = try consumeExpression()
            try expect(type: TokenParenRight.self,
                       error: CompilerError(line: previous?.lineNumber ?? leftParen.lineNumber,
                                            message: "expected ')' after expression"))
            return expression
        }
        
        throw operandTypeMismatchError(peek()!)
    }
    
    fileprivate func useOfUnresolvedIdentifierError(_ instruction: Token) -> Error {
        return CompilerError(line: instruction.lineNumber,
                              format: "use of unresolved identifier: `%@'",
                              instruction.lexeme)
    }
    
    fileprivate func operandTypeMismatchError(_ instruction: Token) -> Error {
        return CompilerError(line: instruction.lineNumber,
                              format: "operand type mismatch: `%@'",
                              instruction.lexeme)
    }
}
