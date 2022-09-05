//
//  ExpressionUtils.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/5/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore

public class ExprUtils: NSObject {
    public static func makeU8(value: Int) -> Expression {
        assert(value >= UInt8.min && value <= UInt8.max)
        return Expression.As(expr: Expression.LiteralInt(value),
                             targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
    }
    
    public static func makeU16(value: Int) -> Expression {
        assert(value >= UInt16.min && value <= UInt16.max)
        return Expression.As(expr: Expression.LiteralInt(value),
                             targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))
    }
    
    public static func makeI8(value: Int) -> Expression {
        assert(value >= Int8.min && value <= Int8.max)
        return Expression.As(expr: Expression.LiteralInt(value),
                             targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i8))))
    }
    
    public static func makeI16(value: Int) -> Expression {
        assert(value >= Int16.min && value <= Int16.max)
        return Expression.As(expr: Expression.LiteralInt(value),
                             targetType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.i16))))
    }
    
    public static func makeBool(value: Bool) -> Expression {
        return Expression.As(expr: Expression.LiteralBool(value),
                             targetType: Expression.PrimitiveType(.bool(.mutableBool)))
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
        return Expression.Binary(op: .star,
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
        return Expression.Subscript(subscriptable: Expression.Identifier(identifier), argument: expr)
    }
    
    public static func makeRange(_ begin: Int, _ limit: Int) -> Expression {
        return Expression.StructInitializer(identifier: Expression.Identifier("Range"), arguments: [Expression.StructInitializer.Argument(name: "begin", expr: Expression.LiteralInt(begin)), Expression.StructInitializer.Argument(name: "limit", expr: Expression.LiteralInt(limit))])
    }
}
