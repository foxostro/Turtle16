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
    public static func makeU8(value: Int) -> Expression {
        return Expression.As(expr: Expression.LiteralInt(value),
                             targetType: .u8)
    }
    
    public static func makeU16(value: Int) -> Expression {
        return Expression.As(expr: Expression.LiteralInt(value),
                             targetType: .u16)
    }
    
    public static func makeBool(value: Bool) -> Expression {
        return Expression.As(expr: Expression.LiteralBool(value),
                             targetType: .bool)
    }
    
    public static func makeAdd(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: .plus,
                                 left: left,
                                 right: right)
    }
    
    public static func makeSub(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: .minus,
                                 left: left,
                                 right: right)
    }
    
    public static func makeMul(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: .multiply,
                                 left: left,
                                 right: right)
    }
    
    public static func makeDiv(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: .divide,
                                 left: left,
                                 right: right)
    }
    
    public static func makeComparisonEq(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: .eq,
                                 left: left,
                                 right: right)
    }
    
    public static func makeComparisonNe(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: .ne,
                                 left: left,
                                 right: right)
    }
    
    public static func makeComparisonLt(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: .lt,
                                 left: left,
                                 right: right)
    }
    
    public static func makeComparisonGt(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: .gt,
                                 left: left,
                                 right: right)
    }
    
    public static func makeComparisonLe(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: .le,
                                 left: left,
                                 right: right)
    }
    
    public static func makeComparisonGe(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(op: .ge,
                                 left: left,
                                 right: right)
    }
    
    public static func makeAssignment(name: String, right: Expression) -> Expression {
        return makeAssignment(lexpr: Expression.Identifier(name),
                              rexpr: right)
    }
    
    public static func makeAssignment(lexpr: Expression, rexpr: Expression) -> Expression {
        return Expression.Assignment(lexpr: lexpr, rexpr: rexpr)
    }
    
    public static func makeNeg(expr: Expression) -> Expression {
        return Expression.Unary(op: .minus,
                                expression: expr)
    }
    
    public static func makeSubscript(identifier: String, expr: Expression) -> Expression {
        return Expression.Subscript(identifier: Expression.Identifier(identifier),
                                    expr: expr)
    }
}
