//
//  ExpressionUtils.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/5/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCompilerToolbox

public class ExprUtils: NSObject {
    public static func makeLiteralWord(value: Int) -> Expression {
        return Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "\(value)", literal: value))
    }
    
    public static func makeLiteralBoolean(value: Bool) -> Expression {
        return Expression.LiteralBoolean(boolean: TokenBoolean(lineNumber: 1, lexeme: "\(value)", literal: value))
    }
    
    public static func makeAdd(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus), left: left, right: right)
    }
    
    public static func makeSub(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus), left: left, right: right)
    }
    
    public static func makeMul(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply), left: left, right: right)
    }
    
    public static func makeDiv(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide), left: left, right: right)
    }
    
    public static func makeComparisonEq(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "==", op: .eq), left: left, right: right)
    }
    
    public static func makeComparisonNe(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "!=", op: .ne), left: left, right: right)
    }
    
    public static func makeComparisonLt(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "<", op: .lt), left: left, right: right)
    }
    
    public static func makeComparisonGt(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: ">", op: .gt), left: left, right: right)
    }
    
    public static func makeComparisonLe(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "<=", op: .le), left: left, right: right)
    }
    
    public static func makeComparisonGe(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: ">=", op: .ge), left: left, right: right)
    }
    
    public static func makeIdentifier(name: String) -> Expression {
        return Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: name))
    }
    
    public static func makeAssignment(_ name: String, right: Expression) -> Expression {
        return Expression.Assignment(identifier: TokenIdentifier(lineNumber: 1, lexeme: name), expression: right)
    }
    
    public static func makeNeg(expr: Expression) -> Expression {
        return Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus), expression: expr)
    }
}
