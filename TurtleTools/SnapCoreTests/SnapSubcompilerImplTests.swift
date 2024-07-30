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
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let symbols = SymbolTable()
        
        func makeImpl() throws {
            let foo = StructDeclaration(
                identifier: Expression.Identifier("Foo"),
                members: [],
                visibility: .privateVisibility)
            _ = try SnapSubcompilerStructDeclaration(
                symbols: symbols,
                globalEnvironment: globalEnvironment)
            .compile(foo)
            
            let functionSymbols = SymbolTable(parent: symbols, frameLookupMode: .set(Frame()))
            
            let functionBodySymbols = SymbolTable(parent: functionSymbols, frameLookupMode: .inherit)
            
            let impl = Impl(
                typeArguments: [],
                structTypeExpr: Expression.Identifier("Foo"),
                children: [
                    FunctionDeclaration(
                        identifier: Expression.Identifier("bar"),
                        functionType: Expression.FunctionType(
                            name: "bar",
                            returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))),
                            arguments: [
                                Expression.PointerType(Expression.Identifier("Foo"))
                            ]),
                        argumentNames: ["baz"],
                        typeArguments: [],
                        body: Block(
                            symbols: functionBodySymbols,
                            children: [
                                Return(Expression.LiteralInt(0))
                            ]),
                        symbols: functionSymbols)
                ])
            _ = try SnapSubcompilerImpl(
                symbols: symbols,
                globalEnvironment: globalEnvironment)
            .compile(impl)
        }
        try makeImpl()
        
        let actualFunType: FunctionType?
        if globalEnvironment.functionsToCompile.isEmpty {
            actualFunType = nil
        }
        else {
            actualFunType = globalEnvironment.functionsToCompile.removeFirst()
        }
        
        XCTAssertEqual(actualFunType?.name, "bar")
        
        let fooType = try symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(actualFunType?.arguments, [.pointer(fooType)])
        
        XCTAssertEqual(actualFunType?.returnType, .arithmeticType(.mutableInt(.u8)))
    }
    
    func testRedefinesExistingSymbol() throws {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let symbols = SymbolTable()
        
        let foo = StructDeclaration(
            identifier: Expression.Identifier("Foo"),
            members: [
                StructDeclaration.Member(
                    name: "bar",
                    type: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))
            ],
            visibility: .privateVisibility)
        _ = try SnapSubcompilerStructDeclaration(
            symbols: symbols,
            globalEnvironment: globalEnvironment)
        .compile(foo)
        
        let functionSymbols = SymbolTable(parent: symbols, frameLookupMode: .set(Frame()))
        
        let functionBodySymbols = SymbolTable(parent: functionSymbols, frameLookupMode: .inherit)
        
        let impl = Impl(
            typeArguments: [],
            structTypeExpr: Expression.Identifier("Foo"),
            children: [
                FunctionDeclaration(
                    identifier: Expression.Identifier("bar"),
                    functionType: Expression.FunctionType(
                        name: "bar",
                        returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))),
                        arguments: [
                            Expression.PointerType(Expression.Identifier("Foo"))
                        ]),
                    argumentNames: ["baz"],
                    typeArguments: [],
                    body: Block(
                        symbols: functionBodySymbols,
                        children: [
                            Return(Expression.LiteralInt(0))
                        ]),
                    symbols: functionSymbols)
            ])
        
        XCTAssertThrowsError(try SnapSubcompilerImpl(symbols: symbols, globalEnvironment: globalEnvironment).compile(impl)) {
            
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "function redefines existing symbol: `bar'")
        }
    }
}
