//
//  TraitScannerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/9/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

final class TraitScannerTests: XCTestCase {

    func testCompileTraitAddsToTypeTable_Empty() throws {
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"), members: [])
        
        let scanner = TraitScanner()
        try scanner.scan(trait: ast)
        
        let expectedSymbols = SymbolTable()
        expectedSymbols.frameLookupMode = .set(Frame())
        expectedSymbols.breadcrumb = .traitType("Foo")
        let expected: SymbolType = .traitType(TraitType(name: "Foo", nameOfTraitObjectType: "__Foo_object", nameOfVtableType: "__Foo_vtable", symbols: expectedSymbols))
        let actual = try scanner.symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(expected, actual)
    }
    
    func testCompileTraitAddsToTypeTable_HasMethod() throws {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.u8), arguments: [
            Expression.PointerType(Expression.Identifier("Foo"))
        ])))
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                   members: [bar],
                                   visibility: .privateVisibility)
        
        let scanner = TraitScanner()
        try scanner.scan(trait: ast)
        
        let memoryLayoutStrategy = MemoryLayoutStrategyNull()
        let members = SymbolTable()
        let expected: SymbolType = .traitType(TraitType(
            name: "Foo",
            nameOfTraitObjectType: "__Foo_object",
            nameOfVtableType: "__Foo_vtable",
            symbols: members))
        members.breadcrumb = .traitType("Foo")
        let frame = Frame()
        members.frameLookupMode = .set(frame)
        let memberType: SymbolType = .pointer(.function(FunctionType(returnType: .u8, arguments: [.pointer(expected)])))
        let sizeOfMemoryType = memoryLayoutStrategy.sizeof(type: memberType)
        let offset = frame.allocate(size: sizeOfMemoryType)
        let symbol = Symbol(type: memberType, offset: offset, storage: .automaticStorage)
        frame.add(identifier: "bar", symbol: symbol)
        members.bind(identifier: "bar", symbol: symbol)
        members.parent = nil

        let actual = try scanner.symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(expected, actual)
    }

    func testCompileTraitAddsVtableType_Empty() throws {
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"), members: [])
        
        let scanner = TraitScanner()
        try scanner.scan(trait: ast)
        
        let traitType = try scanner.symbols.resolveType(identifier: "Foo")
        let nameOfVtableType = traitType.unwrapTraitType().nameOfVtableType
        XCTAssertEqual("__Foo_vtable", nameOfVtableType)
    }

    func testCompileTraitAddsVtableType_HasMethod() throws {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.u8), arguments: [
            Expression.PointerType(Expression.Identifier("Foo"))
        ])))
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                   members: [bar],
                                   visibility: .privateVisibility)

        let scanner = TraitScanner()
        try scanner.scan(trait: ast)
        
        let traitType = try scanner.symbols.resolveType(identifier: "Foo")
        let nameOfVtableType = traitType.unwrapTraitType().nameOfVtableType
        XCTAssertEqual("__Foo_vtable", nameOfVtableType)
    }

    func testCompileTraitAddsVtableType_HasConstMethod() throws {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.u8), arguments: [
            Expression.PointerType(Expression.ConstType(Expression.Identifier("Foo")))
        ])))
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                   members: [bar],
                                   visibility: .privateVisibility)

        let scanner = TraitScanner()
        try scanner.scan(trait: ast)
        
        let traitType = try scanner.symbols.resolveType(identifier: "Foo")
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
        
        let scanner = TraitScanner()
        try scanner.scan(trait: ast)
        
        let traitType = try scanner.symbols.resolveType(identifier: "Foo")
        XCTAssertEqual("__Foo_vtable", traitType.unwrapTraitType().nameOfVtableType)
        XCTAssertEqual("__Foo_object", traitType.unwrapTraitType().nameOfTraitObjectType)
    }

    func testCompileTraitAddsTraitObjectType() throws {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.u8), arguments: [
            Expression.PointerType(Expression.Identifier("Foo"))
        ])))
        let ast = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                   members: [bar],
                                   visibility: .privateVisibility)
        
        let scanner = TraitScanner()
        try scanner.scan(trait: ast)
        
        let traitType = try scanner.symbols.resolveType(identifier: "Foo")
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
        
        let scanner = TraitScanner()
        try scanner.scan(trait: ast)
        let actual = try scanner.symbols.resolveType(identifier: "Foo")
        
        let expected = SymbolType.genericTraitType(GenericTraitType(template: ast))
        XCTAssertEqual(expected, actual)
    }

}
