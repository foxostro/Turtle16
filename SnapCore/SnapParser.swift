//
//  SnapParser.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class SnapParser: Parser {
    public final override func consumeStatement() throws -> [AbstractSyntaxTreeNode] {
        return try consumeStatement(shouldExpectEndOfStatement: true)
    }
        
    public final func consumeStatement(shouldExpectEndOfStatement: Bool) throws -> [AbstractSyntaxTreeNode] {
        var shouldExpectEndOfStatement = shouldExpectEndOfStatement
        let result: [AbstractSyntaxTreeNode]
        if nil != accept(TokenEOF.self) {
            result = []
            shouldExpectEndOfStatement = false
        }
        else if nil != accept(TokenNewline.self) {
            result = []
            shouldExpectEndOfStatement = false
        }
        else if let token = accept(TokenLet.self) {
            result = try consumeLet(token as! TokenLet)
        }
        else if let token = accept(TokenVar.self) {
            result = try consumeVar(token as! TokenVar)
        }
        else if let token = accept(TokenIf.self) {
            result = try consumeIf(token as! TokenIf)
        }
        else if let token = accept(TokenWhile.self) {
            result = try consumeWhile(token as! TokenWhile)
        }
        else if let token = accept(TokenFor.self) {
            result = try consumeForLoop(token as! TokenFor)
        }
        else if let _ = accept(TokenCurlyLeft.self) {
            result = try consumeBlock()
        }
        else if (nil != peek(0) as? TokenIdentifier) && (nil != peek(1) as? TokenColon) {
            result = try consumeLabel()
        }
        else {
            result = [try consumeExpression()]
        }
        if shouldExpectEndOfStatement {
            try expectEndOfStatement()
        }
        return result
    }
    
    private func consumeLet(_ letToken: TokenLet) throws -> [AbstractSyntaxTreeNode] {
        let identifier = try expect(type: TokenIdentifier.self,
                                    error: CompilerError(line: letToken.lineNumber,
                                                          format: "expected to find an identifier in let declaration",
                                                          letToken.lexeme)) as! TokenIdentifier
        let equal = try expect(type: TokenEqual.self,
                               error: CompilerError(line: letToken.lineNumber,
                                                    format: "immutable variables must be assigned a value",
                                                    letToken.lexeme))
        
        if nil != acceptEndOfStatement() {
            throw CompilerError(line: equal.lineNumber,
                                format: "expected value after '%@'",
                                equal.lexeme)
        }
        
        let expression = try consumeExpression()
        
        return [LetDeclaration(identifier: identifier, expression: expression)]
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
        
        let thenStatements: [AbstractSyntaxTreeNode]
        if nil != (peek() as? TokenCurlyLeft) {
            let leftError = "expected `{' after `\(ifToken.lexeme)' condition"
            let rightError = "expected `}' after `then' branch"
            thenStatements = try consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError)
        } else {
            try expect(type: TokenNewline.self, error: CompilerError(line: peek()!.lineNumber, message: "expected newline"))
            thenStatements = try consumeStatement()
        }
        let thenBranch: AbstractSyntaxTreeNode
        if thenStatements.count == 1 {
            thenBranch = thenStatements.first!
        } else {
            thenBranch = AbstractSyntaxTreeNode(children: thenStatements)
        }
        
        var elseBranch: AbstractSyntaxTreeNode? = nil
        let handleElse = {
            let elseToken = try self.expect(type: TokenElse.self, error: CompilerError(line: self.peek()!.lineNumber, message: "expected `else'"))
            
            let elseStatements: [AbstractSyntaxTreeNode]
            if nil != (self.peek() as? TokenCurlyLeft) {
                let leftError = "expected `{' after `\(elseToken.lexeme)'"
                let rightError = "expected `}' after `\(elseToken.lexeme)' branch"
                elseStatements = try self.consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError)
            } else {
                try self.expect(type: TokenNewline.self, error: CompilerError(line: self.peek()!.lineNumber, message: "expected newline"))
                elseStatements = try self.consumeStatement()
            }
            if elseStatements.count == 1 {
                elseBranch = elseStatements.first!
            } else {
                elseBranch = AbstractSyntaxTreeNode(children: elseStatements)
            }
        }
        if (nil != peek(0) as? TokenElse) {
            try handleElse()
        } else if (nil != peek(0) as? TokenNewline) && (nil != peek(1) as? TokenElse) {
            try expect(type: TokenNewline.self, error: CompilerError(line: peek()!.lineNumber, message: "expected newline"))
            try handleElse()
        }
        
        return [If(condition: condition, then: thenBranch, else: elseBranch)]
    }
    
    private func consumeBlock() throws -> [AbstractSyntaxTreeNode] {
        var statements: [AbstractSyntaxTreeNode] = []
        while nil == accept(TokenCurlyRight.self) {
            if nil == peek() || nil != (peek() as? TokenEOF){
                throw CompilerError(line: previous!.lineNumber, message: "expected `}' after block")
            }
            statements += try consumeStatement()
        }
        
        return [AbstractSyntaxTreeNode(children: statements)]
    }
    
    private func consumeBlock(errorOnMissingCurlyLeft: String,
                              errorOnMissingCurlyRight: String) throws -> [AbstractSyntaxTreeNode] {
        try expect(type: TokenCurlyLeft.self, error: CompilerError(line: previous!.lineNumber, message: errorOnMissingCurlyLeft))
        
        if nil != accept(TokenCurlyRight.self) {
            return [AbstractSyntaxTreeNode()]
        }
        
        try expect(type: TokenNewline.self, error: CompilerError(line: previous!.lineNumber, message: "expected newline"))
        
        var statements: [AbstractSyntaxTreeNode] = []
        while nil == accept(TokenCurlyRight.self) {
            if nil == peek() || nil != (peek() as? TokenEOF){
                throw CompilerError(line: previous!.lineNumber, message: errorOnMissingCurlyRight)
            }
            statements += try consumeStatement()
        }
        
        if statements.count == 1 {
            return [statements.first!]
        } else {
            return [AbstractSyntaxTreeNode(children: statements)]
        }
    }
    
    private func consumeWhile(_ whileToken: TokenWhile) throws -> [AbstractSyntaxTreeNode] {
        if nil != acceptEndOfStatement() {
            throw CompilerError(line: whileToken.lineNumber, message: "expected condition after `\(whileToken.lexeme)'")
        }
        if nil != accept(TokenCurlyLeft.self) {
            throw CompilerError(line: whileToken.lineNumber, message: "expected condition after `\(whileToken.lexeme)'")
        }
        let condition = try consumeExpression()
        
        let bodyStatements: [AbstractSyntaxTreeNode]
        if nil != (peek() as? TokenCurlyLeft) {
            let leftError = "expected `{' after `\(whileToken.lexeme)' condition"
            let rightError = "expected `}' after `\(whileToken.lexeme)' body"
            bodyStatements = try consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError)
        } else {
            try expect(type: TokenNewline.self, error: CompilerError(line: peek()!.lineNumber, message: "expected newline"))
            bodyStatements = try consumeStatement()
        }
        let body: AbstractSyntaxTreeNode
        if bodyStatements.count == 1 {
            body = bodyStatements.first!
        } else {
            body = AbstractSyntaxTreeNode(children: bodyStatements)
        }
        
        return [While(condition: condition, body: body)]
    }
    
    private func consumeForLoop(_ forToken: TokenFor) throws -> [AbstractSyntaxTreeNode] {
        let initializerClause = try consumeStatement(shouldExpectEndOfStatement: false).first!
        try expect(type: TokenSemicolon.self, error: CompilerError(line: forToken.lineNumber, message: "expected `;'"))
        let conditionClause = try consumeStatement(shouldExpectEndOfStatement: false).first!
        try expect(type: TokenSemicolon.self, error: CompilerError(line: forToken.lineNumber, message: "expected `;'"))
        let incrementClause = try consumeStatement(shouldExpectEndOfStatement: false).first!
        
        let leftError = "expected `{' after `\(forToken.lexeme)' increment clause"
        let rightError = "expected `}' after `\(forToken.lexeme)' body"
        let bodyStatements = try consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError)
        
        let body: AbstractSyntaxTreeNode
        if bodyStatements.count == 1 {
            body = bodyStatements.first!
        } else {
            body = AbstractSyntaxTreeNode(children: bodyStatements)
        }
        
        return [ForLoop(initializerClause: initializerClause,
                        conditionClause: conditionClause,
                        incrementClause: incrementClause,
                        body: body)]
    }
    
    private func consumeLabel() throws -> [AbstractSyntaxTreeNode] {
        let identifier = try expect(type: TokenIdentifier.self, error: CompilerError(line: peek()!.lineNumber, message: "expected to find an identifier in label declaration")) as! TokenIdentifier
        try expect(type: TokenColon.self, error: CompilerError(line: peek()!.lineNumber, message: "expected label declaration to end with a colon"))
        return [LabelDeclarationNode(identifier: identifier)]
    }
    
    private func acceptEndOfStatement() -> Token? {
        // If we've progressed past the end of the token stream then consider
        // the statement to have been terminated. This can occur at the end of
        // a block at the end of the file.
        guard let next = peek() else {
            return nil
        }
        
        // Reaching the end of a block ends the current statement too.
        // In this case, do not consume the curly brace. It will be expected
        // by the enclosing block momentarily.
        guard nil == (next as? TokenCurlyRight) else {
            return nil
        }
        
        // The current statement can be terminated by a newline.
        // The statement is obviously terminated if we reach the end.
        return accept([TokenNewline.self, TokenEOF.self])
    }
    
    private func expectEndOfStatement() throws {
        // If we've progressed past the end of the token stream then consider
        // the statement to have been terminated. This can occur at the end of
        // a block at the end of the file.
        guard let next = peek() else {
            return
        }
        
        // Reaching the end of a block ends the current statement too.
        // In this case, do not consume the curly brace. It will be expected
        // by the enclosing block momentarily.
        guard nil == (next as? TokenCurlyRight) else {
            return
        }
        
        // The current statement can be terminated by a newline.
        // The statement is obviously terminated if we reach the end.
        try expect(types: [TokenNewline.self, TokenEOF.self],
                   error: expectedEndOfStatementError(next))
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
        while let tokenOperator = accept(operators: [.eq, .ne, .lt, .gt, .le, .ge]) {
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
            return Expression.LiteralWord(number: numberToken)
        }
        else if let booleanToken = accept(TokenBoolean.self) as? TokenBoolean {
            return Expression.LiteralBoolean(boolean: booleanToken)
        }
        else if let identifierToken = accept(TokenIdentifier.self) as? TokenIdentifier {
            return Expression.Identifier(identifier: identifierToken)
        }
        else if (accept(TokenParenLeft.self) as? TokenParenLeft) != nil {
            let expression = try consumeExpression()
            try expect(type: TokenParenRight.self,
                       error: CompilerError(line: previous!.lineNumber,
                                            message: "expected ')' after expression"))
            return expression
        }
        else if let token = peek() {
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
