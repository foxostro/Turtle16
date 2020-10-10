//
//  SnapParser.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

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
        else if let token = accept(TokenStatic.self) as? TokenStatic {
            result = try consumeStatic(token)
        }
        else if let token = accept(TokenPublic.self) as? TokenPublic {
            result = try consumePublic(token)
        }
        else if let token = accept(TokenPrivate.self) as? TokenPrivate {
            result = try consumePrivate(token)
        }
        else if let token = accept(TokenLet.self) as? TokenLet {
            result = try consumeLet(token)
        }
        else if let token = accept(TokenVar.self) as? TokenVar {
            result = try consumeVar(token)
        }
        else if let token = accept(TokenIf.self) as? TokenIf {
            result = try consumeIf(token)
        }
        else if let token = accept(TokenWhile.self) as? TokenWhile {
            result = try consumeWhile(token)
        }
        else if let token = accept(TokenFor.self) as? TokenFor {
            result = try consumeForIn(token)
        }
        else if let leftBrace = accept(TokenCurlyLeft.self) as? TokenCurlyLeft {
            result = try consumeBlock(leftBrace)
        }
        else if (nil != peek(0) as? TokenIdentifier) && (nil != peek(1) as? TokenColon) {
            let sourceAnchor = peek(0)?.sourceAnchor?.union(peek(1)?.sourceAnchor)
            throw CompilerError(sourceAnchor: sourceAnchor, message: "labels are not supported")
        }
        else if let token = accept(TokenFunc.self) as? TokenFunc {
            result = try consumeFunc(token)
        }
        else if let token = accept(TokenReturn.self) as? TokenReturn {
            result = try consumeReturn(token)
        }
        else if let token = accept(TokenStruct.self) as? TokenStruct {
            result = try consumeStruct(token)
        }
        else if let token = accept(TokenImpl.self) as? TokenImpl {
            result = try consumeImpl(token)
        }
        else if let token = accept(TokenTypealias.self) as? TokenTypealias {
            result = try consumeTypealias(token)
        }
        else if let token = accept(TokenMatch.self) as? TokenMatch {
            result = try consumeMatch(token)
        }
        else if let token = accept(TokenAssert.self) as? TokenAssert {
            result = try consumeAssert(token)
        }
        else if let token = accept(TokenTest.self) as? TokenTest {
            result = try consumeTest(token)
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
        let visibility: SymbolVisibility
        if nil != accept(TokenPublic.self) {
            visibility = .publicVisibility
        } else if nil != accept(TokenPrivate.self) {
            visibility = .privateVisibility
        } else {
            visibility = .privateVisibility
        }
        
        if let token = accept(TokenLet.self) {
            return try consumeLet(token as! TokenLet,
                                  storage: .staticStorage,
                                  firstSpeciferToken: staticToken,
                                  visibility: visibility)
        } else {
            let token = try expect(type: TokenVar.self, error: CompilerError(sourceAnchor: staticToken.sourceAnchor, message: "expected declaration"))
            return try consumeVar(token as! TokenVar,
                                  storage: .staticStorage,
                                  firstSpeciferToken: staticToken,
                                  visibility: visibility)
        }
    }
    
    private func consumePublic(_ publicToken: TokenPublic) throws -> [AbstractSyntaxTreeNode] {
        return try consumeVisibilitySpecifier(publicToken, .publicVisibility)
    }
    
    private func consumePrivate(_ privateToken: TokenPrivate) throws -> [AbstractSyntaxTreeNode] {
        return try consumeVisibilitySpecifier(privateToken, .privateVisibility)
    }
    
    public func consumeVisibilitySpecifier(_ visibilityToken: Token, _ visibility: SymbolVisibility) throws -> [AbstractSyntaxTreeNode] {
        if let _ = accept(TokenStatic.self) as? TokenStatic {
            if let token = accept(TokenLet.self) as? TokenLet {
                return try consumeLet(token,
                                      storage: .staticStorage,
                                      firstSpeciferToken: visibilityToken,
                                      visibility: visibility)
            } else {
                let token = try expect(type: TokenVar.self, error: CompilerError(sourceAnchor: visibilityToken.sourceAnchor, message: "expected declaration")) as! TokenVar
                return try consumeVar(token,
                                      storage: .staticStorage,
                                      firstSpeciferToken: visibilityToken,
                                      visibility: visibility)
            }
        }
        else if let token = accept(TokenLet.self) as? TokenLet {
            return try consumeLet(token,
                                  storage: .stackStorage,
                                  firstSpeciferToken: visibilityToken,
                                  visibility: visibility)
        }
        else if let token = accept(TokenVar.self) as? TokenVar {
            return try consumeVar(token,
                                  storage: .stackStorage,
                                  firstSpeciferToken: visibilityToken,
                                  visibility: visibility)
        }
        else if let _ = accept(TokenFunc.self) as? TokenFunc {
            return try consumeFunc(visibilityToken, visibility)
        }
        else if let _ = accept(TokenStruct.self) as? TokenStruct {
            return try consumeStruct(visibilityToken, visibility)
        }
        else if let _ = accept(TokenTypealias.self) as? TokenTypealias {
            return try consumeTypealias(visibilityToken, visibility)
        }
        else {
            throw CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "unexpected token following `\(visibilityToken.lexeme)' specifier")
        }
    }
    
    private func consumeLet(_ letToken: TokenLet,
                            storage: SymbolStorage = .stackStorage,
                            firstSpeciferToken: Token? = nil,
                            visibility: SymbolVisibility = .privateVisibility) throws -> [AbstractSyntaxTreeNode] {
        let isMutable = false
        let errorMessageWhenMissingIdentifier = "expected to find an identifier in let declaration"
        let errorMessageWhenNoInitialValue = "constants must be assigned a value"
        let errorFormatWhenNoInitialValueAfterEqual = "expected value after `%@'"
        return try consumeVar(letToken,
                              errorMessageWhenMissingIdentifier,
                              errorMessageWhenNoInitialValue,
                              errorFormatWhenNoInitialValueAfterEqual,
                              storage,
                              isMutable,
                              firstSpeciferToken,
                              visibility)
    }
    
    private func consumeVar(_ varToken: TokenVar,
                            storage: SymbolStorage = .stackStorage,
                            firstSpeciferToken: Token? = nil,
                            visibility: SymbolVisibility = .privateVisibility) throws -> [AbstractSyntaxTreeNode] {
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
                              firstSpeciferToken,
                              visibility)
    }
    
    fileprivate func consumeVar(_ letOrVarToken: Token,
                                _ errorMessageWhenMissingIdentifier: String,
                                _ errorMessageWhenNoInitialValue: String,
                                _ errorFormatWhenNoInitialValueAfterEqual: String,
                                _ storage: SymbolStorage,
                                _ isMutable: Bool,
                                _ firstSpeciferToken: Token?,
                                _ visibility: SymbolVisibility) throws -> [AbstractSyntaxTreeNode] {
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
        
        let expression: Expression?
        let exprSourceAnchor: SourceAnchor
        if let token = accept(TokenUndefined.self) {
            expression = nil
            exprSourceAnchor = token.sourceAnchor!
        } else {
            expression = try consumeExpression()
            exprSourceAnchor = expression!.sourceAnchor!
        }
        
        if let arr = expression as? Expression.LiteralArray {
            if arr.elements.count == 0 && explicitType == nil {
                throw CompilerError(sourceAnchor: arr.sourceAnchor,
                                    message: "empty array literal requires an explicit type")
            }
        }
        
        let sourceAnchor = letOrVarToken.sourceAnchor?
            .union(exprSourceAnchor)
            .union(firstSpeciferToken?.sourceAnchor)
        return [VarDeclaration(sourceAnchor: sourceAnchor,
                               identifier: Expression.Identifier(sourceAnchor: identifier.sourceAnchor, identifier: identifier.lexeme),
                               explicitType: explicitType,
                               expression: expression,
                               storage: storage,
                               isMutable: isMutable,
                               visibility: visibility)]
    }
    
    fileprivate func consumeTypeAnnotation() throws -> Expression? {
        guard nil != accept(TokenColon.self) else {
            return nil
        }
        return try consumeUnionType()
    }
    
    fileprivate func consumeType() throws -> Expression {
        return try consumeUnionType()
    }
    
    fileprivate func consumeUnionType() throws -> Expression {
        var members: [Expression] = [try consumeConstType()]
        while let _ = accept(operator: .pipe) {
            let expr = try consumeConstType()
            members.append(expr)
        }
        if members.count == 1 {
            return members[0]
        } else {
            let sourceAnchor = members.first?.sourceAnchor?.union(members.last?.sourceAnchor)
            return Expression.UnionType(sourceAnchor: sourceAnchor, members: members)
        }
    }
    
    fileprivate func consumeConstType() throws -> Expression {
        if let constToken = accept(TokenConst.self) {
            let expr = try consumeTypeWithoutRegardForConst()
            let sourceAnchor = constToken.sourceAnchor?.union(expr.sourceAnchor)
            return Expression.ConstType(sourceAnchor: sourceAnchor, typ: expr)
        } else {
            return try consumeTypeWithoutRegardForConst()
        }
    }
    
    fileprivate func consumeTypeWithoutRegardForConst() throws -> Expression {
        if let star = accept(operator: .star) {
            return try consumePointerType(star)
        } else if let _ = peek() as? TokenSquareBracketLeft {
            return try consumeArrayType()
        } else if let identifier = accept(TokenIdentifier.self) as? TokenIdentifier {
            return Expression.Identifier(sourceAnchor: identifier.sourceAnchor,
                                         identifier: identifier.lexeme)
        } else {
            return try consumePrimitiveType()
        }
    }
    
    fileprivate func consumePointerType(_ star: Token) throws -> Expression {
        let typ = try consumeConstType()
        let sourceAnchor = star.sourceAnchor?.union(typ.sourceAnchor)
        return Expression.PointerType(sourceAnchor: sourceAnchor, typ: typ)
    }
    
    fileprivate func consumeArrayType() throws -> Expression {
        try expect(type: TokenSquareBracketLeft.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `[' in array type"))
        if nil != accept(TokenSquareBracketRight.self) {
            let elementType = try consumeType()
            return Expression.DynamicArrayType(elementType)
        }
        else {
            let count: Expression?
            if nil != accept(TokenUnderscore.self) {
                count = nil
            } else {
                count = try consumeExpression()
            }
            try expect(type: TokenSquareBracketRight.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `]' in array type"))
            let elementType = try consumeType()
            return Expression.ArrayType(count: count, elementType: elementType)
        }
    }
    
    fileprivate func consumePrimitiveType() throws -> Expression {
        let typeName = peek()?.sourceAnchor?.text ?? "unknown"
        let tokenType = try expect(type: TokenType.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "use of undeclared type `\(typeName)'")) as! TokenType
        let explicitType = tokenType.representedType
        return Expression.PrimitiveType(sourceAnchor: tokenType.sourceAnchor, typ: explicitType)
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
        let condition = try consumeExpression(allowsStructInitializer: false)
        
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
                let children = try self.consumeStatement()
                if children.isEmpty {
                    throw self.unexpectedEndOfInputError()
                }
                let sourceAnchor = children.map({$0.sourceAnchor}).reduce(children.first?.sourceAnchor, {$0?.union($1)})
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
        let condition = try consumeExpression(allowsStructInitializer: false)
        
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
    
    private func consumeForIn(_ forToken: TokenFor) throws -> [AbstractSyntaxTreeNode] {
        let identifierToken = try expect(type: TokenIdentifier.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected identifier in for-in loop"))
        let identifier = Expression.Identifier(sourceAnchor: identifierToken.sourceAnchor, identifier: identifierToken.lexeme)
        _ = try expect(type: TokenIn.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected the `in' keyword following identifier in for-in loop"))
        let sequenceExpr = try consumeExpression(allowsStructInitializer: false)
        
        let body: Block
        if nil != (peek() as? TokenCurlyLeft) {
            let leftError = "expected `{' after sequence in for-in loop"
            let rightError = "expected `}' after body of for-in loop"
            body = try consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError).first! as! Block
        } else {
            let newline = try expect(type: TokenNewline.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected newline"))
            let sourceAnchor = forToken.sourceAnchor?.union(newline.sourceAnchor)
            body = Block(sourceAnchor: sourceAnchor, children: try consumeStatement())
        }
        
        let sourceAnchor = forToken.sourceAnchor?.union(previous?.sourceAnchor)
        
        return [
            ForIn(sourceAnchor: sourceAnchor,
                  identifier: identifier,
                  sequenceExpr: sequenceExpr,
                  body: body)
        ]
    }
    
    private func consumeFunc(_ firstToken: Token, _ visibility: SymbolVisibility = .privateVisibility) throws -> [AbstractSyntaxTreeNode] {
        let tokenIdentifier = try expect(type: TokenIdentifier.self, error: CompilerError(sourceAnchor: firstToken.sourceAnchor, message: "expected identifier in function declaration")) as! TokenIdentifier
        try expect(type: TokenParenLeft.self, error: CompilerError(sourceAnchor: tokenIdentifier.sourceAnchor, message: "expected `(' in argument list of function declaration"))
        
        var arguments: [Expression.FunctionType.Argument] = []
        
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
                arguments.append(Expression.FunctionType.Argument(name: name, type: type))
            } while nil != accept(TokenComma.self)
        }
        
        try expect(type: TokenParenRight.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `)' in argument list of function declaration"))
        
        let returnType: Expression
        if nil == accept(TokenArrow.self) {
            returnType = Expression.PrimitiveType(.void)
        } else {
            returnType = try consumeType()
        }
        
        let leftError = "expected `{' in body of function declaration"
        let rightError = "expected `}' after function body"
        let body = try consumeBlock(errorOnMissingCurlyLeft: leftError, errorOnMissingCurlyRight: rightError).first as! Block
        let sourceAnchor = firstToken.sourceAnchor?.union(previous?.sourceAnchor)
        return [FunctionDeclaration(sourceAnchor: sourceAnchor,
                                    identifier: Expression.Identifier(sourceAnchor: tokenIdentifier.sourceAnchor, identifier: tokenIdentifier.lexeme),
                                    functionType: Expression.FunctionType(name: tokenIdentifier.lexeme, returnType: returnType, arguments: arguments),
                                    body: body,
                                    visibility: visibility)]
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
    
    private var isStructInitializerExpressionAllowed: [Bool] = [true]
    
    private func consumeExpression(allowsStructInitializer: Bool = true) throws -> Expression {
        isStructInitializerExpressionAllowed.append(allowsStructInitializer)
        let expr = try consumeComparison()
        isStructInitializerExpressionAllowed.removeLast()
        return expr
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
        while let tokenOperator = accept(operators: [.star, .divide, .modulus]) {
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
        if let token = accept(operators: [.minus, .ampersand]) {
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
            return try consumeIs()
        }
    }
    
    private func consumeIs() throws -> Expression {
        let expr = try consumeCall()
        if nil != accept(TokenIs.self) {
            let testType = try consumeType()
            return Expression.Is(sourceAnchor: expr.sourceAnchor?.union(testType.sourceAnchor), expr: expr, testType: testType)
        }
        return expr
    }
    
    private func consumeCall() throws -> Expression {
        var expr = try consumeRange()
        while true {
            if nil != accept(TokenParenLeft.self) as? TokenParenLeft {
                var arguments: [Expression] = []
                if nil == accept(TokenParenRight.self) as? TokenParenRight {
                    repeat {
                        arguments.append(try consumeExpression())
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
    
    private func consumeRange() throws -> Expression {
        let beginExpr = try consumePrimary()
        if nil != accept(TokenDoubleDot.self) {
            let limitExpr = try consumePrimary()
            let sourceAnchor = beginExpr.sourceAnchor?.union(limitExpr.sourceAnchor)
            typealias Arg = Expression.StructInitializer.Argument
            return Expression.StructInitializer(sourceAnchor: sourceAnchor,
                                                identifier: Expression.Identifier("Range"),
                                                arguments: [
                                                    Arg(name: "begin", expr: beginExpr),
                                                    Arg(name: "limit", expr: limitExpr)
                                                ])
        }
        return beginExpr
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
        else if isStructInitializerExpressionAllowed.last!==true, let _ = peek(0) as? TokenIdentifier, let _ = peek(1) as? TokenCurlyLeft {
            return try consumeStructInitializer()
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
            try expect(type: TokenCurlyLeft.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `{' in array literal"))
            var elements: [Expression] = []
            if nil == (peek() as? TokenCurlyRight) {
                repeat {
                    elements.append(try consumeExpression())
                } while nil != accept(TokenComma.self)
            }
            try expect(type: TokenCurlyRight.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `}' in array literal"))
            
            let sourceAnchor = squareBracketLeft.sourceAnchor?.union(previous?.sourceAnchor)
            return Expression.LiteralArray(sourceAnchor: sourceAnchor,
                                           arrayType: typ,
                                           elements: elements)
        }
        else if let literalString = accept(TokenLiteralString.self) as? TokenLiteralString {
            return Expression.LiteralString(sourceAnchor: literalString.sourceAnchor,
                                            value: literalString.literal)
        }
        else if let token = peek() {
            if token is TokenEOF {
                throw unexpectedEndOfInputError()
            } else {
                throw operandTypeMismatchError(token)
            }
        } else {
            throw unexpectedEndOfInputError()
        }
    }
    
    private func consumeStructInitializer() throws -> Expression {
        let identifierToken = try expect(type: TokenIdentifier.self, error: CompilerError(message: "expected identifier"))
        try expect(type: TokenCurlyLeft.self, error: CompilerError(message: "expected `{'"))
        let identifier = Expression.Identifier(sourceAnchor: identifierToken.sourceAnchor, identifier: identifierToken.lexeme)
        var arguments: [Expression.StructInitializer.Argument] = []
        
        if nil == accept(TokenCurlyRight.self) {
            repeat {
                try expect(type: TokenDot.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "malformed argument to struct initializer: expected `.'"))
                
                let argumentIdentifier = try expect(type: TokenIdentifier.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "malformed argument to struct initializer: expected identifier"))
                
                try expect(type: TokenEqual.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "malformed argument to struct initializer: expected `='"))
                
                if nil != accept(TokenCurlyRight.self) {
                    throw CompilerError(sourceAnchor: previous?.sourceAnchor, message: "malformed argument to struct initializer: expected expression")
                }
                
                let argumentExpression = try consumeExpression()
                
                let argument = Expression.StructInitializer.Argument(name: argumentIdentifier.lexeme, expr: argumentExpression)
                
                arguments.append(argument)
            } while nil != accept(TokenComma.self)
            
            let sourceAnchor = identifierToken.sourceAnchor?.union(peek()?.sourceAnchor)
            try expect(type: TokenCurlyRight.self, error: CompilerError(sourceAnchor: sourceAnchor, message: "expected `}' in struct initializer expression"))
        }
        
        return Expression.StructInitializer(sourceAnchor: identifierToken.sourceAnchor?.union(previous?.sourceAnchor),
                                            identifier: identifier,
                                            arguments: arguments)
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
            let expr = try consumeExpression()
            let sourceAnchor = token.sourceAnchor?.union(expr.sourceAnchor)
            return [Return(sourceAnchor: sourceAnchor, expression: expr)]
        } else {
            return [Return(sourceAnchor: token.sourceAnchor, expression: nil)]
        }
    }
    
    private func consumeStruct(_ firstToken: Token, _ visibility: SymbolVisibility = .privateVisibility) throws -> [AbstractSyntaxTreeNode] {
        let identifierToken = try expect(type: TokenIdentifier.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected identifier in struct declaration"))
        let identifier = Expression.Identifier(sourceAnchor: identifierToken.sourceAnchor, identifier: identifierToken.lexeme)
        
        try expect(type: TokenCurlyLeft.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `{' in struct"))
        
        var members: [StructDeclaration.Member] = []
        repeat {
            if let tokenIdentifier = accept(TokenIdentifier.self) {
                if type(of: peek()!) == TokenParenRight.self || type(of: peek()!) == TokenComma.self {
                    throw CompilerError(sourceAnchor: tokenIdentifier.sourceAnchor, message: "member requires an explicit type")
                }
                guard let typeExpr = try consumeTypeAnnotation() else {
                    throw CompilerError(sourceAnchor: previous?.sourceAnchor, message: "expected member name followed by `:'")
                }
                let name = tokenIdentifier.lexeme
                members.append(StructDeclaration.Member(name: name, type: typeExpr))
            }
        } while(nil != accept(TokenComma.self))
        
        let closingBrace = try expect(type: TokenCurlyRight.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `}' in struct"))
        
        let sourceAnchor = firstToken.sourceAnchor?.union(closingBrace.sourceAnchor!)
        return [StructDeclaration(sourceAnchor: sourceAnchor,
                                  identifier: identifier,
                                  members: members,
                                  visibility: visibility)]
    }
    
    private func consumeImpl(_ tokenImpl: TokenImpl) throws -> [AbstractSyntaxTreeNode] {
        let identifierToken = try expect(type: TokenIdentifier.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected identifier in impl declaration"))
        let identifier = Expression.Identifier(sourceAnchor: identifierToken.sourceAnchor, identifier: identifierToken.lexeme)
        try expect(type: TokenCurlyLeft.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `{' in impl declaration"))
        try expect(type: TokenNewline.self, error: CompilerError(sourceAnchor: previous?.sourceAnchor, message: "expected newline"))
        
        var children: [FunctionDeclaration] = []
        while (true) {
            if let token = accept([TokenStatic.self, TokenLet.self, TokenVar.self, TokenIf.self, TokenWhile.self, TokenFor.self, TokenReturn.self, TokenStruct.self]) {
                throw CompilerError(sourceAnchor: token.sourceAnchor, message: "`\(token.lexeme)' is not permitted in impl declaration")
            }
            else if let token = accept(TokenCurlyLeft.self) {
                throw CompilerError(sourceAnchor: token.sourceAnchor, message: "block is not permitted in impl declaration")
            }
            else if let token = accept(TokenImpl.self) {
                throw CompilerError(sourceAnchor: token.sourceAnchor, message: "impl declarations may not contain other impl declarations")
            }
            else if let token = accept(TokenFunc.self) {
                let child = try consumeFunc(token as! TokenFunc)
                children += child.compactMap({$0 as? FunctionDeclaration})
            }
            else if nil != accept(TokenCurlyRight.self) {
                let sourceAnchor = tokenImpl.sourceAnchor?.union(previous?.sourceAnchor)
                return [Impl(sourceAnchor: sourceAnchor, identifier: identifier, children: children)]
            }
            else {
                let expr = try consumeExpression()
                throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "expression statement is not permitted in impl declaration")
            }
            try expectEndOfStatement()
        }
    }
    
    private func consumeTypealias(_ firstToken: Token, _ visibility: SymbolVisibility = .privateVisibility) throws -> [AbstractSyntaxTreeNode] {
        let identifierToken = try expect(type: TokenIdentifier.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected identifier in typealias declaration"))
        let identifier = Expression.Identifier(sourceAnchor: identifierToken.sourceAnchor, identifier: identifierToken.lexeme)
        try expect(type: TokenEqual.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `=' in typealias declaration"))
        let expr = try consumeType()
        return [Typealias(sourceAnchor: firstToken.sourceAnchor?.union(expr.sourceAnchor),
                          lexpr: identifier,
                          rexpr: expr,
                          visibility: visibility)]
    }
    
    private func consumeMatch(_ tokenMatch: TokenMatch) throws -> [AbstractSyntaxTreeNode] {
        let expr = try consumeExpression(allowsStructInitializer: false)
        try expect(type: TokenCurlyLeft.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `{' in match statement"))
        var elseClause: Block? = nil
        var clauses: [Match.Clause] = []
        while let leftParen = accept(TokenParenLeft.self) {
            let maybeIdentifier = try consumeExpression()
            guard let valueIdentifier = maybeIdentifier as? Expression.Identifier else {
                throw CompilerError(sourceAnchor: maybeIdentifier.sourceAnchor, message: "expected identifier in match statement clause")
            }
            let maybeType = try consumeTypeAnnotation()
            guard let valueType = maybeType else {
                throw CompilerError(sourceAnchor: maybeIdentifier.sourceAnchor, message: "expected type annotation in match statement clause")
            }
            try expect(type: TokenParenRight.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `)' in match statement clause"))
            try expect(type: TokenArrow.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `->' in match statement clause"))
            let leftBrace = try expect(type: TokenCurlyLeft.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `{' in match statement clause")) as! TokenCurlyLeft
            let blockStmts = try consumeBlock(leftBrace)
            let block = blockStmts.first as! Block
            clauses.append(Match.Clause(sourceAnchor: leftParen.sourceAnchor?.union(block.sourceAnchor),
                                        valueIdentifier: valueIdentifier,
                                        valueType: valueType,
                                        block: block))
            
            // The list of clauses is comma-separated.
            if nil == accept(TokenComma.self) {
                break
            }
        }
        if nil != accept(TokenElse.self) {
            try expect(type: TokenArrow.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `->' in match statement else-clause"))
            let leftBrace = try expect(type: TokenCurlyLeft.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `{' in match statement else-clause")) as! TokenCurlyLeft
            let blockStmts = try consumeBlock(leftBrace)
            elseClause = blockStmts.first as? Block
        }
        try expect(type: TokenCurlyRight.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `}' in match statement"))
        return [Match(sourceAnchor: tokenMatch.sourceAnchor?.union(previous?.sourceAnchor),
                      expr: expr,
                      clauses: clauses,
                      elseClause: elseClause)]
    }
    
    private func consumeAssert(_ tokenAssert: TokenAssert) throws -> [AbstractSyntaxTreeNode] {
        try expect(type: TokenParenLeft.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `(' in assert statement"))
        if nil != accept(TokenParenRight.self) {
            let sourceAnchor = tokenAssert.sourceAnchor?.union(previous?.sourceAnchor)
            throw CompilerError(sourceAnchor: sourceAnchor, message: "expected expression in assert statement")
        }
        let condition = try consumeExpression()
        let rightParen = try expect(type: TokenParenRight.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `)' in assert statement"))
        let conditionText = String(condition.sourceAnchor!.text)
        let lineNumber = Int(condition.sourceAnchor!.lineNumbers!.startIndex) + 1
        let message = "assertion failed: `\(conditionText)' on line \(lineNumber)"
        let sourceAnchor = tokenAssert.sourceAnchor?.union(rightParen.sourceAnchor)
        return [Assert(sourceAnchor: sourceAnchor,
                       condition: condition,
                       message: message)]
    }
    
    private func consumeTest(_ tokenTest: TokenTest) throws -> [AbstractSyntaxTreeNode] {
        let name = try expect(type: TokenLiteralString.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected test name in test declaration")) as! TokenLiteralString
        let leftBrace = try expect(type: TokenCurlyLeft.self, error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `{' in test declaration")) as! TokenCurlyLeft
        let body = try consumeBlock(leftBrace).first as! Block
        let sourceAnchor = tokenTest.sourceAnchor?.union(body.sourceAnchor)
        return [TestDeclaration(sourceAnchor: sourceAnchor, name: name.literal, body: body)]
    }
}
