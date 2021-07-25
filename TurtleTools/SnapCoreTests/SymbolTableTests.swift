//
//  SymbolTableTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/27/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SymbolTableTests: XCTestCase {
    func testEquatableSymbols() {
        XCTAssertNotEqual(Symbol(type: .u8, offset: 0x10),
                          Symbol(type: .bool, offset: 0x10))
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
        symbols.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: 0x10))
        let symbol = try! symbols.resolve(sourceAnchor: nil, identifier: "foo")
        XCTAssertEqual(symbol.type, .u8)
        XCTAssertEqual(symbol.offset, 0x10)
    }
    
    func testExists() {
        let symbols = SymbolTable()
        XCTAssertFalse(symbols.exists(identifier: "foo"))
        symbols.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: 0x10))
        XCTAssertTrue(symbols.exists(identifier: "foo"))
    }

    func testBindWord_Static_Mutable() {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .u8, offset: 0x10))
        let symbol = try! symbols.resolve(sourceAnchor: nil, identifier: "foo")
        XCTAssertEqual(symbol.type, .u8)
        XCTAssertEqual(symbol.offset, 0x10)
    }

    func testBindWord_Static_Constant() {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .constU8, offset: 0x10))
        let symbol = try! symbols.resolve(sourceAnchor: nil, identifier: "foo")
        XCTAssertEqual(symbol.type, .constU8)
        XCTAssertEqual(symbol.offset, 0x10)
    }

    func testBindBoolean_Static_Mutable() {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .bool, offset: 0x10))
        let symbol = try! symbols.resolve(sourceAnchor: nil, identifier: "foo")
        XCTAssertEqual(symbol.type, .bool)
        XCTAssertEqual(symbol.offset, 0x10)
    }

    func testBindBoolean_Static_Constant() {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .constBool, offset: 0x10))
        let symbol = try! symbols.resolve(sourceAnchor: nil, identifier: "foo")
        XCTAssertEqual(symbol.type, .constBool)
        XCTAssertEqual(symbol.offset, 0x10)
    }
    
    func testExistsInParentScope() {
        let parent = SymbolTable()
        parent.bind(identifier: "foo", symbol: Symbol(type: .constBool, offset: 0x10))
        let symbols = SymbolTable(parent: parent, dict: [:])
        XCTAssertTrue(symbols.exists(identifier: "foo"))
    }
    
    func testSymbolCanBeShadowedInLocalScope() {
        let parent = SymbolTable()
        parent.bind(identifier: "foo", symbol: Symbol(type: .constBool, offset: 0x10))
        let symbols = SymbolTable(parent: parent, dict: [:])
        XCTAssertFalse(symbols.existsAndCannotBeShadowed(identifier: "foo"))
    }
    
    func testSymbolCannotBeShadowedInLocalScope() {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: Symbol(type: .constBool, offset: 0x10))
        XCTAssertTrue(symbols.existsAndCannotBeShadowed(identifier: "foo"))
    }
    
    func testResolveSymbolInParentScope() {
        let parent = SymbolTable()
        parent.bind(identifier: "foo", symbol: Symbol(type: .constBool, offset: 0x10))
        let symbols = SymbolTable(parent: parent, dict: [:])
        let symbol = try! symbols.resolve(sourceAnchor: nil, identifier: "foo")
        XCTAssertEqual(symbol, Symbol(type: .constBool, offset: 0x10))
    }
    
    func testResolveSymbolWithStackFrameDepth() {
        let parent = SymbolTable()
        parent.bind(identifier: "foo", symbol: Symbol(type: .constBool, offset: 0x10))
        let symbols = SymbolTable(parent: parent, dict: [:])
        let resolution = try! symbols.resolveWithStackFrameDepth(sourceAnchor: nil, identifier: "foo")
        XCTAssertEqual(resolution.0, Symbol(type: .constBool, offset: 0x10))
        XCTAssertEqual(resolution.1, 0)
    }
    
    func testResolveSymbolWithScopeDepth() {
        let parent = SymbolTable()
        parent.bind(identifier: "foo", symbol: Symbol(type: .constBool, offset: 0x10))
        let symbols = SymbolTable(parent: parent, dict: [:])
        let resolution = try! symbols.resolveWithScopeDepth(identifier: "foo")
        XCTAssertEqual(resolution.0, Symbol(type: .constBool, offset: 0x10))
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
    
    func testInitializedWithDeclarationOrder() {
        let symbols = SymbolTable([
            "foo" : Symbol(type: .u8, offset: 0),
            "bar" : Symbol(type: .u8, offset: 0)
        ])
        XCTAssertTrue(symbols.declarationOrder.contains("foo"))
        XCTAssertTrue(symbols.declarationOrder.contains("bar"))
        XCTAssertEqual(symbols.declarationOrder.count, 2)
    }
    
    func testDeclarationOrderAffectsEquality() {
        let symbols1 = SymbolTable([
            "foo" : Symbol(type: .u8, offset: 0),
            "bar" : Symbol(type: .u8, offset: 0)
        ])
        symbols1.declarationOrder = ["foo", "bar"]
        
        let symbols2 = SymbolTable([
            "foo" : Symbol(type: .u8, offset: 0),
            "bar" : Symbol(type: .u8, offset: 0)
        ])
        symbols2.declarationOrder = ["bar", "foo"]
        
        XCTAssertNotEqual(symbols1, symbols2)
    }
    
    func testBindUpdatesDeclarationOrder() {
        let symbols = SymbolTable()
        XCTAssertEqual(symbols.declarationOrder, [])
        symbols.bind(identifier: "foo", symbol: Symbol(type: .constBool, offset: 0x10))
        XCTAssertEqual(symbols.declarationOrder, ["foo"])
        symbols.bind(identifier: "bar", symbol: Symbol(type: .constBool, offset: 0x10))
        XCTAssertEqual(symbols.declarationOrder, ["foo", "bar"])
    }
}
