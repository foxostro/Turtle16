//
//  Parser.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 9/2/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

public protocol Parser {
    var hasError: Bool { get }
    var errors: [CompilerError] { get }
    var syntaxTree: AbstractSyntaxTreeNode? { get }
    
    func parse()
}

open class ParserBase: NSObject, Parser {
    public struct Production {
        public typealias Generator = (Token) throws -> [AbstractSyntaxTreeNode]?
        
        let symbol: Token.Type
        let generator: Generator
        
        public init(symbol: Token.Type, generator: @escaping Generator) {
            self.symbol = symbol
            self.generator = generator
        }
    }
    public var productions: [Production] = []
    public var tokens: [Token] = []
    
    public private(set) var errors: [CompilerError] = []
    public var hasError:Bool {
        return errors.count != 0
    }
    public private(set) var syntaxTree: AbstractSyntaxTreeNode? = nil
    
    public func parse() {
        var statements: [AbstractSyntaxTreeNode] = []
        while tokens.count > 0 {
            do {
                statements += try consumeStatement()
            } catch let error as CompilerError {
                errors.append(error)
                advanceToNewline() // recover by skipping to the next line
            } catch {
                // This catch block should be unreachable because
                // consumeStatement() only throws CompilerError. Regardless,
                // we need it to satisfy the compiler.
                let lineNumber = peek()?.lineNumber ?? 1
                errors.append(CompilerError(line: lineNumber, format: "unrecoverable error: %@", error.localizedDescription))
                return
            }
        }
        if hasError {
            syntaxTree = nil
        } else {
            syntaxTree = AbstractSyntaxTreeNode(children: statements)
        }
    }
    
    public func advance() {
        tokens.removeFirst()
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
    
    public func peek() -> Token? {
        return tokens.first
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
    
    func consumeStatement() throws -> [AbstractSyntaxTreeNode] {
        for production in productions {
            guard let symbol = accept(production.symbol) else { continue }
            if let statements = try production.generator(symbol) {
                return statements
            }
        }
        throw CompilerError(format: "unexpected end of input")
    }
}
