//
//  CompilerPassImplTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 12/24/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import SnapCore

final class CompilerPassImplTests: XCTestCase {
    fileprivate typealias Assignment = Expression.Assignment
    fileprivate typealias Binary = Expression.Binary
    fileprivate typealias Bitcast = Expression.Bitcast
    fileprivate typealias Call = Expression.Call
    fileprivate typealias ConstType = Expression.ConstType
    fileprivate typealias Get = Expression.Get
    fileprivate typealias Identifier = Expression.Identifier
    fileprivate typealias LiteralInt = Expression.LiteralInt
    fileprivate typealias PointerType = Expression.PointerType
    fileprivate typealias PrimitiveType = Expression.PrimitiveType
    fileprivate typealias StructInitializer = Expression.StructInitializer
    fileprivate typealias Unary = Expression.Unary
    
    fileprivate let i16: SymbolType = .arithmeticType(.mutableInt(.i16))
    fileprivate let u8: SymbolType = .arithmeticType(.mutableInt(.u8))
    fileprivate let u16: SymbolType = .arithmeticType(.mutableInt(.u16))
    
    fileprivate var testName: String {
        let regex = try! NSRegularExpression(pattern: #"\[\w+\s+(?<testName>\w+)\]"#)
        if let match = regex.firstMatch(in: name, range: NSRange(name.startIndex..., in: name)) {
            let nsRange = match.range(withName: "testName")
            if let range = Range(nsRange, in: name) {
                return String(name[range])
            }
        }
        return ""
    }
    
    fileprivate func parse(_ text: String) -> TopLevel {
        try! SnapCore.parse(text: text, url: URL(fileURLWithPath: testName))
    }
    
    func testEraseImpl() throws {
        let ast0 = Block(children: [
            StructDeclaration(
                identifier: Identifier("Foo"),
                members: [
                    StructDeclaration.Member(
                        name: "val",
                        type: PrimitiveType(i16))
                ],
                visibility: .privateVisibility),
            Impl(
                typeArguments: [],
                structTypeExpr: Identifier("Foo"),
                children: [
                    FunctionDeclaration(
                        identifier: Identifier("bar"),
                        functionType: Expression.FunctionType(
                            name: "bar",
                            returnType: PrimitiveType(u8),
                            arguments: [
                                PointerType(Identifier("Foo"))
                            ]),
                        argumentNames: ["baz"],
                        typeArguments: [],
                        body: Block(children: [
                            Return(LiteralInt(0))
                        ]))
                ]),
            Get(expr: Identifier("Foo"), member: Identifier("val")),
            Get(expr: Identifier("Foo"), member: Identifier("bar"))
        ])
            .reconnect(parent: nil)
        
        let expected = Block(children: [
            StructDeclaration(
                identifier: Identifier("Foo"),
                members: [
                    StructDeclaration.Member(
                        name: "val",
                        type: PrimitiveType(i16))
                ],
                visibility: .privateVisibility),
            FunctionDeclaration(
                identifier: Identifier("__Foo_bar"),
                functionType: Expression.FunctionType(
                    name: "__Foo_bar",
                    returnType: PrimitiveType(u8),
                    arguments: [
                        PointerType(Identifier("Foo"))
                    ]),
                argumentNames: ["baz"],
                typeArguments: [],
                body: Block(children: [
                    Return(LiteralInt(0))
                ])),
            Get(expr: Identifier("Foo"), member: Identifier("val")),
            Identifier("__Foo_bar")
        ])
            .reconnect(parent: nil)
        
        let actual = try ast0
            .eraseImplPass(GlobalEnvironment())?
            .flatten()
        
        XCTAssertEqual(actual, expected)
    }
    
    func testImplInsideFunctionBody() throws {
        let ast0 = Block(children: [
            StructDeclaration(
                identifier: Identifier("Foo"),
                members: [
                    StructDeclaration.Member(
                        name: "val",
                        type: PrimitiveType(i16))
                ],
                visibility: .privateVisibility),
            FunctionDeclaration(
                identifier: Identifier("myFunc"),
                functionType: Expression.FunctionType(
                    name: "myFunc",
                    returnType: PrimitiveType(.void),
                    arguments: []),
                argumentNames: [],
                typeArguments: [],
                body: Block(children: [
                    Impl(
                        typeArguments: [],
                        structTypeExpr: Identifier("Foo"),
                        children: [
                            FunctionDeclaration(
                                identifier: Identifier("bar"),
                                functionType: Expression.FunctionType(
                                    name: "bar",
                                    returnType: PrimitiveType(u8),
                                    arguments: [
                                        PointerType(Identifier("Foo"))
                                    ]),
                                argumentNames: ["baz"],
                                typeArguments: [],
                                body: Block(children: [
                                    Return(LiteralInt(0))
                                ]))
                        ])
                ]),
                visibility: .privateVisibility)
        ])
            .reconnect(parent: nil)
        
        let expected = Block(children: [
            StructDeclaration(
                identifier: Identifier("Foo"),
                members: [
                    StructDeclaration.Member(
                        name: "val",
                        type: PrimitiveType(i16))
                ],
                visibility: .privateVisibility),
            FunctionDeclaration(
                identifier: Identifier("myFunc"),
                functionType: Expression.FunctionType(
                    name: "myFunc",
                    returnType: PrimitiveType(.void),
                    arguments: []),
                argumentNames: [],
                typeArguments: [],
                body: Block(children: [
                    FunctionDeclaration(
                        identifier: Identifier("__myFunc_Foo_bar"),
                        functionType: Expression.FunctionType(
                            name: "__myFunc_Foo_bar",
                            returnType: PrimitiveType(u8),
                            arguments: [
                                PointerType(Identifier("Foo"))
                            ]),
                        argumentNames: ["baz"],
                        typeArguments: [],
                        body: Block(children: [
                            Return(LiteralInt(0))
                        ]))
                ]),
                visibility: .privateVisibility)
        ])
            .reconnect(parent: nil)
        
        let actual = try ast0
            .eraseImplPass(GlobalEnvironment())?
            .flatten()
        
        XCTAssertEqual(actual, expected)
    }
    
    func testGenericStructImplForWithinAFunction() throws {
        let globalEnvironment = GlobalEnvironment()
        let actual = try parse("""
            func myFunction() -> u16 {
                trait Incrementer {
                    func increment(self: *Incrementer)
                }

                struct RealIncrementer[T] {
                    val: T
                }

                impl[T] Incrementer for RealIncrementer@[T] {
                    func increment(self: *RealIncrementer@[T]) {
                        self.val = self.val + 1
                    }
                }

                var realIncrementer = RealIncrementer@[u16] { .val = 41 }
                let incrementer: Incrementer = &realIncrementer
                incrementer.increment()
                return realIncrementer.val
            }
            let p = myFunction()
            """)
            .replaceTopLevelWithBlock()
            .reconnect(parent: nil)
            .genericsPass(globalEnvironment)?
            .vtablesPass(globalEnvironment)?
            .implForPass(globalEnvironment)?
            .eraseMethodCalls(globalEnvironment)?
            .synthesizeTerminalReturnStatements(globalEnvironment)?
            .eraseImplPass(globalEnvironment)?
            .flatten()?
            .eraseSourceAnchors() // aids in comparing against `expected`
        
        let expected = Block(children: [
            FunctionDeclaration(
                identifier: Identifier("myFunction"),
                functionType: Expression.FunctionType(
                    name: "myFunction",
                    returnType: PrimitiveType(u16),
                    arguments: []),
                argumentNames: [],
                typeArguments: [],
                body: Block(children: [
                    StructDeclaration(
                        identifier: Identifier("__Incrementer_vtable"),
                        typeArguments: [],
                        members: [
                            StructDeclaration.Member(
                                name: "increment",
                                type: PointerType(Expression.FunctionType(
                                    name: nil,
                                    returnType: PrimitiveType(.void),
                                    arguments: [
                                        PointerType(PrimitiveType(.void))
                                    ])))
                        ],
                        visibility: .privateVisibility,
                        isConst: false,
                        associatedTraitType: nil),
                    StructDeclaration(
                        identifier: Identifier("__Incrementer_object"),
                        typeArguments: [],
                        members: [
                            StructDeclaration.Member(
                                name: "object",
                                type: PointerType(PrimitiveType(.void))),
                            StructDeclaration.Member(
                                name: "vtable",
                                type: PointerType(ConstType(
                                    Identifier("__Incrementer_vtable"))))
                        ],
                        visibility: .privateVisibility,
                        isConst: false,
                        associatedTraitType: "Incrementer"),
                    FunctionDeclaration(
                        identifier: Identifier("__myFunction_Incrementer_object_increment"),
                        functionType: Expression.FunctionType(
                            name: "__myFunction_Incrementer_object_increment",
                            returnType: PrimitiveType(.void),
                            arguments: [PointerType(Identifier("__Incrementer_object"))]),
                        argumentNames: ["self"],
                        typeArguments: [],
                        body: Block(children: [
                            Call(
                                callee: Get(
                                    expr: Get(
                                        expr: Identifier("self"),
                                        member: Identifier("vtable")),
                                    member: Identifier("increment")),
                                arguments: [
                                    Get(
                                        expr: Identifier("self"),
                                        member: Identifier("object"))
                                ]),
                            Return()
                        ])),
                    VarDeclaration(
                        identifier: Identifier("__Incrementer_RealIncrementer_u16_vtable_instance"),
                        explicitType: Identifier("__Incrementer_vtable"),
                        expression: StructInitializer(
                            expr: Identifier("__Incrementer_vtable"),
                            arguments: [
                                StructInitializer.Argument(
                                    name: "increment",
                                    expr: Bitcast(
                                        expr: Unary(
                                            op: .ampersand,
                                            expression: Identifier("__myFunction_RealIncrementer_u16_increment")),
                                        targetType: PrimitiveType(
                                            .pointer(.function(FunctionType(
                                                name: nil,
                                                mangledName: nil,
                                                returnType: .void,
                                                arguments: [
                                                    .pointer(.void)
                                                ]))))))
                            ]),
                        storage: .staticStorage,
                        isMutable: false,
                        visibility: .privateVisibility),
                    StructDeclaration(
                        identifier: Identifier("__RealIncrementer_u16"),
                        typeArguments: [],
                        members: [
                            StructDeclaration.Member(
                                name: "val",
                                type: PrimitiveType(u16))
                        ],
                        visibility: .privateVisibility,
                        isConst: false),
                    FunctionDeclaration(
                        identifier: Identifier("__myFunction_RealIncrementer_u16_increment"),
                        functionType: Expression.FunctionType(
                            name: "__myFunction_RealIncrementer_u16_increment",
                            returnType: PrimitiveType(.void),
                            arguments: [
                                PointerType(Identifier("__RealIncrementer_u16"))
                            ]),
                        argumentNames: ["self"],
                        typeArguments: [],
                        body: Block(children: [
                            Assignment(
                                lexpr: Get(
                                    expr: Identifier("self"),
                                    member: Identifier("val")),
                                rexpr: Binary(
                                    op: .plus,
                                    left: Get(
                                        expr: Identifier("self"),
                                        member: Identifier("val")),
                                    right: LiteralInt(1))),
                            Return()
                        ]),
                        visibility: .privateVisibility),
                    VarDeclaration(
                        identifier: Identifier("realIncrementer"),
                        explicitType: nil,
                        expression: StructInitializer(
                            expr: Identifier("__RealIncrementer_u16"),
                            arguments: [
                                StructInitializer.Argument(
                                    name: "val",
                                    expr: LiteralInt(41))
                            ]),
                        storage: .automaticStorage,
                        isMutable: true,
                        visibility: .privateVisibility),
                    VarDeclaration(
                        identifier: Identifier("incrementer"),
                        explicitType: Identifier("__Incrementer_object"),
                        expression: StructInitializer(
                            expr: Identifier("__Incrementer_object"),
                            arguments: [
                                StructInitializer.Argument(
                                    name: "object",
                                    expr: Bitcast(
                                        expr: Unary(
                                            op: .ampersand,
                                            expression: Identifier("realIncrementer")),
                                        targetType: PointerType(PrimitiveType(.void)))),
                                StructInitializer.Argument(
                                    name: "vtable",
                                    expr: Identifier("__Incrementer_RealIncrementer_u16_vtable_instance"))
                            ]),
                        storage: .automaticStorage,
                        isMutable: false,
                        visibility: .privateVisibility),
                    Call(
                        callee: Identifier("__myFunction_Incrementer_object_increment"),
                        arguments: [
                            Identifier("incrementer")
                        ]),
                    Return(Get(
                        expr: Identifier("realIncrementer"),
                        member: Identifier("val")))
                ]),
                visibility: .privateVisibility),
                VarDeclaration(
                    identifier: Identifier("p"),
                    explicitType: nil,
                    expression: Call(
                        callee: Identifier("myFunction"),
                        arguments: []),
                    storage: .automaticStorage,
                    isMutable: false,
                    visibility: .privateVisibility)
            ])
            .reconnect(parent: nil)
        
        XCTAssertEqual(actual, expected)
    }
}
