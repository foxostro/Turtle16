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
    public static func makeLiteralArray(lineNumber: Int = 1, _ elements: [Expression]) -> Expression {
        return Expression.LiteralArray(tokenBracketLeft: TokenSquareBracketLeft(lineNumber: 1, lexeme: "["),
                                       elements: elements,
                                       tokenBracketRight: TokenSquareBracketRight(lineNumber: 1, lexeme: "]"))
    }
    
    public static func makeLiteralInt(lineNumber: Int = 1, value: Int) -> Expression {
        return Expression.LiteralWord(number: TokenNumber(lineNumber: lineNumber, lexeme: "\(value)", literal: value))
    }
    
    public static func makeU8(lineNumber: Int = 1, value: Int) -> Expression {
        return Expression.As(expr: Expression.LiteralWord(number: TokenNumber(lineNumber: lineNumber, lexeme: "\(value)", literal: value)),
                             tokenAs: TokenAs(lineNumber: lineNumber, lexeme: "as"),
                             targetType: .u8)
    }
    
    public static func makeU16(lineNumber: Int = 1, value: Int) -> Expression {
        return Expression.As(expr: Expression.LiteralWord(number: TokenNumber(lineNumber: lineNumber, lexeme: "\(value)", literal: value)),
                             tokenAs: TokenAs(lineNumber: lineNumber, lexeme: "as"),
                             targetType: .u16)
    }
    
    public static func makeLiteralBoolean(lineNumber: Int = 1, value: Bool) -> Expression {
        return Expression.LiteralBoolean(boolean: TokenBoolean(lineNumber: lineNumber, lexeme: "\(value)", literal: value))
    }
    
    public static func makeBool(lineNumber: Int = 1, value: Bool) -> Expression {
        return Expression.As(expr: makeLiteralBoolean(lineNumber: lineNumber, value: value),
                             tokenAs: TokenAs(lineNumber: lineNumber, lexeme: "as"),
                             targetType: .bool)
    }
    
    public static func makeAdd(lineNumber: Int = 1, left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: TokenOperator(lineNumber: lineNumber, lexeme: "+", op: .plus), left: left, right: right)
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
    
    public static func makeIdentifier(lineNumber: Int = 1, name: String) -> Expression {
        return Expression.Identifier(identifier: TokenIdentifier(lineNumber: lineNumber, lexeme: name))
    }
    
    public static func makeAssignment(lineNumber: Int = 1, name: String, right: Expression) -> Expression {
        return Expression.Assignment(identifier: TokenIdentifier(lineNumber: lineNumber, lexeme: name), expression: right)
    }
    
    public static func makeNeg(expr: Expression) -> Expression {
        return Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus), expression: expr)
    }
    
    public static func makeSubscript(lineNumber: Int = 1, identifier: String, expr: Expression) -> Expression {
        return Expression.Subscript(tokenIdentifier: TokenIdentifier(lineNumber: lineNumber, lexeme: identifier),
                                    tokenBracketLeft: TokenSquareBracketLeft(lineNumber: 1, lexeme: "["),
                                    expr: expr,
                                    tokenBracketRight: TokenSquareBracketRight(lineNumber: 1, lexeme: "]"))
    }
}
