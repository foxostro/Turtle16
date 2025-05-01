//
//  Parser.swift
//  TurtleCore
//
//  Created by Andrew Fox on 9/2/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

open class Parser {
    public let lineMapper: SourceLineRangeMapper!
    public var tokens: [Token] = []
    public private(set) var previous: Token? = nil

    public private(set) var errors: [CompilerError] = []
    public var hasError: Bool {
        errors.count != 0
    }
    public private(set) var syntaxTree: TopLevel? = nil

    public init(tokens: [Token] = [], lineMapper: SourceLineRangeMapper! = nil) {
        self.tokens = tokens
        self.lineMapper = lineMapper
    }

    public func parse() {
        var statements: [AbstractSyntaxTreeNode] = []
        while !tokens.isEmpty {
            do {
                statements += try consumeStatement()
            } catch let e {
                let error = e as! CompilerError
                errors.append(error)

                // recover by skipping to the next line
                advanceToNewline()
                advance()
            }
        }
        if hasError {
            syntaxTree = nil
        } else {
            let sourceAnchor = statements.map({ $0.sourceAnchor }).reduce(
                statements.first?.sourceAnchor,
                { $0?.union($1) }
            )
            syntaxTree = TopLevel(sourceAnchor: sourceAnchor, children: statements)
        }
    }

    public func advance() {
        previous = peek()
        if !tokens.isEmpty {
            tokens.removeFirst()
        }
    }

    public struct Checkpoint {
        let previous: Token?
        let tokens: [Token]
        let errors: [CompilerError]
    }

    public func checkpoint() -> Checkpoint {
        Checkpoint(previous: previous, tokens: tokens, errors: errors)
    }

    public func restore(checkpoint: Checkpoint) {
        previous = checkpoint.previous
        tokens = checkpoint.tokens
        errors = checkpoint.errors
    }

    public func advanceToNewline() {
        while let token = peek() {
            let tokenType = type(of: token)
            if (tokenType == TokenEOF.self) || (tokenType == TokenNewline.self) {
                break
            } else {
                advance()
            }
        }
    }

    public func peek(_ howMany: Int = 0) -> Token? {
        guard howMany < tokens.count else {
            return nil
        }
        return tokens[howMany]
    }

    public func accept(_ typeInQuestion: AnyClass) -> Token? {
        accept(
            typeInQuestion: typeInQuestion,
            shouldIgnoreNewlines: typeInQuestion != TokenNewline.self
        )
    }

    private func accept(typeInQuestion: AnyClass, shouldIgnoreNewlines: Bool) -> Token? {
        var stepsToAdvance = 0
        while shouldIgnoreNewlines && (nil != (peek(stepsToAdvance) as? TokenNewline)) {
            stepsToAdvance += 1
        }
        if let token = peek(stepsToAdvance) {
            if typeInQuestion == type(of: token) {
                for _ in 0...stepsToAdvance {
                    advance()
                }
                return token
            }
        }
        return nil
    }

    public func accept(_ anyOfTheseTypes: [AnyClass]) -> Token? {
        var shouldIgnoreNewlines = true
        for typ in anyOfTheseTypes {
            if typ == TokenNewline.self {
                shouldIgnoreNewlines = false
            }
        }
        for typ in anyOfTheseTypes {
            if let token = accept(typeInQuestion: typ, shouldIgnoreNewlines: shouldIgnoreNewlines) {
                return token
            }
        }
        return nil
    }

    public func accept(operator op: TokenOperator.Operator) -> TokenOperator? {
        accept(operators: [op])
    }

    public func accept(operators ops: [TokenOperator.Operator]) -> TokenOperator? {
        var stepsToAdvance = 0
        while nil != (peek(stepsToAdvance) as? TokenNewline) {
            stepsToAdvance += 1
        }
        if let token = peek(stepsToAdvance) as? TokenOperator {
            if ops.contains(token.op) {
                for _ in 0...stepsToAdvance {
                    advance()
                }
                return token
            }
        }
        return nil
    }

    @discardableResult public func expect(type: AnyClass, error: Error) throws -> Token {
        let result = accept(type)
        if nil == result {
            throw error
        }
        return result!
    }

    @discardableResult public func expect(types: [AnyClass], error: Error) throws -> Token {
        for type in types {
            let result = accept(type)
            if nil != result {
                return result!
            }
        }
        throw error
    }

    open func consumeStatement() throws -> [AbstractSyntaxTreeNode] {
        throw CompilerError(message: "override consumeStatement() in a child class")
    }

    public func unexpectedEndOfInputError() -> CompilerError {
        let message = "unexpected end of input"
        guard let token = peek() else {
            return CompilerError(sourceAnchor: previous?.sourceAnchor, message: message)
        }
        return CompilerError(sourceAnchor: token.sourceAnchor, message: message)
    }
}
