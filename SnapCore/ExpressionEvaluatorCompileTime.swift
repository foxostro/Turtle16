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
        } else {
            let lineNumber = expression.tokens.first?.lineNumber ?? 1
            throw MustBeCompileTimeConstantError(line: lineNumber)
        }
    }
}
