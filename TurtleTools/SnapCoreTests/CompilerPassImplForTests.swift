//
//  CompilerPassImplForTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 12/15/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import SnapCore

final class CompilerPassImplForTests: XCTestCase {
    let serialFakeAST = Block(children: [
        // Normally, traits are compiled to such a Seq such by traitsPass()
        Seq(children: [
            TraitDeclaration(
                identifier: Expression.Identifier("Serial"),
                members: [
                    TraitDeclaration.Member(name: "puts", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.void), arguments: [
                        Expression.PointerType(Expression.Identifier("Serial")),
                        Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                    ])))
                ],
                visibility: .privateVisibility),
            StructDeclaration(
                identifier: Expression.Identifier("__Serial_vtable"),
                members: [
                    StructDeclaration.Member(
                        name: "puts",
                        type: Expression.PointerType(
                            Expression.FunctionType(
                                returnType: Expression.PrimitiveType(.void),
                                arguments: [
                                    Expression.PointerType(Expression.PrimitiveType(.void)),
                                    Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                                ])))
                ],
                isConst: true),
            StructDeclaration(
                identifier: Expression.Identifier("__Serial_object"),
                members: [
                    StructDeclaration.Member(
                        name: "object",
                        type: Expression.PointerType(Expression.PrimitiveType(.void))),
                    StructDeclaration.Member(
                        name: "vtable",
                        type: Expression.PointerType(Expression.ConstType(
                            Expression.Identifier("__Serial_vtable"))))
                ],
                isConst: true)
        ]),
        StructDeclaration(
            identifier: Expression.Identifier("SerialFake"),
            members: [])
    ])
    
    func testFailToCompileImplForTraitBecauseMethodsAreMissing() throws {
        let ast = serialFakeAST.appending(children: [
            ImplFor(
                typeArguments: [],
                traitTypeExpr: Expression.Identifier("Serial"),
                structTypeExpr: Expression.Identifier("SerialFake"),
                children: [])
        ])
            .reconnect(parent: nil)
        
        XCTAssertThrowsError(try ast.implForPass(GlobalEnvironment())) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' does not implement all trait methods; missing `puts'.")
        }
    }

    func testFailToCompileImplForTraitBecauseMethodHasIncorrectNumberOfParameters() throws {
        let ast = serialFakeAST.appending(children: [
            ImplFor(
                typeArguments: [],
                traitTypeExpr: Expression.Identifier("Serial"),
                structTypeExpr: Expression.Identifier("SerialFake"),
                children: [
                    FunctionDeclaration(
                        identifier: Expression.Identifier("puts"),
                        functionType: Expression.FunctionType(
                            name: "puts",
                            returnType: Expression.PrimitiveType(.void),
                            arguments: [
                                Expression.PointerType(Expression.Identifier("SerialFake"))
                            ]),
                        argumentNames: ["self"],
                        body: Block())
                ])
        ])
            .reconnect(parent: nil)
        
        XCTAssertThrowsError(try ast.implForPass(GlobalEnvironment())) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' method `puts' has 1 parameter but the declaration in the `Serial' trait has 2.")
        }
    }

    func testFailToCompileImplForTraitBecauseMethodHasIncorrectParameterTypes() throws {
        let ast = serialFakeAST.appending(children: [
            ImplFor(
                typeArguments: [],
                traitTypeExpr: Expression.Identifier("Serial"),
                structTypeExpr: Expression.Identifier("SerialFake"),
                children: [
                    FunctionDeclaration(
                        identifier: Expression.Identifier("puts"),
                        functionType: Expression.FunctionType(
                            name: "puts",
                            returnType: Expression.PrimitiveType(.void),
                            arguments: [
                                Expression.PointerType(Expression.Identifier("SerialFake")),
                                Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8)))
                            ]),
                        argumentNames: ["self", "s"],
                        body: Block())
                ])
        ])
            .reconnect(parent: nil)
        
        XCTAssertThrowsError(try ast.implForPass(GlobalEnvironment())) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' method `puts' has incompatible type for trait `Serial'; expected `[]u8' argument, got `u8' instead")
        }
    }

    func testFailToCompileImplForTraitBecauseMethodHasIncorrectSelfParameterTypes() throws {
        let ast = serialFakeAST.appending(children: [
            ImplFor(
                typeArguments: [],
                traitTypeExpr: Expression.Identifier("Serial"),
                structTypeExpr: Expression.Identifier("SerialFake"),
                children: [
                    FunctionDeclaration(
                        identifier: Expression.Identifier("puts"),
                        functionType: Expression.FunctionType(
                            name: "puts",
                            returnType: Expression.PrimitiveType(.void),
                            arguments: [
                                Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))),
                                Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                            ]),
                        argumentNames: ["self", "s"],
                        body: Block())
                ])
        ])
            .reconnect(parent: nil)
        
        XCTAssertThrowsError(try ast.implForPass(GlobalEnvironment())) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' method `puts' has incompatible type for trait `Serial'; expected `*SerialFake' argument, got `u8' instead")
        }
    }

    func testFailToCompileImplForTraitBecauseMethodHasIncorrectReturnType() throws {
        let ast = serialFakeAST.appending(children: [
            ImplFor(
                typeArguments: [],
                traitTypeExpr: Expression.Identifier("Serial"),
                structTypeExpr: Expression.Identifier("SerialFake"),
                children: [
                    FunctionDeclaration(
                        identifier: Expression.Identifier("puts"),
                        functionType: Expression.FunctionType(
                            name: "puts",
                            returnType: Expression.PrimitiveType(.bool(.mutableBool)),
                            arguments: [
                                Expression.PointerType(Expression.Identifier("SerialFake")),
                                Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                            ]),
                        argumentNames: ["self", "s"],
                        body: Block(children: [
                            Return(Expression.LiteralBool(false))
                        ]))
                ])
        ])
            .reconnect(parent: nil)
        
        XCTAssertThrowsError(try ast.implForPass(GlobalEnvironment())) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "`SerialFake' method `puts' has incompatible type for trait `Serial'; expected `void' return value, got `bool' instead")
        }
    }
    
    func testCompileImplForTrait() throws {
        let innerBlockID = AbstractSyntaxTreeNode.ID()
        let implForID = AbstractSyntaxTreeNode.ID()
        
        let ast0 = serialFakeAST.appending(children: [
            ImplFor(
                typeArguments: [],
                traitTypeExpr: Expression.Identifier("Serial"),
                structTypeExpr: Expression.Identifier("SerialFake"),
                children: [
                    FunctionDeclaration(
                        identifier: Expression.Identifier("puts"),
                        functionType: Expression.FunctionType(
                            name: "puts",
                            returnType: Expression.PrimitiveType(.void),
                            arguments: [
                                Expression.PointerType(Expression.Identifier("Serial")),
                                Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                            ]),
                        argumentNames: ["self", "s"],
                        body: Block(id: innerBlockID))
                ],
                id: implForID)
        ])
            .reconnect(parent: nil)
        
        // We expect that the AST is rewritten to include the declaration of the
        // vtable instance following the declaration of the vtable type itself.
        // We expect that the ImplFor node is rewritten to a plain Impl node.
        let expected = Block(children: [
            Seq(tags: [.vtable], children: [
                StructDeclaration(
                    identifier: Expression.Identifier("__Serial_vtable"),
                    members: [
                        StructDeclaration.Member(
                            name: "puts",
                            type: Expression.PrimitiveType(.pointer(.function(FunctionType(
                                returnType: .void,
                                arguments: [
                                    .pointer(.void),
                                    .dynamicArray(elementType: .arithmeticType(.mutableInt(.u8)))
                                ])))))
                    ],
                    visibility: .privateVisibility,
                    isConst: false),
                VarDeclaration(
                    identifier: Expression.Identifier("__Serial_SerialFake_vtable_instance"),
                    explicitType: Expression.Identifier("__Serial_vtable"),
                    expression: Expression.StructInitializer(
                        expr: Expression.Identifier("__Serial_vtable"),
                        arguments: [
                            Expression.StructInitializer.Argument(
                                name: "puts",
                                expr: Expression.Bitcast(
                                    expr: Expression.Unary(
                                        op: .ampersand,
                                        expression: Expression.Get(
                                            expr: Expression.Identifier("SerialFake"),
                                            member: Expression.Identifier("puts"))),
                                    targetType: Expression.PrimitiveType(.pointer(.function(FunctionType(
                                        returnType: .void,
                                        arguments: [
                                            .pointer(.void),
                                            .dynamicArray(elementType: .arithmeticType(.mutableInt(.u8)))
                                        ]))))))
                        ]),
                    storage: .staticStorage,
                    isMutable: false,
                    visibility: .privateVisibility)
            ]),
            Seq(children: [
                TraitDeclaration(
                    identifier: Expression.Identifier("Serial"),
                    members: [
                        TraitDeclaration.Member(name: "puts", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.void), arguments: [
                            Expression.PointerType(Expression.Identifier("Serial")),
                            Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                        ])))
                    ],
                    visibility: .privateVisibility),
                StructDeclaration(
                    identifier: Expression.Identifier("__Serial_vtable"),
                    members: [
                        StructDeclaration.Member(
                            name: "puts",
                            type: Expression.PointerType(
                                Expression.FunctionType(
                                    returnType: Expression.PrimitiveType(.void),
                                    arguments: [
                                        Expression.PointerType(Expression.PrimitiveType(.void)),
                                        Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                                    ])))
                    ],
                    isConst: true),
                StructDeclaration(
                    identifier: Expression.Identifier("__Serial_object"),
                    members: [
                        StructDeclaration.Member(
                            name: "object",
                            type: Expression.PointerType(Expression.PrimitiveType(.void))),
                        StructDeclaration.Member(
                            name: "vtable",
                            type: Expression.PointerType(Expression.ConstType(
                                Expression.Identifier("__Serial_vtable"))))
                    ],
                    isConst: true)
            ]),
            StructDeclaration(
                identifier: Expression.Identifier("SerialFake"),
                members: []),
            Impl(
                typeArguments: [],
                structTypeExpr: Expression.Identifier("SerialFake"),
                children: [
                    FunctionDeclaration(
                        identifier: Expression.Identifier("puts"),
                        functionType: Expression.FunctionType(
                            name: "puts",
                            returnType: Expression.PrimitiveType(.void),
                            arguments: [
                                Expression.PointerType(Expression.Identifier("Serial")),
                                Expression.DynamicArrayType(Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
                            ]),
                        argumentNames: ["self", "s"],
                        body: Block(id: innerBlockID))
                ],
                id: implForID)
        ], id: ast0.id)
            .reconnect(parent: nil)
        
        let actual = try ast0.implForPass(GlobalEnvironment())
        
        XCTAssertEqual(actual, expected)
    }
}
