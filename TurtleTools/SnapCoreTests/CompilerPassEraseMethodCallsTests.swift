//
//  CompilerPassEraseMethodCallsTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 12/25/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassEraseMethodCallsTests: XCTestCase {
    func testEraseMethodCalls() throws {
        let ast0 = Block(children: [
            StructDeclaration(
                identifier: Identifier("Foo"),
                members: [
                    StructDeclaration.Member(
                        name: "val",
                        type: PrimitiveType(.i16)
                    )
                ],
                visibility: .privateVisibility
            ),
            Impl(
                typeArguments: [],
                structTypeExpr: Identifier("Foo"),
                children: [
                    FunctionDeclaration(
                        identifier: Identifier("bar"),
                        functionType: FunctionType(
                            name: "bar",
                            returnType: PrimitiveType(.u8),
                            arguments: [
                                PointerType(Identifier("Foo"))
                            ]
                        ),
                        argumentNames: ["baz"],
                        typeArguments: [],
                        body: Block(children: [
                            Return(LiteralInt(0))
                        ])
                    )
                ]
            ),
            VarDeclaration(
                identifier: Identifier("instance"),
                explicitType: Identifier("Foo"),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            Call(
                callee: Get(
                    expr: Identifier("instance"),
                    member: Identifier("bar")
                ),
                arguments: []
            )
        ])
        .reconnect(parent: nil)

        let expected = Block(children: [
            StructDeclaration(
                identifier: Identifier("Foo"),
                members: [
                    StructDeclaration.Member(
                        name: "val",
                        type: PrimitiveType(.i16)
                    )
                ],
                visibility: .privateVisibility
            ),
            Impl(
                typeArguments: [],
                structTypeExpr: Identifier("Foo"),
                children: [
                    FunctionDeclaration(
                        identifier: Identifier("bar"),
                        functionType: FunctionType(
                            name: "bar",
                            returnType: PrimitiveType(.u8),
                            arguments: [
                                PointerType(Identifier("Foo"))
                            ]
                        ),
                        argumentNames: ["baz"],
                        typeArguments: [],
                        body: Block(children: [
                            Return(LiteralInt(0))
                        ])
                    )
                ]
            ),
            VarDeclaration(
                identifier: Identifier("instance"),
                explicitType: Identifier("Foo"),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            Call(
                callee: Get(
                    expr: Identifier("Foo"),
                    member: Identifier("bar")
                ),
                arguments: [
                    Identifier("instance")
                ]
            )
        ])
        .reconnect(parent: nil)

        let actual = try ast0
            .eraseMethodCalls()?
            .flatten()

        XCTAssertEqual(actual, expected)
    }

    func testEraseMethodCallsThroughPointer() throws {
        let ast0 = Block(children: [
            StructDeclaration(
                identifier: Identifier("Foo"),
                members: [
                    StructDeclaration.Member(
                        name: "val",
                        type: PrimitiveType(.i16)
                    )
                ],
                visibility: .privateVisibility
            ),
            Impl(
                typeArguments: [],
                structTypeExpr: Identifier("Foo"),
                children: [
                    FunctionDeclaration(
                        identifier: Identifier("bar"),
                        functionType: FunctionType(
                            name: "bar",
                            returnType: PrimitiveType(.u8),
                            arguments: [
                                PointerType(Identifier("Foo"))
                            ]
                        ),
                        argumentNames: ["baz"],
                        typeArguments: [],
                        body: Block(children: [
                            Return(LiteralInt(0))
                        ])
                    )
                ]
            ),
            VarDeclaration(
                identifier: Identifier("instance"),
                explicitType: PointerType(Identifier("Foo")),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            Call(
                callee: Get(
                    expr: Identifier("instance"),
                    member: Identifier("bar")
                ),
                arguments: []
            )
        ])
        .reconnect(parent: nil)

        let expected = Block(children: [
            StructDeclaration(
                identifier: Identifier("Foo"),
                members: [
                    StructDeclaration.Member(
                        name: "val",
                        type: PrimitiveType(.i16)
                    )
                ],
                visibility: .privateVisibility
            ),
            Impl(
                typeArguments: [],
                structTypeExpr: Identifier("Foo"),
                children: [
                    FunctionDeclaration(
                        identifier: Identifier("bar"),
                        functionType: FunctionType(
                            name: "bar",
                            returnType: PrimitiveType(.u8),
                            arguments: [
                                PointerType(Identifier("Foo"))
                            ]
                        ),
                        argumentNames: ["baz"],
                        typeArguments: [],
                        body: Block(children: [
                            Return(LiteralInt(0))
                        ])
                    )
                ]
            ),
            VarDeclaration(
                identifier: Identifier("instance"),
                explicitType: PointerType(Identifier("Foo")),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            Call(
                callee: Get(
                    expr: Identifier("Foo"),
                    member: Identifier("bar")
                ),
                arguments: [
                    Identifier("instance")
                ]
            )
        ])
        .reconnect(parent: nil)

        let actual = try ast0
            .eraseMethodCalls()?
            .flatten()

        XCTAssertEqual(actual, expected)
    }

    func testDirectReferenceToStructMethodIsUnaffected() throws {
        let ast0 = Block(children: [
            StructDeclaration(
                identifier: Identifier("Foo"),
                members: [
                    StructDeclaration.Member(
                        name: "val",
                        type: PrimitiveType(.i16)
                    )
                ],
                visibility: .privateVisibility
            ),
            Impl(
                typeArguments: [],
                structTypeExpr: Identifier("Foo"),
                children: [
                    FunctionDeclaration(
                        identifier: Identifier("bar"),
                        functionType: FunctionType(
                            name: "bar",
                            returnType: PrimitiveType(.u8),
                            arguments: [
                                PointerType(Identifier("Foo"))
                            ]
                        ),
                        argumentNames: ["baz"],
                        typeArguments: [],
                        body: Block(children: [
                            Return(LiteralInt(0))
                        ])
                    )
                ]
            ),
            VarDeclaration(
                identifier: Identifier("instance"),
                explicitType: Identifier("Foo"),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            Call(
                callee: Get(
                    expr: Identifier("Foo"),
                    member: Identifier("bar")
                ),
                arguments: [
                    Identifier("instance")
                ]
            )
        ])
        .reconnect(parent: nil)

        let actual = try ast0
            .eraseMethodCalls()?
            .flatten()

        XCTAssertEqual(ast0, actual)
    }

    func testNoSelfParameter() throws {
        let ast0 = Block(children: [
            StructDeclaration(
                identifier: Identifier("Foo"),
                members: [
                    StructDeclaration.Member(
                        name: "val",
                        type: PrimitiveType(.i16)
                    )
                ],
                visibility: .privateVisibility
            ),
            Impl(
                typeArguments: [],
                structTypeExpr: Identifier("Foo"),
                children: [
                    FunctionDeclaration(
                        identifier: Identifier("bar"),
                        functionType: FunctionType(
                            name: "bar",
                            returnType: PrimitiveType(.u8),
                            arguments: []
                        ),
                        argumentNames: ["baz"],
                        typeArguments: [],
                        body: Block(children: [
                            Return(LiteralInt(0))
                        ])
                    )
                ]
            ),
            VarDeclaration(
                identifier: Identifier("instance"),
                explicitType: Identifier("Foo"),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            Call(
                callee: Get(
                    expr: Identifier("instance"),
                    member: Identifier("bar")
                ),
                arguments: []
            )
        ])
        .reconnect(parent: nil)

        let expected = Block(children: [
            StructDeclaration(
                identifier: Identifier("Foo"),
                members: [
                    StructDeclaration.Member(
                        name: "val",
                        type: PrimitiveType(.i16)
                    )
                ],
                visibility: .privateVisibility
            ),
            Impl(
                typeArguments: [],
                structTypeExpr: Identifier("Foo"),
                children: [
                    FunctionDeclaration(
                        identifier: Identifier("bar"),
                        functionType: FunctionType(
                            name: "bar",
                            returnType: PrimitiveType(.u8),
                            arguments: []
                        ),
                        argumentNames: ["baz"],
                        typeArguments: [],
                        body: Block(children: [
                            Return(LiteralInt(0))
                        ])
                    )
                ]
            ),
            VarDeclaration(
                identifier: Identifier("instance"),
                explicitType: Identifier("Foo"),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            Call(
                callee: Get(
                    expr: Identifier("Foo"),
                    member: Identifier("bar")
                ),
                arguments: []
            )
        ])
        .reconnect(parent: nil)

        let actual = try ast0
            .eraseMethodCalls()?
            .flatten()

        XCTAssertEqual(actual, expected)
    }

    func testGetAddressOfFunctionMember() throws {
        let ast0 = Block(children: [
            StructDeclaration(
                identifier: Identifier("Foo"),
                members: [
                    StructDeclaration.Member(
                        name: "val",
                        type: PrimitiveType(.i16)
                    )
                ],
                visibility: .privateVisibility
            ),
            Impl(
                typeArguments: [],
                structTypeExpr: Identifier("Foo"),
                children: [
                    FunctionDeclaration(
                        identifier: Identifier("bar"),
                        functionType: FunctionType(
                            name: "bar",
                            returnType: PrimitiveType(.u8),
                            arguments: []
                        ),
                        argumentNames: ["baz"],
                        typeArguments: [],
                        body: Block(children: [
                            Return(LiteralInt(0))
                        ])
                    )
                ]
            ),
            VarDeclaration(
                identifier: Identifier("instance"),
                explicitType: Identifier("Foo"),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            Get(expr: Identifier("instance"), member: Identifier("bar"))
        ])
        .reconnect(parent: nil)

        let expected = Block(children: [
            StructDeclaration(
                identifier: Identifier("Foo"),
                members: [
                    StructDeclaration.Member(
                        name: "val",
                        type: PrimitiveType(.i16)
                    )
                ],
                visibility: .privateVisibility
            ),
            Impl(
                typeArguments: [],
                structTypeExpr: Identifier("Foo"),
                children: [
                    FunctionDeclaration(
                        identifier: Identifier("bar"),
                        functionType: FunctionType(
                            name: "bar",
                            returnType: PrimitiveType(.u8),
                            arguments: []
                        ),
                        argumentNames: ["baz"],
                        typeArguments: [],
                        body: Block(children: [
                            Return(LiteralInt(0))
                        ])
                    )
                ]
            ),
            VarDeclaration(
                identifier: Identifier("instance"),
                explicitType: Identifier("Foo"),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            Get(expr: Identifier("Foo"), member: Identifier("bar"))
        ])
        .reconnect(parent: nil)

        let actual = try ast0
            .eraseMethodCalls()?
            .flatten()

        XCTAssertEqual(actual, expected)
    }
}
