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
        else if let token = accept(TokenIf.self) {
            return try consumeIf(token as! TokenIf)
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
    
    private func consumeIf(_ ifToken: TokenIf) throws -> [AbstractSyntaxTreeNode] {
        if nil != acceptEndOfStatement() {
            throw CompilerError(line: ifToken.lineNumber, message: "expected condition after `\(ifToken.lexeme)'")
        }
        if nil != accept(TokenCurlyLeft.self) {
            throw CompilerError(line: ifToken.lineNumber, message: "expected condition after `\(ifToken.lexeme)'")
        }
        let condition = try consumeExpression()
        let leftError = CompilerError(line: ifToken.lineNumber, message: "expected `{' after `\(ifToken.lexeme)' condition")
        let rightError = CompilerError(line: ifToken.lineNumber, message: "expected `}' after `then' branch")
        let thenBranch = try consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError)
        var elseBranch: AbstractSyntaxTreeNode? = nil
        let handleElse = {
            let elseToken = try self.expect(type: TokenElse.self, error: CompilerError(line: self.peek()!.lineNumber, message: "expected `else'"))
            let leftError = CompilerError(line: elseToken.lineNumber, message: "expected `{' after `\(elseToken.lexeme)'")
            let rightError = CompilerError(line: elseToken.lineNumber, message: "expected `}' after `\(elseToken.lexeme)' branch")
            elseBranch = try self.consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError)
        }
        if (nil != peek(0) as? TokenElse) {
            try handleElse()
        } else if (nil != peek(0) as? TokenNewline) && (nil != peek(1) as? TokenElse) {
            try expect(type: TokenNewline.self, error: CompilerError(line: peek()!.lineNumber, message: "expected newline"))
            try handleElse()
        }
        try expectEndOfStatement()
        return [If(condition: condition, then: thenBranch, else: elseBranch)]
    }
    
    private func consumeBlock(errorOnMissingCurlyLeft: CompilerError,
                              errorOnMissingCurlyRight: CompilerError) throws -> AbstractSyntaxTreeNode {
        try expect(type: TokenCurlyLeft.self, error: errorOnMissingCurlyLeft)
        try expectEndOfStatement()
        
        var statements: [AbstractSyntaxTreeNode] = []
        while nil == accept(TokenCurlyRight.self) {
            if nil == peek() || nil != (peek() as? TokenEOF){
                throw errorOnMissingCurlyRight
            }
            statements += try consumeStatement()
        }
        
        let branch: AbstractSyntaxTreeNode
        if statements.count == 1 {
            branch = statements.first!
        } else {
            branch = AbstractSyntaxTreeNode(children: statements)
        }
        
        return branch
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
        return try consumeComparison()
    }
    
    private func consumeComparison() throws -> Expression {
        var expression = try consumeAssignment()
        while let tokenOperator = accept(operators: [.eq]) {
            let right = try consumeAssignment()
            expression = Expression.Binary(op: tokenOperator, left: expression, right: right)
        }
        return expression
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
        
        if let token = peek() {
            throw operandTypeMismatchError(token)
        } else {
            throw unexpectedEndOfInputError()
        }
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
