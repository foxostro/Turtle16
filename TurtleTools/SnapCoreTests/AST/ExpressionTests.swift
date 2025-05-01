//
//  ExpressionNodeTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class ExpressionTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(
            LiteralInt(1),
            CommentNode(string: "")
        )
    }

    func testLiteralWordEquality() {
        XCTAssertNotEqual(
            LiteralInt(1),
            LiteralInt(2)
        )
        XCTAssertEqual(
            LiteralInt(1),
            LiteralInt(1)
        )
        XCTAssertEqual(
            LiteralInt(1).hashValue,
            LiteralInt(1).hashValue
        )
    }

    func testLiteralBooleanEquality() {
        XCTAssertNotEqual(
            LiteralBool(true),
            LiteralBool(false)
        )
        XCTAssertEqual(
            LiteralBool(true),
            LiteralBool(true)
        )
        XCTAssertEqual(
            LiteralBool(true).hashValue,
            LiteralBool(true).hashValue
        )
    }

    func testIdentifierEquality() {
        XCTAssertNotEqual(
            Identifier("foo"),
            Identifier("bar")
        )
        XCTAssertEqual(
            Identifier("foo"),
            Identifier("foo")
        )
        XCTAssertEqual(
            Identifier("foo").hashValue,
            Identifier("foo").hashValue
        )
    }

    func testGroupEquality() {
        // Different expressions
        XCTAssertNotEqual(
            Group(LiteralInt(1)),
            Group(LiteralInt(2))
        )

        // Same
        XCTAssertEqual(
            Group(LiteralInt(1)),
            Group(LiteralInt(1))
        )

        // Same
        XCTAssertEqual(
            Group(LiteralInt(1)).hashValue,
            Group(LiteralInt(1)).hashValue
        )
    }

    func testUnaryEquality() {
        // Different expressions
        XCTAssertNotEqual(
            Unary(
                op: .minus,
                expression: LiteralInt(1)
            ),
            Unary(
                op: .minus,
                expression: LiteralInt(2)
            )
        )

        // Same
        XCTAssertEqual(
            Unary(
                op: .minus,
                expression: LiteralInt(1)
            ),
            Unary(
                op: .minus,
                expression: LiteralInt(1)
            )
        )

        // Same
        XCTAssertEqual(
            Unary(
                op: .minus,
                expression: LiteralInt(1)
            ).hashValue,
            Unary(
                op: .minus,
                expression: LiteralInt(1)
            ).hashValue
        )
    }

    func testBinaryEquality() {
        // Different right expression
        XCTAssertNotEqual(
            Binary(
                op: .plus,
                left: LiteralInt(1),
                right: LiteralInt(2)
            ),
            Binary(
                op: .plus,
                left: LiteralInt(1),
                right: LiteralInt(9)
            )
        )

        // Different left expression
        XCTAssertNotEqual(
            Binary(
                op: .plus,
                left: LiteralInt(1),
                right: LiteralInt(2)
            ),
            Binary(
                op: .plus,
                left: LiteralInt(42),
                right: LiteralInt(2)
            )
        )

        // Different tokens
        XCTAssertNotEqual(
            Binary(
                op: .plus,
                left: LiteralInt(1),
                right: LiteralInt(2)
            ),
            Binary(
                op: .minus,
                left: LiteralInt(1),
                right: LiteralInt(2)
            )
        )

        // Same
        XCTAssertEqual(
            Binary(
                op: .plus,
                left: LiteralInt(1),
                right: LiteralInt(2)
            ),
            Binary(
                op: .plus,
                left: LiteralInt(1),
                right: LiteralInt(2)
            )
        )

        // Hash
        XCTAssertEqual(
            Binary(
                op: .plus,
                left: LiteralInt(1),
                right: LiteralInt(2)
            ).hashValue,
            Binary(
                op: .plus,
                left: LiteralInt(1),
                right: LiteralInt(2)
            ).hashValue
        )
    }

    func testAssignmentEquality() {
        let foo = Identifier("foo")
        let bar = Identifier("bar")

        // Different right expression
        XCTAssertNotEqual(
            Assignment(
                lexpr: foo,
                rexpr: LiteralInt(1)
            ),
            Assignment(
                lexpr: foo,
                rexpr: LiteralInt(2)
            )
        )

        // Different left identifier
        XCTAssertNotEqual(
            Assignment(
                lexpr: foo,
                rexpr: LiteralInt(1)
            ),
            Assignment(
                lexpr: bar,
                rexpr: LiteralInt(1)
            )
        )

        // Same
        XCTAssertEqual(
            Assignment(
                lexpr: foo,
                rexpr: LiteralInt(1)
            ),
            Assignment(
                lexpr: foo,
                rexpr: LiteralInt(1)
            )
        )

        // Hash
        XCTAssertEqual(
            Assignment(
                lexpr: foo,
                rexpr: LiteralInt(1)
            ).hashValue,
            Assignment(
                lexpr: foo,
                rexpr: LiteralInt(1)
            ).hashValue
        )
    }

    func testCallEquality() {
        // Different callee
        XCTAssertNotEqual(
            Call(
                callee: Identifier("foo"),
                arguments: [LiteralInt(1)]
            ),
            Call(
                callee: Identifier("bar"),
                arguments: [LiteralInt(1)]
            )
        )
        // Different arguments
        XCTAssertNotEqual(
            Call(
                callee: Identifier("foo"),
                arguments: [LiteralInt(1)]
            ),
            Call(
                callee: Identifier("foo"),
                arguments: [LiteralInt(2)]
            )
        )

        // Same
        XCTAssertEqual(
            Call(
                callee: Identifier("foo"),
                arguments: [LiteralInt(1)]
            ),
            Call(
                callee: Identifier("foo"),
                arguments: [LiteralInt(1)]
            )
        )

        // Hash
        XCTAssertEqual(
            Call(
                callee: Identifier("foo"),
                arguments: [LiteralInt(1)]
            ).hashValue,
            Call(
                callee: Identifier("foo"),
                arguments: [LiteralInt(1)]
            ).hashValue
        )
    }

    func testAsEquality() {
        // Different expr
        XCTAssertNotEqual(
            As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.u8)
            ),
            As(
                expr: Identifier("bar"),
                targetType: PrimitiveType(.u8)
            )
        )

        // Different target type
        XCTAssertNotEqual(
            As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.u16)
            ),
            As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.u8)
            )
        )

        // Same
        XCTAssertEqual(
            As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.u8)
            ),
            As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.u8)
            )
        )

        // Hash
        XCTAssertEqual(
            As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.u8)
            ).hashValue,
            As(
                expr: Identifier("foo"),
                targetType: PrimitiveType(.u8)
            ).hashValue
        )
    }

    func testSubscriptEquality() {
        // Different identifier
        XCTAssertNotEqual(
            Subscript(
                subscriptable: Identifier("foo"),
                argument: LiteralInt(0)
            ),
            Subscript(
                subscriptable: Identifier("bar"),
                argument: LiteralInt(0)
            )
        )

        // Different expression
        XCTAssertNotEqual(
            Subscript(
                subscriptable: Identifier("foo"),
                argument: LiteralInt(0)
            ),
            Subscript(
                subscriptable: Identifier("foo"),
                argument: LiteralInt(1)
            )
        )

        // Same
        XCTAssertEqual(
            Subscript(
                subscriptable: Identifier("foo"),
                argument: LiteralInt(0)
            ),
            Subscript(
                subscriptable: Identifier("foo"),
                argument: LiteralInt(0)
            )
        )

        // Hash
        XCTAssertEqual(
            Subscript(
                subscriptable: Identifier("foo"),
                argument: LiteralInt(0)
            ).hashValue,
            Subscript(
                subscriptable: Identifier("foo"),
                argument: LiteralInt(0)
            ).hashValue
        )
    }

    func testLiteralArrayEquality() {
        // Different explicit lengths
        XCTAssertNotEqual(
            LiteralArray(
                arrayType: ArrayType(count: LiteralInt(1), elementType: PrimitiveType(.u8)),
                elements: [LiteralInt(0)]
            ),
            LiteralArray(
                arrayType: ArrayType(count: LiteralInt(2), elementType: PrimitiveType(.u8)),
                elements: [LiteralInt(0)]
            )
        )

        // Different explicit types
        XCTAssertNotEqual(
            LiteralArray(
                arrayType: ArrayType(count: nil, elementType: PrimitiveType(.u16)),
                elements: [LiteralInt(0)]
            ),
            LiteralArray(
                arrayType: ArrayType(count: nil, elementType: PrimitiveType(.u8)),
                elements: [LiteralInt(0)]
            )
        )

        // Different element expressions
        XCTAssertNotEqual(
            LiteralArray(
                arrayType: ArrayType(count: nil, elementType: PrimitiveType(.u8)),
                elements: [LiteralInt(0)]
            ),
            LiteralArray(
                arrayType: ArrayType(count: nil, elementType: PrimitiveType(.u8)),
                elements: [LiteralBool(false)]
            )
        )

        // Same
        XCTAssertEqual(
            LiteralArray(
                arrayType: ArrayType(count: nil, elementType: PrimitiveType(.u8)),
                elements: [LiteralInt(0)]
            ),
            LiteralArray(
                arrayType: ArrayType(count: nil, elementType: PrimitiveType(.u8)),
                elements: [LiteralInt(0)]
            )
        )

        // Same hashes
        XCTAssertEqual(
            LiteralArray(
                arrayType: ArrayType(count: LiteralInt(1), elementType: PrimitiveType(.u8)),
                elements: [LiteralInt(0)]
            ).hashValue,
            LiteralArray(
                arrayType: ArrayType(count: LiteralInt(1), elementType: PrimitiveType(.u8)),
                elements: [LiteralInt(0)]
            ).hashValue
        )
    }

    func testGetEquality() {
        // Different expressions
        XCTAssertNotEqual(
            Get(
                expr: Identifier("foo"),
                member: Identifier("foo")
            ),
            Get(
                expr: Identifier("bar"),
                member: Identifier("foo")
            )
        )

        // Different members
        XCTAssertNotEqual(
            Get(
                expr: Identifier("foo"),
                member: Identifier("foo")
            ),
            Get(
                expr: Identifier("foo"),
                member: Identifier("bar")
            )
        )

        // Same
        XCTAssertEqual(
            Get(
                expr: Identifier("foo"),
                member: Identifier("foo")
            ),
            Get(
                expr: Identifier("foo"),
                member: Identifier("foo")
            )
        )

        // Same
        XCTAssertEqual(
            Get(
                expr: Identifier("foo"),
                member: Identifier("foo")
            ).hashValue,
            Get(
                expr: Identifier("foo"),
                member: Identifier("foo")
            ).hashValue
        )
    }

    func testPrimitiveTypeEquality() {
        // Different underlying types
        XCTAssertNotEqual(
            PrimitiveType(.u8),
            PrimitiveType(.bool)
        )

        // Same
        XCTAssertEqual(
            PrimitiveType(.u8),
            PrimitiveType(.u8)
        )

        // Same hashes
        XCTAssertEqual(
            PrimitiveType(.u8).hashValue,
            PrimitiveType(.u8).hashValue
        )
    }
}
