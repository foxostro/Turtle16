//
//  SnapSubcompilerFunctionDeclarationTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class SnapSubcompilerFunctionDeclarationTests: XCTestCase {
    func testFunctionRedefinesExistingSymbol() throws {
        let symbols = Env()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .void))
        let compiler = SnapSubcompilerFunctionDeclaration()
        let input = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: FunctionType(name: "foo", returnType: PrimitiveType(.u8), arguments: []),
            argumentNames: [],
            body: Block(children: [])
        )
        .reconnect(parent: nil)
        XCTAssertThrowsError(try compiler.compile(symbols: symbols, node: input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "function redefines existing symbol: `foo\'")
        }
    }

    func testFunctionBodyMissingReturn() throws {
        let symbols = Env()
        let compiler = SnapSubcompilerFunctionDeclaration()
        let input = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: FunctionType(name: "foo", returnType: PrimitiveType(.u8), arguments: []),
            argumentNames: [],
            body: Block(children: [])
        )
        .reconnect(parent: nil)
        XCTAssertThrowsError(try compiler.compile(symbols: symbols, node: input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "missing return in a function expected to return `u8'"
            )
        }
    }

    func testDeclareFunction() throws {
        let symbols = Env()
        let originalBody = Block(children: [])
        let expectedRewrittenBody = Block(children: [Return()])
        let input = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: FunctionType(
                name: "foo",
                returnType: PrimitiveType(.void),
                arguments: []
            ),
            argumentNames: [],
            body: originalBody
        )
        .reconnect(parent: nil)
        let functionType = FunctionTypeInfo(
            name: "foo",
            mangledName: "foo",
            returnType: .void,
            arguments: [],
            ast: input.withBody(expectedRewrittenBody)
        )
        let expected = Symbol(
            type: .function(functionType),
            storage: .automaticStorage(offset: 0)
        )
        try SnapSubcompilerFunctionDeclaration().compile(symbols: symbols, node: input)
        let actual = try symbols.resolve(identifier: "foo")
        XCTAssertEqual(actual, expected)
    }

    func testCompilationFailsBecauseCodeAfterReturnWillNeverBeExecuted() {
        let symbols = Env()
        let compiler = SnapSubcompilerFunctionDeclaration()
        let input = FunctionDeclaration(
            identifier: Identifier("foo"),
            functionType: FunctionType(name: "foo", returnType: PrimitiveType(.u8), arguments: []),
            argumentNames: [],
            body: Block(children: [
                Return(LiteralBool(true)),
                LiteralBool(false)
            ])
        )
        .reconnect(parent: nil)
        XCTAssertThrowsError(try compiler.compile(symbols: symbols, node: input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "code after return will never be executed")
        }
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
            typeArguments: [GenericTypeArgument(identifier: Identifier("T"), constraints: [])],
            body: Block(children: [
                Return(Identifier("a"))
            ]),
            visibility: .privateVisibility,
            symbols: Env()
        )
        .reconnect(parent: nil)
        let symbols = Env()
        try SnapSubcompilerFunctionDeclaration().compile(symbols: symbols, node: input)
        let actualSymbol = try symbols.resolve(identifier: "foo")
        let actualType = actualSymbol.type
        let expectedType = SymbolType.genericFunction(GenericFunctionType(template: input))
        XCTAssertEqual(actualType, expectedType)
    }
}
