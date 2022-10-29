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
    func testCompileTraitAddsToTypeTable_Empty() throws {
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"), members: [])
        
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let globalSymbols = globalEnvironment.globalSymbols
        try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: globalEnvironment.globalSymbols).compile(ast)
        
        let expectedSymbols = SymbolTable()
        expectedSymbols.enclosingFunctionNameMode = .set("Foo")
        let expected: SymbolType = .traitType(TraitType(name: "Foo", nameOfTraitObjectType: "__Foo_object", nameOfVtableType: "__Foo_vtable", symbols: expectedSymbols))
        let actual = try globalSymbols.resolveType(identifier: "Foo")
        XCTAssertEqual(expected, actual)
    }
    
    func testCompileTraitAddsToTypeTable_HasMethod() throws {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [
            Expression.PointerType(Expression.Identifier("Foo"))
        ])))
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                   members: [bar],
                                   visibility: .privateVisibility)

        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let globalSymbols = globalEnvironment.globalSymbols
        try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: globalEnvironment.globalSymbols).compile(ast)

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

        let actual = try globalSymbols.resolveType(identifier: "Foo")
        XCTAssertEqual(expected, actual)
    }

    func testCompileTraitAddsVtableType_Empty() throws {
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"), members: [])

        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let globalSymbols = globalEnvironment.globalSymbols
        try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: globalEnvironment.globalSymbols).compile(ast)
        
        let traitType = try globalSymbols.resolveType(identifier: "Foo")
        let nameOfVtableType = traitType.unwrapTraitType().nameOfVtableType
        XCTAssertEqual("__Foo_vtable", nameOfVtableType)
    }

    func testCompileTraitAddsVtableType_HasMethod() throws {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [
            Expression.PointerType(Expression.Identifier("Foo"))
        ])))
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                   members: [bar],
                                   visibility: .privateVisibility)

        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let globalSymbols = globalEnvironment.globalSymbols
        try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: globalEnvironment.globalSymbols).compile(ast)
        
        let traitType = try globalSymbols.resolveType(identifier: "Foo")
        let nameOfVtableType = traitType.unwrapTraitType().nameOfVtableType
        XCTAssertEqual("__Foo_vtable", nameOfVtableType)
    }

    func testCompileTraitAddsVtableType_HasConstMethod() throws {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [
            Expression.PointerType(Expression.ConstType(Expression.Identifier("Foo")))
        ])))
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                   members: [bar],
                                   visibility: .privateVisibility)

        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let globalSymbols = globalEnvironment.globalSymbols
        try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: globalEnvironment.globalSymbols).compile(ast)
        
        let traitType = try globalSymbols.resolveType(identifier: "Foo")
        let nameOfVtableType = traitType.unwrapTraitType().nameOfVtableType
        XCTAssertEqual("__Foo_vtable", nameOfVtableType)
    }
    
    func testCompileTraitAddsTraitObjectType_VoidReturn() throws {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.void), arguments: [
            Expression.PointerType(Expression.Identifier("Foo"))
        ])))
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                   members: [bar],
                                   visibility: .privateVisibility)
        
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let globalSymbols = globalEnvironment.globalSymbols
        try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: globalEnvironment.globalSymbols).compile(ast)
        
        let traitType = try globalSymbols.resolveType(identifier: "Foo")
        XCTAssertEqual("__Foo_vtable", traitType.unwrapTraitType().nameOfVtableType)
        XCTAssertEqual("__Foo_object", traitType.unwrapTraitType().nameOfTraitObjectType)
    }

    func testCompileTraitAddsTraitObjectType() throws {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [
            Expression.PointerType(Expression.Identifier("Foo"))
        ])))
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                   members: [bar],
                                   visibility: .privateVisibility)
        
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let globalSymbols = globalEnvironment.globalSymbols
        try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: globalEnvironment.globalSymbols).compile(ast)
        
        let traitType = try globalSymbols.resolveType(identifier: "Foo")
        XCTAssertEqual("__Foo_vtable", traitType.unwrapTraitType().nameOfVtableType)
        XCTAssertEqual("__Foo_object", traitType.unwrapTraitType().nameOfTraitObjectType)
    }
}
