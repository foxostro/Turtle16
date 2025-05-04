//
//  CompilerPassVtablesTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/9/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassVtablesTests: XCTestCase {

    func testEmptyTrait() throws {
        let traitIdent = Identifier("Foo")
        let traitObjectIdent = Identifier("__Foo_object")
        let vtableIdent = Identifier("__Foo_vtable")
        let vtableType = PointerType(ConstType(vtableIdent))
        let objectType = PointerType(PrimitiveType(.void))

        let expected = Block(children: [
            Seq(children: [
                StructDeclaration(
                    identifier: vtableIdent,
                    members: [],
                    isConst: false
                ),
                StructDeclaration(
                    identifier: traitObjectIdent,
                    members: [
                        StructDeclaration.Member(
                            name: "object",
                            type: objectType
                        ),
                        StructDeclaration.Member(
                            name: "vtable",
                            type: vtableType
                        )
                    ],
                    isConst: false,
                    associatedTraitType: traitIdent.identifier
                ),
                TraitDeclaration(
                    identifier: traitIdent,
                    members: []
                )
            ])
        ])

        let input = Block(
            children: [
                TraitDeclaration(
                    identifier: traitIdent,
                    members: []
                )
            ],
            id: expected.id
        )

        let actual = try input.vtablesPass()
        XCTAssertEqual(actual, expected)
    }

    func testSimpleConcreteTrait() throws {
        let traitIdent = Identifier("Serial")
        let traitObjectIdent = Identifier("__Serial_object")
        let vtableIdent = Identifier("__Serial_vtable")
        let vtableType = PointerType(ConstType(vtableIdent))
        let objectType = PointerType(PrimitiveType(.void))
        let putsFnType = PointerType(
            FunctionType(
                name: nil,
                returnType: PrimitiveType(.void),
                arguments: [
                    PointerType(Identifier("Serial")),
                    DynamicArrayType(
                        PrimitiveType(
                            .u8
                        )
                    )
                ]
            )
        )

        let expected = Block(children: [
            Seq(children: [
                StructDeclaration(
                    identifier: vtableIdent,
                    members: [
                        StructDeclaration.Member(
                            name: "puts",
                            type: PointerType(
                                FunctionType(
                                    returnType: PrimitiveType(.void),
                                    arguments: [
                                        PointerType(PrimitiveType(.void)),
                                        DynamicArrayType(PrimitiveType(.u8))
                                    ]
                                )
                            )
                        )
                    ],
                    isConst: false
                ),
                StructDeclaration(
                    identifier: traitObjectIdent,
                    members: [
                        StructDeclaration.Member(
                            name: "object",
                            type: objectType
                        ),
                        StructDeclaration.Member(
                            name: "vtable",
                            type: vtableType
                        )
                    ],
                    isConst: false,
                    associatedTraitType: traitIdent.identifier
                ),
                TraitDeclaration(
                    identifier: traitIdent,
                    members: [
                        TraitDeclaration.Member(name: "puts", type: putsFnType)
                    ]
                ),
                Impl(
                    typeArguments: [],
                    structTypeExpr: traitObjectIdent,
                    children: [
                        FunctionDeclaration(
                            identifier: Identifier("puts"),
                            functionType: FunctionType(
                                name: "puts",
                                returnType: PrimitiveType(.void),
                                arguments: [
                                    PointerType(
                                        Identifier("__Serial_object")
                                    ),
                                    DynamicArrayType(
                                        PrimitiveType(
                                            .u8
                                        )
                                    )
                                ]
                            ),
                            argumentNames: ["self", "arg1"],
                            body: Block(children: [
                                Call(
                                    callee: Get(
                                        expr: Get(
                                            expr: Identifier("self"),
                                            member: Identifier("vtable")
                                        ),
                                        member: Identifier("puts")
                                    ),
                                    arguments: [
                                        Get(
                                            expr: Identifier("self"),
                                            member: Identifier("object")
                                        ),
                                        Identifier("arg1")
                                    ]
                                )
                            ])
                        )
                    ]
                )
            ])
        ])

        let input = Block(
            children: [
                TraitDeclaration(
                    identifier: traitIdent,
                    members: [
                        TraitDeclaration.Member(name: "puts", type: putsFnType)
                    ]
                )
            ],
            id: expected.id
        )

        let actual = try input.vtablesPass()
        XCTAssertEqual(actual, expected)
    }

}
