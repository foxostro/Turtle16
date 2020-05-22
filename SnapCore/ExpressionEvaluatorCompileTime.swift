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
        let temp = try evaluate(expression: unary.child)
        return -temp
    }
}
