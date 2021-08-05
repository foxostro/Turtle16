//
//  SnapAbstractSyntaxTreeCompilerDeclPassTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapAbstractSyntaxTreeCompilerDeclPassTests: XCTestCase {
    func makeCompiler() -> SnapAbstractSyntaxTreeCompilerDeclPass {
        return SnapAbstractSyntaxTreeCompilerDeclPass(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
    }
    
    func testExample() throws {
        let compiler = makeCompiler()
        let result = try? compiler.compile(CommentNode(string: "foo"))
        XCTAssertEqual(result, CommentNode(string: "foo"))
    }
    
    func testFunctionDeclaration() throws {
        let globalSymbols = SymbolTable()
        let input = Block(symbols: globalSymbols, children: [
            FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                            functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                            argumentNames: [],
                                            body: Block(children: []))
        ])
        
        let compiler = makeCompiler()
        let result = try? compiler.compile(input)
        XCTAssertEqual(result, input)
        
        let actual = try? globalSymbols.resolve(identifier: "foo")
        let expected = Symbol(type: .function(FunctionType(name: "foo", returnType: .u8, arguments: [])), offset: 0, storage: .automaticStorage)
        XCTAssertEqual(actual, expected)
    }
    
    func testStructDeclaration() throws {
        let globalSymbols = SymbolTable()
        let input = Block(symbols: globalSymbols, children: [
            StructDeclaration(identifier: Expression.Identifier("None"), members: [])
        ])
        
        let expected = Block(symbols: globalSymbols, children: []) // StructDeclaration is removed after being processed
        let compiler = makeCompiler()
        let result = try? compiler.compile(input)
        XCTAssertEqual(result, expected)
        
        let expectedStructSymbols = SymbolTable()
        expectedStructSymbols.enclosingFunctionName = "None"
        let expectedType: SymbolType = .structType(StructType(name: "None", symbols: expectedStructSymbols))
        let actualType = try? globalSymbols.resolveType(identifier: "None")
        XCTAssertEqual(actualType, expectedType)
    }
    
    func testTypealias() throws {
        let globalSymbols = SymbolTable()
        let input = Block(symbols: globalSymbols, children: [
            Typealias(lexpr: Expression.Identifier("Foo"), rexpr: Expression.PrimitiveType(.u8))
        ])
        
        let expected = Block(symbols: globalSymbols, children: []) // Typealias is removed after being processed
        let compiler = makeCompiler()
        let result = try? compiler.compile(input)
        XCTAssertEqual(result, expected)
        
        let expectedType: SymbolType = .u8
        let actualType = try? globalSymbols.resolveType(identifier: "Foo")
        XCTAssertEqual(actualType, expectedType)
    }
    
    func testTraitDeclaration() throws {
        let globalSymbols = SymbolTable()
        let input = Block(symbols: globalSymbols, children: [
            TraitDeclaration(identifier: Expression.Identifier("Foo"), members: [])
        ])
        
        let compiler = makeCompiler()
        XCTAssertNoThrow(try compiler.compile(input))
        
        let expectedSymbols = SymbolTable()
        expectedSymbols.enclosingFunctionName = "Foo"
        let expectedType: SymbolType = .traitType(TraitType(name: "Foo", nameOfTraitObjectType: "__Foo_object", nameOfVtableType: "__Foo_vtable", symbols: expectedSymbols))
        let actualType = try? globalSymbols.resolveType(identifier: "Foo")
        XCTAssertEqual(expectedType, actualType)
    }
}
