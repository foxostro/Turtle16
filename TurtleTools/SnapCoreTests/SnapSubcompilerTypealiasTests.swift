//
//  SnapSubcompilerTypealiasTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapSubcompilerTypealiasTests: XCTestCase {
    func testDeclareTypealias() throws {
        let input = Typealias(lexpr: Expression.Identifier("Foo"), rexpr: Expression.PrimitiveType(.u8))
        let symbols = SymbolTable()
        let result = try? SnapSubcompilerTypealias(symbols).compile(input)
        XCTAssertEqual(result, nil) // Typealias is removed after being processed
        let expectedType: SymbolType = .u8
        let actualType = try? symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(actualType, expectedType)
    }
    
    func testTypealiascannotRedefineExistingType() throws {
        let input = Typealias(lexpr: Expression.Identifier("Foo"), rexpr: Expression.PrimitiveType(.u8))
        let symbols = SymbolTable()
        symbols.bind(identifier: "Foo", symbolType: .u8)
        XCTAssertThrowsError(try SnapSubcompilerTypealias(symbols).compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "typealias redefines existing type: `Foo'")
        }
    }
}
