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
        expectedSymbols.enclosingFunctionName = "Foo"
        let expected: SymbolType = .traitType(TraitType(name: "Foo", nameOfTraitObjectType: "__Foo_object", nameOfVtableType: "__Foo_vtable", symbols: expectedSymbols))
        let actual = try? globalSymbols.resolveType(identifier: "Foo")
        XCTAssertEqual(expected, actual)
    }
    
    func testCompileTraitAddsToTypeTable_HasMethod() {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.u8), arguments: [
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
        members.enclosingFunctionName = "Foo"
        let memberType: SymbolType = .pointer(.function(FunctionType(returnType: .u8, arguments: [.pointer(expected)])))
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
        XCTAssertEqual(result?.first, expected)
    }

    func testCompileTraitAddsVtableType_HasMethod() {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.u8), arguments: [
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
                                            StructDeclaration.Member(name: "bar", type: Expression.PointerType(Expression.FunctionType(returnType: Expression.PrimitiveType(.u8), arguments: [Expression.PointerType(Expression.PrimitiveType(.void))])))
                                         ],
                                         visibility: .privateVisibility,
                                         isConst: true)
        XCTAssertEqual(result?.first, expected)
    }

    func testCompileTraitAddsVtableType_HasConstMethod() {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.u8), arguments: [
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
                                            StructDeclaration.Member(name: "bar", type: Expression.PointerType(Expression.FunctionType(returnType: Expression.PrimitiveType(.u8), arguments: [Expression.PointerType(Expression.PrimitiveType(.void))])))
                                         ],
                                         visibility: .privateVisibility,
                                         isConst: true)
        XCTAssertEqual(result?.first, expected)
    }

    func testCompileTraitAddsTraitObjectType() {
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.u8), arguments: [
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
        
        let expected: [AbstractSyntaxTreeNode] = [
            StructDeclaration(identifier: Expression.Identifier("__Foo_vtable"),
                                             members: [
                                                StructDeclaration.Member(name: "bar", type: Expression.PointerType(Expression.FunctionType(returnType: Expression.PrimitiveType(.u8), arguments: [Expression.PointerType(Expression.PrimitiveType(.void))])))
                                             ],
                                             visibility: .privateVisibility,
                                             isConst: true),
            StructDeclaration(identifier: Expression.Identifier("__Foo_object"),
                                             members: [
                                                StructDeclaration.Member(name: "object", type: Expression.PointerType(Expression.PrimitiveType(.void))),
                                                StructDeclaration.Member(name: "vtable", type: Expression.PointerType(Expression.ConstType(Expression.Identifier("__Foo_vtable"))))
                                             ],
                                             visibility: .privateVisibility)
        ]
        XCTAssertEqual(result, expected)
    }
}
