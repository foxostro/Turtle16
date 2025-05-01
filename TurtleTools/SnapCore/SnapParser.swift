//
//  SnapParser.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapParser: Parser {
    public final override func consumeStatement() throws -> [AbstractSyntaxTreeNode] {
        try consumeStatement(shouldExpectEndOfStatement: true)
    }

    public final func consumeStatement(
        shouldExpectEndOfStatement: Bool
    ) throws -> [AbstractSyntaxTreeNode] {
        var shouldExpectEndOfStatement = shouldExpectEndOfStatement
        let result: [AbstractSyntaxTreeNode]
        if nil != accept(TokenEOF.self) {
            result = []
            shouldExpectEndOfStatement = false
        } else if let token = accept(TokenStatic.self) as? TokenStatic {
            result = try consumeStatic(token)
        } else if let token = accept(TokenPublic.self) as? TokenPublic {
            result = try consumePublic(token)
        } else if let token = accept(TokenPrivate.self) as? TokenPrivate {
            result = try consumePrivate(token)
        } else if let token = accept(TokenLet.self) as? TokenLet {
            result = try consumeLet(token)
        } else if let token = accept(TokenVar.self) as? TokenVar {
            result = try consumeVar(token)
        } else if let token = accept(TokenIf.self) as? TokenIf {
            result = try consumeIf(token)
        } else if let token = accept(TokenWhile.self) as? TokenWhile {
            result = try consumeWhile(token)
        } else if let token = accept(TokenFor.self) as? TokenFor {
            result = try consumeForIn(token)
        } else if let leftBrace = accept(TokenCurlyLeft.self) as? TokenCurlyLeft {
            result = try consumeBlock(leftBrace)
        } else if (nil != peek(0) as? TokenIdentifier) && (nil != peek(1) as? TokenColon) {
            let sourceAnchor = peek(0)?.sourceAnchor?.union(peek(1)?.sourceAnchor)
            throw CompilerError(sourceAnchor: sourceAnchor, message: "labels are not supported")
        } else if let token = accept(TokenFunc.self) as? TokenFunc {
            result = try consumeFunc(token)
        } else if let token = accept(TokenReturn.self) as? TokenReturn {
            result = try consumeReturn(token)
        } else if let token = accept(TokenStruct.self) as? TokenStruct {
            result = try consumeStruct(token)
        } else if let token = accept(TokenTrait.self) as? TokenTrait {
            result = try consumeTrait(token)
        } else if let token = accept(TokenImpl.self) as? TokenImpl {
            result = try consumeImpl(token)
        } else if let token = accept(TokenTypealias.self) as? TokenTypealias {
            result = try consumeTypealias(token)
        } else if let token = accept(TokenMatch.self) as? TokenMatch {
            result = try consumeMatch(token)
        } else if let token = accept(TokenAssert.self) as? TokenAssert {
            result = try consumeAssert(token)
        } else if let token = accept(TokenTest.self) as? TokenTest {
            result = try consumeTest(token)
        } else if let token = accept(TokenImport.self) as? TokenImport {
            result = try consumeImport(token)
        } else if let token = accept(TokenAsm.self) as? TokenAsm {
            result = try consumeAsm(token)
        } else {
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

        guard let token = accept(TokenLet.self) else {
            let token = try expect(
                type: TokenVar.self,
                error: CompilerError(
                    sourceAnchor: staticToken.sourceAnchor,
                    message: "expected declaration"
                )
            )
            return try consumeVar(
                token as! TokenVar,
                storage: .staticStorage(offset: nil),
                firstSpeciferToken: staticToken,
                visibility: visibility
            )
        }
        return try consumeLet(
            token as! TokenLet,
            storage: .staticStorage(offset: nil),
            firstSpeciferToken: staticToken,
            visibility: visibility
        )
    }

    private func consumePublic(_ publicToken: TokenPublic) throws -> [AbstractSyntaxTreeNode] {
        try consumeVisibilitySpecifier(publicToken, .publicVisibility)
    }

    private func consumePrivate(_ privateToken: TokenPrivate) throws -> [AbstractSyntaxTreeNode] {
        try consumeVisibilitySpecifier(privateToken, .privateVisibility)
    }

    public func consumeVisibilitySpecifier(
        _ visibilityToken: Token,
        _ visibility: SymbolVisibility
    ) throws -> [AbstractSyntaxTreeNode] {
        if accept(TokenStatic.self) as? TokenStatic != nil {
            guard let token = accept(TokenLet.self) as? TokenLet else {
                let token =
                    try expect(
                        type: TokenVar.self,
                        error: CompilerError(
                            sourceAnchor: visibilityToken.sourceAnchor,
                            message: "expected declaration"
                        )
                    ) as! TokenVar
                return try consumeVar(
                    token,
                    storage: .staticStorage(offset: nil),
                    firstSpeciferToken: visibilityToken,
                    visibility: visibility
                )
            }
            return try consumeLet(
                token,
                storage: .staticStorage(offset: nil),
                firstSpeciferToken: visibilityToken,
                visibility: visibility
            )
        } else if let token = accept(TokenLet.self) as? TokenLet {
            return try consumeLet(
                token,
                storage: .automaticStorage(offset: nil),
                firstSpeciferToken: visibilityToken,
                visibility: visibility
            )
        } else if let token = accept(TokenVar.self) as? TokenVar {
            return try consumeVar(
                token,
                storage: .automaticStorage(offset: nil),
                firstSpeciferToken: visibilityToken,
                visibility: visibility
            )
        } else if accept(TokenFunc.self) as? TokenFunc != nil {
            return try consumeFunc(visibilityToken, visibility)
        } else if accept(TokenStruct.self) as? TokenStruct != nil {
            return try consumeStruct(visibilityToken, visibility)
        } else if accept(TokenTrait.self) as? TokenTrait != nil {
            return try consumeTrait(visibilityToken, visibility)
        } else if accept(TokenTypealias.self) as? TokenTypealias != nil {
            return try consumeTypealias(visibilityToken, visibility)
        } else {
            throw CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "unexpected token following `\(visibilityToken.lexeme)' specifier"
            )
        }
    }

    private func consumeLet(
        _ letToken: TokenLet,
        storage: SymbolStorage = .automaticStorage(offset: nil),
        firstSpeciferToken: Token? = nil,
        visibility: SymbolVisibility = .privateVisibility
    ) throws -> [AbstractSyntaxTreeNode] {
        let isMutable = false
        let errorMessageWhenMissingIdentifier = "expected to find an identifier in let declaration"
        let errorMessageWhenNoInitialValue = "constants must be assigned a value"
        let errorFormatWhenNoInitialValueAfterEqual = "expected value after `%@'"
        return try consumeVar(
            letToken,
            errorMessageWhenMissingIdentifier,
            errorMessageWhenNoInitialValue,
            errorFormatWhenNoInitialValueAfterEqual,
            storage,
            isMutable,
            firstSpeciferToken,
            visibility
        )
    }

    private func consumeVar(
        _ varToken: TokenVar,
        storage: SymbolStorage = .automaticStorage(offset: nil),
        firstSpeciferToken: Token? = nil,
        visibility: SymbolVisibility = .privateVisibility
    ) throws -> [AbstractSyntaxTreeNode] {
        let isMutable = true
        let errorMessageWhenMissingIdentifier =
            "expected to find an identifier in variable declaration"
        let errorMessageWhenNoInitialValue = "variables must be assigned an initial value"
        let errorFormatWhenNoInitialValueAfterEqual = "expected initial value after `%@'"
        return try consumeVar(
            varToken,
            errorMessageWhenMissingIdentifier,
            errorMessageWhenNoInitialValue,
            errorFormatWhenNoInitialValueAfterEqual,
            storage,
            isMutable,
            firstSpeciferToken,
            visibility
        )
    }

    fileprivate func consumeVar(
        _ letOrVarToken: Token,
        _ errorMessageWhenMissingIdentifier: String,
        _ errorMessageWhenNoInitialValue: String,
        _ errorFormatWhenNoInitialValueAfterEqual: String,
        _ storage: SymbolStorage,
        _ isMutable: Bool,
        _ firstSpeciferToken: Token?,
        _ visibility: SymbolVisibility
    ) throws -> [AbstractSyntaxTreeNode] {
        let identifier =
            try expect(
                type: TokenIdentifier.self,
                error: CompilerError(
                    sourceAnchor: letOrVarToken.sourceAnchor,
                    message: errorMessageWhenMissingIdentifier
                )
            ) as! TokenIdentifier

        let explicitType = try consumeTypeAnnotation()

        let equal =
            try expect(
                type: TokenEqual.self,
                error: CompilerError(
                    sourceAnchor: identifier.sourceAnchor,
                    message: errorMessageWhenNoInitialValue
                )
            ) as! TokenEqual

        if nil != acceptEndOfStatement() {
            throw CompilerError(
                sourceAnchor: equal.sourceAnchor,
                format: errorFormatWhenNoInitialValueAfterEqual,
                equal.lexeme
            )
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

        if let arr = expression as? LiteralArray {
            if arr.elements.count == 0 && explicitType == nil {
                throw CompilerError(
                    sourceAnchor: arr.sourceAnchor,
                    message: "empty array literal requires an explicit type"
                )
            }
        }

        let sourceAnchor = letOrVarToken.sourceAnchor?
            .union(exprSourceAnchor)
            .union(firstSpeciferToken?.sourceAnchor)
        return [
            VarDeclaration(
                sourceAnchor: sourceAnchor,
                identifier: Identifier(
                    sourceAnchor: identifier.sourceAnchor,
                    identifier: identifier.lexeme
                ),
                explicitType: explicitType,
                expression: expression,
                storage: storage,
                isMutable: isMutable,
                visibility: visibility
            )
        ]
    }

    fileprivate func consumeTypeAnnotation() throws -> Expression? {
        guard nil != accept(TokenColon.self) else {
            return nil
        }
        return try consumeUnionType()
    }

    fileprivate func consumeType() throws -> Expression {
        try consumeUnionType()
    }

    fileprivate func consumeUnionType() throws -> Expression {
        var members: [Expression] = [try consumeConstType()]
        while accept(operator: .pipe) != nil {
            let expr = try consumeConstType()
            members.append(expr)
        }
        guard members.count == 1 else {
            let sourceAnchor = members.first?.sourceAnchor?.union(members.last?.sourceAnchor)
            return UnionType(sourceAnchor: sourceAnchor, members: members)
        }
        return members[0]
    }

    fileprivate func consumeConstType() throws -> Expression {
        guard let constToken = accept(TokenConst.self) else {
            return try consumeTypeWithoutRegardForConst()
        }
        let expr = try consumeTypeWithoutRegardForConst()
        let sourceAnchor = constToken.sourceAnchor?.union(expr.sourceAnchor)
        return ConstType(sourceAnchor: sourceAnchor, typ: expr)
    }

    fileprivate func consumeTypeWithoutRegardForConst() throws -> Expression {
        if let star = accept(operator: .star) {
            return try consumePointerType(star)
        } else if peek() as? TokenSquareBracketLeft != nil {
            return try consumeArrayType()
        } else if peek() as? TokenFunc != nil {
            return try consumeFunctionPointerType()
        } else if let app = try consumeGenericTypeApplication() {
            return app
        } else if let identifier = accept(TokenIdentifier.self) as? TokenIdentifier {
            return Identifier(
                sourceAnchor: identifier.sourceAnchor,
                identifier: identifier.lexeme
            )
        } else {
            return try consumePrimitiveType()
        }
    }

    fileprivate func consumePointerType(_ star: Token) throws -> Expression {
        let typ = try consumeConstType()
        let sourceAnchor = star.sourceAnchor?.union(typ.sourceAnchor)
        return PointerType(sourceAnchor: sourceAnchor, typ: typ)
    }

    fileprivate func consumeArrayType() throws -> Expression {
        let tokenBracketLeft = try expect(
            type: TokenSquareBracketLeft.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `[' in array type"
            )
        )
        guard nil != accept(TokenSquareBracketRight.self) else {
            let count: Expression?
            if nil != accept(TokenUnderscore.self) {
                count = nil
            } else {
                count = try consumeExpression()
            }
            try expect(
                type: TokenSquareBracketRight.self,
                error: CompilerError(
                    sourceAnchor: peek()?.sourceAnchor,
                    message: "expected `]' in array type"
                )
            )
            let elementType = try consumeConstType()
            let sourceAnchor = tokenBracketLeft.sourceAnchor?.union(elementType.sourceAnchor)
            return ArrayType(sourceAnchor: sourceAnchor, count: count, elementType: elementType)
        }
        let elementType = try consumeConstType()
        let sourceAnchor = tokenBracketLeft.sourceAnchor?.union(elementType.sourceAnchor)
        return DynamicArrayType(sourceAnchor: sourceAnchor, elementType: elementType)
    }

    private func consumeFunctionPointerType() throws -> Expression {
        let funcKeywordToken = try expect(
            type: TokenFunc.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected the `func' keyword"
            )
        )
        try expect(
            type: TokenParenLeft.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `(' in argument list of function pointer type expression"
            )
        )

        var arguments: [Expression] = []

        if type(of: peek()!) != TokenParenRight.self {
            repeat {
                let argumentType = try consumeType()
                arguments.append(argumentType)
            } while nil != accept(TokenComma.self)
        }

        try expect(
            type: TokenParenRight.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `)' in argument list of function pointer type expression"
            )
        )

        let returnType: Expression
        if nil == accept(TokenArrow.self) {
            returnType = PrimitiveType(.void)
        } else {
            returnType = try consumeType()
        }

        let sourceAnchor = funcKeywordToken.sourceAnchor?.union(previous?.sourceAnchor)
        return PointerType(
            sourceAnchor: sourceAnchor,
            typ: FunctionType(
                sourceAnchor: sourceAnchor,
                name: nil,
                returnType: returnType,
                arguments: arguments
            )
        )
    }

    private func consumePrimitiveType() throws -> Expression {
        let tokenType =
            try expect(
                type: TokenType.self,
                error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected a type")
            ) as! TokenType
        let explicitType = tokenType.representedType
        return PrimitiveType(sourceAnchor: tokenType.sourceAnchor, typ: explicitType)
    }

    private func consumeIf(_ ifToken: TokenIf) throws -> [AbstractSyntaxTreeNode] {
        if nil != acceptEndOfStatement() {
            let s = ifToken.sourceAnchor?.text ?? "if"
            throw CompilerError(
                sourceAnchor: ifToken.sourceAnchor,
                message: "expected condition after `\(s)'"
            )
        }
        if nil != accept(TokenCurlyLeft.self) {
            let s = ifToken.sourceAnchor?.text ?? "if"
            throw CompilerError(
                sourceAnchor: ifToken.sourceAnchor,
                message: "expected condition after `\(s)'"
            )
        }
        let condition = try consumeExpression(allowsStructInitializer: false)

        let thenBranch: AbstractSyntaxTreeNode
        if nil != (peek() as? TokenCurlyLeft) {
            let leftError = "expected `{' after `\(ifToken.lexeme)' condition"
            let rightError = "expected `}' after `then' branch"
            thenBranch = try consumeBlock(
                errorOnMissingCurlyLeft: leftError,
                errorOnMissingCurlyRight: rightError
            ).first!
        } else {
            let newline = try expect(
                type: TokenNewline.self,
                error: CompilerError(
                    sourceAnchor: peek()?.sourceAnchor,
                    message: "expected newline"
                )
            )
            let children = try consumeStatement()
            let sourceAnchor = children.map({ $0.sourceAnchor }).reduce(
                newline.sourceAnchor,
                { $0?.union($1) }
            )
            thenBranch = Block(sourceAnchor: sourceAnchor, children: children)
        }

        var elseBranch: AbstractSyntaxTreeNode? = nil
        let handleElse = {
            let elseToken = try self.expect(
                type: TokenElse.self,
                error: CompilerError(
                    sourceAnchor: self.peek()?.sourceAnchor,
                    message: "expected `else'"
                )
            )

            if nil != (self.peek() as? TokenCurlyLeft) {
                let leftError = "expected `{' after `\(elseToken.lexeme)'"
                let rightError = "expected `}' after `\(elseToken.lexeme)' branch"
                elseBranch = try self.consumeBlock(
                    errorOnMissingCurlyLeft: leftError,
                    errorOnMissingCurlyRight: rightError
                ).first!
            } else {
                let children = try self.consumeStatement()
                if children.isEmpty {
                    throw self.unexpectedEndOfInputError()
                }
                let sourceAnchor = children.map({ $0.sourceAnchor }).reduce(
                    children.first?.sourceAnchor,
                    { $0?.union($1) }
                )
                elseBranch = Block(sourceAnchor: sourceAnchor, children: children)
            }
        }
        if nil != peek(0) as? TokenElse {
            try handleElse()
        } else if (nil != peek(0) as? TokenNewline) && (nil != peek(1) as? TokenElse) {
            try expect(
                type: TokenNewline.self,
                error: CompilerError(
                    sourceAnchor: peek()?.sourceAnchor,
                    message: "expected newline"
                )
            )
            try handleElse()
        }

        let sourceAnchor = ifToken.sourceAnchor?.union(previous?.sourceAnchor)

        return [
            If(
                sourceAnchor: sourceAnchor,
                condition: condition,
                then: thenBranch,
                else: elseBranch
            )
        ]
    }

    private func consumeBlock(_ leftBrace: TokenCurlyLeft) throws -> [AbstractSyntaxTreeNode] {
        var statements: [AbstractSyntaxTreeNode] = []
        while nil == accept(TokenCurlyRight.self) {
            if nil == peek() || nil != (peek() as? TokenEOF) {
                throw CompilerError(
                    sourceAnchor: previous?.sourceAnchor,
                    message: "expected `}' after block"
                )
            }
            statements += try consumeStatement()
        }
        let sourceAnchor = leftBrace.sourceAnchor?.union(previous?.sourceAnchor)
        return [Block(sourceAnchor: sourceAnchor, children: statements)]
    }

    private func consumeBlock(
        errorOnMissingCurlyLeft: String,
        errorOnMissingCurlyRight: String
    ) throws -> [AbstractSyntaxTreeNode] {
        let leftCurly = try expect(
            type: TokenCurlyLeft.self,
            error: CompilerError(
                sourceAnchor: previous?.sourceAnchor,
                message: errorOnMissingCurlyLeft
            )
        )

        if nil != accept(TokenCurlyRight.self) {
            let sourceAnchor = leftCurly.sourceAnchor?.union(previous?.sourceAnchor)
            return [Block(sourceAnchor: sourceAnchor)]
        }

        let newline = try expect(
            type: TokenNewline.self,
            error: CompilerError(sourceAnchor: previous?.sourceAnchor, message: "expected newline")
        )

        var statements: [AbstractSyntaxTreeNode] = []
        while nil == accept(TokenCurlyRight.self) {
            if nil == peek() || nil != (peek() as? TokenEOF) {
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
            throw CompilerError(
                sourceAnchor: whileToken.sourceAnchor,
                message: "expected condition after `\(whileToken.lexeme)'"
            )
        }
        if nil != accept(TokenCurlyLeft.self) {
            throw CompilerError(
                sourceAnchor: whileToken.sourceAnchor,
                message: "expected condition after `\(whileToken.lexeme)'"
            )
        }
        let condition = try consumeExpression(allowsStructInitializer: false)

        let body: AbstractSyntaxTreeNode
        if nil != (peek() as? TokenCurlyLeft) {
            let leftError = "expected `{' after `\(whileToken.lexeme)' condition"
            let rightError = "expected `}' after `\(whileToken.lexeme)' body"
            body = try consumeBlock(
                errorOnMissingCurlyLeft: leftError,
                errorOnMissingCurlyRight: rightError
            ).first!
        } else {
            let newline = try expect(
                type: TokenNewline.self,
                error: CompilerError(
                    sourceAnchor: condition.sourceAnchor,
                    message: "expected newline or curly brace after `while' condition"
                )
            )
            let sourceAnchor = whileToken.sourceAnchor?.union(newline.sourceAnchor)
            body = Block(sourceAnchor: sourceAnchor, children: try consumeStatement())
        }

        let sourceAnchor = whileToken.sourceAnchor?.union(previous?.sourceAnchor)
        return [While(sourceAnchor: sourceAnchor, condition: condition, body: body)]
    }

    private func consumeForIn(_ forToken: TokenFor) throws -> [AbstractSyntaxTreeNode] {
        let identifierToken = try expect(
            type: TokenIdentifier.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected identifier in for-in loop"
            )
        )
        let identifier = Identifier(
            sourceAnchor: identifierToken.sourceAnchor,
            identifier: identifierToken.lexeme
        )
        _ = try expect(
            type: TokenIn.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected the `in' keyword following identifier in for-in loop"
            )
        )
        let sequenceExpr = try consumeExpression(allowsStructInitializer: false)

        let body: Block
        if nil != (peek() as? TokenCurlyLeft) {
            let leftError = "expected `{' after sequence in for-in loop"
            let rightError = "expected `}' after body of for-in loop"
            body =
                try consumeBlock(
                    errorOnMissingCurlyLeft: leftError,
                    errorOnMissingCurlyRight: rightError
                ).first! as! Block
        } else {
            let newline = try expect(
                type: TokenNewline.self,
                error: CompilerError(
                    sourceAnchor: peek()?.sourceAnchor,
                    message: "expected newline"
                )
            )
            let sourceAnchor = forToken.sourceAnchor?.union(newline.sourceAnchor)
            body = Block(sourceAnchor: sourceAnchor, children: try consumeStatement())
        }

        let sourceAnchor = forToken.sourceAnchor?.union(previous?.sourceAnchor)

        return [
            ForIn(
                sourceAnchor: sourceAnchor,
                identifier: identifier,
                sequenceExpr: sequenceExpr,
                body: body
            )
        ]
    }

    private func consumeFunc(
        _ firstToken: Token,
        _ visibility: SymbolVisibility = .privateVisibility
    ) throws -> [AbstractSyntaxTreeNode] {
        let tokenIdentifier =
            try expect(
                type: TokenIdentifier.self,
                error: CompilerError(
                    sourceAnchor: firstToken.sourceAnchor,
                    message: "expected identifier in function declaration"
                )
            ) as! TokenIdentifier

        let typeArguments = try consumeOptionalTypeArgumentListWithConstraints()

        try expect(
            type: TokenParenLeft.self,
            error: CompilerError(
                sourceAnchor: tokenIdentifier.sourceAnchor,
                message: "expected `(' in argument list of function declaration"
            )
        )

        var argumentNames: [String] = []
        var argumentTypes: [Expression] = []

        if type(of: peek()!) != TokenParenRight.self {
            repeat {
                let tokenIdentifier =
                    try expect(
                        type: TokenIdentifier.self,
                        error: CompilerError(
                            sourceAnchor: peek()?.sourceAnchor,
                            message: "expected parameter name followed by `:'"
                        )
                    ) as! TokenIdentifier
                if type(of: peek()!) == TokenParenRight.self || type(of: peek()!) == TokenComma.self
                {
                    throw CompilerError(
                        sourceAnchor: tokenIdentifier.sourceAnchor,
                        message: "parameter requires an explicit type"
                    )
                }
                guard let type = try consumeTypeAnnotation() else {
                    throw CompilerError(
                        sourceAnchor: previous?.sourceAnchor,
                        message: "expected parameter name followed by `:'"
                    )
                }
                let name = tokenIdentifier.lexeme
                argumentNames.append(name)
                argumentTypes.append(type)
            } while nil != accept(TokenComma.self)
        }

        try expect(
            type: TokenParenRight.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `)' in argument list of function declaration"
            )
        )

        let returnType: Expression
        if nil == accept(TokenArrow.self) {
            returnType = PrimitiveType(.void)
        } else {
            returnType = try consumeType()
        }

        let leftError = "expected `{' in body of function declaration"
        let rightError = "expected `}' after function body"
        let body =
            try consumeBlock(
                errorOnMissingCurlyLeft: leftError,
                errorOnMissingCurlyRight: rightError
            ).first as! Block
        let sourceAnchor = firstToken.sourceAnchor?.union(previous?.sourceAnchor)
        return [
            FunctionDeclaration(
                sourceAnchor: sourceAnchor,
                identifier: Identifier(
                    sourceAnchor: tokenIdentifier.sourceAnchor,
                    identifier: tokenIdentifier.lexeme
                ),
                functionType: FunctionType(
                    sourceAnchor: sourceAnchor,
                    name: tokenIdentifier.lexeme,
                    returnType: returnType,
                    arguments: argumentTypes
                ),
                argumentNames: argumentNames,
                typeArguments: typeArguments,
                body: body,
                visibility: visibility
            )
        ]
    }

    private func consumeOptionalTypeArgumentListWithConstraints() throws -> [GenericTypeArgument] {
        guard nil != accept(TokenSquareBracketLeft.self) else {
            return []
        }

        var arguments: [GenericTypeArgument] = []

        repeat {
            if let identifierToken = accept(TokenIdentifier.self) as? TokenIdentifier {
                let ident = Identifier(
                    sourceAnchor: identifierToken.sourceAnchor,
                    identifier: identifierToken.lexeme
                )

                var constraints: [Identifier] = []
                if nil != accept(TokenColon.self) {
                    repeat {
                        let identifierToken =
                            try expect(
                                type: TokenIdentifier.self,
                                error: CompilerError(
                                    sourceAnchor: peek()?.sourceAnchor,
                                    message: "expected identifier in generic type constraint"
                                )
                            ) as! TokenIdentifier
                        let ident = Identifier(
                            sourceAnchor: identifierToken.sourceAnchor,
                            identifier: identifierToken.lexeme
                        )
                        constraints.append(ident)
                    } while nil != accept(operator: .plus)
                }

                let sourceAnchor = ident.sourceAnchor?.union(constraints.last?.sourceAnchor)
                let arg = GenericTypeArgument(
                    sourceAnchor: sourceAnchor,
                    identifier: ident,
                    constraints: constraints
                )
                arguments.append(arg)
            }
        } while nil != accept(TokenComma.self)

        try expect(
            type: TokenSquareBracketRight.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `]' in type argument list"
            )
        )

        return arguments
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
        try expect(
            types: [TokenNewline.self, TokenEOF.self],
            error: expectedEndOfStatementError(next)
        )
    }

    private func expectedEndOfStatementError(_ token: Token) -> Error {
        CompilerError(
            sourceAnchor: token.sourceAnchor,
            message: "expected to find the end of the statement: `\(token.lexeme)'"
        )
    }

    private func consumeExpression(allowsStructInitializer: Bool = true) throws -> Expression {
        pushAllowStructInitializer(allowsStructInitializer)
        let expr = try consumeAssignment()
        popAllowStructInitializer()
        return expr
    }

    private func consumeAssignment() throws -> Expression {
        let lexpr = try consumeLogicalOperator()
        if nil != accept(TokenEqual.self) {
            let rexpr = try consumeLogicalOperator()
            let sourceAnchor = lexpr.sourceAnchor?.union(rexpr.sourceAnchor)
            let expression = Assignment(
                sourceAnchor: sourceAnchor,
                lexpr: lexpr,
                rexpr: rexpr
            )
            return expression
        }
        return lexpr
    }

    private func consumeLogicalOperator() throws -> Expression {
        var expression = try consumeBitwiseOperator()
        while let tokenOperator = accept(operators: [.doubleAmpersand, .doublePipe]) {
            let right = try consumeBitwiseOperator()
            let sourceAnchor = expression.sourceAnchor?.union(right.sourceAnchor)
            expression = Binary(
                sourceAnchor: sourceAnchor,
                op: tokenOperator.op,
                left: expression,
                right: right
            )
        }
        return expression
    }

    private func consumeBitwiseOperator() throws -> Expression {
        var expression = try consumeRelationalOperator()
        while let tokenOperator = accept(operators: [.pipe, .caret, .ampersand]) {
            let right = try consumeRelationalOperator()
            let sourceAnchor = expression.sourceAnchor?.union(right.sourceAnchor)
            expression = Binary(
                sourceAnchor: sourceAnchor,
                op: tokenOperator.op,
                left: expression,
                right: right
            )
        }
        return expression
    }

    private func consumeRelationalOperator() throws -> Expression {
        var expression = try consumeBitwiseShift()
        while let tokenOperator = accept(operators: [.ne, .eq, .gt, .ge, .lt, .le]) {
            let right = try consumeBitwiseShift()
            let sourceAnchor = expression.sourceAnchor?.union(right.sourceAnchor)
            expression = Binary(
                sourceAnchor: sourceAnchor,
                op: tokenOperator.op,
                left: expression,
                right: right
            )
        }
        return expression
    }

    private func consumeBitwiseShift() throws -> Expression {
        var expression = try consumeAddition()
        while let tokenOperator = accept(operators: [.leftDoubleAngle, .rightDoubleAngle]) {
            let right = try consumeAddition()
            let sourceAnchor = expression.sourceAnchor?.union(right.sourceAnchor)
            expression = Binary(
                sourceAnchor: sourceAnchor,
                op: tokenOperator.op,
                left: expression,
                right: right
            )
        }
        return expression
    }

    private func consumeAddition() throws -> Expression {
        var expression = try consumeMultiplication()
        while let tokenOperator = accept(operators: [.plus, .minus]) {
            let right = try consumeMultiplication()
            let sourceAnchor = expression.sourceAnchor?.union(right.sourceAnchor)
            expression = Binary(
                sourceAnchor: sourceAnchor,
                op: tokenOperator.op,
                left: expression,
                right: right
            )
        }
        return expression
    }

    private func consumeMultiplication() throws -> Expression {
        var expression = try consumeBitcast()
        while let tokenOperator = accept(operators: [.star, .divide, .modulus]) {
            let right = try consumeBitcast()
            let sourceAnchor = expression.sourceAnchor?.union(right.sourceAnchor)
            expression = Binary(
                sourceAnchor: sourceAnchor,
                op: tokenOperator.op,
                left: expression,
                right: right
            )
        }
        return expression
    }

    private func consumeBitcast() throws -> Expression {
        let expr = try consumeCast()
        guard let tokenBitcastAs = accept(TokenBitcastAs.self) as? TokenBitcastAs else {
            return expr
        }
        let targetType = try consumeType()
        let sourceAnchor = expr.sourceAnchor?.union(tokenBitcastAs.sourceAnchor).union(
            previous?.sourceAnchor
        )
        return Bitcast(
            sourceAnchor: sourceAnchor,
            expr: expr,
            targetType: targetType
        )
    }

    private func consumeCast() throws -> Expression {
        let expr = try consumeUnary()
        guard let tokenAs = accept(TokenAs.self) as? TokenAs else {
            return expr
        }
        let targetType = try consumeType()
        let sourceAnchor = expr.sourceAnchor?.union(tokenAs.sourceAnchor).union(
            previous?.sourceAnchor
        )
        return As(
            sourceAnchor: sourceAnchor,
            expr: expr,
            targetType: targetType
        )
    }

    private func consumeUnary() throws -> Expression {
        if let token = accept(operators: [.ampersand, .tilde, .bang, .minus]) {
            let right = try consumeUnary()
            let sourceAnchor = token.sourceAnchor?.union(right.sourceAnchor)
            return Unary(
                sourceAnchor: sourceAnchor,
                op: token.op,
                expression: right
            )
        }

        return try consumeSubscript()
    }

    private func consumeSubscript() throws -> Expression {
        let expr = try consumeIs()

        guard nil != accept(TokenSquareBracketLeft.self) else {
            return expr
        }
        let argument = try consumeExpression()
        let rightBracket =
            try expect(
                type: TokenSquareBracketRight.self,
                error: CompilerError(sourceAnchor: peek()?.sourceAnchor, message: "expected `]'")
            ) as! TokenSquareBracketRight
        let sourceAnchor = expr.sourceAnchor?.union(rightBracket.sourceAnchor)
        return Subscript(sourceAnchor: sourceAnchor, subscriptable: expr, argument: argument)
    }

    private func consumeIs() throws -> Expression {
        let expr = try consumeRange()
        if nil != accept(TokenIs.self) {
            let testType = try consumeType()
            return Is(
                sourceAnchor: expr.sourceAnchor?.union(testType.sourceAnchor),
                expr: expr,
                testType: testType
            )
        }
        return expr
    }

    private var isStructInitializerExpressionAllowed: [Bool] = [true]

    private func pushAllowStructInitializer(_ allowStructInitializer: Bool) {
        isStructInitializerExpressionAllowed.append(allowStructInitializer)
    }

    private func popAllowStructInitializer() {
        isStructInitializerExpressionAllowed.removeLast()
    }

    private func consumeRange() throws -> Expression {
        let beginExpr = try consumeSizeof()
        if nil != accept(TokenDoubleDot.self) {
            pushAllowStructInitializer(false)
            let limitExpr = try consumeCall()
            popAllowStructInitializer()
            let sourceAnchor = beginExpr.sourceAnchor?.union(limitExpr.sourceAnchor)
            typealias Arg = StructInitializer.Argument
            return StructInitializer(
                sourceAnchor: sourceAnchor,
                identifier: Identifier("Range"),
                arguments: [
                    Arg(name: "begin", expr: beginExpr),
                    Arg(name: "limit", expr: limitExpr),
                ]
            )
        }
        return beginExpr
    }

    private func consumeSizeof() throws -> Expression {
        guard let token = accept([TokenSizeof.self]) else {
            return try consumeCall()
        }
        try expect(
            type: TokenParenLeft.self,
            error: CompilerError(
                sourceAnchor: token.sourceAnchor,
                message: "expected `(' in sizeof expression"
            )
        )
        let expr: Expression
        do {
            expr = try consumeExpression()
        } catch _ as CompilerError {
            expr = try consumeType()  // try again as a type expression
        }
        let rparen = try expect(
            type: TokenParenRight.self,
            error: CompilerError(
                sourceAnchor: token.sourceAnchor,
                message: "expected `)' in sizeof expression"
            )
        )
        let sourceAnchor = token.sourceAnchor?.union(rparen.sourceAnchor)
        return SizeOf(sourceAnchor: sourceAnchor, expr: expr)
    }

    private func consumeCall() throws -> Expression {
        var expr = try consumeStructInitializer()
        while true {
            if nil != accept(TokenParenLeft.self) as? TokenParenLeft {
                var arguments: [Expression] = []
                if nil == accept(TokenParenRight.self) as? TokenParenRight {
                    repeat {
                        arguments.append(try consumeExpression())
                    } while nil != accept(TokenComma.self)
                    try expect(
                        type: TokenParenRight.self,
                        error: CompilerError(
                            sourceAnchor: peek()?.sourceAnchor,
                            message: "expected `)'"
                        )
                    )
                }
                let sourceAnchor = expr.sourceAnchor?.union(previous?.sourceAnchor)
                expr = Call(
                    sourceAnchor: sourceAnchor,
                    callee: expr,
                    arguments: arguments
                )
            } else if let dot = accept(TokenDot.self) as? TokenDot {
                let lexeme = dot.sourceAnchor?.text ?? "."
                let error = CompilerError(
                    sourceAnchor: dot.sourceAnchor,
                    message: "expected member name following `\(lexeme)'"
                )
                let member: Expression
                if let app = try consumeGenericTypeApplication() {
                    member = app
                } else {
                    let identifierToken = try expect(type: TokenIdentifier.self, error: error)
                    member = Identifier(
                        sourceAnchor: identifierToken.sourceAnchor,
                        identifier: identifierToken.lexeme
                    )
                }
                let sourceAnchor = expr.sourceAnchor?.union(member.sourceAnchor)
                expr = Get(
                    sourceAnchor: sourceAnchor,
                    expr: expr,
                    member: member
                )
            } else {
                break
            }
        }
        return expr
    }

    private func consumeStructInitializer() throws -> Expression {
        let primary = try consumePrimary()

        // If the primary is an identifier or a generic type application then
        // the expression might be a struct initializer.
        if (nil == primary as? Identifier) && (nil == primary as? GenericTypeApplication) {
            return primary
        }

        // If the next token is a curly brace then the expression might be a
        // struct initializer.
        if nil == peek() as? TokenCurlyLeft {
            return primary
        }

        // We do not allow struct initializer expressions in some places, such
        // as during the parsing of the limit of a Range expression. This is
        // necessary because there are several places, such as if statements and
        // for loops, where an expression is typically always followed by a
        // left curly brace.
        if false == isStructInitializerExpressionAllowed.last! {
            return primary
        }

        try expect(type: TokenCurlyLeft.self, error: CompilerError(message: "expected `{'"))

        var arguments: [StructInitializer.Argument] = []

        if nil == accept(TokenCurlyRight.self) {
            repeat {
                try expect(
                    type: TokenDot.self,
                    error: CompilerError(
                        sourceAnchor: peek()?.sourceAnchor,
                        message: "malformed argument to struct initializer: expected `.'"
                    )
                )

                let argumentIdentifier = try expect(
                    type: TokenIdentifier.self,
                    error: CompilerError(
                        sourceAnchor: peek()?.sourceAnchor,
                        message: "malformed argument to struct initializer: expected identifier"
                    )
                )

                try expect(
                    type: TokenEqual.self,
                    error: CompilerError(
                        sourceAnchor: peek()?.sourceAnchor,
                        message: "malformed argument to struct initializer: expected `='"
                    )
                )

                if nil != accept(TokenCurlyRight.self) {
                    throw CompilerError(
                        sourceAnchor: previous?.sourceAnchor,
                        message: "malformed argument to struct initializer: expected expression"
                    )
                }

                if nil == accept(TokenUndefined.self) {
                    let argumentExpression = try consumeExpression()
                    let argument = StructInitializer.Argument(
                        name: argumentIdentifier.lexeme,
                        expr: argumentExpression
                    )
                    arguments.append(argument)
                }
            } while nil != accept(TokenComma.self)

            let sourceAnchor = primary.sourceAnchor?.union(peek()?.sourceAnchor)
            try expect(
                type: TokenCurlyRight.self,
                error: CompilerError(
                    sourceAnchor: sourceAnchor,
                    message: "expected `}' in struct initializer expression"
                )
            )
        }

        return StructInitializer(
            sourceAnchor: primary.sourceAnchor?.union(previous?.sourceAnchor),
            expr: primary,
            arguments: arguments
        )
    }

    private func consumePrimary() throws -> Expression {
        if let numberToken = accept(TokenNumber.self) as? TokenNumber {
            return LiteralInt(
                sourceAnchor: numberToken.sourceAnchor,
                value: numberToken.literal
            )
        } else if let booleanToken = accept(TokenBoolean.self) as? TokenBoolean {
            return LiteralBool(
                sourceAnchor: booleanToken.sourceAnchor,
                value: booleanToken.literal
            )
        } else if let app = try consumeGenericTypeApplication() {
            return app
        } else if let identifierToken = accept(TokenIdentifier.self) as? TokenIdentifier {
            return Identifier(
                sourceAnchor: identifierToken.sourceAnchor,
                identifier: identifierToken.lexeme
            )
        } else if let leftParen = accept(TokenParenLeft.self) as? TokenParenLeft {
            let expression = try consumeExpression()
            let rightParen = try expect(
                type: TokenParenRight.self,
                error: CompilerError(
                    sourceAnchor: peek()?.sourceAnchor,
                    message: "expected `)' after expression"
                )
            )
            let sourceAnchor = leftParen.sourceAnchor?.union(rightParen.sourceAnchor)
            return Group(sourceAnchor: sourceAnchor, expression: expression)
        } else if let squareBracketLeft = peek() as? TokenSquareBracketLeft {
            let typ = try consumeArrayType()
            try expect(
                type: TokenCurlyLeft.self,
                error: CompilerError(
                    sourceAnchor: peek()?.sourceAnchor,
                    message: "expected `{' in array literal"
                )
            )
            var elements: [Expression] = []
            if nil == (peek() as? TokenCurlyRight) {
                repeat {
                    elements.append(try consumeExpression())
                } while nil != accept(TokenComma.self)
            }
            try expect(
                type: TokenCurlyRight.self,
                error: CompilerError(
                    sourceAnchor: peek()?.sourceAnchor,
                    message: "expected `}' in array literal"
                )
            )

            let sourceAnchor = squareBracketLeft.sourceAnchor?.union(previous?.sourceAnchor)
            return LiteralArray(
                sourceAnchor: sourceAnchor,
                arrayType: typ,
                elements: elements
            )
        } else if let literalString = accept(TokenLiteralString.self) as? TokenLiteralString {
            return LiteralString(
                sourceAnchor: literalString.sourceAnchor,
                value: literalString.literal
            )
        } else if let token = peek() {
            guard token is TokenEOF else {
                throw operandTypeMismatchError(token)
            }
            throw unexpectedEndOfInputError()
        } else {
            throw unexpectedEndOfInputError()
        }
    }

    private func consumeGenericTypeApplication() throws -> GenericTypeApplication? {
        guard peek(0) as? TokenIdentifier != nil,
            peek(1) as? TokenAt != nil
        else {
            return nil
        }

        let identifierToken = try expect(
            type: TokenIdentifier.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected identifier in generic type application"
            )
        )
        let identifier = Identifier(
            sourceAnchor: identifierToken.sourceAnchor,
            identifier: identifierToken.lexeme
        )
        try expect(
            type: TokenAt.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `@' in type argument list"
            )
        )
        try expect(
            type: TokenSquareBracketLeft.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `[' in type argument list"
            )
        )
        let arguments = try consumeTypeArgumentList()
        let rightBracket = try expect(
            type: TokenSquareBracketRight.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `[' in type argument list"
            )
        )
        let anchor = identifierToken.sourceAnchor?.union(rightBracket.sourceAnchor)

        return GenericTypeApplication(
            sourceAnchor: anchor,
            identifier: identifier,
            arguments: arguments
        )
    }

    private func consumeTypeArgumentList() throws -> [Expression] {
        if peek() as? TokenSquareBracketRight != nil {
            return []
        }

        var arguments: [Expression] = []

        repeat {
            let type = try consumeType()
            arguments.append(type)
        } while nil != accept(TokenComma.self)

        return arguments
    }

    private func useOfUnresolvedIdentifierError(_ instruction: Token) -> Error {
        CompilerError(
            sourceAnchor: instruction.sourceAnchor,
            message: "use of unresolved identifier: `\(instruction.lexeme)'"
        )
    }

    private func operandTypeMismatchError(_ instruction: Token) -> Error {
        let str = String(instruction.sourceAnchor?.text ?? "")
        return CompilerError(
            sourceAnchor: instruction.sourceAnchor,
            message: "operand type mismatch: `\(str)'"
        )
    }

    private func consumeReturn(_ token: TokenReturn) throws -> [AbstractSyntaxTreeNode] {
        guard nil == acceptEndOfStatement() else {
            return [Return(sourceAnchor: token.sourceAnchor, expression: nil)]
        }
        let expr = try consumeExpression()
        let sourceAnchor = token.sourceAnchor?.union(expr.sourceAnchor)
        return [Return(sourceAnchor: sourceAnchor, expression: expr)]
    }

    private func consumeStruct(
        _ firstToken: Token,
        _ visibility: SymbolVisibility = .privateVisibility
    ) throws -> [AbstractSyntaxTreeNode] {
        let identifierToken = try expect(
            type: TokenIdentifier.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected identifier in struct declaration"
            )
        )
        let identifier = Identifier(
            sourceAnchor: identifierToken.sourceAnchor,
            identifier: identifierToken.lexeme
        )
        let typeArguments = try consumeOptionalTypeArgumentListWithConstraints()

        try expect(
            type: TokenCurlyLeft.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `{' in struct"
            )
        )

        var members: [StructDeclaration.Member] = []
        repeat {
            if let tokenIdentifier = accept(TokenIdentifier.self) {
                if type(of: peek()!) == TokenParenRight.self || type(of: peek()!) == TokenComma.self
                {
                    throw CompilerError(
                        sourceAnchor: tokenIdentifier.sourceAnchor,
                        message: "member requires an explicit type"
                    )
                }
                guard let typeExpr = try consumeTypeAnnotation() else {
                    throw CompilerError(
                        sourceAnchor: previous?.sourceAnchor,
                        message: "expected member name followed by `:'"
                    )
                }
                let name = tokenIdentifier.lexeme
                members.append(StructDeclaration.Member(name: name, type: typeExpr))
            }
        } while nil != accept(TokenComma.self)

        let closingBrace = try expect(
            type: TokenCurlyRight.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `}' in struct"
            )
        )

        let sourceAnchor = firstToken.sourceAnchor?.union(closingBrace.sourceAnchor!)
        return [
            StructDeclaration(
                sourceAnchor: sourceAnchor,
                identifier: identifier,
                typeArguments: typeArguments,
                members: members,
                visibility: visibility
            )
        ]
    }

    private func consumeTrait(
        _ firstToken: Token,
        _ visibility: SymbolVisibility = .privateVisibility
    ) throws -> [AbstractSyntaxTreeNode] {
        let identifierToken = try expect(
            type: TokenIdentifier.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected identifier in trait declaration"
            )
        )
        let identifier = Identifier(
            sourceAnchor: identifierToken.sourceAnchor,
            identifier: identifierToken.lexeme
        )
        let typeArguments = try consumeOptionalTypeArgumentListWithConstraints()

        try expect(
            type: TokenCurlyLeft.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `{' in trait"
            )
        )

        var closingBrace: Token? = nil
        var members: [TraitDeclaration.Member] = []

        if let tok = accept(TokenCurlyRight.self) {
            closingBrace = tok
        } else {
            while true {
                let tokenFunc = try expect(
                    type: TokenFunc.self,
                    error: CompilerError(
                        sourceAnchor: peek()?.sourceAnchor,
                        message: "expected `func' in trait method list"
                    )
                )
                let tokenIdentifier =
                    try expect(
                        type: TokenIdentifier.self,
                        error: CompilerError(
                            sourceAnchor: firstToken.sourceAnchor,
                            message: "expected identifier in function declaration"
                        )
                    ) as! TokenIdentifier
                try expect(
                    type: TokenParenLeft.self,
                    error: CompilerError(
                        sourceAnchor: tokenIdentifier.sourceAnchor,
                        message: "expected `(' in argument list of function declaration"
                    )
                )

                var argumentTypes: [Expression] = []

                if type(of: peek()!) != TokenParenRight.self {
                    repeat {
                        let tokenIdentifier =
                            try expect(
                                type: TokenIdentifier.self,
                                error: CompilerError(
                                    sourceAnchor: peek()?.sourceAnchor,
                                    message: "expected parameter name followed by `:'"
                                )
                            ) as! TokenIdentifier
                        if type(of: peek()!) == TokenParenRight.self
                            || type(of: peek()!) == TokenComma.self
                        {
                            throw CompilerError(
                                sourceAnchor: tokenIdentifier.sourceAnchor,
                                message: "parameter requires an explicit type"
                            )
                        }
                        guard let type = try consumeTypeAnnotation() else {
                            throw CompilerError(
                                sourceAnchor: previous?.sourceAnchor,
                                message: "expected parameter name followed by `:'"
                            )
                        }
                        argumentTypes.append(type)
                    } while nil != accept(TokenComma.self)
                }

                try expect(
                    type: TokenParenRight.self,
                    error: CompilerError(
                        sourceAnchor: peek()?.sourceAnchor,
                        message: "expected `)' in argument list of function declaration"
                    )
                )

                let returnType: Expression
                if nil == accept(TokenArrow.self) {
                    returnType = PrimitiveType(.void)
                } else {
                    returnType = try consumeType()
                }

                let funcSourceAnchor = tokenFunc.sourceAnchor?.union(previous?.sourceAnchor)

                let typeExpr = PointerType(
                    sourceAnchor: funcSourceAnchor,
                    typ: FunctionType(
                        sourceAnchor: funcSourceAnchor,
                        name: nil,
                        returnType: returnType,
                        arguments: argumentTypes
                    )
                )
                members.append(
                    TraitDeclaration.Member(name: tokenIdentifier.lexeme, type: typeExpr)
                )

                if let tok = accept(TokenCurlyRight.self) {
                    closingBrace = tok
                    break
                } else {
                    try expect(
                        type: TokenNewline.self,
                        error: CompilerError(
                            sourceAnchor: peek()?.sourceAnchor,
                            message: "expected newline"
                        )
                    )
                }
            }  // while
        }  // else

        let sourceAnchor = firstToken.sourceAnchor?.union(closingBrace?.sourceAnchor)
        return [
            TraitDeclaration(
                sourceAnchor: sourceAnchor,
                identifier: identifier,
                typeArguments: typeArguments,
                members: members,
                visibility: visibility
            )
        ]
    }

    private func consumeImpl(_ tokenImpl: TokenImpl) throws -> [AbstractSyntaxTreeNode] {
        let typeArguments = try consumeOptionalTypeArgumentListWithConstraints()
        let firstTypeExpr = try consumeTypeWithoutRegardForConst()

        // An impl-for statement will have "for identifier" next.
        let secondTypeExpr: Expression?
        if nil != accept(TokenFor.self) {
            secondTypeExpr = try consumeTypeWithoutRegardForConst()
        } else {
            secondTypeExpr = nil
        }

        let openingCurlyBrace = try expect(
            type: TokenCurlyLeft.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `{' in impl declaration"
            )
        )
        try expect(
            type: TokenNewline.self,
            error: CompilerError(sourceAnchor: previous?.sourceAnchor, message: "expected newline")
        )

        var children: [FunctionDeclaration] = []
        while true {
            if let token = accept([
                TokenStatic.self, TokenLet.self, TokenVar.self, TokenIf.self, TokenWhile.self,
                TokenFor.self, TokenReturn.self, TokenStruct.self,
            ]) {
                throw CompilerError(
                    sourceAnchor: token.sourceAnchor,
                    message: "`\(token.lexeme)' is not permitted in impl declaration"
                )
            } else if let token = accept(TokenCurlyLeft.self) {
                throw CompilerError(
                    sourceAnchor: token.sourceAnchor,
                    message: "block is not permitted in impl declaration"
                )
            } else if let token = accept(TokenImpl.self) {
                throw CompilerError(
                    sourceAnchor: token.sourceAnchor,
                    message: "impl declarations may not contain other impl declarations"
                )
            } else if let token = accept(TokenFunc.self) {
                let child = try consumeFunc(token as! TokenFunc)
                children += child.compactMap({ $0 as? FunctionDeclaration })
            } else if nil != accept(TokenCurlyRight.self) {
                let sourceAnchor = tokenImpl.sourceAnchor?.union(openingCurlyBrace.sourceAnchor)
                guard let secondTypeExpr else {
                    return [
                        Impl(
                            sourceAnchor: sourceAnchor,
                            typeArguments: typeArguments,
                            structTypeExpr: firstTypeExpr,
                            children: children
                        )
                    ]
                }
                return [
                    ImplFor(
                        sourceAnchor: sourceAnchor,
                        typeArguments: typeArguments,
                        traitTypeExpr: firstTypeExpr,
                        structTypeExpr: secondTypeExpr,
                        children: children
                    )
                ]
            } else {
                let expr = try consumeExpression()
                throw CompilerError(
                    sourceAnchor: expr.sourceAnchor,
                    message: "expression statement is not permitted in impl declaration"
                )
            }
            try expectEndOfStatement()
        }
    }

    private func consumeTypealias(
        _ firstToken: Token,
        _ visibility: SymbolVisibility = .privateVisibility
    ) throws -> [AbstractSyntaxTreeNode] {
        let identifierToken = try expect(
            type: TokenIdentifier.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected identifier in typealias declaration"
            )
        )
        let identifier = Identifier(
            sourceAnchor: identifierToken.sourceAnchor,
            identifier: identifierToken.lexeme
        )
        try expect(
            type: TokenEqual.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `=' in typealias declaration"
            )
        )
        let expr = try consumeType()
        return [
            Typealias(
                sourceAnchor: firstToken.sourceAnchor?.union(expr.sourceAnchor),
                lexpr: identifier,
                rexpr: expr,
                visibility: visibility
            )
        ]
    }

    private func consumeMatch(_ tokenMatch: TokenMatch) throws -> [AbstractSyntaxTreeNode] {
        let expr = try consumeExpression(allowsStructInitializer: false)
        try expect(
            type: TokenCurlyLeft.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `{' in match statement"
            )
        )
        var elseClause: Block? = nil
        var clauses: [Match.Clause] = []
        while let leftParen = accept(TokenParenLeft.self) {
            let maybeIdentifier = try consumeExpression()
            guard let valueIdentifier = maybeIdentifier as? Identifier else {
                throw CompilerError(
                    sourceAnchor: maybeIdentifier.sourceAnchor,
                    message: "expected identifier in match statement clause"
                )
            }
            let maybeType = try consumeTypeAnnotation()
            guard let valueType = maybeType else {
                throw CompilerError(
                    sourceAnchor: maybeIdentifier.sourceAnchor,
                    message: "expected type annotation in match statement clause"
                )
            }
            try expect(
                type: TokenParenRight.self,
                error: CompilerError(
                    sourceAnchor: peek()?.sourceAnchor,
                    message: "expected `)' in match statement clause"
                )
            )
            try expect(
                type: TokenArrow.self,
                error: CompilerError(
                    sourceAnchor: peek()?.sourceAnchor,
                    message: "expected `->' in match statement clause"
                )
            )
            let leftBrace =
                try expect(
                    type: TokenCurlyLeft.self,
                    error: CompilerError(
                        sourceAnchor: peek()?.sourceAnchor,
                        message: "expected `{' in match statement clause"
                    )
                ) as! TokenCurlyLeft
            let blockStmts = try consumeBlock(leftBrace)
            let block = blockStmts.first as! Block
            clauses.append(
                Match.Clause(
                    sourceAnchor: leftParen.sourceAnchor?.union(block.sourceAnchor),
                    valueIdentifier: valueIdentifier,
                    valueType: valueType,
                    block: block
                )
            )

            // The list of clauses is comma-separated.
            if nil == accept(TokenComma.self) {
                break
            }
        }
        if nil != accept(TokenElse.self) {
            try expect(
                type: TokenArrow.self,
                error: CompilerError(
                    sourceAnchor: peek()?.sourceAnchor,
                    message: "expected `->' in match statement else-clause"
                )
            )
            let leftBrace =
                try expect(
                    type: TokenCurlyLeft.self,
                    error: CompilerError(
                        sourceAnchor: peek()?.sourceAnchor,
                        message: "expected `{' in match statement else-clause"
                    )
                ) as! TokenCurlyLeft
            let blockStmts = try consumeBlock(leftBrace)
            elseClause = blockStmts.first as? Block
        }
        try expect(
            type: TokenCurlyRight.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `}' in match statement"
            )
        )
        return [
            Match(
                sourceAnchor: tokenMatch.sourceAnchor?.union(previous?.sourceAnchor),
                expr: expr,
                clauses: clauses,
                elseClause: elseClause
            )
        ]
    }

    private func consumeAssert(_ tokenAssert: TokenAssert) throws -> [AbstractSyntaxTreeNode] {
        try expect(
            type: TokenParenLeft.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `(' in assert statement"
            )
        )
        if nil != accept(TokenParenRight.self) {
            let sourceAnchor = tokenAssert.sourceAnchor?.union(previous?.sourceAnchor)
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "expected expression in assert statement"
            )
        }
        let condition = try consumeExpression()
        let rightParen = try expect(
            type: TokenParenRight.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `)' in assert statement"
            )
        )
        let conditionText = String(condition.sourceAnchor!.text)
        let lineNumber = Int(condition.sourceAnchor!.lineNumbers!.startIndex) + 1
        let message = "assertion failed: `\(conditionText)' on line \(lineNumber)"
        let sourceAnchor = tokenAssert.sourceAnchor?.union(rightParen.sourceAnchor)
        return [
            Assert(
                sourceAnchor: sourceAnchor,
                condition: condition,
                message: message
            )
        ]
    }

    private func consumeTest(_ tokenTest: TokenTest) throws -> [AbstractSyntaxTreeNode] {
        let name =
            try expect(
                type: TokenLiteralString.self,
                error: CompilerError(
                    sourceAnchor: peek()?.sourceAnchor,
                    message: "expected test name in test declaration"
                )
            ) as! TokenLiteralString
        let leftBrace =
            try expect(
                type: TokenCurlyLeft.self,
                error: CompilerError(
                    sourceAnchor: peek()?.sourceAnchor,
                    message: "expected `{' in test declaration"
                )
            ) as! TokenCurlyLeft
        let body = try consumeBlock(leftBrace).first as! Block
        let sourceAnchor = tokenTest.sourceAnchor?.union(body.sourceAnchor)
        return [TestDeclaration(sourceAnchor: sourceAnchor, name: name.literal, body: body)]
    }

    private func consumeImport(_ tokenImport: TokenImport) throws -> [AbstractSyntaxTreeNode] {
        let name = try expect(
            type: TokenIdentifier.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected identifier in import statement"
            )
        )
        let sourceAnchor = tokenImport.sourceAnchor?.union(name.sourceAnchor)
        return [Import(sourceAnchor: sourceAnchor, moduleName: name.lexeme)]
    }

    private func consumeAsm(_ tokenAsm: TokenAsm) throws -> [AbstractSyntaxTreeNode] {
        _ = try expect(
            type: TokenParenLeft.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `(' in asm statement"
            )
        )
        let code =
            try expect(
                type: TokenLiteralString.self,
                error: CompilerError(
                    sourceAnchor: peek()?.sourceAnchor,
                    message: "expected string literal containing assembly code in asm statement"
                )
            ) as! TokenLiteralString
        let rightParen = try expect(
            type: TokenParenRight.self,
            error: CompilerError(
                sourceAnchor: peek()?.sourceAnchor,
                message: "expected `)' in asm statement"
            )
        )
        let sourceAnchor = tokenAsm.sourceAnchor?.union(rightParen.sourceAnchor)
        return [Asm(sourceAnchor: sourceAnchor, assemblyCode: code.literal)]
    }
}
