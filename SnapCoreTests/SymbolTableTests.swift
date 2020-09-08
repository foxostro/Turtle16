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
                          Symbol(type: .bool, offset: 0x10, isMutable: true))
    }
    
    func testUseOfUnresolvedIdentifier() {
        let symbols = SymbolTable()
        XCTAssertThrowsError(try symbols.resolve(sourceAnchor: nil, identifier: "foo")) {
            let error = $0 as? CompilerError
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.message, "use of unresolved identifier: `foo'")
        }
        XCTAssertThrowsError(try symbols.resolveWithStackFrameDepth(sourceAnchor: nil, identifier: "foo")) {
            let error = $0 as? CompilerError
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.message, "use of unresolved identifier: `foo'")
        }
    }
    
    func testSuccessfullyResolveSymbolByIdentifier() {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: 0x10, isMutable: true))
        let symbol = try! symbols.resolve(sourceAnchor: nil, identifier: "foo")
        switch symbol.type {
        case .u8:
            XCTAssertEqual(symbol.offset, 0x10)
            XCTAssertEqual(symbol.isMutable, true)
        default:
            XCTFail()
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
        let symbol = try! symbols.resolve(sourceAnchor: nil, identifier: "foo")
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
        let symbol = try! symbols.resolve(sourceAnchor: nil, identifier: "foo")
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
        symbols.bind(identifier: "foo", symbol: Symbol(type: .bool, offset: 0x10, isMutable: true))
        let symbol = try! symbols.resolve(sourceAnchor: nil, identifier: "foo")
        switch symbol.type {
        case .bool:
            XCTAssertEqual(symbol.offset, 0x10)
            XCTAssertTrue(symbol.isMutable)
        default:
            XCTFail()
        }
    }

    func testBindBoolean_Static_Immutable() {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .bool, offset: 0x10, isMutable: false))
        let symbol = try! symbols.resolve(sourceAnchor: nil, identifier: "foo")
        switch symbol.type {
        case .bool:
            XCTAssertEqual(symbol.offset, 0x10)
            XCTAssertFalse(symbol.isMutable)
        default:
            XCTFail()
        }
    }
    
    func testExistsInParentScope() {
        let parent = SymbolTable()
        parent.bind(identifier: "foo", symbol: Symbol(type: .bool, offset: 0x10, isMutable: false))
        let symbols = SymbolTable(parent: parent, dict: [:])
        XCTAssertTrue(symbols.exists(identifier: "foo"))
    }
    
    func testSymbolCanBeShadowedInLocalScope() {
        let parent = SymbolTable()
        parent.bind(identifier: "foo", symbol: Symbol(type: .bool, offset: 0x10, isMutable: false))
        let symbols = SymbolTable(parent: parent, dict: [:])
        XCTAssertFalse(symbols.existsAndCannotBeShadowed(identifier: "foo"))
    }
    
    func testSymbolCannotBeShadowedInLocalScope() {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .bool, offset: 0x10, isMutable: false))
        XCTAssertTrue(symbols.existsAndCannotBeShadowed(identifier: "foo"))
    }
    
    func testResolveSymbolInParentScope() {
        let parent = SymbolTable()
        parent.bind(identifier: "foo", symbol: Symbol(type: .bool, offset: 0x10, isMutable: false))
        let symbols = SymbolTable(parent: parent, dict: [:])
        let symbol = try! symbols.resolve(sourceAnchor: nil, identifier: "foo")
        XCTAssertEqual(symbol, Symbol(type: .bool, offset: 0x10, isMutable: false))
    }
    
    func testResolveSymbolWithStackFrameDepth() {
        let parent = SymbolTable()
        parent.bind(identifier: "foo", symbol: Symbol(type: .bool, offset: 0x10, isMutable: false))
        let symbols = SymbolTable(parent: parent, dict: [:])
        let resolution = try! symbols.resolveWithStackFrameDepth(sourceAnchor: nil, identifier: "foo")
        XCTAssertEqual(resolution.0, Symbol(type: .bool, offset: 0x10, isMutable: false))
        XCTAssertEqual(resolution.1, 0)
    }
    
    func testResolveSymbolWithScopeDepth() {
        let parent = SymbolTable()
        parent.bind(identifier: "foo", symbol: Symbol(type: .bool, offset: 0x10, isMutable: false))
        let symbols = SymbolTable(parent: parent, dict: [:])
        let resolution = try! symbols.resolveWithScopeDepth(identifier: "foo")
        XCTAssertEqual(resolution.0, Symbol(type: .bool, offset: 0x10, isMutable: false))
        XCTAssertEqual(resolution.1, 1)
    }
    
    func testFailToResolveType() {
        let symbols = SymbolTable()
        XCTAssertThrowsError(try symbols.resolveType(identifier: "foo")) {
            let error = $0 as? CompilerError
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.message, "use of undeclared type `foo'")
        }
    }
    
    func testSuccessfullyResolveTypeByIdentifier() {
        let symbols = SymbolTable(parent: nil, dict: [:], typeDict: ["foo" : .structType(StructType(name: "foo", symbols: SymbolTable()))])
        let symbolType = try! symbols.resolveType(identifier: "foo")
        switch symbolType {
        case .structType(let typ):
            XCTAssertEqual(typ.name, "foo")
        default:
            XCTFail()
        }
    }

    func testBindStructType() {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbolType: .structType(StructType(name: "foo", symbols: SymbolTable())))
        let symbolType = try! symbols.resolveType(identifier: "foo")
        switch symbolType {
        case .structType(let typ):
            XCTAssertEqual(typ.name, "foo")
        default:
            XCTFail()
        }
    }
}
