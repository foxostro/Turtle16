//
//  CompilerPassTraitsTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/9/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import SnapCore

final class CompilerPassTraitsTests: XCTestCase {

    func testEmptyTrait() throws {
        let traitIdent = Expression.Identifier("Foo")
        let traitObjectIdent = Expression.Identifier("__Foo_object")
        let vtableIdent = Expression.Identifier("__Foo_vtable")
        let vtableType = Expression.PointerType(Expression.ConstType(vtableIdent))
        let objectType = Expression.PointerType(Expression.PrimitiveType(.void))
        
        let expected = Block(children: [
            Seq(children: [
                TraitDeclaration(
                    identifier: traitIdent,
                    members: []),
                StructDeclaration(
                    identifier: vtableIdent,
                    members: [],
                    isConst: true),
                StructDeclaration(
                    identifier: traitObjectIdent,
                    members: [
                        StructDeclaration.Member(
                            name: "object",
                            type: objectType),
                        StructDeclaration.Member(
                            name: "vtable",
                            type: vtableType)
                    ],
                    isConst: true)
            ])
        ])
        
        let input = Block(
            children: [
                TraitDeclaration(
                    identifier: traitIdent,
                    members: [])
            ],
            id: expected.id)
        
        let actual = try input.traitsPass(GlobalEnvironment())
        XCTAssertEqual(actual, expected)
    }
    
    func testSimpleConcreteTrait() throws {
        let traitIdent = Expression.Identifier("Serial")
        let traitObjectIdent = Expression.Identifier("__Serial_object")
        let vtableIdent = Expression.Identifier("__Serial_vtable")
        let vtableType = Expression.PointerType(Expression.ConstType(vtableIdent))
        let objectType = Expression.PointerType(Expression.PrimitiveType(.void))
        let putsFnType = Expression.PointerType(
            Expression.FunctionType(
                name: nil,
                returnType: Expression.PrimitiveType(.void),
                arguments: [
                    Expression.PointerType(Expression.Identifier("Serial")),
                    Expression.DynamicArrayType(
                        Expression.PrimitiveType(
                            .arithmeticType(.mutableInt(.u8))))
                ]))
        
        let expected = Block(children: [
            Seq(children: [
                TraitDeclaration(
                    identifier: traitIdent,
                    members: [
                        TraitDeclaration.Member(name: "puts", type:  putsFnType)
                    ]),
                StructDeclaration(
                    identifier: vtableIdent,
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
                    identifier: traitObjectIdent,
                    members: [
                        StructDeclaration.Member(
                            name: "object",
                            type: objectType),
                        StructDeclaration.Member(
                            name: "vtable",
                            type: vtableType)
                    ],
                    isConst: true)
            ])
        ])
        
        let input = Block(
            children: [
                TraitDeclaration(
                    identifier: traitIdent,
                    members: [
                        TraitDeclaration.Member(name: "puts", type: putsFnType)
                    ])
            ],
            id: expected.id)
        
        let actual = try input.traitsPass(GlobalEnvironment())
        XCTAssertEqual(actual, expected)
    }

}
