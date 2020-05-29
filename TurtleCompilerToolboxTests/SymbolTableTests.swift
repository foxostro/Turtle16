//
//  SymbolTableTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 5/27/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class SymbolTableTests: XCTestCase {
    func testBindConstantAddress() {
        let symbols = SymbolTable()
        symbols.bindConstantAddress(identifier: "foo", value: 0xffff)
        let symbol = try! symbols.resolve(identifier: "foo")
        switch symbol {
        case .constantAddress(let address):
            XCTAssertEqual(address.value, 0xffff)
        default:
            XCTFail()
        }
    }

    func testBindConstantWord() {
        let symbols = SymbolTable()
        symbols.bindConstantWord(identifier: "foo", value: 0xff)
        let symbol = try! symbols.resolve(identifier: "foo")
        switch symbol {
        case .constantWord(let word):
            XCTAssertEqual(word.value, 0xff)
        default:
            XCTFail()
        }
    }
    
    func testUseOfUnresolvedIdentifier() {
        let symbols = SymbolTable()
        let token = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        XCTAssertThrowsError(try symbols.resolve(identifierToken: token)) {
            let error = $0 as? CompilerError
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.message, "use of unresolved identifier: `foo'")
        }
        XCTAssertThrowsError(try symbols.resolve(identifier: "foo")) {
            let error = $0 as? CompilerError
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.message, "use of unresolved identifier: `foo'")
        }
    }
    
    func testExists() {
        let symbols = SymbolTable()
        XCTAssertFalse(symbols.exists(identifier: "foo"))
        symbols.bindConstantAddress(identifier: "foo", value: 0xffff)
        XCTAssertTrue(symbols.exists(identifier: "foo"))
    }
}
