//
//  CompilerPassEraseEseqTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/5/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassEraseEseqTests: XCTestCase {
    func testEraseEmptyEseq() throws {
        let expected: Expression = LiteralInt(0)
        let input = Eseq(seq: Seq(), expr: LiteralInt(0))
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInTopLevel() throws {
        let expected = TopLevel(children: [
            VarDeclaration(
                identifier: Identifier("t"),
                explicitType: PrimitiveType(.u16),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false
            ),
            LiteralInt(0)
        ])
        let input = TopLevel(children: [
            Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.u16),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: LiteralInt(0)
            )
        ])
        let actual = try input.eraseEseq()?.flatten()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInSubroutine() throws {
        let expected = Subroutine(
            identifier: "foo",
            children: [
                VarDeclaration(
                    identifier: Identifier("t"),
                    explicitType: PrimitiveType(.u16),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                ),
                LiteralInt(0)
            ]
        )
        let input = Subroutine(
            identifier: "foo",
            children: [
                Eseq(
                    seq: Seq(children: [
                        VarDeclaration(
                            identifier: Identifier("t"),
                            explicitType: PrimitiveType(.u16),
                            expression: nil,
                            storage: .automaticStorage(offset: nil),
                            isMutable: false
                        )
                    ]),
                    expr: LiteralInt(0)
                )
            ]
        )
        let actual = try input.eraseEseq()?.flatten()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInSeq() throws {
        let expected = Seq(children: [
            VarDeclaration(
                identifier: Identifier("t"),
                explicitType: PrimitiveType(.u16),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false
            ),
            LiteralInt(0)
        ])
        let input = Seq(children: [
            Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.u16),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: LiteralInt(0)
            )
        ])
        let actual = try input.eraseEseq()?.flatten()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInVarDeclarationExplicitType() throws {
        let expected = Seq(children: [
            VarDeclaration(
                identifier: Identifier("t"),
                explicitType: PrimitiveType(.u16),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false
            ),
            VarDeclaration(
                identifier: Identifier("a"),
                explicitType: PrimitiveType(.u16),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false
            )
        ])
        let input = VarDeclaration(
            identifier: Identifier("a"),
            explicitType: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.u16),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: PrimitiveType(.u16)
            ),
            expression: nil,
            storage: .automaticStorage(offset: nil),
            isMutable: false
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInVarDeclarationExpression() throws {
        let expected = Seq(children: [
            VarDeclaration(
                identifier: Identifier("t"),
                explicitType: PrimitiveType(.u16),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false
            ),
            VarDeclaration(
                identifier: Identifier("a"),
                explicitType: PrimitiveType(.u16),
                expression: LiteralInt(0),
                storage: .automaticStorage(offset: nil),
                isMutable: false
            )
        ])
        let input = VarDeclaration(
            identifier: Identifier("a"),
            explicitType: PrimitiveType(.u16),
            expression: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.u16),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: LiteralInt(0)
            ),
            storage: .automaticStorage(offset: nil),
            isMutable: false
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInIfStatement() throws {
        let expected = Seq(children: [
            VarDeclaration(
                identifier: Identifier("t"),
                explicitType: PrimitiveType(.bool),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false
            ),
            If(
                condition: Identifier("t"),
                then: Block(),
                else: nil
            )
        ])
        let input = If(
            condition: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.bool),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("t")
            ),
            then: Block(),
            else: nil
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInForInStatement() throws {
        let expected = Seq(children: [
            VarDeclaration(
                identifier: Identifier("t"),
                explicitType: PrimitiveType(.bool),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false
            ),
            ForIn(
                identifier: Identifier("i"),
                sequenceExpr: Identifier("t"),
                body: Block()
            )
        ])
        let input = ForIn(
            identifier: Identifier("i"),
            sequenceExpr: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.bool),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("t")
            ),
            body: Block()
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInReturn() throws {
        let expected = Seq(children: [
            VarDeclaration(
                identifier: Identifier("t"),
                explicitType: PrimitiveType(.u16),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false
            ),
            Return(LiteralInt(0))
        ])
        let input = Return(
            Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.u16),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: LiteralInt(0)
            )
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInMatch() throws {
        let expected = Seq(children: [
            VarDeclaration(
                identifier: Identifier("t"),
                explicitType: PrimitiveType(.u16),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false
            ),
            Match(
                expr: LiteralInt(0),
                clauses: [],
                elseClause: nil
            )
        ])
        let input = Match(
            expr: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.u16),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: LiteralInt(0)
            ),
            clauses: [],
            elseClause: nil
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInAssert() throws {
        let expected = Seq(children: [
            VarDeclaration(
                identifier: Identifier("t"),
                explicitType: PrimitiveType(.bool),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false
            ),
            Assert(
                condition: Identifier("t"),
                message: ""
            )
        ])
        let input = Assert(
            condition: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.bool),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("t")
            ),
            message: ""
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInGotoIfFalse() throws {
        let expected = Seq(children: [
            VarDeclaration(
                identifier: Identifier("t"),
                explicitType: PrimitiveType(.bool),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false
            ),
            GotoIfFalse(
                condition: Identifier("t"),
                target: ""
            )
        ])
        let input = GotoIfFalse(
            condition: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.bool),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("t")
            ),
            target: ""
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInLiteralArray() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("t"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: LiteralArray(
                arrayType: ArrayType(count: nil, elementType: PrimitiveType(.u8)),
                elements: [
                    Identifier("t")
                ]
            )
        )
        let input = LiteralArray(
            arrayType: ArrayType(count: nil, elementType: PrimitiveType(.u8)),
            elements: [
                Eseq(
                    seq: Seq(children: [
                        VarDeclaration(
                            identifier: Identifier("t"),
                            explicitType: PrimitiveType(.u8),
                            expression: nil,
                            storage: .automaticStorage(offset: nil),
                            isMutable: false
                        )
                    ]),
                    expr: Identifier("t")
                )
            ]
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInTypeCastExpression() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("t"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: As(
                expr: Identifier("t"),
                targetType: Identifier("type")
            )
        )
        let input = As(
            expr: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.u8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("t")
            ),
            targetType: Identifier("type")
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInBitCastExpression() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("t"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: Bitcast(
                expr: Identifier("t"),
                targetType: Identifier("type")
            )
        )
        let input = Bitcast(
            expr: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.u8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("t")
            ),
            targetType: Identifier("type")
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInUnaryExpression() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("t"),
                    explicitType: PrimitiveType(.i8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: Unary(
                op: .minus,
                expression: Identifier("t")
            )
        )
        let input = Unary(
            op: .minus,
            expression: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.i8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("t")
            )
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInBinaryExpression() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("a"),
                    explicitType: PrimitiveType(.i8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                ),
                VarDeclaration(
                    identifier: Identifier("b"),
                    explicitType: PrimitiveType(.i8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: Binary(
                op: .plus,
                left: Identifier("a"),
                right: Identifier("b")
            )
        )
        let input = Binary(
            op: .plus,
            left: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("a"),
                        explicitType: PrimitiveType(.i8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("a")
            ),
            right: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("b"),
                        explicitType: PrimitiveType(.i8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("b")
            )
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInIsExpression() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("t"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: Is(
                expr: Identifier("t"),
                testType: PrimitiveType(.u8)
            )
        )
        let input = Is(
            expr: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.u8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("t")
            ),
            testType: PrimitiveType(.u8)
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInInitialAssignment() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("a"),
                    explicitType: PrimitiveType(.i8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                ),
                VarDeclaration(
                    identifier: Identifier("b"),
                    explicitType: PrimitiveType(.i8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: InitialAssignment(
                lexpr: Identifier("a"),
                rexpr: Identifier("b")
            )
        )
        let input = InitialAssignment(
            lexpr: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("a"),
                        explicitType: PrimitiveType(.i8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("a")
            ),
            rexpr: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("b"),
                        explicitType: PrimitiveType(.i8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("b")
            )
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInAssignment() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("a"),
                    explicitType: PrimitiveType(.i8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                ),
                VarDeclaration(
                    identifier: Identifier("b"),
                    explicitType: PrimitiveType(.i8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: Assignment(
                lexpr: Identifier("a"),
                rexpr: Identifier("b")
            )
        )
        let input = Assignment(
            lexpr: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("a"),
                        explicitType: PrimitiveType(.i8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("a")
            ),
            rexpr: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("b"),
                        explicitType: PrimitiveType(.i8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("b")
            )
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInSubscript() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("arr"),
                    explicitType: ArrayType(
                        count: LiteralInt(1),
                        elementType: PrimitiveType(.u16)
                    ),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                ),
                VarDeclaration(
                    identifier: Identifier("i"),
                    explicitType: PrimitiveType(.u16),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: Subscript(
                subscriptable: Identifier("t"),
                argument: Identifier("i")
            )
        )
        let input = Subscript(
            subscriptable: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("arr"),
                        explicitType: ArrayType(
                            count: LiteralInt(1),
                            elementType: PrimitiveType(.u16)
                        ),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("t")
            ),
            argument: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("i"),
                        explicitType: PrimitiveType(.u16),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("i")
            )
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInGet() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("a"),
                    explicitType: PrimitiveType(.void),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                ),
                VarDeclaration(
                    identifier: Identifier("b"),
                    explicitType: PrimitiveType(.void),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: Get(
                expr: Identifier("a"),
                member: Identifier("b")
            )
        )
        let input = Get(
            expr: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("a"),
                        explicitType: PrimitiveType(.void),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("a")
            ),
            member: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("b"),
                        explicitType: PrimitiveType(.void),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("b")
            )
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInStructInitializer() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("baz"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: StructInitializer(
                identifier: Identifier("foo"),
                arguments: [
                    StructInitializer.Argument(
                        name: "bar",
                        expr: Identifier("baz")
                    )
                ]
            )
        )
        let input = StructInitializer(
            identifier: Identifier("foo"),
            arguments: [
                StructInitializer.Argument(
                    name: "bar",
                    expr: Eseq(
                        seq: Seq(children: [
                            VarDeclaration(
                                identifier: Identifier("baz"),
                                explicitType: PrimitiveType(.u8),
                                expression: nil,
                                storage: .automaticStorage(offset: nil),
                                isMutable: false
                            )
                        ]),
                        expr: Identifier("baz")
                    )
                )
            ]
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInCall() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("u"),
                    explicitType: PrimitiveType(.void),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                ),
                VarDeclaration(
                    identifier: Identifier("v"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: Call(
                callee: Identifier("u"),
                arguments: [
                    Identifier("v")
                ]
            )
        )
        let input = Call(
            callee: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("u"),
                        explicitType: PrimitiveType(.void),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("u")
            ),
            arguments: [
                Eseq(
                    seq: Seq(children: [
                        VarDeclaration(
                            identifier: Identifier("v"),
                            explicitType: PrimitiveType(.u8),
                            expression: nil,
                            storage: .automaticStorage(offset: nil),
                            isMutable: false
                        )
                    ]),
                    expr: Identifier("v")
                )
            ]
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInSizeOf() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("t"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: SizeOf(Identifier("t"))
        )
        let input = SizeOf(
            Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.u8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("t")
            )
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInTypeOf() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("t"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: TypeOf(Identifier("t"))
        )
        let input = TypeOf(
            Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.u8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: Identifier("t")
            )
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInPointerType() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("t"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: PointerType(PrimitiveType(.u16))
        )
        let input = PointerType(
            Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.u8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: PrimitiveType(.u16)
            )
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInConstType() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("t"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: ConstType(PrimitiveType(.u16))
        )
        let input = ConstType(
            Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.u8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: PrimitiveType(.u16)
            )
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInMutableType() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("t"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: MutableType(PrimitiveType(.u16))
        )
        let input = MutableType(
            Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.u8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: PrimitiveType(.u16)
            )
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInUnionType() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("t"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: UnionType([PrimitiveType(.u16)])
        )
        let input = UnionType([
            Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.u8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: PrimitiveType(.u16)
            )
        ])
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInDynamicArrayType() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("t"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: DynamicArrayType(PrimitiveType(.u16))
        )
        let input = DynamicArrayType(
            Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("t"),
                        explicitType: PrimitiveType(.u8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: PrimitiveType(.u16)
            )
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInArrayType() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("u"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                ),
                VarDeclaration(
                    identifier: Identifier("v"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: ArrayType(
                count: PrimitiveType(.u16),
                elementType: PrimitiveType(.u16)
            )
        )
        let input = ArrayType(
            count: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("u"),
                        explicitType: PrimitiveType(.u8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: PrimitiveType(.u16)
            ),
            elementType: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("v"),
                        explicitType: PrimitiveType(.u8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: PrimitiveType(.u16)
            )
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInFunctionType() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("u"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                ),
                VarDeclaration(
                    identifier: Identifier("v"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: FunctionType(
                returnType: PrimitiveType(.u16),
                arguments: [
                    PrimitiveType(.u16)
                ]
            )
        )
        let input = FunctionType(
            returnType: Eseq(
                seq: Seq(children: [
                    VarDeclaration(
                        identifier: Identifier("u"),
                        explicitType: PrimitiveType(.u8),
                        expression: nil,
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    )
                ]),
                expr: PrimitiveType(.u16)
            ),
            arguments: [
                Eseq(
                    seq: Seq(children: [
                        VarDeclaration(
                            identifier: Identifier("v"),
                            explicitType: PrimitiveType(.u8),
                            expression: nil,
                            storage: .automaticStorage(offset: nil),
                            isMutable: false
                        )
                    ]),
                    expr: PrimitiveType(.u16)
                )
            ]
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }

    func testEraseEseqInGenericTypeApplication() throws {
        let expected = Eseq(
            seq: Seq(children: [
                VarDeclaration(
                    identifier: Identifier("u"),
                    explicitType: PrimitiveType(.u8),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]),
            expr: GenericTypeApplication(
                identifier: Identifier("fn"),
                arguments: [
                    PrimitiveType(.u8)
                ]
            )
        )
        let input = GenericTypeApplication(
            identifier: Identifier("fn"),
            arguments: [
                Eseq(
                    seq: Seq(children: [
                        VarDeclaration(
                            identifier: Identifier("u"),
                            explicitType: PrimitiveType(.u8),
                            expression: nil,
                            storage: .automaticStorage(offset: nil),
                            isMutable: false
                        )
                    ]),
                    expr: PrimitiveType(.u8)
                )
            ]
        )
        let actual = try input.eraseEseq()
        XCTAssertEqual(actual, expected)
    }
}
