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
    typealias Identifier = Expression.Identifier
    typealias PrimitiveType = Expression.PrimitiveType
    typealias PointerType = Expression.PointerType
    typealias LiteralInt = Expression.LiteralInt
    typealias Get = Expression.Get
    let i16: SymbolType = .arithmeticType(.mutableInt(.i16))
    let u8: SymbolType = .arithmeticType(.mutableInt(.u8))
    
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
                    name: "bar",
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
}
