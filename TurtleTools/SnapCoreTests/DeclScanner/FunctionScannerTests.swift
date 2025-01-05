//
//  FunctionScannerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/15/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

final class FunctionScannerTests: XCTestCase {
    func testFunctionRedefinesExistingSymbol() throws {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .void))
        
        let input = FunctionDeclaration(
            identifier: Expression.Identifier("foo"),
            functionType: Expression.FunctionType(
                name: "foo",
                returnType: Expression.PrimitiveType(.u8),
                arguments: []),
            argumentNames: [],
            body: Block(children: []))
            .reconnect(parent: nil)
        
        let scanner = FunctionScanner(symbols: symbols)
        XCTAssertThrowsError(try scanner.scan(func: input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "function redefines existing symbol: `foo\'")
        }
    }
    
    func testFunctionRedefinesExistingType() throws {
        let symbols = SymbolTable()
        symbols.bind(
            identifier: "foo",
            symbolType: .bool,
            visibility: .privateVisibility)
        
        let input = FunctionDeclaration(
            identifier: Expression.Identifier("foo"),
            functionType: Expression.FunctionType(
                name: "foo",
                returnType: Expression.PrimitiveType(.u8),
                arguments: []),
            argumentNames: [],
            body: Block(children: []))
            .reconnect(parent: nil)
        
        let scanner = FunctionScanner(symbols: symbols)
        XCTAssertThrowsError(try scanner.scan(func: input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "function redefines existing type: `foo\'")
        }
    }
    
    func testDeclareFunction() throws {
        let input = FunctionDeclaration(
            identifier: Expression.Identifier("foo"),
            functionType: Expression.FunctionType(
                name: "foo",
                returnType: Expression.PrimitiveType(.void),
                arguments: []),
            argumentNames: [],
            body: Block(children: []))
            .reconnect(parent: nil)
        let functionType = FunctionType(
            name: "foo",
            mangledName: "foo",
            returnType: .void,
            arguments: [],
            ast: input)
        let expected = Symbol(
            type: .function(functionType),
            offset: 0,
            storage: .automaticStorage)
        let scanner = FunctionScanner()
        try scanner.scan(func: input)
        let actual = try scanner.symbols.resolve(identifier: "foo")
        XCTAssertEqual(actual, expected)
    }
    
    func testDeclareGenericFunction() throws {
        let functionType = Expression.FunctionType(
            name: "foo",
            returnType: Expression.Identifier("T"),
            arguments: [Expression.Identifier("T")])
        let input = FunctionDeclaration(
            identifier: Expression.Identifier("foo"),
            functionType: functionType,
            argumentNames: ["a"],
            typeArguments: [Expression.GenericTypeArgument(
                identifier: Expression.Identifier("T"),
                constraints: [])],
            body: Block(children: [
                Return(Expression.Identifier("a"))
            ]),
            visibility: .privateVisibility,
            symbols: SymbolTable())
            .reconnect(parent: nil)
        let scanner = FunctionScanner()
        try scanner.scan(func: input)
        let actualSymbol = try scanner.symbols.resolve(identifier: "foo")
        let actualType = actualSymbol.type
        let expectedType = SymbolType.genericFunction(Expression.GenericFunctionType(template: input))
        XCTAssertEqual(actualType, expectedType)
    }
}
