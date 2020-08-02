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
        else if let leftBrace = accept(TokenCurlyLeft.self) {
            result = try consumeBlock(leftBrace as! TokenCurlyLeft)
        }
        else if (nil != peek(0) as? TokenIdentifier) && (nil != peek(1) as? TokenColon) {
            let sourceAnchor = peek(0)?.sourceAnchor?.union(peek(1)?.sourceAnchor)
            throw CompilerError(sourceAnchor: sourceAnchor, message: "labels are not supported")
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
            return try consumeLet(token as! TokenLet,
                                  storage: .staticStorage,
                                  storageSpecifier: staticToken)
        } else {
            let token = try expect(type: TokenVar.self, error: CompilerError(sourceAnchor: staticToken.sourceAnchor, message: "expected declaration"))
            return try consumeVar(token as! TokenVar,
                                  storage: .staticStorage,
                                  storageSpecifier: staticToken)
        }
    }
    
    private func consumeLet(_ letToken: TokenLet,
                            storage: SymbolStorage = .stackStorage,
                            storageSpecifier: Token? = nil) throws -> [AbstractSyntaxTreeNode] {
        let isMutable = false
        let errorMessageWhenMissingIdentifier = "expected to find an identifier in let declaration"
        let errorMessageWhenNoInitialValue = "immutable variables must be assigned a value"
        let errorFormatWhenNoInitialValueAfterEqual = "expected value after `%@'"
        return try consumeVar(letToken,
                              errorMessageWhenMissingIdentifier,
                              errorMessageWhenNoInitialValue,
                              errorFormatWhenNoInitialValueAfterEqual,
                              storage,
                              isMutable,
                              storageSpecifier)
    }
    
    private func consumeVar(_ varToken: TokenVar,
                            storage: SymbolStorage = .stackStorage,
                            storageSpecifier: Token? = nil) throws -> [AbstractSyntaxTreeNode] {
        let isMutable = true
        let errorMessageWhenMissingIdentifier = "expected to find an identifier in variable declaration"
        let errorMessageWhenNoInitialValue = "variables must be assigned an initial value"
        let errorFormatWhenNoInitialValueAfterEqual = "expected initial value after `%@'"
        return try consumeVar(varToken,
                              errorMessageWhenMissingIdentifier,
                              errorMessageWhenNoInitialValue,
                              errorFormatWhenNoInitialValueAfterEqual,
                              storage,
                              isMutable,
                              storageSpecifier)
    }
    
    fileprivate func consumeVar(_ letOrVarToken: Token,
                                _ errorMessageWhenMissingIdentifier: String,
                                _ errorMessageWhenNoInitialValue: String,
                                _ errorFormatWhenNoInitialValueAfterEqual: String,
                                _ storage: SymbolStorage,
                                _ isMutable: Bool,
                                _ storageSpecifier: Token?) throws -> [AbstractSyntaxTreeNode] {
        let identifier = try expect(type: TokenIdentifier.self,
                                    error: CompilerError(sourceAnchor: letOrVarToken.sourceAnchor,
                                                         message: errorMessageWhenMissingIdentifier)) as! TokenIdentifier
        
        let explicitType = try consumeTypeAnnotation()
        
        let equal = try expect(type: TokenEqual.self,
                               error: CompilerError(sourceAnchor: identifier.sourceAnchor,
                                                    message: errorMessageWhenNoInitialValue)) as! TokenEqual
        
        if nil != acceptEndOfStatement() {
            throw CompilerError(sourceAnchor: equal.sourceAnchor,
                                format: errorFormatWhenNoInitialValueAfterEqual,
                                equal.lexeme)
        }
        
        let expression = try consumeExpression()
        
        if let arr = expression as? Expression.LiteralArray {
            if arr.elements.count == 0 && explicitType == nil {
                throw CompilerError(sourceAnchor: arr.sourceAnchor,
                                    message: "empty array literal requires an explicit type")
            }
        }
        
        let sourceAnchor = letOrVarToken.sourceAnchor?
            .union(expression.sourceAnchor)
            .union(storageSpecifier?.sourceAnchor)
        return [VarDeclaration(sourceAnchor: sourceAnchor,
                               identifier: Expression.Identifier(sourceAnchor: identifier.sourceAnchor, identifier: identifier.lexeme),
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
        if let _ = peek() as? TokenSquareBracketLeft {
            return try consumeArrayType()
        } else {
            return try consumePrimitiveType()
        }
    }
    
    fileprivate func consumeArrayType() throws -> SymbolType {
        try expect(type: TokenSquareBracketLeft.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `[' in array type"))
        let count: Int?
        if nil != accept(TokenSquareBracketRight.self) {
            let elementType = try consumeType()
            return .dynamicArray(elementType: elementType)
        }
        else {
            if nil != accept(TokenUnderscore.self) {
                count = nil
            } else {
                count = (try expect(type: TokenNumber.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected integer literal for the array count")) as! TokenNumber).literal
            }
            try expect(type: TokenSquareBracketRight.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `]' in array type"))
            let elementType = try consumeType()
            return .array(count: count, elementType: elementType)
        }
    }
    
    fileprivate func consumePrimitiveType() throws -> SymbolType {
        let typeName = peek()?.sourceAnchor?.text ?? "unknown"
        let tokenType = try expect(type: TokenType.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "use of undeclared type `\(typeName)'")) as! TokenType
        let explicitType = tokenType.representedType
        return explicitType
    }
    
    private func consumeIf(_ ifToken: TokenIf) throws -> [AbstractSyntaxTreeNode] {
        if nil != acceptEndOfStatement() {
            let s = ifToken.sourceAnchor?.text ?? "if"
            throw CompilerError(sourceAnchor: ifToken.sourceAnchor, message: "expected condition after `\(s)'")
        }
        if nil != accept(TokenCurlyLeft.self) {
            let s = ifToken.sourceAnchor?.text ?? "if"
            throw CompilerError(sourceAnchor: ifToken.sourceAnchor, message: "expected condition after `\(s)'")
        }
        let condition = try consumeExpression()
        
        let thenBranch: AbstractSyntaxTreeNode
        if nil != (peek() as? TokenCurlyLeft) {
            let leftError = "expected `{' after `\(ifToken.lexeme)' condition"
            let rightError = "expected `}' after `then' branch"
            thenBranch = try consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError).first!
        } else {
            let newline = try expect(type: TokenNewline.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected newline"))
            let children = try consumeStatement()
            let sourceAnchor = children.map({$0.sourceAnchor}).reduce(newline.sourceAnchor, {$0?.union($1)})
            thenBranch = Block(sourceAnchor: sourceAnchor, children: children)
        }
        
        var elseBranch: AbstractSyntaxTreeNode? = nil
        let handleElse = {
            let elseToken = try self.expect(type: TokenElse.self, error: CompilerError(sourceAnchor: self.peek()?.sourceAnchor, message: "expected `else'"))
            
            if nil != (self.peek() as? TokenCurlyLeft) {
                let leftError = "expected `{' after `\(elseToken.lexeme)'"
                let rightError = "expected `}' after `\(elseToken.lexeme)' branch"
                elseBranch = try self.consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError).first!
            } else {
                let newline = try self.expect(type: TokenNewline.self, error: CompilerError(sourceAnchor: self.peek()?.sourceAnchor, message: "expected newline"))
                let children = try self.consumeStatement()
                let sourceAnchor = children.map({$0.sourceAnchor}).reduce(newline.sourceAnchor, {$0?.union($1)})
                elseBranch = Block(sourceAnchor: sourceAnchor, children: children)
            }
        }
        if (nil != peek(0) as? TokenElse) {
            try handleElse()
        } else if (nil != peek(0) as? TokenNewline) && (nil != peek(1) as? TokenElse) {
            try expect(type: TokenNewline.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected newline"))
            try handleElse()
        }
        
        let sourceAnchor = ifToken.sourceAnchor?.union(previous?.sourceAnchor)
        
        return [If(sourceAnchor: sourceAnchor,
                   condition: condition,
                   then: thenBranch,
                   else: elseBranch)]
    }
    
    private func consumeBlock(_ leftBrace: TokenCurlyLeft) throws -> [AbstractSyntaxTreeNode] {
        var statements: [AbstractSyntaxTreeNode] = []
        while nil == accept(TokenCurlyRight.self) {
            if nil == peek() || nil != (peek() as? TokenEOF){
                throw CompilerError(sourceAnchor: previous?.sourceAnchor, message: "expected `}' after block")
            }
            statements += try consumeStatement()
        }
        let sourceAnchor = leftBrace.sourceAnchor?.union(previous?.sourceAnchor)
        return [Block(sourceAnchor: sourceAnchor, children: statements)]
    }
    
    private func consumeBlock(errorOnMissingCurlyLeft: String,
                              errorOnMissingCurlyRight: String) throws -> [AbstractSyntaxTreeNode] {
        let leftCurly = try expect(type: TokenCurlyLeft.self, error: CompilerError(sourceAnchor: previous?.sourceAnchor, message: errorOnMissingCurlyLeft))
        
        if nil != accept(TokenCurlyRight.self) {
            let sourceAnchor = leftCurly.sourceAnchor?.union(previous?.sourceAnchor)
            return [Block(sourceAnchor: sourceAnchor)]
        }
        
        let newline = try expect(type: TokenNewline.self, error: CompilerError(sourceAnchor: previous?.sourceAnchor, message: "expected newline"))
        
        var statements: [AbstractSyntaxTreeNode] = []
        while nil == accept(TokenCurlyRight.self) {
            if nil == peek() || nil != (peek() as? TokenEOF){
                let sourceAnchor: SourceAnchor?
                if let lastStatement = statements.last {
                    sourceAnchor = lastStatement.sourceAnchor
                } else {
                    sourceAnchor = newline.sourceAnchor
                }
                throw CompilerError(sourceAnchor: sourceAnchor, message: errorOnMissingCurlyRight)
            }
            statements += try consumeStatement()
        }
        
        let sourceAnchor = leftCurly.sourceAnchor?.union(previous?.sourceAnchor)
        
        return [Block(sourceAnchor: sourceAnchor, children: statements)]
    }
    
    private func consumeWhile(_ whileToken: TokenWhile) throws -> [AbstractSyntaxTreeNode] {
        if nil != acceptEndOfStatement() {
            throw CompilerError(sourceAnchor: whileToken.sourceAnchor, message: "expected condition after `\(whileToken.lexeme)'")
        }
        if nil != accept(TokenCurlyLeft.self) {
            throw CompilerError(sourceAnchor: whileToken.sourceAnchor, message: "expected condition after `\(whileToken.lexeme)'")
        }
        let condition = try consumeExpression()
        
        let body: AbstractSyntaxTreeNode
        if nil != (peek() as? TokenCurlyLeft) {
            let leftError = "expected `{' after `\(whileToken.lexeme)' condition"
            let rightError = "expected `}' after `\(whileToken.lexeme)' body"
            body = try consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError).first!
        } else {
            let newline = try expect(type: TokenNewline.self, error: CompilerError(sourceAnchor: condition.sourceAnchor, message: "expected newline or curly brace after `while' condition"))
            let sourceAnchor = whileToken.sourceAnchor?.union(newline.sourceAnchor)
            body = Block(sourceAnchor: sourceAnchor, children: try consumeStatement())
        }
        
        let sourceAnchor = whileToken.sourceAnchor?.union(previous?.sourceAnchor)
        return [While(sourceAnchor: sourceAnchor, condition: condition, body: body)]
    }
    
    private func consumeForLoop(_ forToken: TokenFor) throws -> [AbstractSyntaxTreeNode] {
        let initializerClause = try consumeStatement(shouldExpectEndOfStatement: false).first!
        try expect(type: TokenSemicolon.self, error: CompilerError(sourceAnchor: forToken.sourceAnchor, message: "expected `;'"))
        let conditionClause = try consumeExpression()
        try expect(type: TokenSemicolon.self, error: CompilerError(sourceAnchor: forToken.sourceAnchor, message: "expected `;'"))
        let incrementClause = try consumeStatement(shouldExpectEndOfStatement: false).first!
        
        let body: AbstractSyntaxTreeNode
        if nil != (peek() as? TokenCurlyLeft) {
            let leftError = "expected `{' after `\(forToken.lexeme)' increment clause"
            let rightError = "expected `}' after `\(forToken.lexeme)' body"
            body = try consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError).first!
        } else {
            let newline = try expect(type: TokenNewline.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected newline"))
            let sourceAnchor = forToken.sourceAnchor?.union(newline.sourceAnchor)
            body = Block(sourceAnchor: sourceAnchor, children: try consumeStatement())
        }
        
        let sourceAnchor = forToken.sourceAnchor?.union(previous?.sourceAnchor)
        
        return [
            Block(sourceAnchor: sourceAnchor,
                  children: [
                    ForLoop(sourceAnchor: sourceAnchor,
                            initializerClause: initializerClause,
                            conditionClause: conditionClause,
                            incrementClause: incrementClause,
                            body: body)
                ])
        ]
    }
    
    private func consumeFunc(_ token: TokenFunc) throws -> [AbstractSyntaxTreeNode] {
        let returnType: SymbolType
        let tokenIdentifier = try expect(type: TokenIdentifier.self, error: CompilerError(sourceAnchor: token.sourceAnchor, message: "expected identifier in function declaration")) as! TokenIdentifier
        try expect(type: TokenParenLeft.self, error: CompilerError(sourceAnchor: tokenIdentifier.sourceAnchor, message: "expected `(' in argument list of function declaration"))
        
        var arguments: [FunctionType.Argument] = []
        
        if type(of: peek()!) != TokenParenRight.self {
            repeat {
                let tokenIdentifier = try expect(type: TokenIdentifier.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected parameter name followed by `:'")) as! TokenIdentifier
                if type(of: peek()!) == TokenParenRight.self || type(of: peek()!) == TokenComma.self {
                    throw CompilerError(sourceAnchor: tokenIdentifier.sourceAnchor, message: "parameter requires an explicit type")
                }
                guard let type = try consumeTypeAnnotation() else {
                    throw CompilerError(sourceAnchor: previous?.sourceAnchor, message: "expected parameter name followed by `:'")
                }
                let name = tokenIdentifier.lexeme
                arguments.append(FunctionType.Argument(name: name, type: type))
            } while nil != accept(TokenComma.self)
        }
        
        try expect(type: TokenParenRight.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `)' in argument list of function declaration"))
        
        if nil == accept(TokenArrow.self) {
            returnType = .void
        } else {
            returnType = try consumeType()
        }
        let leftError = "expected `{' in body of function declaration"
        let rightError = "expected `}' after function body"
        let body = try consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError).first as! Block
        let sourceAnchor = token.sourceAnchor?.union(previous?.sourceAnchor)
        return [FunctionDeclaration(sourceAnchor: sourceAnchor,
                                    identifier: Expression.Identifier(sourceAnchor: tokenIdentifier.sourceAnchor, identifier: tokenIdentifier.lexeme),
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
        return CompilerError(sourceAnchor: token.sourceAnchor, message: "expected to find the end of the statement: `\(token.lexeme)'")
    }
    
    private func consumeExpression() throws -> Expression {
        return try consumeComparison()
    }
    
    private func consumeComparison() throws -> Expression {
        var expression = try consumeAssignment()
        while let tokenOperator = accept(operators: [.eq, .ne, .lt, .gt, .le, .ge]) {
            let right = try consumeAssignment()
            let sourceAnchor = expression.sourceAnchor?.union(right.sourceAnchor)
            expression = Expression.Binary(sourceAnchor: sourceAnchor,
                                           op: tokenOperator.op,
                                           left: expression,
                                           right: right)
        }
        return expression
    }
    
    private func consumeAssignment() throws -> Expression {
        let lexpr = try consumeAddition()
        if nil != accept(TokenEqual.self) {
            let rexpr = try consumeAddition()
            let sourceAnchor = lexpr.sourceAnchor?.union(rexpr.sourceAnchor)
            let expression = Expression.Assignment(sourceAnchor: sourceAnchor,
                                                   lexpr: lexpr,
                                                   rexpr: rexpr)
            return expression
        }
        return lexpr
    }
    
    private func consumeAddition() throws -> Expression {
        var expression = try consumeMultiplication()
        while let tokenOperator = accept(operators: [.plus, .minus]) {
            let right = try consumeMultiplication()
            let sourceAnchor = expression.sourceAnchor?.union(right.sourceAnchor)
            expression = Expression.Binary(sourceAnchor: sourceAnchor,
                                           op: tokenOperator.op,
                                           left: expression, right: right)
        }
        return expression
    }
    
    private func consumeMultiplication() throws -> Expression {
        var expression = try consumeCast()
        while let tokenOperator = accept(operators: [.multiply, .divide, .modulus]) {
            let right = try consumeCast()
            let sourceAnchor = expression.sourceAnchor?.union(right.sourceAnchor)
            expression = Expression.Binary(sourceAnchor: sourceAnchor,
                                           op: tokenOperator.op,
                                           left: expression,
                                           right: right)
        }
        return expression
    }
    
    private func consumeCast() throws -> Expression {
        let expr = try consumeUnary()
        if let tokenAs = accept(TokenAs.self) as? TokenAs {
            let targetType = try consumeType()
            let sourceAnchor = expr.sourceAnchor?.union(tokenAs.sourceAnchor).union(previous?.sourceAnchor)
            return Expression.As(sourceAnchor: sourceAnchor,
                                 expr: expr,
                                 targetType: targetType)
        } else {
            return expr
        }
    }
    
    private func consumeUnary() throws -> Expression {
        if let token = accept(operator: .minus) {
            let right = try consumeUnary()
            let sourceAnchor = token.sourceAnchor?.union(right.sourceAnchor)
            return Expression.Unary(sourceAnchor: sourceAnchor,
                                    op: token.op,
                                    expression: right)
        }
        
        return try consumeSubscript()
    }
    
    private func consumeSubscript() throws -> Expression {
        if (nil != peek(0) as? TokenIdentifier) && (nil != peek(1) as? TokenSquareBracketLeft) {
            let identifier = try expect(type: TokenIdentifier.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected identifier")) as! TokenIdentifier
            let leftBracket = try expect(type: TokenSquareBracketLeft.self, error: CompilerError(sourceAnchor: identifier.sourceAnchor, message: "expected `['")) as! TokenSquareBracketLeft
            let expr = try consumeExpression()
            let rightBracket = try expect(type: TokenSquareBracketRight.self, error: CompilerError(sourceAnchor: leftBracket.sourceAnchor, message: "expected `]'")) as! TokenSquareBracketRight
            let sourceAnchor = identifier.sourceAnchor?.union(rightBracket.sourceAnchor)
            return Expression.Subscript(sourceAnchor: sourceAnchor,
                                        identifier: Expression.Identifier(sourceAnchor: identifier.sourceAnchor, identifier: identifier.lexeme),
                                        expr: expr)
        } else {
            return try consumeCall()
        }
    }
    
    private func consumeCall() throws -> Expression {
        var expr = try consumePrimary()
        while true {
            if nil != accept(TokenParenLeft.self) as? TokenParenLeft {
                var arguments: [Expression] = []
                if nil == accept(TokenParenRight.self) as? TokenParenRight {
                    repeat {
                        while nil != accept(TokenNewline.self) {}
                        arguments.append(try consumeExpression())
                        while nil != accept(TokenNewline.self) {}
                    } while nil != accept(TokenComma.self)
                    try expect(type: TokenParenRight.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `)'"))
                }
                let sourceAnchor = expr.sourceAnchor?.union(previous?.sourceAnchor)
                expr = Expression.Call(sourceAnchor: sourceAnchor,
                                       callee: expr,
                                       arguments: arguments)
            }
            else if let dot = accept(TokenDot.self) as? TokenDot {
                let lexeme = dot.sourceAnchor?.text ?? "."
                let error = CompilerError(sourceAnchor: dot.sourceAnchor,
                                          message: "expected member name following `\(lexeme)'")
                let identifierToken = try expect(type: TokenIdentifier.self, error: error)
                let member = Expression.Identifier(sourceAnchor: identifierToken.sourceAnchor,
                                                   identifier: identifierToken.lexeme)
                let sourceAnchor = expr.sourceAnchor?.union(member.sourceAnchor)
                expr = Expression.Get(sourceAnchor: sourceAnchor,
                                      expr: expr,
                                      member: member)
            }
            else {
                break
            }
        }
        return expr
    }
    
    private func consumePrimary() throws -> Expression {
        if let numberToken = accept(TokenNumber.self) as? TokenNumber {
            return Expression.LiteralInt(sourceAnchor: numberToken.sourceAnchor,
                                          value: numberToken.literal)
        }
        else if let booleanToken = accept(TokenBoolean.self) as? TokenBoolean {
            return Expression.LiteralBool(sourceAnchor: booleanToken.sourceAnchor,
                                             value: booleanToken.literal)
        }
        else if let identifierToken = accept(TokenIdentifier.self) as? TokenIdentifier {
            return Expression.Identifier(sourceAnchor: identifierToken.sourceAnchor,
                                         identifier: identifierToken.lexeme)
        }
        else if let leftParen = accept(TokenParenLeft.self) as? TokenParenLeft {
            let expression = try consumeExpression()
            let rightParen = try expect(type: TokenParenRight.self,
                       error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `)' after expression"))
            let sourceAnchor = leftParen.sourceAnchor?.union(rightParen.sourceAnchor)
            return Expression.Group(sourceAnchor: sourceAnchor, expression: expression)
        }
        else if let squareBracketLeft = peek() as? TokenSquareBracketLeft {
            let typ = try consumeArrayType()
            let explicitCount: Int?
            let explicitType: SymbolType
            switch typ {
            case .array(count: let n, elementType: let a):
                explicitCount = n
                explicitType = a
            default:
                abort()
            }
            
            try expect(type: TokenCurlyLeft.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `{' in array literal"))
            var elements: [Expression] = []
            if nil == (peek() as? TokenCurlyRight) {
                repeat {
                    while nil != accept(TokenNewline.self) {}
                    elements.append(try consumeExpression())
                    while nil != accept(TokenNewline.self) {}
                } while nil != accept(TokenComma.self)
            }
            try expect(type: TokenCurlyRight.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `}' in array literal"))
            
            let sourceAnchor = squareBracketLeft.sourceAnchor?.union(previous?.sourceAnchor)
            return Expression.LiteralArray(sourceAnchor: sourceAnchor,
                                           explicitType: explicitType,
                                           explicitCount: explicitCount,
                                           elements: elements)
        }
        else if let literalString = accept(TokenLiteralString.self) as? TokenLiteralString {
            let sourceAnchor = literalString.sourceAnchor
            let elements = literalString.literal.utf8.map({
                Expression.LiteralInt(sourceAnchor: sourceAnchor, value: Int($0))
            })
            return Expression.LiteralArray(sourceAnchor: sourceAnchor,
                                           explicitType: .u8,
                                           explicitCount: nil,
                                           elements: elements)
        }
        else if let token = peek() {
            throw operandTypeMismatchError(token)
        } else {
            throw unexpectedEndOfInputError()
        }
    }
    
    private func useOfUnresolvedIdentifierError(_ instruction: Token) -> Error {
        return CompilerError(sourceAnchor: instruction.sourceAnchor, message: "use of unresolved identifier: `\(instruction.lexeme)'")
    }
    
    private func operandTypeMismatchError(_ instruction: Token) -> Error {
        let str = String(instruction.sourceAnchor?.text ?? "")
        return CompilerError(sourceAnchor: instruction.sourceAnchor, message: "operand type mismatch: `\(str)'")
    }
    
    private func consumeReturn(_ token: TokenReturn) throws -> [AbstractSyntaxTreeNode] {
        if nil == acceptEndOfStatement() {
            return [Return(sourceAnchor: token.sourceAnchor, expression: try consumeExpression())]
        } else {
            return [Return(sourceAnchor: token.sourceAnchor, expression: nil)]
        }
    }
}
