//
//  SnapParser.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class SnapParser: ParserBase {
    public final override func consumeStatement() throws -> [AbstractSyntaxTreeNode] {
        if nil != accept(TokenEOF.self) {
            return []
        }
        else if nil != accept(TokenNewline.self) {
            return []
        }
        else if let token = accept(TokenLet.self) {
            return try consumeLet(token as! TokenLet)
        }
        else if let token = accept(TokenVar.self) {
            return try consumeVar(token as! TokenVar)
        }
        else if (nil != peek(0) as? TokenIdentifier) && (nil != peek(1) as? TokenColon) {
            return try consumeLabel()
        }
        else {
            let expression = try consumeExpression()
            try expectEndOfStatement()
            return [expression]
        }
    }
    
    private func consumeLet(_ letToken: TokenLet) throws -> [AbstractSyntaxTreeNode] {
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
    
    private func consumeVar(_ varToken: TokenVar) throws -> [AbstractSyntaxTreeNode] {
        let identifier = try expect(type: TokenIdentifier.self,
                                    error: CompilerError(line: varToken.lineNumber,
                                                         format: "expected to find an identifier in variable declaration",
                                                         varToken.lexeme)) as! TokenIdentifier
        let equal = try expect(type: TokenEqual.self,
                               error: CompilerError(line: identifier.lineNumber,
                                                    message: "variables must be assigned an initial value"))
        
        if nil != acceptEndOfStatement() {
            throw CompilerError(line: equal.lineNumber,
                                format: "expected initial value after `%@'",
                                equal.lexeme)
        }
        
        let expression = try consumeExpression()
        
        try expectEndOfStatement()
        
        return [VarDeclaration(identifier: identifier, expression: expression)]
    }
    
    private func consumeLabel() throws -> [AbstractSyntaxTreeNode] {
        let identifier = try expect(type: TokenIdentifier.self, error: CompilerError(line: peek()!.lineNumber, message: "expected to find an identifier in label declaration")) as! TokenIdentifier
        try expect(type: TokenColon.self, error: CompilerError(line: peek()!.lineNumber, message: "expected label declaration to end with a colon"))
        try expectEndOfStatement()
        return [LabelDeclarationNode(identifier: identifier)]
    }
    
    private func acceptEndOfStatement() -> Token? {
        return accept([TokenNewline.self, TokenEOF.self])
    }
    
    private func expectEndOfStatement() throws {
        try expect(types: [TokenNewline.self, TokenEOF.self],
                          error: expectedEndOfStatementError(peek()!))
    }
    
    private func expectedEndOfStatementError(_ token: Token) -> Error {
        return CompilerError(line: token.lineNumber,
                              format: "expected to find the end of the statement: `%@'",
                              token.lexeme)
    }
    
    private func consumeExpression() throws -> Expression {
        return try consumeAssignment()
    }
    
    private func consumeAssignment() throws -> Expression {
        let lhs = try consumeAddition()
        
        if let identifier = lhs as? Expression.Identifier {
            if nil != accept(TokenEqual.self) {
                let rhs = try consumeAddition()
                let expression = Expression.Assignment(identifier: identifier.identifier, expression: rhs)
                return expression
            }
        }
        
        return lhs
    }
    
    private func consumeAddition() throws -> Expression {
        var expression = try consumeMultiplication()
        while let tokenOperator = accept(operators: [.plus, .minus]) {
            let right = try consumeMultiplication()
            expression = Expression.Binary(op: tokenOperator, left: expression, right: right)
        }
        return expression
    }
    
    private func consumeMultiplication() throws -> Expression {
        var expression = try consumeUnary()
        while let tokenOperator = accept(operators: [.multiply, .divide, .modulus]) {
            let right = try consumeUnary()
            expression = Expression.Binary(op: tokenOperator, left: expression, right: right)
        }
        return expression
    }
    
    private func consumeUnary() throws -> Expression {
        if let token = accept(operator: .minus) {
            let right = try consumeUnary()
            return Expression.Unary(op: token, expression: right)
        }
        
        return try consumePrimary()
    }
    
    private func consumePrimary() throws -> Expression {
        if let numberToken = accept(TokenNumber.self) as? TokenNumber {
            return Expression.Literal(number: numberToken)
        }
        
        if let identifierToken = accept(TokenIdentifier.self) as? TokenIdentifier {
            return Expression.Identifier(identifier: identifierToken)
        }
        
        if (accept(TokenParenLeft.self) as? TokenParenLeft) != nil {
            let expression = try consumeExpression()
            try expect(type: TokenParenRight.self,
                       error: CompilerError(line: previous!.lineNumber,
                                            message: "expected ')' after expression"))
            return expression
        }
        
        throw operandTypeMismatchError(peek()!)
    }
    
    private func useOfUnresolvedIdentifierError(_ instruction: Token) -> Error {
        return CompilerError(line: instruction.lineNumber,
                              format: "use of unresolved identifier: `%@'",
                              instruction.lexeme)
    }
    
    private func operandTypeMismatchError(_ instruction: Token) -> Error {
        return CompilerError(line: instruction.lineNumber,
                              format: "operand type mismatch: `%@'",
                              instruction.lexeme)
    }
}
