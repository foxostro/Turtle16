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
        expectedStructSymbols.enclosingFunctionNameMode = .set("None")
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
        expectedSymbols.enclosingFunctionNameMode = .set("Foo")
        let expectedType: SymbolType = .traitType(TraitType(name: "Foo", nameOfTraitObjectType: "__Foo_object", nameOfVtableType: "__Foo_vtable", symbols: expectedSymbols))
        let actualType = try? globalSymbols.resolveType(identifier: "Foo")
        XCTAssertEqual(expectedType, actualType)
    }
    
    func testModule() throws {
        let globalSymbols = SymbolTable()
        let input = Block(symbols: globalSymbols, children: [
            Module(name: "Foo", children: [
                FunctionDeclaration(identifier: Expression.Identifier("puts"), functionType: Expression.FunctionType(name: "puts", returnType: Expression.PrimitiveType(.void), arguments: [Expression.DynamicArrayType(Expression.PrimitiveType(.u8))]), argumentNames: ["s"], body: Block(children: []), visibility: .publicVisibility)
            ])
        ])
        
        let compiler = makeCompiler()
        let result = try? compiler.compile(input)
        let moduleOutput = (result as? Block)?.children.first as? Module
        
        XCTAssertTrue(globalSymbols.symbolTable.isEmpty)
        XCTAssertTrue(globalSymbols.existsAsModule(identifier: "Foo"))
        XCTAssertFalse(globalSymbols.modulesAlreadyImported.contains("Foo"))
        let puts = try? moduleOutput?.symbols.resolve(identifier: "puts")
        XCTAssertNotNil(puts)
    }
    
    func testImportStdlib() throws {
        let globalSymbols = SymbolTable()
        let input = Block(symbols: globalSymbols, children: [
            Import(moduleName: kStandardLibraryModuleName)
        ])
        let compiler = makeCompiler()
        let output = try compiler.compile(input)
        XCTAssertNotNil(output)
        XCTAssertTrue(globalSymbols.existsAsModule(identifier: kStandardLibraryModuleName))
        XCTAssertTrue(globalSymbols.modulesAlreadyImported.contains(kStandardLibraryModuleName))
        XCTAssertNotNil(try? globalSymbols.resolve(identifier: "panic"))
    }
    
    func testImpl() throws {
        func makeImpl() throws -> (Impl, SymbolTable) {
            let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.u8), arguments: [
                Expression.PointerType(Expression.Identifier("Foo"))
            ])))
            let foo = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                       members: [bar],
                                       visibility: .privateVisibility)
            
            let symbols = SymbolTable()
            
            let traitCompiler = SnapSubcompilerTraitDeclaration(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL(), symbols: symbols)
            let seq = try traitCompiler.compile(foo)
            
            let structCompiler0 = SnapSubcompilerStructDeclaration(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL(), symbols: symbols)
            _ = try structCompiler0.compile(seq.children[0] as! StructDeclaration)
            
            let structCompiler1 = SnapSubcompilerStructDeclaration(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL(), symbols: symbols)
            _ = try structCompiler1.compile(seq.children[1] as! StructDeclaration)
            
            let impl = seq.children[2] as! Impl
            
            return (impl, symbols)
        }
        
        func makeExpectedMethod() -> FunctionDeclaration {
            let expectedMethod = FunctionDeclaration(identifier: Expression.Identifier("bar"),
                                                     functionType: Expression.FunctionType(name: "bar", returnType: Expression.PrimitiveType(.u8), arguments: [Expression.PointerType(Expression.Identifier("__Foo_object"))]),
                                                     argumentNames: ["self"],
                                                     body: Block(children: [
                                                      Return(Expression.Call(callee: Expression.Get(expr: Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("vtable")), member: Expression.Identifier("bar")), arguments: [Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("object"))]))
                                                     ]))
            let implSymbols = SymbolTable()
            implSymbols.enclosingFunctionNameMode = .set("Foo")
            SymbolTablesReconnector(implSymbols).reconnect(expectedMethod)
            return expectedMethod
        }
        
        let (impl, symbols) = try makeImpl()
        let input = Block(symbols: symbols, children: [impl])
        
        let compiler = makeCompiler()
        var output: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(output = try compiler.compile(input))
        
        guard let outerBlock = output as? Block else {
            XCTFail()
            return
        }
        
        guard let innerBlock = outerBlock.children.first as? Block else {
            XCTFail()
            return
        }
        
        guard let method = innerBlock.children.first as? FunctionDeclaration else {
            XCTFail()
            return
        }
        
        let expectedMethod = makeExpectedMethod()
        
        XCTAssertEqual(method, expectedMethod)
    }
}
