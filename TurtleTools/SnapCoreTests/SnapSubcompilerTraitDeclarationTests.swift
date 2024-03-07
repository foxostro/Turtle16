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
        let symbols = SymbolTable()
        _ = try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: symbols)
        .compile(ast)
        
        let expectedSymbols = SymbolTable()
        expectedSymbols.frameLookupMode = .set(Frame())
        expectedSymbols.enclosingFunctionNameMode = .set("Foo")
        let expected: SymbolType = .traitType(TraitType(name: "Foo", nameOfTraitObjectType: "__Foo_object", nameOfVtableType: "__Foo_vtable", symbols: expectedSymbols))
        let actual = try symbols.resolveType(identifier: "Foo")
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
        let symbols = SymbolTable()
        _ = try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: symbols)
        .compile(ast)
        
        let memoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()
        let members = SymbolTable()
        let fullyQualifiedTraitType = TraitType(name: "Foo", nameOfTraitObjectType: "__Foo_object", nameOfVtableType: "__Foo_vtable", symbols: members)
        let expected: SymbolType = .traitType(fullyQualifiedTraitType)
        members.enclosingFunctionNameMode = .set("Foo")
        let frame = Frame()
        members.frameLookupMode = .set(frame)
        let memberType: SymbolType = .pointer(.function(FunctionType(returnType: .arithmeticType(.mutableInt(.u8)), arguments: [.pointer(expected)])))
        let symbol = Symbol(type: memberType, offset: frame.storagePointer, storage: .automaticStorage)
        members.bind(identifier: "bar", symbol: symbol)
        let sizeOfMemoryType = memoryLayoutStrategy.sizeof(type: memberType)
        frame.bumpStoragePointer(sizeOfMemoryType)
        members.parent = nil

        let actual = try symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(expected, actual)
    }

    func testCompileTraitAddsVtableType_Empty() throws {
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"), members: [])

        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let symbols = SymbolTable()
        _ = try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: symbols)
        .compile(ast)
        
        let traitType = try symbols.resolveType(identifier: "Foo")
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
        let symbols = SymbolTable()
        _ = try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: symbols)
        .compile(ast)
        
        let traitType = try symbols.resolveType(identifier: "Foo")
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
        let symbols = SymbolTable()
        _ = try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: symbols)
        .compile(ast)
        
        let traitType = try symbols.resolveType(identifier: "Foo")
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
        let symbols = SymbolTable()
        _ = try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: symbols)
        .compile(ast)
        
        let traitType = try symbols.resolveType(identifier: "Foo")
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
        let symbols = SymbolTable()
        _ = try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: symbols)
        .compile(ast)
        
        let traitType = try symbols.resolveType(identifier: "Foo")
        XCTAssertEqual("__Foo_vtable", traitType.unwrapTraitType().nameOfVtableType)
        XCTAssertEqual("__Foo_object", traitType.unwrapTraitType().nameOfTraitObjectType)
    }
    
    func testCompileTraitAddsToTypeTable_EmptyGenericTrait() throws {
        let ast = TraitDeclaration(
            identifier: Expression.Identifier("Foo"),
            typeArguments: [
                Expression.GenericTypeArgument(
                    identifier: Expression.Identifier("T"),
                    constraints: [])
            ],
            members: [])
        
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let symbols = SymbolTable()
        _ = try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: symbols)
        .compile(ast)
        let actual = try symbols.resolveType(identifier: "Foo")
        
        let expected: SymbolType = .genericTraitType(GenericTraitType(template: ast))
        XCTAssertEqual(expected, actual)
    }
}
