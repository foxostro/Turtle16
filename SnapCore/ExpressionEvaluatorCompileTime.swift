//
//  ExpressionEvaluatorCompileTime.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

// Evaluates an Expression at compile time.
// Throws exceptions when this is not possible.
public class ExpressionEvaluatorCompileTime: NSObject {
    let symbols: SymbolTable
    
    public init(symbols: SymbolTable = SymbolTable()) {
        self.symbols = symbols
    }
    
    public class MustBeCompileTimeConstantError: CompilerError {
        public init(line lineNumber: Int) {
            super.init(line: lineNumber, message: "expression must be a compile time constant")
        }
    }
    
    // Throws ExpressionMustBeCompileTimeConstantError when the expression can
    // not be evaluated at compile time.
    public func evaluate(expression: Expression) throws -> Int {
        if let literal = expression as? Expression.Literal {
            return literal.number.literal
        } else if let identifier = expression as? Expression.Identifier {
            return try resolve(identifier: identifier.identifier)
        } else if let unary = expression as? Expression.Unary {
            return try evaluate(unary: unary)
        } else if let binary = expression as? Expression.Binary {
            return try evaluate(binary: binary)
        } else {
            let lineNumber = expression.tokens.first?.lineNumber ?? 1
            throw MustBeCompileTimeConstantError(line: lineNumber)
        }
    }
    
    func resolve(identifier: TokenIdentifier) throws -> Int {
        guard let value = symbols[identifier.lexeme] else {
            throw MustBeCompileTimeConstantError(line: identifier.lineNumber)
        }
        return value
    }
    
    public func evaluate(unary: Expression.Unary) throws -> Int {
        let result: Int
        let prior = try evaluate(expression: unary.child)
        if unary.op.op == .minus {
            result = -prior
        } else {
            throw CompilerError(line: unary.op.lineNumber, format: "\'%@\' is not a prefix unary operator", unary.op.lexeme)
        }
        return result
    }
    
    public func evaluate(binary: Expression.Binary) throws -> Int {
        let result: Int
        let left = try evaluate(expression: binary.left)
        let right = try evaluate(expression: binary.right)
        switch binary.op.op {
        case .plus:
            result = left + right
        case .minus:
            result = left - right
        case .multiply:
            result = left * right
        case .divide:
            result = left / right
        }
        return result
    }
}
