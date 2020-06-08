//
//  SymbolTableTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/27/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class SymbolTableTests: XCTestCase {
    func testEquatableSymbols() {
        XCTAssertNotEqual(Symbol(type: .u8, offset: 0x10, isMutable: true),
                          Symbol(type: .boolean, offset: 0x10, isMutable: true))
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
    
    func testSuccessfullyResolveAnIdentifierByToken() {
        let symbols = SymbolTable()
        let token = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        symbols.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: 0x10, isMutable: true))
        let symbol = try! symbols.resolve(identifierToken: token)
        switch symbol.type {
        case .boolean, .u8:
            XCTAssertEqual(symbol.offset, 0x10)
            XCTAssertEqual(symbol.isMutable, true)
        }
    }
    
    func testExists() {
        let symbols = SymbolTable()
        XCTAssertFalse(symbols.exists(identifier: "foo"))
        symbols.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: 0x10, isMutable: true))
        XCTAssertTrue(symbols.exists(identifier: "foo"))
    }

    func testBindWord_Static_Mutable() {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: 0x10, isMutable: true))
        let symbol = try! symbols.resolve(identifier: "foo")
        switch symbol.type {
        case .u8:
            XCTAssertEqual(symbol.offset, 0x10)
            XCTAssertTrue(symbol.isMutable)
        default:
            XCTFail()
        }
    }

    func testBindWord_Static_Immutable() {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: 0x10, isMutable: false))
        let symbol = try! symbols.resolve(identifier: "foo")
        switch symbol.type {
        case .u8:
            XCTAssertEqual(symbol.offset, 0x10)
            XCTAssertFalse(symbol.isMutable)
        default:
            XCTFail()
        }
    }

    func testBindBoolean_Static_Mutable() {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .boolean, offset: 0x10, isMutable: true))
        let symbol = try! symbols.resolve(identifier: "foo")
        switch symbol.type {
        case .boolean:
            XCTAssertEqual(symbol.offset, 0x10)
            XCTAssertTrue(symbol.isMutable)
        default:
            XCTFail()
        }
    }

    func testBindBoolean_Static_Immutable() {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .boolean, offset: 0x10, isMutable: false))
        let symbol = try! symbols.resolve(identifier: "foo")
        switch symbol.type {
        case .boolean:
            XCTAssertEqual(symbol.offset, 0x10)
            XCTAssertFalse(symbol.isMutable)
        default:
            XCTFail()
        }
    }
    
    func testExistsInParentScope() {
        let parent = SymbolTable()
        parent.bind(identifier: "foo", symbol: Symbol(type: .boolean, offset: 0x10, isMutable: false))
        let symbols = SymbolTable(parent: parent, dict: [:])
        XCTAssertTrue(symbols.exists(identifier: "foo"))
    }
    
    func testResolveSymbolInParentScope() {
        let parent = SymbolTable()
        parent.bind(identifier: "foo", symbol: Symbol(type: .boolean, offset: 0x10, isMutable: false))
        let symbols = SymbolTable(parent: parent, dict: [:])
        let symbol = try! symbols.resolve(identifier: "foo")
        XCTAssertEqual(symbol, Symbol(type: .boolean, offset: 0x10, isMutable: false))
    }
}
