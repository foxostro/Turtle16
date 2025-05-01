//
//  FunctionScannerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/15/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class FunctionScannerTests: XCTestCase {
    func testFunctionRedefinesExistingSymbol() throws {
        let symbols = Env()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .void))

        let input = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: FunctionType(
                name: "foo",
                returnType: PrimitiveType(.u8),
                arguments: []
            ),
            argumentNames: [],
            body: Block(children: [])
        )
        .reconnect(parent: nil)

        let scanner = FunctionScanner(symbols: symbols)
        XCTAssertThrowsError(try scanner.scan(func: input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "function redefines existing symbol: `foo\'")
        }
    }

    func testFunctionRedefinesExistingType() throws {
        let symbols = Env()
        symbols.bind(
            identifier: "foo",
            symbolType: .bool,
            visibility: .privateVisibility
        )

        let input = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: FunctionType(
                name: "foo",
                returnType: PrimitiveType(.u8),
                arguments: []
            ),
            argumentNames: [],
            body: Block(children: [])
        )
        .reconnect(parent: nil)

        let scanner = FunctionScanner(symbols: symbols)
        XCTAssertThrowsError(try scanner.scan(func: input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "function redefines existing type: `foo\'")
        }
    }

    func testDeclareFunction() throws {
        let input = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: FunctionType(
                name: "foo",
                returnType: PrimitiveType(.void),
                arguments: []
            ),
            argumentNames: [],
            body: Block(children: [])
        )
        .reconnect(parent: nil)
        let functionType = FunctionTypeInfo(
            name: "foo",
            mangledName: "foo",
            returnType: .void,
            arguments: [],
            ast: input
        )
        let expected = Symbol(
            type: .function(functionType),
            storage: .automaticStorage(offset: 0)
        )
        let scanner = FunctionScanner()
        try scanner.scan(func: input)
        let actual = try scanner.symbols.resolve(identifier: "foo")
        XCTAssertEqual(actual, expected)
    }

    func testDeclareGenericFunction() throws {
        let functionType = FunctionType(
            name: "foo",
            returnType: Identifier("T"),
            arguments: [Identifier("T")]
        )
        let input = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: functionType,
            argumentNames: ["a"],
            typeArguments: [
                GenericTypeArgument(
                    identifier: Identifier("T"),
                    constraints: []
                )
            ],
            body: Block(children: [
                Return(Identifier("a"))
            ]),
            visibility: .privateVisibility,
            symbols: Env()
        )
        .reconnect(parent: nil)
        let scanner = FunctionScanner()
        try scanner.scan(func: input)
        let actualSymbol = try scanner.symbols.resolve(identifier: "foo")
        let actualType = actualSymbol.type
        let expectedType = SymbolType.genericFunction(GenericFunctionType(template: input))
        XCTAssertEqual(actualType, expectedType)
    }
}
