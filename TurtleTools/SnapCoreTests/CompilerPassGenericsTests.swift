//
//  CompilerPassGenericsTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/30/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassGenericsTests: XCTestCase {

    fileprivate func parse(_ text: String) -> TopLevel {
        try! SnapCore.parse(text: text, url: URL(fileURLWithPath: testName))
    }

    fileprivate func makeGenericFunctionDeclaration(
        _ parentSymbols: Env = Env()
    ) -> FunctionDeclaration {
        parse(
            """
            func foo[T](a: T) -> T {
                let b: T = a
                return b
            }
            """
        )
        .children.last!
        .reconnect(parent: parentSymbols) as! FunctionDeclaration
    }

    fileprivate func addGenericFunctionSymbol(_ symbols: Env) -> Env {
        let template = makeGenericFunctionDeclaration(symbols)
        let genericFunctionType = GenericFunctionType(template: template)
        symbols.bind(identifier: "foo", symbol: Symbol(type: .genericFunction(genericFunctionType)))
        return symbols
    }

    // Every expression with a generic function application is rewritten to
    // instead reference the concrete instantiation of the function.
    func testRewriteGenericFunctionApplicationExpressionToConcreteInstantiation() throws {
        let symbols = addGenericFunctionSymbol(Env())
        let expr = GenericTypeApplication(
            identifier: Identifier("foo"),
            arguments: [PrimitiveType(.constU16)]
        )
        let compiler = CompilerPassGenerics(symbols: symbols)
        let actual = try compiler.visit(expr: expr)
        let expected = Identifier("foo[const u16]")
        XCTAssertEqual(actual, expected)
    }

    // The concrete instantiation of the function is added to the symbol table.
    func testGenericFunctionApplicationCausesConcreteFunctionToBeAddedToSymbolTable() throws {
        let symbols = addGenericFunctionSymbol(Env())
        let expr = GenericTypeApplication(
            identifier: Identifier("foo"),
            arguments: [PrimitiveType(.constU16)]
        )
        let compiler = CompilerPassGenerics(symbols: symbols)
        _ = try compiler.visit(expr: expr)

        let sym = try symbols.resolve(identifier: "foo[const u16]")
        switch sym.type {
        case .function(let funTyp):
            XCTAssertEqual(funTyp.mangledName, "foo[const u16]")
            XCTAssertEqual(funTyp.name, "foo[const u16]")
            XCTAssertEqual(funTyp.arguments, [.constU16])
            XCTAssertEqual(funTyp.returnType, .constU16)

        default:
            XCTFail()
        }
    }

    // The generic function declaration is erased from the AST
    // The body of a generic function is not compiled before concrete instantiation
    func testGenericFunctionDeclarationIsErasedFromAST() throws {
        let ast0 = Block(children: [
            makeGenericFunctionDeclaration()
        ])

        let compiler = CompilerPassGenerics(symbols: Env())
        let ast1 = try compiler.run(ast0)

        XCTAssertEqual(ast1, Block())
    }

    // The concrete instantiation of the function is added to the AST.
    func testGenericFunctionApplicationCausesConcreteFunctionToBeAddedToAST() throws {
        let symbols = Env()
        let blockSymbols = Env(parent: symbols)
        let funSym = Env(parent: blockSymbols, frameLookupMode: .set(Frame()))

        let expected = Block(
            symbols: blockSymbols,
            children: [
                FunctionDeclaration(
                    identifier: Identifier("foo[const u16]"),
                    functionType: FunctionType(
                        name: "foo[const u16]",
                        returnType: PrimitiveType(.constU16),
                        arguments: [PrimitiveType(.constU16)]
                    ),
                    argumentNames: ["a"],
                    body: Block(children: [
                        Return(Identifier("a"))
                    ]),
                    visibility: .privateVisibility,
                    symbols: funSym
                ),
                Identifier("foo[const u16]"),
            ]
        )

        let ast0 = Block(
            symbols: blockSymbols,
            children: [
                FunctionDeclaration(
                    identifier: Identifier("foo"),
                    functionType: FunctionType(
                        name: "foo",
                        returnType: Identifier("T"),
                        arguments: [Identifier("T")]
                    ),
                    argumentNames: ["a"],
                    typeArguments: [
                        GenericTypeArgument(
                            identifier: Identifier("T"),
                            constraints: []
                        )
                    ],
                    body: Block(
                        symbols: Env(parent: funSym),
                        children: [
                            Return(Identifier("a"))
                        ]
                    ),
                    visibility: .privateVisibility,
                    symbols: funSym
                ),
                GenericTypeApplication(
                    identifier: Identifier("foo"),
                    arguments: [PrimitiveType(.constU16)]
                ),
            ]
        )

        let ast1 = try CompilerPassGenerics(symbols: symbols).run(ast0)

        XCTAssertEqual(ast1, expected)
    }

    // A Call expression which calls a generic function is rewritten to a
    // generic function application expression
    func testCallExprWithGenericFunctionIsRewrittenToApp() throws {
        let symbols = Env()
        let blockSymbols = Env(parent: symbols)
        let funSym = Env(parent: blockSymbols, frameLookupMode: .set(Frame()))

        let expected = Block(
            symbols: blockSymbols,
            children: [
                FunctionDeclaration(
                    identifier: Identifier("foo[u16]"),
                    functionType: FunctionType(
                        name: "foo[u16]",
                        returnType: PrimitiveType(.u16),
                        arguments: [PrimitiveType(.u16)]
                    ),
                    argumentNames: ["a"],
                    body: Block(children: [
                        Return(Identifier("a"))
                    ]),
                    visibility: .privateVisibility,
                    symbols: funSym
                ),
                Call(
                    callee: Identifier("foo[u16]"),
                    arguments: [PrimitiveType(.u16)]
                ),
            ]
        )

        let ast0 = Block(
            symbols: blockSymbols,
            children: [
                FunctionDeclaration(
                    identifier: Identifier("foo"),
                    functionType: FunctionType(
                        name: "foo",
                        returnType: Identifier("T"),
                        arguments: [Identifier("T")]
                    ),
                    argumentNames: ["a"],
                    typeArguments: [
                        GenericTypeArgument(
                            identifier: Identifier("T"),
                            constraints: []
                        )
                    ],
                    body: Block(
                        symbols: Env(parent: funSym),
                        children: [
                            Return(Identifier("a"))
                        ]
                    ),
                    visibility: .privateVisibility,
                    symbols: funSym
                ),
                Call(
                    callee: Identifier("foo"),
                    arguments: [PrimitiveType(.u16)]
                ),
            ]
        )

        let ast1 = try CompilerPassGenerics(symbols: symbols).run(ast0)

        XCTAssertEqual(ast1, expected)
    }

    func testRejectsGenericFunctionApplicationWithIncorrectNumberOfArguments() throws {
        let symbols = Env()
        let funSym = Env(parent: symbols, frameLookupMode: .set(Frame()))
        let bodySym = Env(parent: funSym)
        let functionType = FunctionType(
            name: "foo",
            returnType: Identifier("T"),
            arguments: [Identifier("T")]
        )
        let template = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: functionType,
            argumentNames: ["a"],
            typeArguments: [
                GenericTypeArgument(identifier: Identifier("T"), constraints: [])
            ],
            body: Block(symbols: bodySym),
            visibility: .privateVisibility,
            symbols: funSym
        )
        let genericFunctionType = GenericFunctionType(template: template)
        symbols.bind(
            identifier: "foo",
            symbol: Symbol(type: .genericFunction(genericFunctionType))
        )

        let compiler = CompilerPassGenerics(symbols: symbols)
        let expr = GenericTypeApplication(
            identifier: Identifier("foo"),
            arguments: [
                PrimitiveType(.u16),
                PrimitiveType(.u16),
            ]
        )
        XCTAssertThrowsError(try compiler.visit(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "incorrect number of type arguments in application of generic function type `foo@[u16, u16]'"
            )
        }
    }

    func testCannotTakeTheAddressOfGenericFunctionWithInappropriateTypeArguments() {
        let symbols = Env()
        let funSym = Env(parent: symbols, frameLookupMode: .set(Frame()))
        let bodySym = Env(parent: funSym)
        let functionType = FunctionType(
            name: "foo",
            returnType: Identifier("T"),
            arguments: [Identifier("T")]
        )
        let template = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: functionType,
            argumentNames: ["a"],
            typeArguments: [
                GenericTypeArgument(identifier: Identifier("T"), constraints: [])
            ],
            body: Block(symbols: bodySym),
            visibility: .privateVisibility,
            symbols: funSym
        )
        let genericFunctionType = GenericFunctionType(template: template)
        symbols.bind(
            identifier: "foo",
            symbol: Symbol(type: .genericFunction(genericFunctionType))
        )

        let expr = Unary(
            op: .ampersand,
            expression: GenericTypeApplication(
                identifier: Identifier("foo"),
                arguments: [
                    PrimitiveType(.constU16),
                    PrimitiveType(.constU16),
                ]
            )
        )
        let compiler = CompilerPassGenerics(symbols: symbols)
        XCTAssertThrowsError(try compiler.visit(expr: expr)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "incorrect number of type arguments in application of generic function type `foo@[const u16, const u16]'"
            )
        }
    }

    // The concrete instantiation of the generic struct is erased from the AST.
    func testGenericStructDeclarationsAreErasedFromAST() throws {
        let ast0 = Block(children: [
            StructDeclaration(
                identifier: Identifier("foo"),
                typeArguments: [
                    GenericTypeArgument(
                        identifier: Identifier("T"),
                        constraints: []
                    )
                ],
                members: [
                    StructDeclaration.Member(
                        name: "bar",
                        type: Identifier("T")
                    )
                ],
                visibility: .privateVisibility,
                isConst: false
            )
        ])

        let compiler = CompilerPassGenerics(symbols: Env())
        let ast1 = try compiler.run(ast0)
        XCTAssertEqual(ast1, Block())
    }

    // The concrete instantiation of the generic struct is added to the symbol table.
    func testGenericTypeApplicationCausesConcreteStructToBeAddedToSymbolTable() throws {
        let symbols = Env()

        let ast0 = Block(
            symbols: symbols,
            children: [
                StructDeclaration(
                    identifier: Identifier("foo"),
                    typeArguments: [
                        GenericTypeArgument(
                            identifier: Identifier("T"),
                            constraints: []
                        )
                    ],
                    members: [
                        StructDeclaration.Member(
                            name: "bar",
                            type: Identifier("T")
                        )
                    ],
                    visibility: .privateVisibility,
                    isConst: false
                ),
                StructInitializer(
                    expr: GenericTypeApplication(
                        identifier: Identifier("foo"),
                        arguments: [PrimitiveType(.u16)]
                    ),
                    arguments: [
                        StructInitializer.Argument(
                            name: "T",
                            expr: PrimitiveType(.u16)
                        )
                    ]
                ),
            ]
        )

        let _ = try CompilerPassGenerics(symbols: symbols).run(ast0)

        switch try symbols.resolveType(identifier: "foo[u16]") {
        case .structType(let typ):
            XCTAssertEqual(typ.name, "foo[u16]")
            XCTAssertEqual(typ.symbols.maybeResolve(identifier: "bar")?.type, .u16)

        default:
            XCTFail()
        }
    }

    // The concrete instantiation of the generic struct is inserted into the AST
    func testGenericTypeApplicationCausesConcreteStructToBeAddedToAST() throws {
        let expected = Block(children: [
            StructDeclaration(
                identifier: Identifier("foo[u16]"),
                members: [
                    StructDeclaration.Member(
                        name: "bar",
                        type: PrimitiveType(.u16)
                    )
                ],
                visibility: .privateVisibility,
                isConst: false
            ),
            StructInitializer(
                expr: Identifier("foo[u16]"),
                arguments: [
                    StructInitializer.Argument(
                        name: "T",
                        expr: PrimitiveType(.u16)
                    )
                ]
            ),
        ])

        let ast0 = Block(children: [
            StructDeclaration(
                identifier: Identifier("foo"),
                typeArguments: [
                    GenericTypeArgument(
                        identifier: Identifier("T"),
                        constraints: []
                    )
                ],
                members: [
                    StructDeclaration.Member(
                        name: "bar",
                        type: Identifier("T")
                    )
                ],
                visibility: .privateVisibility,
                isConst: false
            ),
            StructInitializer(
                expr: GenericTypeApplication(
                    identifier: Identifier("foo"),
                    arguments: [PrimitiveType(.u16)]
                ),
                arguments: [
                    StructInitializer.Argument(
                        name: "T",
                        expr: PrimitiveType(.u16)
                    )
                ]
            ),
        ])

        let ast1 = try CompilerPassGenerics().run(ast0)

        XCTAssertEqual(ast1, expected)
    }

    // Instantiating a generic struct with methods will emit AST nodes for the
    // concrete struct as well as an Impl node for the methods.
    // This test is for the case where the methods are not themselves generic.
    func testInstantiatingGenericStructEmitsImplNodesForMethods_1() throws {
        let symbols = Env()
        let funSym = Env(parent: symbols, frameLookupMode: .set(Frame()))
        let bodySym = Env(parent: funSym)

        let outerBlockID = AbstractSyntaxTreeNode.ID()
        let myStructFooID = AbstractSyntaxTreeNode.ID()
        let structInitializerID = AbstractSyntaxTreeNode.ID()

        let expected = Block(
            symbols: symbols,
            children: [
                StructDeclaration(
                    identifier: Identifier("MyStruct[u16]"),
                    members: []
                ),
                Impl(
                    typeArguments: [],
                    structTypeExpr: Identifier("MyStruct[u16]"),
                    children: [
                        FunctionDeclaration(
                            identifier: Identifier("foo"),
                            functionType: FunctionType(
                                name: "foo",
                                returnType: PrimitiveType(.u8),
                                arguments: [PrimitiveType(.u8)]
                            ),
                            argumentNames: ["arg1"],
                            typeArguments: [],
                            body: Block(
                                symbols: bodySym,
                                children: [
                                    Return(Identifier("arg1"))
                                ]
                            ),
                            symbols: funSym
                        )
                    ]
                ),
                StructInitializer(
                    expr: Identifier("MyStruct[u16]"),
                    arguments: [],
                    id: structInitializerID
                ),
            ],
            id: outerBlockID
        )

        let ast0 = Block(
            symbols: symbols,
            children: [
                StructDeclaration(
                    identifier: Identifier("MyStruct"),
                    typeArguments: [
                        GenericTypeArgument(
                            identifier: Identifier("T"),
                            constraints: []
                        )
                    ],
                    members: []
                ),
                Impl(
                    typeArguments: [
                        GenericTypeArgument(
                            identifier: Identifier("T"),
                            constraints: []
                        )
                    ],
                    structTypeExpr: GenericTypeApplication(
                        identifier: Identifier("MyStruct"),
                        arguments: [
                            Identifier("T")
                        ]
                    ),
                    children: [
                        FunctionDeclaration(
                            identifier: Identifier("foo"),
                            functionType: FunctionType(
                                name: "foo",
                                returnType: PrimitiveType(.u8),
                                arguments: [PrimitiveType(.u8)]
                            ),
                            argumentNames: ["arg1"],
                            typeArguments: [],
                            body: Block(
                                symbols: bodySym,
                                children: [
                                    Return(Identifier("arg1"))
                                ]
                            ),
                            symbols: funSym,
                            id: myStructFooID
                        )
                    ]
                ),
                StructInitializer(
                    expr: GenericTypeApplication(
                        identifier: Identifier("MyStruct"),
                        arguments: [
                            PrimitiveType(.u16)
                        ]
                    ),
                    arguments: [],
                    id: structInitializerID
                ),
            ],
            id: outerBlockID
        )

        let ast1 = try CompilerPassGenerics().run(ast0)

        XCTAssertEqual(ast1, expected)
    }

    // Instantiating a generic struct with methods will emit AST nodes for the
    // concrete struct as well as an Impl node for the methods.
    // This test is for the case where the methods use the Impl's generic type
    // argument but are not otherwise generic themselves.
    func testInstantiatingGenericStructEmitsImplNodesForMethods_2() throws {
        let symbols = Env()
        let funSym = Env(parent: symbols, frameLookupMode: .set(Frame()))
        let bodySym = Env(parent: funSym)

        let expected = Block(
            symbols: symbols,
            children: [
                StructDeclaration(
                    identifier: Identifier("MyStruct[u16]"),
                    members: []
                ),
                Impl(
                    typeArguments: [],
                    structTypeExpr: Identifier("MyStruct[u16]"),
                    children: [
                        FunctionDeclaration(
                            identifier: Identifier("foo"),
                            functionType: FunctionType(
                                name: "foo",
                                returnType: PrimitiveType(.u16),
                                arguments: [PrimitiveType(.u16)]
                            ),
                            argumentNames: ["arg1"],
                            typeArguments: [],
                            body: Block(
                                symbols: bodySym,
                                children: [
                                    Return(Identifier("arg1"))
                                ]
                            ),
                            symbols: funSym
                        )
                    ]
                ),
                StructInitializer(
                    expr: Identifier("MyStruct[u16]"),
                    arguments: []
                ),
            ]
        )

        let ast0 = Block(
            symbols: symbols,
            children: [
                StructDeclaration(
                    identifier: Identifier("MyStruct"),
                    typeArguments: [
                        GenericTypeArgument(
                            identifier: Identifier("T"),
                            constraints: []
                        )
                    ],
                    members: []
                ),
                Impl(
                    typeArguments: [
                        GenericTypeArgument(
                            identifier: Identifier("T"),
                            constraints: []
                        )
                    ],
                    structTypeExpr: GenericTypeApplication(
                        identifier: Identifier("MyStruct"),
                        arguments: [
                            Identifier("T")
                        ]
                    ),
                    children: [
                        FunctionDeclaration(
                            identifier: Identifier("foo"),
                            functionType: FunctionType(
                                name: "foo",
                                returnType: Identifier("T"),
                                arguments: [Identifier("T")]
                            ),
                            argumentNames: ["arg1"],
                            typeArguments: [],
                            body: Block(
                                symbols: bodySym,
                                children: [
                                    Return(Identifier("arg1"))
                                ]
                            ),
                            symbols: funSym
                        )
                    ]
                ),
                StructInitializer(
                    expr: GenericTypeApplication(
                        identifier: Identifier("MyStruct"),
                        arguments: [
                            PrimitiveType(.u16)
                        ]
                    ),
                    arguments: []
                ),
            ],
            id: expected.id
        )

        let ast1 = try CompilerPassGenerics().run(ast0)

        XCTAssertEqual(ast1, expected)
    }

    // If the generic struct has multiple Impl nodes associated with it then
    // instantiating that generic struct will result in the compiler pass
    // emitting one Impl node on the concrete struct for each Impl node on the
    // generic struct.
    func testInstantiatingGenericStructEmitsImplNodesForMethods_3() throws {
        let ast0 = Block(
            children: [
                StructDeclaration(
                    identifier: Identifier("MyStruct"),
                    typeArguments: [
                        GenericTypeArgument(
                            identifier: Identifier("T"),
                            constraints: []
                        )
                    ],
                    members: []
                ),
                Impl(
                    typeArguments: [
                        GenericTypeArgument(
                            identifier: Identifier("T"),
                            constraints: []
                        )
                    ],
                    structTypeExpr: GenericTypeApplication(
                        identifier: Identifier("MyStruct"),
                        arguments: [
                            Identifier("T")
                        ]
                    ),
                    children: [
                        FunctionDeclaration(
                            identifier: Identifier("foo"),
                            functionType: FunctionType(
                                name: "foo",
                                returnType: Identifier("T"),
                                arguments: [Identifier("T")]
                            ),
                            argumentNames: ["arg1"],
                            typeArguments: [],
                            body: Block(children: [
                                Return(Identifier("arg1"))
                            ])
                        )
                    ]
                ),
                Impl(
                    typeArguments: [
                        GenericTypeArgument(
                            identifier: Identifier("T"),
                            constraints: []
                        )
                    ],
                    structTypeExpr: GenericTypeApplication(
                        identifier: Identifier("MyStruct"),
                        arguments: [
                            Identifier("T")
                        ]
                    ),
                    children: [
                        FunctionDeclaration(
                            identifier: Identifier("bar"),
                            functionType: FunctionType(
                                name: "bar",
                                returnType: Identifier("T"),
                                arguments: [Identifier("T")]
                            ),
                            argumentNames: ["arg1"],
                            typeArguments: [],
                            body: Block(children: [
                                Return(Identifier("arg1"))
                            ])
                        )
                    ]
                ),
                StructInitializer(
                    expr: GenericTypeApplication(
                        identifier: Identifier("MyStruct"),
                        arguments: [
                            PrimitiveType(.u16)
                        ]
                    ),
                    arguments: []
                ),
            ])
            .reconnect(parent: nil)

        let expected = Block(
            children: [
                StructDeclaration(
                    identifier: Identifier("MyStruct[u16]"),
                    members: []
                ),
                Impl(
                    typeArguments: [],
                    structTypeExpr: Identifier("MyStruct[u16]"),
                    children: [
                        FunctionDeclaration(
                            identifier: Identifier("foo"),
                            functionType: FunctionType(
                                name: "foo",
                                returnType: PrimitiveType(.u16),
                                arguments: [PrimitiveType(.u16)]
                            ),
                            argumentNames: ["arg1"],
                            typeArguments: [],
                            body: Block(children: [
                                Return(Identifier("arg1"))
                            ])
                        )
                    ]
                ),
                Impl(
                    typeArguments: [],
                    structTypeExpr: Identifier("MyStruct[u16]"),
                    children: [
                        FunctionDeclaration(
                            identifier: Identifier("bar"),
                            functionType: FunctionType(
                                name: "bar",
                                returnType: PrimitiveType(.u16),
                                arguments: [PrimitiveType(.u16)]
                            ),
                            argumentNames: ["arg1"],
                            typeArguments: [],
                            body: Block(children: [
                                Return(Identifier("arg1"))
                            ])
                        )
                    ]
                ),
                StructInitializer(
                    expr: Identifier("MyStruct[u16]"),
                    arguments: []
                ),
            ],
            id: ast0.id
        )
        .reconnect(parent: nil)

        let ast1 = try CompilerPassGenerics().run(ast0)

        XCTAssertEqual(ast1, expected)
    }

    // Declaration of a type may shadow a generic type parameter
    func testTypeDeclarationMayShadowGenericTypeParameter() throws {
        let ast = Block(
            children: [
                StructDeclaration(
                    identifier: Identifier("MyStruct"),
                    typeArguments: [
                        GenericTypeArgument(
                            identifier: Identifier("T"),
                            constraints: []
                        )
                    ],
                    members: []
                ),
                Impl(
                    typeArguments: [
                        GenericTypeArgument(
                            identifier: Identifier("T"),
                            constraints: []
                        )
                    ],
                    structTypeExpr: GenericTypeApplication(
                        identifier: Identifier("MyStruct"),
                        arguments: [
                            Identifier("T")
                        ]
                    ),
                    children: [
                        FunctionDeclaration(
                            identifier: Identifier("foo"),
                            functionType: FunctionType(
                                name: "foo",
                                returnType: Identifier("T"),
                                arguments: [Identifier("T")]
                            ),
                            argumentNames: ["arg1"],
                            typeArguments: [],
                            body: Block(children: [
                                StructDeclaration(StructTypeInfo(name: "T", fields: Env())),
                                Return(Identifier("arg1")),
                            ])
                        )
                    ]
                ),
                StructInitializer(
                    expr: GenericTypeApplication(
                        identifier: Identifier("MyStruct"),
                        arguments: [
                            PrimitiveType(.u16)
                        ]
                    ),
                    arguments: []
                ),
            ])
            .reconnect(parent: nil)

        XCTAssertNoThrow(try CompilerPassGenerics().run(ast))
    }

    // Generic trait declarations are erased from the AST.
    func testGenericTraitDeclarationsAreErasedFromAST() throws {
        let ast0 = Block(children: [
            TraitDeclaration(
                identifier: Identifier("foo"),
                typeArguments: [
                    GenericTypeArgument(
                        identifier: Identifier("T"),
                        constraints: []
                    )
                ],
                members: [
                    TraitDeclaration.Member(
                        name: "bar",
                        type: FunctionType(
                            name: "bar",
                            returnType: Identifier("T"),
                            arguments: [Identifier("T")]
                        )
                    )
                ]
            )
        ])

        let compiler = CompilerPassGenerics(symbols: Env())
        let ast1 = try compiler.run(ast0)
        XCTAssertEqual(ast1, Block())
    }

    // The concrete instantiation of the generic trait is added to the symbol table.
    func testGenericTypeApplicationCausesConcreteTraitToBeAddedToSymbolTable() throws {
        let symbols = Env()

        let ast0 = Block(
            symbols: symbols,
            children: [
                TraitDeclaration(
                    identifier: Identifier("MyTrait"),
                    typeArguments: [
                        GenericTypeArgument(
                            identifier: Identifier("T"),
                            constraints: []
                        )
                    ],
                    members: []
                ),
                StructDeclaration(
                    identifier: Identifier("MyStruct"),
                    members: []
                ),
                ImplFor(
                    typeArguments: [],
                    traitTypeExpr: GenericTypeApplication(
                        identifier: Identifier("MyTrait"),
                        arguments: [PrimitiveType(.u16)]
                    ),
                    structTypeExpr: Identifier("MyStruct"),
                    children: []
                ),
            ]
        )

        _ = try CompilerPassGenerics(symbols: symbols).run(ast0)

        switch try symbols.resolveType(identifier: "MyTrait[u16]") {
        case .traitType(let typ):
            XCTAssertEqual(typ.name, "MyTrait[u16]")

        default:
            XCTFail()
        }
    }

    // The concrete instantiation of the generic trait is inserted into the AST.
    func testGenericTypeApplicationCausesConcreteTraitToBeAddedToAST() throws {
        let symbols = Env()
        let funSym = Env(parent: symbols, frameLookupMode: .set(Frame()))
        let bodySym = Env(parent: funSym)

        let expected = Block(
            symbols: symbols,
            children: [
                TraitDeclaration(
                    identifier: Identifier("MyTrait[u16]"),
                    members: [
                        TraitDeclaration.Member(
                            name: "foo",
                            type: PointerType(
                                FunctionType(
                                    name: "foo",
                                    returnType: PrimitiveType(.u16),
                                    arguments: [PrimitiveType(.u16)]
                                )
                            )
                        )
                    ]
                ),
                StructDeclaration(
                    identifier: Identifier("MyStruct"),
                    members: []
                ),
                ImplFor(
                    typeArguments: [],
                    traitTypeExpr: Identifier("MyTrait[u16]"),
                    structTypeExpr: Identifier("MyStruct"),
                    children: [
                        FunctionDeclaration(
                            identifier: Identifier("foo"),
                            functionType: FunctionType(
                                name: "foo",
                                returnType: PrimitiveType(.u16),
                                arguments: [PrimitiveType(.u16)]
                            ),
                            argumentNames: ["arg1"],
                            body: Block(
                                symbols: bodySym,
                                children: [
                                    Return(Identifier("arg1"))
                                ]
                            ),
                            symbols: funSym
                        )
                    ]
                ),
            ]
        )
        let expectedBodyId = ((expected.children[2] as! ImplFor).children[0]).body.id

        let ast0 = Block(
            symbols: symbols,
            children: [
                TraitDeclaration(
                    identifier: Identifier("MyTrait"),
                    typeArguments: [
                        GenericTypeArgument(
                            identifier: Identifier("T"),
                            constraints: []
                        )
                    ],
                    members: [
                        TraitDeclaration.Member(
                            name: "foo",
                            type: PointerType(
                                FunctionType(
                                    name: "foo",
                                    returnType: Identifier("T"),
                                    arguments: [Identifier("T")]
                                )
                            )
                        )
                    ]
                ),
                StructDeclaration(
                    identifier: Identifier("MyStruct"),
                    members: []
                ),
                ImplFor(
                    typeArguments: [],
                    traitTypeExpr: GenericTypeApplication(
                        identifier: Identifier("MyTrait"),
                        arguments: [PrimitiveType(.u16)]
                    ),
                    structTypeExpr: Identifier("MyStruct"),
                    children: [
                        FunctionDeclaration(
                            identifier: Identifier("foo"),
                            functionType: FunctionType(
                                name: "foo",
                                returnType: PrimitiveType(.u16),
                                arguments: [PrimitiveType(.u16)]
                            ),
                            argumentNames: ["arg1"],
                            body: Block(
                                symbols: bodySym,
                                children: [
                                    Return(Identifier("arg1"))
                                ],
                                id: expectedBodyId
                            ),
                            symbols: funSym
                        )
                    ]
                ),
            ],
            id: expected.id
        )

        let ast1 = try CompilerPassGenerics(symbols: symbols).run(ast0)

        XCTAssertEqual(ast1, expected)
    }

    func testGetWhereMemberIsGenericTypeApp() throws {
        let symbols = Env()
        let funSym = Env(parent: symbols, frameLookupMode: .set(Frame()))
        let bodySym = Env(parent: funSym)

        let blockId = AbstractSyntaxTreeNode.ID()
        let implId = AbstractSyntaxTreeNode.ID()

        let expected = Block(
            symbols: symbols,
            children: [
                StructDeclaration(
                    identifier: Identifier("MyStruct"),
                    members: []
                ),
                Impl(
                    typeArguments: [],
                    structTypeExpr: Identifier("MyStruct"),
                    children: [
                        FunctionDeclaration(
                            identifier: Identifier("foo[const u16]"),
                            functionType: FunctionType(
                                name: "foo[const u16]",
                                returnType: PrimitiveType(.constU16),
                                arguments: [PrimitiveType(.constU16)]
                            ),
                            argumentNames: ["arg1"],
                            body: Block(
                                symbols: bodySym,
                                children: [
                                    Return(Identifier("arg1"))
                                ]
                            ),
                            symbols: funSym
                        )
                    ],
                    id: implId
                ),
                Call(
                    callee: Get(
                        expr: Identifier("MyStruct"),
                        member: Identifier("foo[const u16]")
                    ),
                    arguments: [
                        LiteralInt(0)
                    ]
                ),
            ],
            id: blockId
        )

        let ast0 = Block(
            symbols: symbols,
            children: [
                StructDeclaration(
                    identifier: Identifier("MyStruct"),
                    members: []
                ),
                Impl(
                    typeArguments: [],
                    structTypeExpr: Identifier("MyStruct"),
                    children: [
                        FunctionDeclaration(
                            identifier: Identifier("foo"),
                            functionType: FunctionType(
                                name: "foo",
                                returnType: Identifier("T"),
                                arguments: [Identifier("T")]
                            ),
                            argumentNames: ["arg1"],
                            typeArguments: [
                                GenericTypeArgument(
                                    identifier: Identifier("T"),
                                    constraints: []
                                )
                            ],
                            body: Block(
                                symbols: bodySym,
                                children: [
                                    Return(Identifier("arg1"))
                                ]
                            ),
                            symbols: funSym
                        )
                    ],
                    id: implId
                ),
                Call(
                    callee: Get(
                        expr: Identifier("MyStruct"),
                        member: GenericTypeApplication(
                            identifier: Identifier("foo"),
                            arguments: [
                                PrimitiveType(.constU16)
                            ]
                        )
                    ),
                    arguments: [
                        LiteralInt(0)
                    ]
                ),
            ],
            id: blockId
        )

        let ast1 = try CompilerPassGenerics(symbols: symbols).run(ast0)

        XCTAssertEqual(ast1, expected)
    }

    // Instantiating a concrete function from a generic will partially evaluate
    // the generic function AST with concrete values for the type arguments
    // bound in the symbol table.
    func testConcreteFunctionInstantiation() throws {
        let expected = Block(
            children: [
                FunctionDeclaration(
                    identifier: Identifier("foo[const u16]"),
                    functionType: FunctionType(
                        name: "foo[const u16]",
                        returnType: PrimitiveType(.constU16),
                        arguments: [PrimitiveType(.constU16)]
                    ),
                    argumentNames: ["a"],
                    body: Block(
                        children: [
                            Return(
                                Binary(
                                    op: .plus,
                                    left: Identifier("a"),
                                    right: LiteralInt(1)
                                )
                            )
                        ]),
                    visibility: .privateVisibility
                ),
                Identifier("foo[const u16]"),
            ])
            .reconnect(parent: nil)

        let ast0 = try parse(
            """
            func foo[T](a: T) -> T {
                return a + 1
            }
            foo@[const u16]
            """
        )
        .eraseSourceAnchors()?
        .replaceTopLevelWithBlock()
        .reconnect(parent: nil)
        let ast1 = try CompilerPassGenerics().run(ast0)
        XCTAssertEqual(ast1, expected)
    }

    // A function's generic type parameter may shadow an existing type
    func testFunctionGenericTypeParameterMayShadowAnExistingType() throws {
        let ast = Block(
            children: [
                StructDeclaration(
                    identifier: Identifier("T"),
                    members: []
                ),
                FunctionDeclaration(
                    identifier: Identifier("foo"),
                    functionType: FunctionType(
                        name: "foo",
                        returnType: PrimitiveType(.void),
                        arguments: [PrimitiveType(.void)]
                    ),
                    argumentNames: ["arg1"],
                    typeArguments: [
                        GenericTypeArgument(
                            identifier: Identifier("T"),  // Shadows the variable, "T"
                            constraints: []
                        )
                    ],
                    body: Block()
                ),
                GenericTypeApplication(
                    identifier: Identifier("foo"),
                    arguments: [
                        PrimitiveType(.u16)
                    ]
                ),
            ])
            .reconnect(parent: nil)

        XCTAssertNoThrow(try CompilerPassGenerics().run(ast))
    }

    func testFunctionBodyMayShadowFunctionGenericTypeParameter() throws {
        let ast = Block(
            children: [
                FunctionDeclaration(
                    identifier: Identifier("foo"),
                    functionType: FunctionType(
                        name: "foo",
                        returnType: PrimitiveType(.void),
                        arguments: [PrimitiveType(.void)]
                    ),
                    argumentNames: ["arg1"],
                    typeArguments: [
                        GenericTypeArgument(
                            identifier: Identifier("T"),
                            constraints: []
                        )
                    ],
                    body: Block(children: [
                        VarDeclaration(
                            identifier: Identifier("T"),  // Shadows the generic type parameter, "T"
                            explicitType: PrimitiveType(.bool),
                            expression: LiteralBool(true),
                            storage: .automaticStorage,
                            isMutable: false
                        )
                    ])
                ),
                GenericTypeApplication(
                    identifier: Identifier("foo"),
                    arguments: [
                        PrimitiveType(.u16)
                    ]
                ),
            ])
            .reconnect(parent: nil)

        XCTAssertNoThrow(try CompilerPassGenerics().run(ast))
    }
}
