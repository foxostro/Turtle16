//
//  CompilerPassImplForTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 12/15/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassImplForTests: XCTestCase {
    let serialFakeAST = Block(children: [
        Seq(children: [
            StructDeclaration(
                identifier: Identifier("__Serial_vtable"),
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
                isConst: true
            ),
            StructDeclaration(
                identifier: Identifier("__Serial_object"),
                members: [
                    StructDeclaration.Member(
                        name: "object",
                        type: PointerType(PrimitiveType(.void))
                    ),
                    StructDeclaration.Member(
                        name: "vtable",
                        type: PointerType(ConstType(Identifier("__Serial_vtable")))
                    )
                ],
                isConst: true,
                associatedTraitType: "Serial"
            ),
            TraitDeclaration(
                identifier: Identifier("Serial"),
                members: [
                    TraitDeclaration.Member(
                        name: "puts",
                        type: PointerType(
                            FunctionType(
                                name: nil,
                                returnType: PrimitiveType(.void),
                                arguments: [
                                    PointerType(Identifier("Serial")),
                                    DynamicArrayType(PrimitiveType(.u8))
                                ]
                            )
                        )
                    )
                ],
                visibility: .privateVisibility
            )
        ]),
        StructDeclaration(
            identifier: Identifier("SerialFake"),
            members: []
        )
    ])

    let innerBlockID = AbstractSyntaxTreeNode.ID()
    let implForID = AbstractSyntaxTreeNode.ID()

    var serialFakeWithImplForAST: Block {
        serialFakeAST.appending(children: [
            ImplFor(
                typeArguments: [],
                traitTypeExpr: Identifier("Serial"),
                structTypeExpr: Identifier("SerialFake"),
                children: [
                    FunctionDeclaration(
                        identifier: Identifier("puts"),
                        functionType: FunctionType(
                            name: "puts",
                            returnType: PrimitiveType(.void),
                            arguments: [
                                PointerType(Identifier("Serial")),
                                DynamicArrayType(PrimitiveType(.u8))
                            ]
                        ),
                        argumentNames: ["self", "s"],
                        body: Block(id: innerBlockID)
                    )
                ],
                id: implForID
            ),
            VarDeclaration(
                identifier: Identifier("serialFake"),
                explicitType: Identifier("SerialFake"),
                expression: StructInitializer(
                    identifier: Identifier("SerialFake"),
                    arguments: []
                ),
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            )
        ])
        .reconnect(parent: nil)
    }

    var compiledSerialFakeWithImplForAST: Block {
        Block(children: [
            Seq(children: [
                StructDeclaration(
                    identifier: Identifier("__Serial_vtable"),
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
                    isConst: true
                ),
                StructDeclaration(
                    identifier: Identifier("__Serial_object"),
                    members: [
                        StructDeclaration.Member(
                            name: "object",
                            type: PointerType(PrimitiveType(.void))
                        ),
                        StructDeclaration.Member(
                            name: "vtable",
                            type: PointerType(ConstType(Identifier("__Serial_vtable")))
                        )
                    ],
                    isConst: true,
                    associatedTraitType: "Serial"
                )
            ]),
            StructDeclaration(
                identifier: Identifier("SerialFake"),
                members: []
            ),
            Seq(children: [
                Impl(
                    typeArguments: [],
                    structTypeExpr: Identifier("SerialFake"),
                    children: [
                        FunctionDeclaration(
                            identifier: Identifier("puts"),
                            functionType: FunctionType(
                                name: "puts",
                                returnType: PrimitiveType(.void),
                                arguments: [
                                    PointerType(Identifier("__Serial_object")),
                                    DynamicArrayType(PrimitiveType(.u8))
                                ]
                            ),
                            argumentNames: ["self", "s"],
                            body: Block(id: innerBlockID)
                        )
                    ],
                    id: implForID
                ),
                VarDeclaration(
                    identifier: Identifier("__Serial_SerialFake_vtable_instance"),
                    explicitType: Identifier("__Serial_vtable"),
                    expression: StructInitializer(
                        expr: Identifier("__Serial_vtable"),
                        arguments: [
                            StructInitializer.Argument(
                                name: "puts",
                                expr: Bitcast(
                                    expr: Unary(
                                        op: .ampersand,
                                        expression: Get(
                                            expr: Identifier("SerialFake"),
                                            member: Identifier("puts")
                                        )
                                    ),
                                    targetType: PrimitiveType(
                                        .pointer(
                                            .function(
                                                FunctionTypeInfo(
                                                    returnType: .void,
                                                    arguments: [
                                                        .pointer(.void),
                                                        .dynamicArray(elementType: .u8)
                                                    ]
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        ]
                    ),
                    storage: .staticStorage(offset: nil),
                    isMutable: false,
                    visibility: .privateVisibility
                )
            ]),
            VarDeclaration(
                identifier: Identifier("serialFake"),
                explicitType: Identifier("SerialFake"),
                expression: StructInitializer(
                    identifier: Identifier("SerialFake"),
                    arguments: []
                ),
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            )
        ])
    }

    func testFailToCompileImplForTraitBecauseMethodsAreMissing() throws {
        let ast = serialFakeAST.appending(
            children: [
                ImplFor(
                    typeArguments: [],
                    traitTypeExpr: Identifier("Serial"),
                    structTypeExpr: Identifier("SerialFake"),
                    children: []
                )
            ])
            .reconnect(parent: nil)

        XCTAssertThrowsError(try ast.implForPass()) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "`SerialFake' does not implement all trait methods; missing `puts'."
            )
        }
    }

    func testFailToCompileImplForTraitBecauseMethodHasIncorrectNumberOfParameters() throws {
        let ast = serialFakeAST.appending(children: [
            ImplFor(
                typeArguments: [],
                traitTypeExpr: Identifier("Serial"),
                structTypeExpr: Identifier("SerialFake"),
                children: [
                    FunctionDeclaration(
                        identifier: Identifier("puts"),
                        functionType: FunctionType(
                            name: "puts",
                            returnType: PrimitiveType(.void),
                            arguments: [
                                PointerType(Identifier("SerialFake"))
                            ]
                        ),
                        argumentNames: ["self"],
                        body: Block()
                    )
                ]
            )
        ])
        .reconnect(parent: nil)

        XCTAssertThrowsError(try ast.implForPass()) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "`SerialFake' method `puts' has 1 parameter but the declaration in the `Serial' trait has 2."
            )
        }
    }

    func testFailToCompileImplForTraitBecauseMethodHasIncorrectParameterTypes() throws {
        let ast = serialFakeAST.appending(children: [
            ImplFor(
                typeArguments: [],
                traitTypeExpr: Identifier("Serial"),
                structTypeExpr: Identifier("SerialFake"),
                children: [
                    FunctionDeclaration(
                        identifier: Identifier("puts"),
                        functionType: FunctionType(
                            name: "puts",
                            returnType: PrimitiveType(.void),
                            arguments: [
                                PointerType(Identifier("SerialFake")),
                                PrimitiveType(.u8)
                            ]
                        ),
                        argumentNames: ["self", "s"],
                        body: Block()
                    )
                ]
            )
        ])
        .reconnect(parent: nil)

        XCTAssertThrowsError(try ast.implForPass()) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "`SerialFake' method `puts' has incompatible type for trait `Serial'; expected `[]u8' argument, got `u8' instead"
            )
        }
    }

    func testFailToCompileImplForTraitBecauseMethodHasIncorrectSelfParameterTypes() throws {
        let ast = serialFakeAST.appending(children: [
            ImplFor(
                typeArguments: [],
                traitTypeExpr: Identifier("Serial"),
                structTypeExpr: Identifier("SerialFake"),
                children: [
                    FunctionDeclaration(
                        identifier: Identifier("puts"),
                        functionType: FunctionType(
                            name: "puts",
                            returnType: PrimitiveType(.void),
                            arguments: [
                                PrimitiveType(.u8),
                                DynamicArrayType(PrimitiveType(.u8))
                            ]
                        ),
                        argumentNames: ["self", "s"],
                        body: Block()
                    )
                ]
            )
        ])
        .reconnect(parent: nil)

        XCTAssertThrowsError(try ast.implForPass()) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "`SerialFake' method `puts' has incompatible type for trait `Serial'; expected `*SerialFake' argument, got `u8' instead"
            )
        }
    }

    func testFailToCompileImplForTraitBecauseMethodHasIncorrectReturnType() throws {
        let ast = serialFakeAST.appending(children: [
            ImplFor(
                typeArguments: [],
                traitTypeExpr: Identifier("Serial"),
                structTypeExpr: Identifier("SerialFake"),
                children: [
                    FunctionDeclaration(
                        identifier: Identifier("puts"),
                        functionType: FunctionType(
                            name: "puts",
                            returnType: PrimitiveType(.bool),
                            arguments: [
                                PointerType(Identifier("SerialFake")),
                                DynamicArrayType(PrimitiveType(.u8))
                            ]
                        ),
                        argumentNames: ["self", "s"],
                        body: Block(children: [
                            Return(LiteralBool(false))
                        ])
                    )
                ]
            )
        ])
        .reconnect(parent: nil)

        XCTAssertThrowsError(try ast.implForPass()) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "`SerialFake' method `puts' has incompatible type for trait `Serial'; expected `void' return value, got `bool' instead"
            )
        }
    }

    func testCompileImplForTrait() throws {
        // We expect...
        // * Trait declarations are erased
        // * ImplFor nodes are rewritten as plain Impl nodes
        // * The vtable instance is inserted immediately following the Impl node
        let ast0 = serialFakeWithImplForAST
        let expected = compiledSerialFakeWithImplForAST
        let actual = try ast0.implForPass()
        XCTAssertEqual(actual, expected)
    }

    func testRewriteVarDeclaration_DirectAssignmentOfConcreteInstance() throws {
        // VarDeclarations which assign to an instance of a trait are rewritten
        // to direct manipulation of a trait object instead
        let ast0 = serialFakeWithImplForAST.appending(children: [
            VarDeclaration(
                identifier: Identifier("serial"),
                explicitType: Identifier("Serial"),
                expression: Identifier("serialFake"),
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            )
        ])
        let expected = compiledSerialFakeWithImplForAST.appending(children: [
            VarDeclaration(
                identifier: Identifier("serial"),
                explicitType: Identifier("__Serial_object"),
                expression: StructInitializer(
                    identifier: Identifier("__Serial_object"),
                    arguments: [
                        StructInitializer.Argument(
                            name: "object",
                            expr: Bitcast(
                                expr: Unary(
                                    op: .ampersand,
                                    expression: Identifier("serialFake")
                                ),
                                targetType: PointerType(PrimitiveType(.void))
                            )
                        ),
                        StructInitializer.Argument(
                            name: "vtable",
                            expr: Identifier("__Serial_SerialFake_vtable_instance")
                        )
                    ]
                ),
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            )
        ])
        let actual = try ast0.implForPass()
        XCTAssertEqual(actual, expected)
    }

    func testRewriteVarDeclaration_TakeAddressOfConcreteInstance() throws {
        // VarDeclarations which assign to an instance of a trait are rewritten
        // to direct manipulation of a trait object instead
        let ast0 = serialFakeWithImplForAST.appending(children: [
            VarDeclaration(
                identifier: Identifier("serial"),
                explicitType: Identifier("Serial"),
                expression: Unary(
                    op: .ampersand,
                    expression: Identifier("serialFake")
                ),
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            )
        ])
        let expected = compiledSerialFakeWithImplForAST.appending(children: [
            VarDeclaration(
                identifier: Identifier("serial"),
                explicitType: Identifier("__Serial_object"),
                expression: StructInitializer(
                    identifier: Identifier("__Serial_object"),
                    arguments: [
                        StructInitializer.Argument(
                            name: "object",
                            expr: Bitcast(
                                expr: Unary(
                                    op: .ampersand,
                                    expression: Identifier("serialFake")
                                ),
                                targetType: PointerType(PrimitiveType(.void))
                            )
                        ),
                        StructInitializer.Argument(
                            name: "vtable",
                            expr: Identifier("__Serial_SerialFake_vtable_instance")
                        )
                    ]
                ),
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            )
        ])
        let actual = try ast0.implForPass()
        XCTAssertEqual(actual, expected)
    }

    func testRewriteInitialAssignment_DirectAssignmentOfConcreteInstance() throws {
        // InitialAssignment expressions which assign to an instance of a trait
        // are rewritten to direct manipulation of a trait object
        let ast0 = serialFakeWithImplForAST.appending(children: [
            VarDeclaration(
                identifier: Identifier("serial"),
                explicitType: Identifier("Serial"),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            InitialAssignment(
                lexpr: Identifier("serial"),
                rexpr: Identifier("serialFake")
            )
        ])
        let expected = compiledSerialFakeWithImplForAST.appending(children: [
            VarDeclaration(
                identifier: Identifier("serial"),
                explicitType: Identifier("__Serial_object"),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            InitialAssignment(
                lexpr: Identifier("serial"),
                rexpr: StructInitializer(
                    identifier: Identifier("__Serial_object"),
                    arguments: [
                        StructInitializer.Argument(
                            name: "object",
                            expr: Bitcast(
                                expr: Unary(
                                    op: .ampersand,
                                    expression: Identifier("serialFake")
                                ),
                                targetType: PointerType(PrimitiveType(.void))
                            )
                        ),
                        StructInitializer.Argument(
                            name: "vtable",
                            expr: Identifier("__Serial_SerialFake_vtable_instance")
                        )
                    ]
                )
            )
        ])
        let actual = try ast0.implForPass()
        XCTAssertEqual(actual, expected)
    }

    func testRewriteInitialAssignment_TakeAddressOfConcreteInstance() throws {
        // InitialAssignment expressions which assign to an instance of a trait
        // are rewritten to direct manipulation of a trait object
        let ast0 = serialFakeWithImplForAST.appending(children: [
            VarDeclaration(
                identifier: Identifier("serial"),
                explicitType: Identifier("Serial"),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            InitialAssignment(
                lexpr: Identifier("serial"),
                rexpr: Unary(
                    op: .ampersand,
                    expression: Identifier("serialFake")
                )
            )
        ])
        let expected = compiledSerialFakeWithImplForAST.appending(children: [
            VarDeclaration(
                identifier: Identifier("serial"),
                explicitType: Identifier("__Serial_object"),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            InitialAssignment(
                lexpr: Identifier("serial"),
                rexpr: StructInitializer(
                    identifier: Identifier("__Serial_object"),
                    arguments: [
                        StructInitializer.Argument(
                            name: "object",
                            expr: Bitcast(
                                expr: Unary(
                                    op: .ampersand,
                                    expression: Identifier("serialFake")
                                ),
                                targetType: PointerType(PrimitiveType(.void))
                            )
                        ),
                        StructInitializer.Argument(
                            name: "vtable",
                            expr: Identifier("__Serial_SerialFake_vtable_instance")
                        )
                    ]
                )
            )
        ])
        let actual = try ast0.implForPass()
        XCTAssertEqual(actual, expected)
    }

    func testRewriteAssignment_DirectAssignmentOfConcreteInstance() throws {
        // InitialAssignment expressions which assign to an instance of a trait
        // are rewritten to direct manipulation of a trait object
        let ast0 = serialFakeWithImplForAST.appending(children: [
            VarDeclaration(
                identifier: Identifier("serial"),
                explicitType: Identifier("Serial"),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            Assignment(
                lexpr: Identifier("serial"),
                rexpr: Identifier("serialFake")
            )
        ])
        let expected = compiledSerialFakeWithImplForAST.appending(children: [
            VarDeclaration(
                identifier: Identifier("serial"),
                explicitType: Identifier("__Serial_object"),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            Assignment(
                lexpr: Identifier("serial"),
                rexpr: StructInitializer(
                    identifier: Identifier("__Serial_object"),
                    arguments: [
                        StructInitializer.Argument(
                            name: "object",
                            expr: Bitcast(
                                expr: Unary(
                                    op: .ampersand,
                                    expression: Identifier("serialFake")
                                ),
                                targetType: PointerType(PrimitiveType(.void))
                            )
                        ),
                        StructInitializer.Argument(
                            name: "vtable",
                            expr: Identifier("__Serial_SerialFake_vtable_instance")
                        )
                    ]
                )
            )
        ])
        let actual = try ast0.implForPass()
        XCTAssertEqual(actual, expected)
    }

    func testRewriteAssignment_TakeAddressOfConcreteInstance() throws {
        // InitialAssignment expressions which assign to an instance of a trait
        // are rewritten to direct manipulation of a trait object
        let ast0 = serialFakeWithImplForAST.appending(children: [
            VarDeclaration(
                identifier: Identifier("serial"),
                explicitType: Identifier("Serial"),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            Assignment(
                lexpr: Identifier("serial"),
                rexpr: Unary(
                    op: .ampersand,
                    expression: Identifier("serialFake")
                )
            )
        ])
        let expected = compiledSerialFakeWithImplForAST.appending(children: [
            VarDeclaration(
                identifier: Identifier("serial"),
                explicitType: Identifier("__Serial_object"),
                expression: nil,
                storage: .automaticStorage(offset: nil),
                isMutable: false,
                visibility: .privateVisibility
            ),
            Assignment(
                lexpr: Identifier("serial"),
                rexpr: StructInitializer(
                    identifier: Identifier("__Serial_object"),
                    arguments: [
                        StructInitializer.Argument(
                            name: "object",
                            expr: Bitcast(
                                expr: Unary(
                                    op: .ampersand,
                                    expression: Identifier("serialFake")
                                ),
                                targetType: PointerType(PrimitiveType(.void))
                            )
                        ),
                        StructInitializer.Argument(
                            name: "vtable",
                            expr: Identifier("__Serial_SerialFake_vtable_instance")
                        )
                    ]
                )
            )
        ])
        let actual = try ast0.implForPass()
        XCTAssertEqual(actual, expected)
    }
}
