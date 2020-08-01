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
        return Expression.As(sourceAnchor: nil,
                             expr: Expression.LiteralWord(sourceAnchor: nil, value: value),
                             targetType: .u8)
    }
    
    public static func makeU16(value: Int) -> Expression {
        return Expression.As(sourceAnchor: nil,
                             expr: Expression.LiteralWord(sourceAnchor: nil, value: value),
                             targetType: .u16)
    }
    
    public static func makeBool(value: Bool) -> Expression {
        return Expression.As(sourceAnchor: nil,
                             expr: Expression.LiteralBoolean(sourceAnchor: nil, value: value),
                             targetType: .bool)
    }
    
    public static func makeAdd(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(sourceAnchor: nil,
                                 op: .plus,
                                 left: left,
                                 right: right)
    }
    
    public static func makeSub(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(sourceAnchor: nil,
                                 op: .minus,
                                 left: left,
                                 right: right)
    }
    
    public static func makeMul(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(sourceAnchor: nil,
                                 op: .multiply,
                                 left: left,
                                 right: right)
    }
    
    public static func makeDiv(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(sourceAnchor: nil,
                                 op: .divide,
                                 left: left,
                                 right: right)
    }
    
    public static func makeComparisonEq(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(sourceAnchor: nil,
                                 op: .eq,
                                 left: left,
                                 right: right)
    }
    
    public static func makeComparisonNe(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(sourceAnchor: nil,
                                 op: .ne,
                                 left: left,
                                 right: right)
    }
    
    public static func makeComparisonLt(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(sourceAnchor: nil,
                                 op: .lt,
                                 left: left,
                                 right: right)
    }
    
    public static func makeComparisonGt(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(sourceAnchor: nil,
                                 op: .gt,
                                 left: left,
                                 right: right)
    }
    
    public static func makeComparisonLe(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(sourceAnchor: nil,
                                 op: .le,
                                 left: left,
                                 right: right)
    }
    
    public static func makeComparisonGe(left: Expression, right: Expression) -> Expression {
        return Expression.Binary(sourceAnchor: nil,
                                 op: .ge,
                                 left: left,
                                 right: right)
    }
    
    public static func makeAssignment(name: String, right: Expression) -> Expression {
        return makeAssignment(lexpr: Expression.Identifier(sourceAnchor: nil, identifier: name),
                              rexpr: right)
    }
    
    public static func makeAssignment(lexpr: Expression, rexpr: Expression) -> Expression {
        return Expression.Assignment(sourceAnchor: nil, lexpr: lexpr, rexpr: rexpr)
    }
    
    public static func makeNeg(expr: Expression) -> Expression {
        return Expression.Unary(sourceAnchor: nil,
                                op: .minus,
                                expression: expr)
    }
    
    public static func makeSubscript(identifier: String, expr: Expression) -> Expression {
        return Expression.Subscript(sourceAnchor: nil,
                                    identifier: Expression.Identifier(sourceAnchor: nil, identifier: identifier),
                                    expr: expr)
    }
}
