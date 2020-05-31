//
//  Parser.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 9/2/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

open class Parser: NSObject {
    public var tokens: [Token] = []
    public private(set) var previous: Token? = nil
    
    public private(set) var errors: [CompilerError] = []
    public var hasError:Bool {
        return errors.count != 0
    }
    public private(set) var syntaxTree: AbstractSyntaxTreeNode? = nil
    
    public init(tokens: [Token] = []) {
        self.tokens = tokens
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
            syntaxTree = AbstractSyntaxTreeNode(children: statements)
        }
    }
    
    public func advance() {
        previous = peek()
        if !tokens.isEmpty {
            tokens.removeFirst()
        }
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
        if howMany < tokens.count {
            return tokens[howMany]
        } else {
            return nil
        }
    }
    
    public func accept(_ typeInQuestion: AnyClass) -> Token? {
        if let token = peek() {
            if typeInQuestion == type(of: token) {
                advance()
                return token
            }
        }
        return nil
    }
    
    public func accept(_ anyOfTheseTypes: [AnyClass]) -> Token? {
        if let token = peek() {
            let tokenType = type(of: token)
            for type in anyOfTheseTypes {
                if tokenType == type {
                    advance()
                    return token
                }
            }
        }
        return nil
    }
    
    public func accept(operator op: TokenOperator.Operator) -> TokenOperator? {
        return accept(operators: [op])
    }
    
    public func accept(operators ops: [TokenOperator.Operator]) -> TokenOperator? {
        if let token = peek() as? TokenOperator {
            if ops.contains(token.op) {
                advance()
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
        throw CompilerError(format: "override consumeStatement() in a child class")
    }
    
    public func unexpectedEndOfInputError() -> CompilerError {
        let message = "unexpected end of input"
        if let token = peek() {
            return CompilerError(line: token.lineNumber, message: message)
        } else if let previous = previous {
            return CompilerError(line: previous.lineNumber, message: message)
        }
        
        return CompilerError(message: message)
    }
}
