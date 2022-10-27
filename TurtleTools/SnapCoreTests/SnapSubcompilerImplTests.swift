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
        let globalEnvironment = GlobalEnvironment()
        
        func makeImpl() throws -> (Impl, SymbolTable) {
            let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [
                Expression.PointerType(Expression.Identifier("Foo"))
            ])))
            let foo = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                       members: [bar],
                                       visibility: .privateVisibility)
            
            let symbols = SymbolTable()
            
            let traitCompiler = SnapSubcompilerTraitDeclaration(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL(), symbols: symbols)
            let seq = try traitCompiler.compile(foo)
            
            let structCompiler0 = SnapSubcompilerStructDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
            _ = try structCompiler0.compile(seq.children[0] as! StructDeclaration)
            
            let structCompiler1 = SnapSubcompilerStructDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
            _ = try structCompiler1.compile(seq.children[1] as! StructDeclaration)
            
            let impl = seq.children[2] as! Impl
            
            return (impl, symbols)
        }
        
        func makeExpectedMethodType(symbols: SymbolTable, globalEnvironment: GlobalEnvironment) -> FunctionType {
            let argTypeExpr = Expression.PointerType(Expression.Identifier("__Foo_object"))
            let argType = try! RvalueExpressionTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment).check(expression: argTypeExpr)
            let expectedMethodType = FunctionType(name: "bar",
                                                  mangledName: "____Foo_object_bar",
                                                  returnType: .arithmeticType(.mutableInt(.u8)),
                                                  arguments: [argType])
            return expectedMethodType
        }
        
        let (impl, symbols) = try makeImpl()
        
        try SnapSubcompilerImpl(symbols: symbols, globalEnvironment: globalEnvironment).compile(impl)
        
        XCTAssertFalse(globalEnvironment.functionsToCompile.isEmpty)
        guard !globalEnvironment.functionsToCompile.isEmpty else {
            return
        }
        
        let methodType = globalEnvironment.functionsToCompile.removeFirst()
        let expectedMethodType = makeExpectedMethodType(symbols: symbols, globalEnvironment: globalEnvironment)
        XCTAssertEqual(methodType, expectedMethodType)
    }
    
    func testRedefinesExistingSymbol() throws {
        let globalEnvironment = GlobalEnvironment()
        
        func makeImpl() throws -> (Impl, SymbolTable) {
            let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(Expression.FunctionType(name: nil, returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: [
                Expression.PointerType(Expression.Identifier("Foo"))
            ])))
            let foo = TraitDeclaration(identifier: Expression.Identifier("Foo"),
                                       members: [bar, bar],
                                       visibility: .privateVisibility)
            
            let symbols = SymbolTable()
            
            let traitCompiler = SnapSubcompilerTraitDeclaration(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL(), symbols: symbols)
            let seq = try traitCompiler.compile(foo)
            
            let structCompiler0 = SnapSubcompilerStructDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
            _ = try structCompiler0.compile(seq.children[0] as! StructDeclaration)
            
            let structCompiler1 = SnapSubcompilerStructDeclaration(symbols: symbols, globalEnvironment: globalEnvironment)
            _ = try structCompiler1.compile(seq.children[1] as! StructDeclaration)
            
            let impl = seq.children[2] as! Impl
            
            return (impl, symbols)
        }
        
        let (impl, symbols) = try makeImpl()
        
    
        let compiler = SnapSubcompilerImpl(symbols: symbols, globalEnvironment: globalEnvironment)
        
        XCTAssertThrowsError(try compiler.compile(impl)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "function redefines existing symbol: `bar\'")
        }
    }
}
