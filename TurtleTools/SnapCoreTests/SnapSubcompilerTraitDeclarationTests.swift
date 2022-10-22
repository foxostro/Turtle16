//
//  SnapSubcompilerTraitDeclarationTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapSubcompilerTraitDeclarationTests: XCTestCase {
    fileprivate func makeCompiler(_ symbols: SymbolTable) -> SnapSubcompilerTraitDeclaration {
        return SnapSubcompilerTraitDeclaration(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL(), symbols: symbols)
    }
    
    func testCompileTraitAddsToTypeTable_Empty() {
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"), members: [])
        
        let globalSymbols = SymbolTable()
        let _ = try? makeCompiler(globalSymbols).compile(ast)
        
        let expectedSymbols = SymbolTable()
        expectedSymbols.enclosingFunctionNameMode = .set("Foo")
        let expected: SymbolType = .traitType(TraitType(name: "Foo", nameOfTraitObjectType: "__Foo_object", nameOfVtableType: "__Foo_vtable", symbols: expectedSymbols))
        let actual = try? globalSymbols.resolveType(identifier: "Foo")
        XCTAssertEqual(expected, actual)
    }
    
    func testCompileTraitAddsToTypeTable_HasMethod() {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [
            Expression.PointerType(Expression.Identifier("Foo"))
        ])))
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                   members: [bar],
                                   visibility: .privateVisibility)

        let globalSymbols = SymbolTable()
        let _ = try? makeCompiler(globalSymbols).compile(ast)

        let memoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()
        let members = SymbolTable()
        let fullyQualifiedTraitType = TraitType(name: "Foo", nameOfTraitObjectType: "__Foo_object", nameOfVtableType: "__Foo_vtable", symbols: members)
        let expected: SymbolType = .traitType(fullyQualifiedTraitType)
        members.enclosingFunctionNameMode = .set("Foo")
        let memberType: SymbolType = .pointer(.function(FunctionType(returnType: .arithmeticType(.mutableInt(.u8)), arguments: [.pointer(expected)])))
        let symbol = Symbol(type: memberType, offset: members.storagePointer, storage: .automaticStorage)
        members.bind(identifier: "bar", symbol: symbol)
        let sizeOfMemoryType = memoryLayoutStrategy.sizeof(type: memberType)
        members.storagePointer += sizeOfMemoryType
        members.parent = nil

        let actual = try? globalSymbols.resolveType(identifier: "Foo")
        XCTAssertEqual(expected, actual)
    }

    func testCompileTraitAddsVtableType_Empty() {
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"), members: [])

        let globalSymbols = SymbolTable()
        let result = try? makeCompiler(globalSymbols).compile(ast)
        
        let traitType = try? globalSymbols.resolveType(identifier: "Foo")
        let nameOfVtableType = traitType?.unwrapTraitType().nameOfVtableType ?? ""
        XCTAssertEqual("__Foo_vtable", nameOfVtableType)
        
        let expected = StructDeclaration(identifier: Expression.Identifier("__Foo_vtable"),
                                         members: [],
                                         visibility: .privateVisibility,
                                         isConst: true)
        XCTAssertEqual(result?.children.first, expected)
    }

    func testCompileTraitAddsVtableType_HasMethod() {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [
            Expression.PointerType(Expression.Identifier("Foo"))
        ])))
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                   members: [bar],
                                   visibility: .privateVisibility)

        let globalSymbols = SymbolTable()
        let result = try? makeCompiler(globalSymbols).compile(ast)
        
        let traitType = try? globalSymbols.resolveType(identifier: "Foo")
        let nameOfVtableType = traitType?.unwrapTraitType().nameOfVtableType ?? ""
        XCTAssertEqual("__Foo_vtable", nameOfVtableType)
        
        let expected = StructDeclaration(identifier: Expression.Identifier("__Foo_vtable"),
                                         members: [
                                            StructDeclaration.Member(name: "bar", type: Expression.PointerType(Expression.FunctionType(returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [Expression.PointerType(Expression.PrimitiveType(.void))])))
                                         ],
                                         visibility: .privateVisibility,
                                         isConst: true)
        XCTAssertEqual(result?.children.first, expected)
    }

    func testCompileTraitAddsVtableType_HasConstMethod() {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [
            Expression.PointerType(Expression.ConstType(Expression.Identifier("Foo")))
        ])))
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                   members: [bar],
                                   visibility: .privateVisibility)

        let globalSymbols = SymbolTable()
        let result = try? makeCompiler(globalSymbols).compile(ast)
        
        let traitType = try? globalSymbols.resolveType(identifier: "Foo")
        let nameOfVtableType = traitType?.unwrapTraitType().nameOfVtableType ?? ""
        XCTAssertEqual("__Foo_vtable", nameOfVtableType)
        
        let expected = StructDeclaration(identifier: Expression.Identifier("__Foo_vtable"),
                                         members: [
                                            StructDeclaration.Member(name: "bar", type: Expression.PointerType(Expression.FunctionType(returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [Expression.PointerType(Expression.PrimitiveType(.void))])))
                                         ],
                                         visibility: .privateVisibility,
                                         isConst: true)
        XCTAssertEqual(result?.children.first, expected)
    }
    
    func testCompileTraitAddsTraitObjectType_VoidReturn() {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.void), arguments: [
            Expression.PointerType(Expression.Identifier("Foo"))
        ])))
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                   members: [bar],
                                   visibility: .privateVisibility)
        
        let globalSymbols = SymbolTable()
        let result = try? makeCompiler(globalSymbols).compile(ast)
        
        let traitType = try? globalSymbols.resolveType(identifier: "Foo")
        XCTAssertEqual("__Foo_vtable", traitType?.unwrapTraitType().nameOfVtableType)
        XCTAssertEqual("__Foo_object", traitType?.unwrapTraitType().nameOfTraitObjectType)
        
        let expected = Seq(children: [
            StructDeclaration(identifier: Expression.Identifier("__Foo_vtable"), members: [
               StructDeclaration.Member(name: "bar", type: Expression.PointerType(Expression.FunctionType(returnType: Expression.PrimitiveType(.void), arguments: [Expression.PointerType(Expression.PrimitiveType(.void))])))
            ], visibility: .privateVisibility, isConst: true),
            StructDeclaration(identifier: Expression.Identifier("__Foo_object"), members: [
                StructDeclaration.Member(name: "object", type: Expression.PointerType(Expression.PrimitiveType(.void))),
                StructDeclaration.Member(name: "vtable", type: Expression.PointerType(Expression.ConstType(Expression.Identifier("__Foo_vtable"))))
            ], visibility: .privateVisibility),
            Impl(typeArguments: [], structTypeExpr: Expression.Identifier("__Foo_object"), children: [
                FunctionDeclaration(identifier: Expression.Identifier("bar"), functionType: Expression.FunctionType(name: "bar", returnType: Expression.PrimitiveType(.void), arguments: [Expression.PointerType(Expression.Identifier("__Foo_object"))]), argumentNames: ["self"], body: Block(children: [
                    Expression.Call(callee: Expression.Get(expr: Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("vtable")), member: Expression.Identifier("bar")), arguments: [
                        Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("object"))
                    ])
                ]))
            ])
        ])
        XCTAssertEqual(result, expected)
    }

    func testCompileTraitAddsTraitObjectType() {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [
            Expression.PointerType(Expression.Identifier("Foo"))
        ])))
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                   members: [bar],
                                   visibility: .privateVisibility)
        
        let globalSymbols = SymbolTable()
        let result = try? makeCompiler(globalSymbols).compile(ast)
        
        let traitType = try? globalSymbols.resolveType(identifier: "Foo")
        XCTAssertEqual("__Foo_vtable", traitType?.unwrapTraitType().nameOfVtableType)
        XCTAssertEqual("__Foo_object", traitType?.unwrapTraitType().nameOfTraitObjectType)
        
        let expected = Seq(children: [
            StructDeclaration(identifier: Expression.Identifier("__Foo_vtable"), members: [
               StructDeclaration.Member(name: "bar", type: Expression.PointerType(Expression.FunctionType(returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [Expression.PointerType(Expression.PrimitiveType(.void))])))
            ], visibility: .privateVisibility, isConst: true),
            StructDeclaration(identifier: Expression.Identifier("__Foo_object"), members: [
                StructDeclaration.Member(name: "object", type: Expression.PointerType(Expression.PrimitiveType(.void))),
                StructDeclaration.Member(name: "vtable", type: Expression.PointerType(Expression.ConstType(Expression.Identifier("__Foo_vtable"))))
            ], visibility: .privateVisibility),
            Impl(typeArguments: [], structTypeExpr: Expression.Identifier("__Foo_object"), children: [
                FunctionDeclaration(identifier: Expression.Identifier("bar"), functionType: Expression.FunctionType(name: "bar", returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [Expression.PointerType(Expression.Identifier("__Foo_object"))]), argumentNames: ["self"], body: Block(children: [
                    Return(Expression.Call(callee: Expression.Get(expr: Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("vtable")), member: Expression.Identifier("bar")), arguments: [
                        Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("object"))
                    ]))
                ]))
            ])
        ])
        XCTAssertEqual(result, expected)
    }
}
