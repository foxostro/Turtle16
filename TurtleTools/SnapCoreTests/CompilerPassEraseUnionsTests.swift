//
//  CompilerPassEraseUnionsTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/12/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassEraseUnionsTests: XCTestCase {
    private typealias Member = StructDeclaration.Member
    private let memoryLayoutStrategy = MemoryLayoutStrategyTurtle16()
    private let foo = Identifier("foo")
    private let bar = Identifier("bar")
    private let tag = Identifier("tag")
    private let payload = Identifier("payload")
    private let pointee = Identifier("pointee")

    func testEraseUnionTypeExpression_ZeroMembers() throws {
        let input = Block(children: [
            UnionType([])
        ])
        .reconnect(parent: nil)

        let fields = Env(
            frameLookupMode: .set(Frame()),
            tuples: [
                (tag.identifier, Symbol(type: .u16, offset: 0)),
                (payload.identifier, Symbol(type: .array(count: 0, elementType: .u8), offset: 1))
            ]
        )

        let expected = Block(children: [
            PrimitiveType(.structType(StructTypeInfo(name: "", fields: fields)))
        ])
        .reconnect(parent: nil)

        let actual = try input.eraseUnions(memoryLayoutStrategy)
        XCTAssertEqual(actual, expected)
    }

    func testEraseUnionTypeExpression_TwoMembers() throws {
        let input = Block(children: [
            UnionType([PrimitiveType(.u16), PrimitiveType(.bool)])
        ])
        .reconnect(parent: nil)

        let fields = Env(
            frameLookupMode: .set(Frame()),
            tuples: [
                (tag.identifier, Symbol(type: .u16, offset: 0)),
                (payload.identifier, Symbol(type: .array(count: 1, elementType: .u8), offset: 1))
            ]
        )
        fields.frameLookupMode = .set(Frame())

        let expected = Block(children: [
            PrimitiveType(
                .structType(
                    StructTypeInfo(name: "", fields: fields)
                )
            )
        ])
        .reconnect(parent: nil)

        let actual = try input.eraseUnions(memoryLayoutStrategy)
        XCTAssertEqual(actual, expected)
    }

    func testRewriteDeclarationOfVariableWithUnionType() throws {
        let input = Block(children: [
            VarDeclaration(
                identifier: foo,
                explicitType: UnionType([PrimitiveType(.u16), PrimitiveType(.bool)]),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false
            )
        ])
        .reconnect(parent: nil)

        let fields = Env(
            frameLookupMode: .set(Frame()),
            tuples: [
                (tag.identifier, Symbol(type: .u16, offset: 0)),
                (payload.identifier, Symbol(type: .array(count: 1, elementType: .u8), offset: 1))
            ]
        )
        fields.frameLookupMode = .set(Frame())

        let expected = Block(children: [
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(
                    .structType(
                        StructTypeInfo(name: "", fields: fields)
                    )
                ),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false
            )
        ])
        .reconnect(parent: nil)

        let actual = try input.eraseUnions(memoryLayoutStrategy)
        XCTAssertEqual(actual, expected)
    }

    func testRewriteDeclarationOfVariableWithUnionType_WithInitialValue() throws {
        let input = Block(children: [
            VarDeclaration(
                identifier: foo,
                explicitType: UnionType([PrimitiveType(.u16), PrimitiveType(.bool)]),
                expression: LiteralBool(false),
                storage: .automaticStorage(offset: nil),
                isMutable: false
            )
        ])
        .reconnect(parent: nil)

        let fields = Env(
            frameLookupMode: .set(Frame()),
            tuples: [
                (tag.identifier, Symbol(type: .u16, offset: 0)),
                (payload.identifier, Symbol(type: .array(count: 1, elementType: .u8), offset: 1))
            ]
        )
        fields.frameLookupMode = .set(Frame())

        let expected = Block(children: [
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(
                    .structType(
                        StructTypeInfo(name: "", fields: fields)
                    )
                ),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false
            ),
            Eseq(
                seq: Seq(
                    children: [
                        InitialAssignment(
                            lexpr: Get(
                                expr: foo,
                                member: tag
                            ),
                            rexpr: LiteralInt(1)
                        )
                    ]
                ),
                expr: InitialAssignment(
                    lexpr: Get(
                        expr: Bitcast(
                            expr: Unary(
                                op: .ampersand,
                                expression: Get(
                                    expr: foo,
                                    member: payload
                                )
                            ),
                            targetType: PointerType(PrimitiveType(.constBool))
                        ),
                        member: pointee
                    ),
                    rexpr: LiteralBool(false)
                )
            )
        ])
        .reconnect(parent: nil)

        let actual = try input
            .eraseUnions(memoryLayoutStrategy)?
            .eraseEseq()?
            .flatten()
        XCTAssertEqual(actual, expected)
    }
    
    func testAssignUnionValueToUnionValueOfSameType() throws {
        let input = Block(children: [
            VarDeclaration(
                identifier: foo,
                explicitType: UnionType([PrimitiveType(.u16), PrimitiveType(.bool)]),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: true
            ),
            VarDeclaration(
                identifier: bar,
                explicitType: UnionType([PrimitiveType(.u16), PrimitiveType(.bool)]),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: true
            ),
            Assignment(
                lexpr: foo,
                rexpr: bar
            )
        ])
        .reconnect(parent: nil)

        let fields = Env(
            frameLookupMode: .set(Frame()),
            tuples: [
                (tag.identifier, Symbol(type: .u16, offset: 0)),
                (payload.identifier, Symbol(type: .array(count: 1, elementType: .u8), offset: 1))
            ]
        )
        fields.frameLookupMode = .set(Frame())

        let expected = Block(children: [
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(
                    .structType(
                        StructTypeInfo(name: "", fields: fields)
                    )
                ),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: true
            ),
            VarDeclaration(
                identifier: bar,
                explicitType: PrimitiveType(
                    .structType(
                        StructTypeInfo(name: "", fields: fields)
                    )
                ),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: true
            ),
            Assignment(
                lexpr: foo,
                rexpr: bar
            )
        ])
        .reconnect(parent: nil)

        let actual = try input.eraseUnions(memoryLayoutStrategy)
        XCTAssertEqual(actual, expected)
    }

    func testRewriteAssignmentToVariableWithUnionType_tag0() throws {
        let input = Block(children: [
            VarDeclaration(
                identifier: foo,
                explicitType: UnionType([PrimitiveType(.u16), PrimitiveType(.bool)]),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: true
            ),
            Assignment(
                lexpr: foo,
                rexpr: LiteralInt(0xabcd)
            )
        ])
        .reconnect(parent: nil)

        let fields = Env(
            frameLookupMode: .set(Frame()),
            tuples: [
                (tag.identifier, Symbol(type: .u16, offset: 0)),
                (payload.identifier, Symbol(type: .array(count: 1, elementType: .u8), offset: 1))
            ]
        )
        fields.frameLookupMode = .set(Frame())

        let expected = Block(children: [
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(
                    .structType(
                        StructTypeInfo(name: "", fields: fields)
                    )
                ),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: true
            ),
            Eseq(
                seq: Seq(children: [
                    Assignment(
                        lexpr: Get(expr: foo, member: tag),
                        rexpr: LiteralInt(0)
                    )
                ]),
                expr: Assignment(
                    lexpr: Get(
                        expr: Bitcast(
                            expr: Unary(
                                op: .ampersand,
                                expression: Get(
                                    expr: foo,
                                    member: payload
                                )
                            ),
                            targetType: PointerType(PrimitiveType(.u16))
                        ),
                        member: pointee
                    ),
                    rexpr: LiteralInt(0xabcd)
                )
            )
        ])
        .reconnect(parent: nil)

        let actual = try input.eraseUnions(memoryLayoutStrategy)
        XCTAssertEqual(actual, expected)
    }

    func testRewriteAssignmentToVariableWithUnionType_tag1() throws {
        let input = Block(children: [
            VarDeclaration(
                identifier: foo,
                explicitType: UnionType([PrimitiveType(.u16), PrimitiveType(.bool)]),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: true
            ),
            Assignment(
                lexpr: foo,
                rexpr: LiteralBool(true)
            )
        ])
        .reconnect(parent: nil)

        let fields = Env(
            frameLookupMode: .set(Frame()),
            tuples: [
                (tag.identifier, Symbol(type: .u16, offset: 0)),
                (payload.identifier, Symbol(type: .array(count: 1, elementType: .u8), offset: 1))
            ]
        )
        fields.frameLookupMode = .set(Frame())

        let expected = Block(children: [
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(
                    .structType(
                        StructTypeInfo(name: "", fields: fields)
                    )
                ),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: true
            ),
            Eseq(
                seq: Seq(children: [
                    Assignment(
                        lexpr: Get(expr: foo, member: tag),
                        rexpr: LiteralInt(1)
                    )
                ]),
                expr: Assignment(
                    lexpr: Get(
                        expr: Bitcast(
                            expr: Unary(
                                op: .ampersand,
                                expression: Get(
                                    expr: foo,
                                    member: payload
                                )
                            ),
                            targetType: PointerType(PrimitiveType(.bool))
                        ),
                        member: pointee
                    ),
                    rexpr: LiteralBool(true)
                )
            )
        ])
        .reconnect(parent: nil)

        let actual = try input.eraseUnions(memoryLayoutStrategy)
        XCTAssertEqual(actual, expected)
    }

    public func testUnionIs() throws {
        let input = Block(children: [
            VarDeclaration(
                identifier: foo,
                explicitType: UnionType([PrimitiveType(.u16), PrimitiveType(.bool)]),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: true
            ),
            Is(
                expr: foo,
                testType: PrimitiveType(.bool)
            )
        ])
        .reconnect(parent: nil)

        let fields = Env(
            frameLookupMode: .set(Frame()),
            tuples: [
                (tag.identifier, Symbol(type: .u16, offset: 0)),
                (payload.identifier, Symbol(type: .array(count: 1, elementType: .u8), offset: 1))
            ]
        )
        fields.frameLookupMode = .set(Frame())

        let expected = Block(children: [
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(
                    .structType(
                        StructTypeInfo(name: "", fields: fields)
                    )
                ),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: true
            ),
            Binary(
                op: .eq,
                left: Get(expr: foo, member: tag),
                right: LiteralInt(1)
            )
        ])
        .reconnect(parent: nil)

        let actual = try input.eraseUnions(memoryLayoutStrategy)
        XCTAssertEqual(actual, expected)
    }

    public func testUnionAs() throws {
        let input = Block(children: [
            VarDeclaration(
                identifier: foo,
                explicitType: UnionType([PrimitiveType(.u16), PrimitiveType(.bool)]),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: true
            ),
            As(
                expr: foo,
                targetType: PrimitiveType(.bool)
            )
        ])
        .reconnect(parent: nil)

        let fields = Env(
            frameLookupMode: .set(Frame()),
            tuples: [
                (tag.identifier, Symbol(type: .u16, offset: 0)),
                (payload.identifier, Symbol(type: .array(count: 1, elementType: .u8), offset: 1))
            ]
        )
        fields.frameLookupMode = .set(Frame())

        let expected = Block(children: [
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(
                    .structType(
                        StructTypeInfo(name: "", fields: fields)
                    )
                ),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: true
            ),
            Eseq(
                seq: Seq(
                    children: [
                        If(
                            condition: Unary(
                                op: .bang,
                                expression: Binary(
                                    op: .eq,
                                    left: Get(expr: foo, member: tag),
                                    right: LiteralInt(1)
                                )
                            ),
                            then: Block(
                                children: [
                                    Call(
                                        callee: Identifier("__panic"),
                                        arguments: [
                                            LiteralString("bad union cast")
                                        ]
                                    )
                                ]
                            ),
                            else: nil
                        )
                    ]
                ),
                expr:
                    As(
                        expr: Unary(
                            op: .ampersand,
                            expression: Get(
                                expr: foo,
                                member: payload
                            )
                        ),
                        targetType: PrimitiveType(.bool)
                    )
            )
        ])
        .reconnect(parent: nil)

        let actual = try input.eraseUnions(memoryLayoutStrategy)
        XCTAssertEqual(actual, expected)
    }

    public func testUnionAs_WithImplicitlyConvertibleType() throws {
        let input = Block(children: [
            VarDeclaration(
                identifier: foo,
                explicitType: UnionType([PrimitiveType(.u16), PrimitiveType(.bool)]),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: true
            ),
            As(
                expr: foo,
                targetType: PrimitiveType(.u8)
            )
        ])
        .reconnect(parent: nil)

        let fields = Env(
            frameLookupMode: .set(Frame()),
            tuples: [
                (tag.identifier, Symbol(type: .u16, offset: 0)),
                (payload.identifier, Symbol(type: .array(count: 1, elementType: .u8), offset: 1))
            ]
        )
        fields.frameLookupMode = .set(Frame())

        let expected = Block(children: [
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(
                    .structType(
                        StructTypeInfo(name: "", fields: fields)
                    )
                ),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: true
            ),
            Eseq(
                seq: Seq(
                    children: [
                        If(
                            condition: Unary(
                                op: .bang,
                                expression: Binary(
                                    op: .eq,
                                    left: Get(expr: foo, member: tag),
                                    right: LiteralInt(0)
                                )
                            ),
                            then: Block(
                                children: [
                                    Call(
                                        callee: Identifier("__panic"),
                                        arguments: [
                                            LiteralString("bad union cast")
                                        ]
                                    )
                                ]
                            ),
                            else: nil
                        )
                    ]
                ),
                expr:
                    As(
                        expr: As(
                            expr: Unary(
                                op: .ampersand,
                                expression: Get(
                                    expr: foo,
                                    member: payload
                                )
                            ),
                            targetType: PrimitiveType(.u16)
                        ),
                        targetType: PrimitiveType(.u8)
                    )
            )
        ])
        .reconnect(parent: nil)

        let actual = try input.eraseUnions(memoryLayoutStrategy)
        XCTAssertEqual(actual, expected)
    }
    
    public func testConversionToUnionType() throws {
        let input = Block(children: [
            As(
                expr: LiteralBool(true),
                targetType: UnionType([PrimitiveType(.bool)])
            )
        ])
        .reconnect(parent: nil)

        let structTyp = {
            let fields = Env(
                frameLookupMode: .set(Frame()),
                tuples: [
                    (tag.identifier, Symbol(type: .u16, offset: 0)),
                    (payload.identifier, Symbol(type: .array(count: 1, elementType: .u8), offset: 1))
                ]
            )
            fields.frameLookupMode = .set(Frame())
            let typ = PrimitiveType(
                .structType(
                    StructTypeInfo(name: "", fields: fields)
                )
            )
            return typ
        }()

        let expected = Block(children: [
            Eseq(
                seq: Seq(
                    children: [
                        VarDeclaration(
                            identifier: Identifier("__temp0"),
                            explicitType: structTyp,
                            expression: nil,
                            storage: .automaticStorage(offset: nil),
                            isMutable: false
                        ),
                        InitialAssignment(
                            lexpr: Get(
                                expr: Identifier("__temp0"),
                                member: Identifier("tag")
                            ),
                            rexpr: LiteralInt(0)
                        ),
                        InitialAssignment(
                            lexpr: Get(
                                expr: Bitcast(
                                    expr: Unary(
                                        op: .ampersand,
                                        expression: Get(
                                            expr: Identifier("__temp0"),
                                            member: payload
                                        )
                                    ),
                                    targetType: PointerType(PrimitiveType(.bool))
                                ),
                                member: pointee
                            ),
                            rexpr: LiteralBool(true)
                        )
                    ]
                ),
                expr: Identifier("__temp0")
            )
        ])
        .reconnect(parent: nil)

        let actual = try input.eraseUnions(memoryLayoutStrategy)
        XCTAssertEqual(actual, expected)
    }
}
