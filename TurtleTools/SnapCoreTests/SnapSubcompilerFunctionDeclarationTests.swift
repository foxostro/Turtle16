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
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .void))
        let compiler = SnapSubcompilerFunctionDeclaration(symbols)
        let input = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                        functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                        argumentNames: [],
                                        body: Block(children: []))
        XCTAssertThrowsError(try compiler.compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "function redefines existing symbol: `foo\'")
        }
    }
    
    func testDeclareFunction() throws {
        let symbols = SymbolTable()
        let compiler = SnapSubcompilerFunctionDeclaration(symbols)
        let input = FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                        functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                        argumentNames: [],
                                        body: Block(children: []))
        XCTAssertNoThrow(try compiler.compile(input))
        let actual = try? symbols.resolve(identifier: "foo")
        let expected = Symbol(type: .function(FunctionType(name: "foo", returnType: .u8, arguments: [])), offset: 0, storage: .automaticStorage)
        XCTAssertEqual(actual, expected)
    }
}
