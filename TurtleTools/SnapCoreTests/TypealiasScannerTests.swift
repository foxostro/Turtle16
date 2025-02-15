//
//  TypealiasScannerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

final class TypealiasScannerTests: XCTestCase {
    func testDeclareTypealias() throws {
        let input = Typealias(lexpr: Identifier("Foo"), rexpr: PrimitiveType(.u8))
        let symbols = Env()
        try TypealiasScanner(symbols).compile(input)
        let expectedType: SymbolType = .u8
        let actualType = try? symbols.resolveType(identifier: "Foo")
        XCTAssertEqual(actualType, expectedType)
    }
    
    func testTypealiascannotRedefineExistingSymbol() throws {
        let input = Typealias(lexpr: Identifier("Foo"), rexpr: PrimitiveType(.u8))
        let symbols = Env()
        symbols.bind(identifier: "Foo", symbol: Symbol(type: .void, offset: nil, storage: .staticStorage, visibility: .privateVisibility))
        symbols.bind(identifier: "Foo", symbolType: .u8)
        XCTAssertThrowsError(try TypealiasScanner(symbols).compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "typealias redefines existing symbol: `Foo'")
        }
    }
    
    func testTypealiascannotRedefineExistingType() throws {
        let input = Typealias(lexpr: Identifier("Foo"), rexpr: PrimitiveType(.u8))
        let symbols = Env()
        symbols.bind(identifier: "Foo", symbolType: .u8)
        XCTAssertThrowsError(try TypealiasScanner(symbols).compile(input)) {
            let error = $0 as? CompilerError
            XCTAssertEqual(error?.message, "typealias redefines existing type: `Foo'")
        }
    }
}
