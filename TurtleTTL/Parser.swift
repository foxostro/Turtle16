//
//  Parser.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 9/2/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class Parser: NSObject {
    public struct Production {
        typealias Generator = (Token) throws -> [AbstractSyntaxTreeNode]?
        let symbol: Token.Type
        let generator: Generator
    }
    var productions: [Production] = []
    var tokens: [Token] = []
    
    public func parse() throws -> AbstractSyntaxTreeNode {
        var statements: [AbstractSyntaxTreeNode] = []
        while tokens.count > 0 {
            statements += try consumeStatement()
        }
        return AbstractSyntaxTreeNode(children: statements)
    }
    
    func advance() {
        tokens.removeFirst()
    }
    
    func peek() -> Token? {
        return tokens.first
    }
    
    func accept(_ typeInQuestion: AnyClass) -> Any? {
        if let token = peek() {
            if typeInQuestion == type(of: token) {
                advance()
                return token
            }
        }
        return nil
    }
    
    func expect(type: AnyClass, error: Error) throws {
        if nil == accept(type) {
            throw error
        }
    }
    
    func expect(types: [AnyClass], error: Error) throws {
        for t in types {
            if nil != accept(t) {
                return
            }
        }
        throw error
    }
    
    func consumeStatement() throws -> [AbstractSyntaxTreeNode] {
        for production in productions {
            guard let symbol = accept(production.symbol) as? Token else { continue }
            if let statements = try production.generator(symbol) {
                return statements
            }
        }
        throw AssemblerError(format: "unexpected end of input")
    }
}
