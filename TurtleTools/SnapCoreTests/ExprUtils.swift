//
//  ExprUtils.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/5/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore

// The macOS 15 SDK added the new Foundation.Expression class, introducing a name collision with our
// own Expression class. This typealias resolves the ambiguity in favor of our type.
public typealias Expression = SnapCore.Expression

public enum ExprUtils {
    public static func makeU8(value: Int) -> Expression {
        assert(value >= UInt8.min && value <= UInt8.max)
        return As(
            expr: LiteralInt(value),
            targetType: PrimitiveType(.u8)
        )
    }

    public static func makeU16(value: Int) -> Expression {
        assert(value >= UInt16.min && value <= UInt16.max)
        return As(
            expr: LiteralInt(value),
            targetType: PrimitiveType(.u16)
        )
    }

    public static func makeI8(value: Int) -> Expression {
        assert(value >= Int8.min && value <= Int8.max)
        return As(
            expr: LiteralInt(value),
            targetType: PrimitiveType(.i8)
        )
    }

    public static func makeI16(value: Int) -> Expression {
        assert(value >= Int16.min && value <= Int16.max)
        return As(
            expr: LiteralInt(value),
            targetType: PrimitiveType(.i16)
        )
    }

    public static func makeBool(value: Bool) -> Expression {
        As(
            expr: LiteralBool(value),
            targetType: PrimitiveType(.bool)
        )
    }

    public static func makeAdd(left: Expression, right: Expression) -> Expression {
        Binary(
            op: .plus,
            left: left,
            right: right
        )
    }

    public static func makeSub(left: Expression, right: Expression) -> Expression {
        Binary(
            op: .minus,
            left: left,
            right: right
        )
    }

    public static func makeMul(left: Expression, right: Expression) -> Expression {
        Binary(
            op: .star,
            left: left,
            right: right
        )
    }

    public static func makeDiv(left: Expression, right: Expression) -> Expression {
        Binary(
            op: .divide,
            left: left,
            right: right
        )
    }

    public static func makeComparisonEq(left: Expression, right: Expression) -> Expression {
        Binary(
            op: .eq,
            left: left,
            right: right
        )
    }

    public static func makeComparisonNe(left: Expression, right: Expression) -> Expression {
        Binary(
            op: .ne,
            left: left,
            right: right
        )
    }

    public static func makeComparisonLt(left: Expression, right: Expression) -> Expression {
        Binary(
            op: .lt,
            left: left,
            right: right
        )
    }

    public static func makeComparisonGt(left: Expression, right: Expression) -> Expression {
        Binary(
            op: .gt,
            left: left,
            right: right
        )
    }

    public static func makeComparisonLe(left: Expression, right: Expression) -> Expression {
        Binary(
            op: .le,
            left: left,
            right: right
        )
    }

    public static func makeComparisonGe(left: Expression, right: Expression) -> Expression {
        Binary(
            op: .ge,
            left: left,
            right: right
        )
    }

    public static func makeAssignment(name: String, right: Expression) -> Expression {
        makeAssignment(
            lexpr: Identifier(name),
            rexpr: right
        )
    }

    public static func makeAssignment(lexpr: Expression, rexpr: Expression) -> Expression {
        Assignment(lexpr: lexpr, rexpr: rexpr)
    }

    public static func makeNeg(expr: Expression) -> Expression {
        Unary(
            op: .minus,
            expression: expr
        )
    }

    public static func makeSubscript(identifier: String, expr: Expression) -> Expression {
        Subscript(subscriptable: Identifier(identifier), argument: expr)
    }

    public static func makeRange(_ begin: Int, _ limit: Int) -> Expression {
        StructInitializer(
            identifier: Identifier("Range"),
            arguments: [
                StructInitializer.Argument(name: "begin", expr: LiteralInt(begin)),
                StructInitializer.Argument(name: "limit", expr: LiteralInt(limit))
            ]
        )
    }
}
