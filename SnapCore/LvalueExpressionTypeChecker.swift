//
//  LvalueExpressionTypeChecker.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/24/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

// Evaluates the expression type in an lvalue context.
public class LvalueExpressionTypeChecker: NSObject {
    public let symbols: SymbolTable
    
    public init(symbols: SymbolTable = SymbolTable()) {
        self.symbols = symbols
    }
        
    func rvalueContext() -> ExpressionTypeChecker {
        return ExpressionTypeChecker(symbols: symbols)
    }
    
    @discardableResult public func check(expression: Expression) throws -> SymbolType {
        switch expression {
        case let identifier as Expression.Identifier:
            return try check(identifier: identifier)
        case let expr as Expression.Subscript:
            return try check(subscript: expr)
        default:
            throw makeNotAssignableError(expression: expression)
        }
    }
        
    public func check(identifier expr: Expression.Identifier) throws -> SymbolType {
        return .reference(try rvalueContext().check(identifier: expr))
    }
    
    public func check(subscript expr: Expression.Subscript) throws -> SymbolType {
        let isMutable = try symbols.resolve(identifierToken: expr.tokenIdentifier).isMutable
        if !isMutable {
            throw CompilerError(line: expr.tokenIdentifier.lineNumber,
                                message: "expression is not assignable: `\(expr.tokenIdentifier.lexeme)' is immutable")
        }
        
        return .reference(try rvalueContext().check(subscript: expr))
    }
    
    func makeNotAssignableError(expression: Expression) -> Error {
        let message = "expression is not assignable"
        if let lineNumber = expression.tokens.first?.lineNumber {
            return CompilerError(line: lineNumber, message: message)
        } else {
            return CompilerError(message: message)
        }
    }
}
