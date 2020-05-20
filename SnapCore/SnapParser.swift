//
//  SnapParser.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class SnapParser: ParserBase {
    public init(tokens: [Token]) {
        super.init()
        self.tokens = tokens
        self.productions = [
            Production(symbol: TokenEOF.self,        generator: { _ in [] }),
            Production(symbol: TokenNewline.self,    generator: { _ in [] }),
            Production(symbol: TokenIdentifier.self, generator: { try self.consumeIdentifier($0 as! TokenIdentifier) }),
            Production(symbol: TokenLet.self,        generator: { try self.consumeLet($0 as! TokenLet) })
        ]
    }
    
    func consumeIdentifier(_ identifier: TokenIdentifier) throws -> [AbstractSyntaxTreeNode] {
        try expect(type: TokenColon.self, error: useOfUnresolvedIdentifierError(identifier))
        try expectEndOfStatement()
        return [LabelDeclarationNode(identifier: identifier)]
    }
    
    func consumeLet(_ letToken: TokenLet) throws -> [AbstractSyntaxTreeNode] {
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
    
    func acceptEndOfStatement() -> Token? {
        return accept([TokenNewline.self, TokenEOF.self])
    }
    
    func expectEndOfStatement() throws {
        try expect(types: [TokenNewline.self, TokenEOF.self],
                          error: expectedEndOfStatementError(peek()!))
    }
    
    func expectedEndOfStatementError(_ token: Token) -> Error {
        return CompilerError(line: token.lineNumber,
                              format: "expected to find the end of the statement: `%@'",
                              token.lexeme)
    }
    
    func consumeExpression() throws -> Expression {
        return try consumePrimary()
    }
    
    func consumePrimary() throws -> Expression {
        if let numberToken = accept(TokenNumber.self) as? TokenNumber {
            return Expression.Literal(number: numberToken)
        }
        throw operandTypeMismatchError(peek()!)
    }
    
    func useOfUnresolvedIdentifierError(_ instruction: Token) -> Error {
        return CompilerError(line: instruction.lineNumber,
                              format: "use of unresolved identifier: `%@'",
                              instruction.lexeme)
    }
    
    func operandTypeMismatchError(_ instruction: Token) -> Error {
        return CompilerError(line: instruction.lineNumber,
                              format: "operand type mismatch: `%@'",
                              instruction.lexeme)
    }
}
