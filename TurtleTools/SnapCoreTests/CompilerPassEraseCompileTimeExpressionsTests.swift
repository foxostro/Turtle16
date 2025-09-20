//
//  CompilerPassEraseCompileTimeExpressionsTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/11/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassEraseCompileTimeExpressionsTests: XCTestCase {
    private let a = Identifier("a")
    private let u16 = PrimitiveType(.u16)
    private let bool = PrimitiveType(.bool)

    func testTypeTestExpression() throws {
        let input = Block(
            children: [
                Is(expr: LiteralBool(false), testType: u16)
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralBool(false)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testTypeOfExpression() throws {
        let input = Block(
            children: [
                TypeOf(
                    Binary(
                        op: .plus,
                        left: LiteralInt(1),
                        right: LiteralInt(1)
                    )
                )
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                PrimitiveType(.u8)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testSizeOfExpression_GiveAnExpression() throws {
        let input = Block(
            children: [
                VarDeclaration(identifier: a, explicitType: u16),
                SizeOf(a)
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                VarDeclaration(identifier: a, explicitType: u16),
                As(expr: LiteralInt(1), targetType: u16)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions(
            MemoryLayoutStrategyTurtle16()
        )
        XCTAssertEqual(actual, expected)
    }

    func testSizeOfExpression_NameAType() throws {
        let input = Block(
            children: [
                SizeOf(u16)
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                As(expr: LiteralInt(1), targetType: u16)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions(
            MemoryLayoutStrategyTurtle16()
        )
        XCTAssertEqual(actual, expected)
    }

    func testCompileTimeIntegerArithmeticExpression() throws {
        let input = Block(
            children: [
                Binary(op: .plus, left: LiteralInt(1), right: LiteralInt(2))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralInt(3)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testCompileTimeBooleanExpression() throws {
        let input = Block(
            children: [
                Binary(op: .eq, left: LiteralBool(true), right: LiteralBool(true))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralBool(true)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_bool_eq() throws {
        let input = Block(
            children: [
                Binary(op: .eq, left: LiteralBool(true), right: LiteralBool(true))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralBool(true)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_bool_ne() throws {
        let input = Block(
            children: [
                Binary(op: .ne, left: LiteralBool(true), right: LiteralBool(true))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralBool(false)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_bool_and() throws {
        let input = Block(
            children: [
                Binary(op: .doubleAmpersand, left: LiteralBool(false), right: LiteralBool(true))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralBool(false)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_bool_or() throws {
        let input = Block(
            children: [
                Binary(op: .doublePipe, left: LiteralBool(false), right: LiteralBool(true))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralBool(true)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_eq() throws {
        let input = Block(
            children: [
                Binary(op: .eq, left: LiteralInt(1), right: LiteralInt(1))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralBool(true)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_ne() throws {
        let input = Block(
            children: [
                Binary(op: .ne, left: LiteralInt(1), right: LiteralInt(1))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralBool(false)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_lt() throws {
        let input = Block(
            children: [
                Binary(op: .lt, left: LiteralInt(1), right: LiteralInt(2))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralBool(true)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_gt() throws {
        let input = Block(
            children: [
                Binary(op: .gt, left: LiteralInt(2), right: LiteralInt(1))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralBool(true)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_le() throws {
        let input = Block(
            children: [
                Binary(op: .le, left: LiteralInt(1), right: LiteralInt(1))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralBool(true)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_ge() throws {
        let input = Block(
            children: [
                Binary(op: .ge, left: LiteralInt(1), right: LiteralInt(1))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralBool(true)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_add() throws {
        let input = Block(
            children: [
                Binary(op: .plus, left: LiteralInt(-1000), right: LiteralInt(-1000))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralInt(-2000)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_sub() throws {
        let input = Block(
            children: [
                Binary(op: .minus, left: LiteralInt(1), right: LiteralInt(1))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralInt(0)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_mul() throws {
        let input = Block(
            children: [
                Binary(op: .star, left: LiteralInt(1), right: LiteralInt(-1))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralInt(-1)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_div() throws {
        let input = Block(
            children: [
                Binary(op: .divide, left: LiteralInt(-1), right: LiteralInt(-1))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralInt(1)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_mod() throws {
        let input = Block(
            children: [
                Binary(op: .modulus, left: LiteralInt(3), right: LiteralInt(2))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralInt(1)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_and() throws {
        let input = Block(
            children: [
                Binary(op: .ampersand, left: LiteralInt(0xab), right: LiteralInt(0x0f))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralInt(0xb)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_or() throws {
        let input = Block(
            children: [
                Binary(op: .pipe, left: LiteralInt(0xab), right: LiteralInt(0x0f))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralInt(0xaf)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_xor() throws {
        let input = Block(
            children: [
                Binary(op: .caret, left: LiteralInt(0xab), right: LiteralInt(0xab))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralInt(0)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_lsl() throws {
        let input = Block(
            children: [
                Binary(op: .leftDoubleAngle, left: LiteralInt(2), right: LiteralInt(2))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralInt(8)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testBinary_comptime_lsr() throws {
        let input = Block(
            children: [
                Binary(op: .rightDoubleAngle, left: LiteralInt(8), right: LiteralInt(2))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: [
                LiteralInt(2)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }

    func testGetCountOfArray() throws {
        let shared = [
            VarDeclaration(
                identifier: a,
                explicitType: ArrayType(
                    count: LiteralInt(10),
                    elementType: PrimitiveType(.u8)
                ),
            )
        ]
        let input = Block(
            children: shared + [
                Get(expr: a, member: Identifier("count"))
            ]
        )
        .reconnect(parent: nil)

        let expected = Block(
            children: shared + [
                As(expr: LiteralInt(10), targetType: u16)
            ]
        )
        .reconnect(parent: nil)

        let actual = try input.eraseCompileTimeExpressions()
        XCTAssertEqual(actual, expected)
    }
}
