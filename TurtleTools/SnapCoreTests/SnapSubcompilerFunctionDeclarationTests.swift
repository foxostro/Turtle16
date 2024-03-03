//
//  Subcompiler.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapSubcompilerFunctionDeclarationTests: XCTestCase {
    func testFunctionRedefinesExistingSymbol() throws {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .void))
        let compiler = SnapSubcompilerFunctionDeclaration()
        let input = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                        functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: []),
                                        argumentNames: [],
                                        body: Block(children: []))
        XCTAssertThrowsError(try compiler.compile(globalEnvironment: globalEnvironment, symbols: symbols, node: input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "function redefines existing symbol: `foo\'")
        }
    }
    
    func testFunctionBodyMissingReturn() throws {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let symbols = SymbolTable()
        let compiler = SnapSubcompilerFunctionDeclaration()
        let input = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                        functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: []),
                                        argumentNames: [],
                                        body: Block(children: []))
        XCTAssertThrowsError(try compiler.compile(globalEnvironment: globalEnvironment, symbols: symbols, node: input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "missing return in a function expected to return `u8'")
        }
    }
    
    func testDeclareFunction() throws {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let symbols = SymbolTable()
        let originalBody = Block(children: [])
        let expectedRewrittenBody = Block(children: [Return()])
        let input = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                        functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.void), arguments: []),
                                        argumentNames: [],
                                        body: originalBody)
        let functionType = FunctionType(name: "foo",
                                        mangledName: "foo",
                                        returnType: .void,
                                        arguments: [],
                                        ast: input.withBody(expectedRewrittenBody))
        let expected = Symbol(type: .function(functionType),
                              offset: 0,
                              storage: .automaticStorage)
        try SnapSubcompilerFunctionDeclaration()
            .compile(globalEnvironment: globalEnvironment,
                     symbols: symbols,
                     node: input)
        let actual = try symbols.resolve(identifier: "foo")
        XCTAssertEqual(actual, expected)
    }
    
    func testCompilationFailsBecauseCodeAfterReturnWillNeverBeExecuted() {
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let symbols = SymbolTable()
        let compiler = SnapSubcompilerFunctionDeclaration()
        let input = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                        functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))), arguments: []),
                                        argumentNames: [],
                                        body: Block(children: [
                                            Return(Expression.LiteralBool(true)),
                                            Expression.LiteralBool(false)
                                        ]))
        XCTAssertThrowsError(try compiler.compile(globalEnvironment: globalEnvironment, symbols: symbols, node: input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "code after return will never be executed")
        }
    }
    
    func testDeclareGenericFunction() throws {
        let functionType = Expression.FunctionType(name: "foo",
                                                   returnType: Expression.Identifier("T"),
                                                   arguments: [Expression.Identifier("T")])
        let input = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                        functionType: functionType,
                                        argumentNames: ["a"],
                                        typeArguments: [Expression.GenericTypeArgument(identifier: Expression.Identifier("T"), constraints: [])],
                                        body: Block(children: [
                                            Return(Expression.Identifier("a"))
                                        ]),
                                        visibility: .privateVisibility,
                                        symbols: SymbolTable())
        let globalEnvironment = GlobalEnvironment(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
        let symbols = SymbolTable()
        try SnapSubcompilerFunctionDeclaration()
            .compile(globalEnvironment: globalEnvironment,
                     symbols: symbols,
                     node: input)
        let actualSymbol = try symbols.resolve(identifier: "foo")
        let actualType = actualSymbol.type
        let expectedType = SymbolType.genericFunction(Expression.GenericFunctionType(template: input))
        XCTAssertEqual(actualType, expectedType)
    }
}
