//
//  SnapSubcompilerImplTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/4/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapSubcompilerImplTests: XCTestCase {
    func testExample() throws {
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
        
        let memoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()
        let compiler = SnapSubcompilerImpl(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols)
        var output: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(output = try compiler.compile(impl))
        
        guard let block = output as? Block else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(block.children.count, 1)
        
        guard let method = block.children.first as? FunctionDeclaration else {
            XCTFail()
            return
        }
        
        let expectedMethod = makeExpectedMethod()
        
        XCTAssertEqual(method, expectedMethod)
    }
    
    func testRedefinesExistingSymbol() throws {
        func makeImpl() throws -> (Impl, SymbolTable) {
            let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.u8), arguments: [
                Expression.PointerType(Expression.Identifier("Foo"))
            ])))
            let foo = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                       members: [bar, bar],
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
        
        let (impl, symbols) = try makeImpl()
        
        let memoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()
        let compiler = SnapSubcompilerImpl(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols)
        
        XCTAssertThrowsError(try compiler.compile(impl)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "function redefines existing symbol: `bar\'")
        }
    }
}
