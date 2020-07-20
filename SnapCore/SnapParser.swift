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
        else if let token = accept(TokenStatic.self) {
            result = try consumeStatic(token as! TokenStatic)
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
            throw CompilerError(line: peek()!.lineNumber, message: "labels are not supported")
        }
        else if let token = accept(TokenFunc.self) {
            result = try consumeFunc(token as! TokenFunc)
        }
        else if let token = accept(TokenReturn.self) {
            result = try consumeReturn(token as! TokenReturn)
        }
        else {
            result = [try consumeExpression()]
        }
        if shouldExpectEndOfStatement {
            try expectEndOfStatement()
        }
        return result
    }
    
    private func consumeStatic(_ staticToken: TokenStatic) throws -> [AbstractSyntaxTreeNode] {
        if let token = accept(TokenLet.self) {
            return try consumeLet(token as! TokenLet, storage: .staticStorage)
        }
        
        let token = try expect(type: TokenVar.self, error: CompilerError(line: staticToken.lineNumber, message: "expected declaration"))
        return try consumeVar(token as! TokenVar, storage: .staticStorage)
    }
    
    private func consumeLet(_ letToken: TokenLet, storage: SymbolStorage = .stackStorage) throws -> [AbstractSyntaxTreeNode] {
        let isMutable = false
        let errorMessageWhenMissingIdentifier = "expected to find an identifier in let declaration"
        let errorMessageWhenNoInitialValue = "immutable variables must be assigned a value"
        let errorFormatWhenNoInitialValueAfterEqual = "expected value after `%@'"
        return try consumeVar(letToken,
                              errorMessageWhenMissingIdentifier,
                              errorMessageWhenNoInitialValue,
                              errorFormatWhenNoInitialValueAfterEqual,
                              storage,
                              isMutable)
    }
    
    private func consumeVar(_ varToken: TokenVar, storage: SymbolStorage = .stackStorage) throws -> [AbstractSyntaxTreeNode] {
        let isMutable = true
        let errorMessageWhenMissingIdentifier = "expected to find an identifier in variable declaration"
        let errorMessageWhenNoInitialValue = "variables must be assigned an initial value"
        let errorFormatWhenNoInitialValueAfterEqual = "expected initial value after `%@'"
        return try consumeVar(varToken,
                              errorMessageWhenMissingIdentifier,
                              errorMessageWhenNoInitialValue,
                              errorFormatWhenNoInitialValueAfterEqual,
                              storage,
                              isMutable)
    }
    
    fileprivate func consumeVar(_ letOrVarToken: Token,
                                _ errorMessageWhenMissingIdentifier: String,
                                _ errorMessageWhenNoInitialValue: String,
                                _ errorFormatWhenNoInitialValueAfterEqual: String,
                                _ storage: SymbolStorage,
                                _ isMutable: Bool) throws -> [AbstractSyntaxTreeNode] {
        let identifier = try expect(type: TokenIdentifier.self,
                                    error: CompilerError(line: letOrVarToken.lineNumber,
                                                         format: errorMessageWhenMissingIdentifier,
                                                         letOrVarToken.lexeme)) as! TokenIdentifier
        
        let explicitType = try consumeTypeAnnotation()
        
        let equal = try expect(type: TokenEqual.self,
                               error: CompilerError(line: letOrVarToken.lineNumber,
                                                    message: errorMessageWhenNoInitialValue))
        
        if nil != acceptEndOfStatement() {
            throw CompilerError(line: equal.lineNumber,
                                format: errorFormatWhenNoInitialValueAfterEqual,
                                equal.lexeme)
        }
        
        let expression = try consumeExpression()
        
        if let arr = expression as? Expression.Array {
            if arr.elements.count == 0 && explicitType == nil {
                throw CompilerError(line: arr.tokens.first!.lineNumber,
                                    message: "empty array literal requires an explicit type")
            }
        }
        
        return [VarDeclaration(identifier: identifier,
                               explicitType: explicitType,
                               expression: expression,
                               storage: storage,
                               isMutable: isMutable)]
    }
    
    fileprivate func consumeTypeAnnotation() throws -> SymbolType? {
        guard nil != accept(TokenColon.self) else {
            return nil
        }
        return try consumeType()
    }
    
    fileprivate func consumeType() throws -> SymbolType {
        if nil != accept(TokenSquareBracketLeft.self) {
            let baseType = try consumePrimitiveType()
            try expect(type: TokenSquareBracketRight.self, error: CompilerError(line: peek()!.lineNumber, message: "expected `]'"))
            return .array(baseType)
        } else {
            let explicitType = try consumePrimitiveType()
            return explicitType
        }
    }
    
    fileprivate func consumePrimitiveType() throws -> SymbolType {
        let tokenType = try expect(type: TokenType.self, error: CompilerError(line: peek()!.lineNumber, message: "")) as! TokenType
        let explicitType = tokenType.representedType
        return explicitType
    }
    
    private func consumeIf(_ ifToken: TokenIf) throws -> [AbstractSyntaxTreeNode] {
        if nil != acceptEndOfStatement() {
            throw CompilerError(line: ifToken.lineNumber, message: "expected condition after `\(ifToken.lexeme)'")
        }
        if nil != accept(TokenCurlyLeft.self) {
            throw CompilerError(line: ifToken.lineNumber, message: "expected condition after `\(ifToken.lexeme)'")
        }
        let condition = try consumeExpression()
        
        let thenBranch: AbstractSyntaxTreeNode
        if nil != (peek() as? TokenCurlyLeft) {
            let leftError = "expected `{' after `\(ifToken.lexeme)' condition"
            let rightError = "expected `}' after `then' branch"
            thenBranch = try consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError).first!
        } else {
            try expect(type: TokenNewline.self, error: CompilerError(line: peek()!.lineNumber, message: "expected newline"))
            thenBranch = Block(children: try consumeStatement())
        }
        
        var elseBranch: AbstractSyntaxTreeNode? = nil
        let handleElse = {
            let elseToken = try self.expect(type: TokenElse.self, error: CompilerError(line: self.peek()!.lineNumber, message: "expected `else'"))
            
            if nil != (self.peek() as? TokenCurlyLeft) {
                let leftError = "expected `{' after `\(elseToken.lexeme)'"
                let rightError = "expected `}' after `\(elseToken.lexeme)' branch"
                elseBranch = try self.consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError).first!
            } else {
                try self.expect(type: TokenNewline.self, error: CompilerError(line: self.peek()!.lineNumber, message: "expected newline"))
                elseBranch = Block(children: try self.consumeStatement())
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
        
        return [Block(children: statements)]
    }
    
    private func consumeBlock(errorOnMissingCurlyLeft: String,
                              errorOnMissingCurlyRight: String) throws -> [AbstractSyntaxTreeNode] {
        try expect(type: TokenCurlyLeft.self, error: CompilerError(line: previous!.lineNumber, message: errorOnMissingCurlyLeft))
        
        if nil != accept(TokenCurlyRight.self) {
            return [Block()]
        }
        
        try expect(type: TokenNewline.self, error: CompilerError(line: previous!.lineNumber, message: "expected newline"))
        
        var statements: [AbstractSyntaxTreeNode] = []
        while nil == accept(TokenCurlyRight.self) {
            if nil == peek() || nil != (peek() as? TokenEOF){
                throw CompilerError(line: previous!.lineNumber, message: errorOnMissingCurlyRight)
            }
            statements += try consumeStatement()
        }
        
        return [Block(children: statements)]
    }
    
    private func consumeWhile(_ whileToken: TokenWhile) throws -> [AbstractSyntaxTreeNode] {
        if nil != acceptEndOfStatement() {
            throw CompilerError(line: whileToken.lineNumber, message: "expected condition after `\(whileToken.lexeme)'")
        }
        if nil != accept(TokenCurlyLeft.self) {
            throw CompilerError(line: whileToken.lineNumber, message: "expected condition after `\(whileToken.lexeme)'")
        }
        let condition = try consumeExpression()
        
        let body: AbstractSyntaxTreeNode
        if nil != (peek() as? TokenCurlyLeft) {
            let leftError = "expected `{' after `\(whileToken.lexeme)' condition"
            let rightError = "expected `}' after `\(whileToken.lexeme)' body"
            body = try consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError).first!
        } else {
            try expect(type: TokenNewline.self, error: CompilerError(line: peek()!.lineNumber, message: "expected newline"))
            body = Block(children: try consumeStatement())
        }
        
        return [While(condition: condition, body: body)]
    }
    
    private func consumeForLoop(_ forToken: TokenFor) throws -> [AbstractSyntaxTreeNode] {
        let initializerClause = try consumeStatement(shouldExpectEndOfStatement: false).first!
        try expect(type: TokenSemicolon.self, error: CompilerError(line: forToken.lineNumber, message: "expected `;'"))
        let conditionClause = try consumeExpression()
        try expect(type: TokenSemicolon.self, error: CompilerError(line: forToken.lineNumber, message: "expected `;'"))
        let incrementClause = try consumeStatement(shouldExpectEndOfStatement: false).first!
        
        let body: AbstractSyntaxTreeNode
        if nil != (peek() as? TokenCurlyLeft) {
            let leftError = "expected `{' after `\(forToken.lexeme)' increment clause"
            let rightError = "expected `}' after `\(forToken.lexeme)' body"
            body = try consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError).first!
        } else {
            try expect(type: TokenNewline.self, error: CompilerError(line: peek()!.lineNumber, message: "expected newline"))
            body = Block(children: try consumeStatement())
        }
        
        return [
            Block(children: [
                ForLoop(initializerClause: initializerClause,
                        conditionClause: conditionClause,
                        incrementClause: incrementClause,
                        body: body)
            ])
        ]
    }
    
    private func consumeFunc(_ token: TokenFunc) throws -> [AbstractSyntaxTreeNode] {
        let returnType: SymbolType
        let tokenIdentifier = try expect(type: TokenIdentifier.self, error: CompilerError(line: peek()!.lineNumber, message: "expected identifier in function declaration")) as! TokenIdentifier
        try expect(type: TokenParenLeft.self, error: CompilerError(line: peek()!.lineNumber, message: "expected `(' in argument list of function declaration"))
        
        var arguments: [FunctionType.Argument] = []
        
        if type(of: peek()!) != TokenParenRight.self {
            repeat {
                let tokenIdentifier = try expect(type: TokenIdentifier.self, error: CompilerError(line: peek()!.lineNumber, message: "expected parameter name followed by `:'")) as! TokenIdentifier
                if type(of: peek()!) == TokenParenRight.self || type(of: peek()!) == TokenComma.self {
                    throw CompilerError(line: peek()!.lineNumber, message: "parameter requires an explicit type")
                }
                try expect(type: TokenColon.self, error: CompilerError(line: peek()!.lineNumber, message: "expected parameter name followed by `:'"))
                let tokenType = try expect(type: TokenType.self, error: CompilerError(line: peek()!.lineNumber, message: "")) as! TokenType
                let name = tokenIdentifier.lexeme
                let type = tokenType.representedType
                arguments.append(FunctionType.Argument(name: name, type: type))
            } while nil != accept(TokenComma.self)
        }
        
        try expect(type: TokenParenRight.self, error: CompilerError(line: peek()!.lineNumber, message: "expected `)' in argument list of function declaration"))
        
        if nil == accept(TokenArrow.self) {
            returnType = .void
        } else {
            let typeToken = try expect(type: TokenType.self, error: CompilerError(line: peek()!.lineNumber, message: "use of undeclared type `\(peek()!.lexeme)'")) as! TokenType
            returnType = typeToken.representedType
        }
        let leftError = "expected `{' in body of function declaration"
        let rightError = "expected `}' after function body"
        let body = try consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError).first as! Block
        return [FunctionDeclaration(identifier: tokenIdentifier,
                                    functionType: FunctionType(returnType: returnType,
                                                               arguments: arguments),
                                    body: body)]
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
        var expression = try consumeCast()
        while let tokenOperator = accept(operators: [.multiply, .divide, .modulus]) {
            let right = try consumeCast()
            expression = Expression.Binary(op: tokenOperator, left: expression, right: right)
        }
        return expression
    }
    
    private func consumeCast() throws -> Expression {
        let expr = try consumeUnary()
        if let tokenAs = accept(TokenAs.self) {
            let tokenType = try expect(type: TokenType.self, error: CompilerError(line: peek()!.lineNumber, message: "")) as! TokenType
            return Expression.As(expr: expr, tokenAs: tokenAs as! TokenAs, tokenType: tokenType)
        } else {
            return expr
        }
    }
    
    private func consumeUnary() throws -> Expression {
        if let token = accept(operator: .minus) {
            let right = try consumeUnary()
            return Expression.Unary(op: token, expression: right)
        }
        
        return try consumeSubscript()
    }
    
    private func consumeSubscript() throws -> Expression {
        if (nil != peek(0) as? TokenIdentifier) && (nil != peek(1) as? TokenSquareBracketLeft) {
            let identifier = try expect(type: TokenIdentifier.self, error: CompilerError(line: peek()!.lineNumber, message: "expected identifier")) as! TokenIdentifier
            let leftBracket = try expect(type: TokenSquareBracketLeft.self, error: CompilerError(line: identifier.lineNumber, message: "expected `['")) as! TokenSquareBracketLeft
            let expr = try consumeExpression()
            let rightBracket = try expect(type: TokenSquareBracketRight.self, error: CompilerError(line: leftBracket.lineNumber, message: "expected `]'")) as! TokenSquareBracketRight
            return Expression.Subscript(tokenIdentifier: identifier,
                                        tokenBracketLeft: leftBracket,
                                        expr: expr,
                                        tokenBracketRight: rightBracket)
        } else {
            return try consumeCall()
        }
    }
    
    private func consumeCall() throws -> Expression {
        var expr = try consumePrimary()
        if nil != accept(TokenParenLeft.self) as? TokenParenLeft {
            var arguments: [Expression] = []
            if nil == accept(TokenParenRight.self) as? TokenParenRight {
                repeat {
                    while nil != accept(TokenNewline.self) {}
                    arguments.append(try consumeExpression())
                    while nil != accept(TokenNewline.self) {}
                } while nil != accept(TokenComma.self)
                try expect(type: TokenParenRight.self, error: CompilerError(line: peek()!.lineNumber, message: "expected `)'"))
            }
            expr = Expression.Call(callee: expr, arguments: arguments)
        }
        return expr
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
                                            message: "expected `)' after expression"))
            return expression
        }
        else if let tokenSquareBracketLeft = accept(TokenSquareBracketLeft.self) as? TokenSquareBracketLeft {
            var elements: [Expression] = []
            if nil == (peek() as? TokenSquareBracketRight) {
                repeat {
                    while nil != accept(TokenNewline.self) {}
                    elements.append(try consumeExpression())
                    while nil != accept(TokenNewline.self) {}
                } while nil != accept(TokenComma.self)
            }
            let tokenSquareBracketRight = try expect(type: TokenSquareBracketRight.self, error: CompilerError(line: peek()!.lineNumber, message: "expected `]' after expression")) as! TokenSquareBracketRight
            return Expression.Array(tokenBracketLeft: tokenSquareBracketLeft,
                                    elements: elements,
                                    tokenBracketRight: tokenSquareBracketRight)
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
    
    private func consumeReturn(_ token: TokenReturn) throws -> [AbstractSyntaxTreeNode] {
        if nil == acceptEndOfStatement() {
            return [Return(token: token, expression: try consumeExpression())]
        } else {
            return [Return(token: token, expression: nil)]
        }
    }
}
