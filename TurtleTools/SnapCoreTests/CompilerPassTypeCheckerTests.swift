//
//  CompilerPassTypeCheckerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassTypeCheckerTests: XCTestCase {
    func testSimpleExpressionStatement() throws {
        let node = Block(
            children: [
                LiteralInt(42)
            ]
        )
        .reconnect(parent: nil)

        XCTAssertNoThrow(try node.typeCheck())
    }

    func testBinaryExpression() throws {
        let node = Block(
            children: [
                Binary(
                    op: .plus,
                    left: LiteralInt(1),
                    right: LiteralInt(2)
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertNoThrow(try node.typeCheck())
    }

    func testInvalidBinaryExpression() throws {
        let node = Block(
            children: [
                Binary(
                    op: .plus,
                    left: LiteralInt(1),
                    right: LiteralBool(true)
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertThrowsError(try node.typeCheck()) { error in
            let compilerError = error as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "binary operator `+' cannot be applied to operands of types `integer constant 1' and `boolean constant true'"
            )
        }
    }

    func testIfStatementWithValidCondition() throws {
        let node = Block(
            children: [
                If(
                    condition: LiteralBool(true),
                    then: Block(),
                    else: nil
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertNoThrow(try node.typeCheck())
    }

    func testIfStatementWithInvalidCondition() throws {
        let node = Block(
            children: [
                If(
                    condition: LiteralInt(1),
                    then: Block(),
                    else: nil
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertThrowsError(try node.typeCheck()) { error in
            let compilerError = error as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "condition must be of boolean type, not `integer constant 1'"
            )
        }
    }

    func testWhileStatementWithValidCondition() throws {
        let node = Block(
            children: [
                While(
                    condition: LiteralBool(false),
                    body: Block()
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertNoThrow(try node.typeCheck())
    }

    func testWhileStatementWithInvalidCondition() throws {
        let node = Block(
            children: [
                While(
                    condition: LiteralInt(0),
                    body: Block()
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertThrowsError(try node.typeCheck()) { error in
            let compilerError = error as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "condition must be of boolean type, not `integer constant 0'"
            )
        }
    }

    func testAssertWithValidCondition() throws {
        let node = Block(
            children: [
                Assert(condition: LiteralBool(true), message: "test")
            ]
        )
        .reconnect(parent: nil)

        XCTAssertNoThrow(try node.typeCheck())
    }

    func testAssertWithInvalidCondition() throws {
        let node = Block(
            children: [
                Assert(condition: LiteralString("true"), message: "test")
            ]
        )
        .reconnect(parent: nil)

        XCTAssertThrowsError(try node.typeCheck()) { error in
            let compilerError = error as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "assert condition must be of boolean type, not `[4]u8'"
            )
        }
    }

    func testGotoIfFalseWithValidCondition() throws {
        let node = Block(
            children: [
                GotoIfFalse(condition: LiteralBool(false), target: "label")
            ]
        )
        .reconnect(parent: nil)

        XCTAssertNoThrow(try node.typeCheck())
    }

    func testGotoIfFalseWithInvalidCondition() throws {
        let node = Block(
            children: [
                GotoIfFalse(condition: LiteralInt(0), target: "label")
            ]
        )

        XCTAssertThrowsError(try node.typeCheck()) { error in
            let compilerError = error as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "goto condition must be of boolean type, not `integer constant 0'"
            )
        }
    }

    func testValidAssignment() throws {
        let node = Block(
            children: [
                VarDeclaration(
                    identifier: Identifier("foo"),
                    explicitType: PrimitiveType(.u16),
                    isMutable: true
                ),
                Assignment(
                    lexpr: Identifier("foo"),
                    rexpr: LiteralInt(42)
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertNoThrow(try node.typeCheck())
    }

    func testInvalidAssignment() throws {
        let node = Block(
            children: [
                VarDeclaration(
                    identifier: Identifier("foo"),
                    explicitType: PrimitiveType(.u16),
                    isMutable: true
                ),
                Assignment(
                    lexpr: Identifier("foo"),
                    rexpr: LiteralBool(true)
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertThrowsError(try node.typeCheck()) { error in
            let compilerError = error as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot assign value of type `boolean constant true' to type `u16'"
            )
        }
    }

    func testUnaryExpression() throws {
        let node = Block(
            children: [
                VarDeclaration(
                    identifier: Identifier("foo"),
                    explicitType: PrimitiveType(.u16)
                ),
                Unary(
                    op: .ampersand,
                    expression: Identifier("foo")
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertNoThrow(try node.typeCheck())
    }

    func testInvalidUnaryExpression() throws {
        let node = Block(
            children: [
                Unary(
                    op: .ampersand,
                    expression: LiteralInt(42)
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertThrowsError(try node.typeCheck()) { error in
            let compilerError = error as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "lvalue required as operand of unary operator `&'"
            )
        }
    }

    func testCallExpression() throws {
        let node = Block(
            children: [
                FunctionDeclaration(
                    identifier: Identifier("test"),
                    functionType: FunctionType(
                        name: "test",
                        returnType: PrimitiveType(.u16),
                        arguments: [PrimitiveType(.u16)]
                    ),
                    argumentNames: ["a"],
                    body: Block(children: [Identifier("a")])
                ),
                Call(
                    callee: Identifier("test"),
                    arguments: [LiteralInt(42)]
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertNoThrow(try node.typeCheck())
    }

    func testSubscriptExpression() throws {
        let node = Block(
            children: [
                VarDeclaration(
                    identifier: Identifier("arr"),
                    explicitType: ArrayType(
                        count: LiteralInt(10),
                        elementType: PrimitiveType(.u16)
                    )
                ),
                Subscript(
                    subscriptable: Identifier("arr"),
                    argument: LiteralInt(0)
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertNoThrow(try node.typeCheck())
    }

    func testGetExpression() throws {
        let node = Block(
            children: [
                StructDeclaration(
                    identifier: Identifier("Point"),
                    members: [
                        StructDeclaration.Member(name: "x", type: PrimitiveType(.u16)),
                        StructDeclaration.Member(name: "y", type: PrimitiveType(.u16))
                    ]
                ),
                VarDeclaration(
                    identifier: Identifier("point"),
                    explicitType: Identifier("Point")
                ),
                Get(
                    expr: Identifier("point"),
                    member: Identifier("x")
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertNoThrow(try node.typeCheck())
    }

    func testVarDeclarationWithExplicitType() throws {
        let node = Block(
            children: [
                VarDeclaration(
                    identifier: Identifier("foo"),
                    explicitType: PrimitiveType(.u16)
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertNoThrow(try node.typeCheck())
    }

    func testMatchStatement() throws {
        let node = Block(
            children: [
                VarDeclaration(
                    identifier: Identifier("value"),
                    explicitType: PrimitiveType(.u16)
                ),
                Match(
                    expr: Identifier("value"),
                    clauses: [
                        Match.Clause(
                            valueIdentifier: Identifier("x"),
                            valueType: PrimitiveType(.u16),
                            block: Block()
                        )
                    ],
                    elseClause: nil
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertNoThrow(try node.typeCheck())
    }

    func testLiteralArray() throws {
        let node = Block(
            children: [
                LiteralArray(
                    arrayType: ArrayType(count: LiteralInt(3), elementType: PrimitiveType(.u16)),
                    elements: [LiteralInt(1), LiteralInt(2), LiteralInt(3)]
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertNoThrow(try node.typeCheck())
    }

    func testComplexBlock() throws {
        let node = Block(
            children: [
                VarDeclaration(identifier: Identifier("x"), explicitType: PrimitiveType(.u16)),
                VarDeclaration(identifier: Identifier("y"), explicitType: PrimitiveType(.u16)),
                Binary(op: .plus, left: Identifier("x"), right: Identifier("y"))
            ]
        )
        .reconnect(parent: nil)

        XCTAssertNoThrow(try node.typeCheck())
    }
}
