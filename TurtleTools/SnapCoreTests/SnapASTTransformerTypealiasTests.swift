//
//  SnapASTTransformerTypealiasTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapASTTransformerTypealiasTests: XCTestCase {
    func testIgnoresUnrecognizedNodes() throws {
        let symbols = SymbolTable()
        let result = try? SnapASTTransformerTypealias(symbols).compile(CommentNode(string: ""))
        XCTAssertEqual(result, CommentNode(string: ""))
    }
    
    func testDeclareTypealias() throws {
        let input = Typealias(lexpr: Expression.Identifier("Foo"), rexpr: Expression.PrimitiveType(.u8))
        let symbols = SymbolTable()
        let result = try? SnapASTTransformerTypealias(symbols).compile(input)
        XCTAssertEqual(result, input)
        let expectedType: SymbolType = .u8
        let actualType = try? symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(actualType, expectedType)
    }
    
    func testTypealiascannotRedefineExistingType() throws {
        let input = Typealias(lexpr: Expression.Identifier("Foo"), rexpr: Expression.PrimitiveType(.u8))
        let symbols = SymbolTable()
        symbols.bind(identifier: "Foo", symbolType: .u8)
        XCTAssertThrowsError(try SnapASTTransformerTypealias(symbols).compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "typealias redefines existing type: `Foo'")
        }
    }
}
