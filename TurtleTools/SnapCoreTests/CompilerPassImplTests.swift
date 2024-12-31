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
    fileprivate typealias Identifier = Expression.Identifier
    fileprivate typealias PrimitiveType = Expression.PrimitiveType
    fileprivate typealias PointerType = Expression.PointerType
    fileprivate typealias ConstType = Expression.ConstType
    fileprivate typealias LiteralInt = Expression.LiteralInt
    fileprivate typealias Get = Expression.Get
    fileprivate typealias Call = Expression.Call
    fileprivate typealias StructInitializer = Expression.StructInitializer
    fileprivate typealias Bitcast = Expression.Bitcast
    fileprivate typealias Unary = Expression.Unary
    fileprivate typealias Binary = Expression.Binary
    fileprivate typealias Assignment = Expression.Assignment
    fileprivate let i16: SymbolType = .arithmeticType(.mutableInt(.i16))
    fileprivate let u8: SymbolType = .arithmeticType(.mutableInt(.u8))
    fileprivate let u16: SymbolType = .arithmeticType(.mutableInt(.u16))
    
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
}
