//
//  CompilerPassWithDeclScanTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/18/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import SnapCore

final class CompilerPassWithDeclScanTests: XCTestCase {
    func testInit() {
        let _ = CompilerPassWithDeclScan()
    }
    
    func testPassesProgramThroughUnmodified() throws {
        let compiler = CompilerPassWithDeclScan()
        let result = try compiler.run(CommentNode(string: "foo"))
        XCTAssertEqual(result, CommentNode(string: "foo"))
    }
    
    func testFunctionDeclaration() throws {
        let symbols = SymbolTable()
        let originalFunctionDeclaration = FunctionDeclaration(
            identifier: Expression.Identifier("foo"),
            functionType: Expression.FunctionType(
                name: "foo",
                returnType: Expression.PrimitiveType(.void),
                arguments: []),
            argumentNames: [],
            body: Block(children: []))
        let input = Block(symbols: symbols, children: [
            originalFunctionDeclaration
        ])
            .reconnect(parent: nil)
        
        let expectedRewrittenFunctionDeclaration = originalFunctionDeclaration
            .withBody(Block(children: [
                Return()
            ]))
        let expectedFunctionType = FunctionType(
            name: "foo",
            mangledName: "foo",
            returnType: .void,
            arguments: [],
            ast: expectedRewrittenFunctionDeclaration)
        let expected = Symbol(
            type: .function(expectedFunctionType),
            offset: 0,
            storage: .automaticStorage)
        
        let compiler = CompilerPassWithDeclScan()
        _ = try compiler.visit(input)
        let actual = try symbols.resolve(identifier: "foo")
        XCTAssertEqual(actual, expected)
    }
    
    func testStructDeclaration() throws {
        let symbols = SymbolTable()
        let input = Block(symbols: symbols, children: [
            StructDeclaration(identifier: Expression.Identifier("None"), members: [])
        ])
        
        let compiler = CompilerPassWithDeclScan()
        let result = try compiler.run(input)
        XCTAssertEqual(result, input)
        
        let expectedStructSymbols = SymbolTable()
        expectedStructSymbols.frameLookupMode = .set(Frame())
        expectedStructSymbols.enclosingFunctionNameMode = .set("None")
        let expectedType: SymbolType = .structType(StructType(name: "None", symbols: expectedStructSymbols))
        let actualType = try symbols.resolveType(identifier: "None")
        XCTAssertEqual(actualType, expectedType)
    }
    
    func testTypealias() throws {
        let symbols = SymbolTable()
        let input = Block(symbols: symbols, children: [
            Typealias(lexpr: Expression.Identifier("Foo"), rexpr: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
        ])
        
        let compiler = CompilerPassWithDeclScan()
        let result = try compiler.run(input)
        XCTAssertEqual(result, input)
        
        let expectedType: SymbolType = .arithmeticType(.mutableInt(.u8))
        let actualType = try? symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(actualType, expectedType)
    }
    
    func testTraitDeclaration() throws {
        let symbols = SymbolTable()
        
        let input = Block(symbols: symbols, children: [
            TraitDeclaration(identifier: Expression.Identifier("Foo"), members: [])
        ])
        
        let compiler = CompilerPassWithDeclScan()
        _ = try compiler.run(input)
        
        let expectedSymbols = SymbolTable()
        expectedSymbols.frameLookupMode = .set(Frame())
        expectedSymbols.enclosingFunctionNameMode = .set("Foo")
        let expectedType: SymbolType = .traitType(TraitType(name: "Foo", nameOfTraitObjectType: "__Foo_object", nameOfVtableType: "__Foo_vtable", symbols: expectedSymbols))
        let actualType = try? symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(expectedType, actualType)
    }
    
    func testImportingAModuleCausesItToExportPublicSymbols() throws {
        let globalEnvironment = GlobalEnvironment()
        let symbols = SymbolTable()
        let ast0 = Block(symbols: symbols, children: [
            Import(moduleName: "Foo")
        ])
        let ast1 = try ast0.importPass(
            injectModules: [("Foo", "public struct None {}\n")],
            globalEnvironment: globalEnvironment)
        
        let compiler = CompilerPassWithDeclScan(globalEnvironment)
        let ast2 = try compiler.run(ast1)
        
        XCTAssertEqual(ast2, ast1)
        XCTAssertTrue(symbols.modulesAlreadyImported.contains("Foo"))
        XCTAssertNoThrow(try symbols.resolveType(identifier: "None"))
    }
}
