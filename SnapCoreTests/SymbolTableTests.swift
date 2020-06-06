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
        XCTAssertNotEqual(SymbolTable.Symbol.word(.staticStorage(address: 0x10, isMutable: true)),
                          SymbolTable.Symbol.word(.constantInt(1)))
    }
    
    func testBindLabel() {
        let symbols = SymbolTable()
        symbols.bindLabel(identifier: "foo", value: 0xffff)
        let symbol = try! symbols.resolve(identifier: "foo")
        switch symbol {
        case .label(let value):
            XCTAssertEqual(value, 0xffff)
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
        symbols.bindLabel(identifier: "foo", value: 0xffff)
        XCTAssertTrue(symbols.exists(identifier: "foo"))
    }

    func testBindWord_Static_Mutable() {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: .word(.staticStorage(address: 0x10, isMutable: true)))
        let symbol = try! symbols.resolve(identifier: "foo")
        switch symbol {
        case .word(let storage):
            switch storage {
            case .staticStorage(let address, let isMutable):
                XCTAssertEqual(address, 0x10)
                XCTAssertEqual(isMutable, true)
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
    }

    func testBindWord_Static_Immutable() {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: .word(.staticStorage(address: 0x10, isMutable: false)))
        let symbol = try! symbols.resolve(identifier: "foo")
        switch symbol {
        case .word(let storage):
            switch storage {
            case .staticStorage(let address, let isMutable):
                XCTAssertEqual(address, 0x10)
                XCTAssertEqual(isMutable, false)
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
    }

    func testBindWord_Constant() {
        let symbols = SymbolTable()
        symbols.bind(identifier: "foo", symbol: .word(.constantInt(42)))
        let symbol = try! symbols.resolve(identifier: "foo")
        switch symbol {
        case .word(let storage):
            switch storage {
            case .constantInt(let value):
                XCTAssertEqual(value, 42)
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
    }
}
