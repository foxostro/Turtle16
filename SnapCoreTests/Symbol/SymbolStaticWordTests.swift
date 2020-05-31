//
//  SymbolStaticWordTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore

class SymbolStaticWordTests: XCTestCase {
    func testEquality() {
        XCTAssertFalse(SymbolStaticWord(identifier: "", address: 0).isEqual(nil))
        XCTAssertNotEqual(SymbolStaticWord(identifier: "", address: 0), NSObject())
        XCTAssertNotEqual(SymbolStaticWord(identifier: "foo", address: 0), SymbolStaticWord(identifier: "bar", address: 0))
        XCTAssertNotEqual(SymbolStaticWord(identifier: "", address: 0), SymbolStaticWord(identifier: "", address: 1))
        XCTAssertNotEqual(SymbolStaticWord(identifier: "", address: 0, isMutable: true), SymbolStaticWord(identifier: "", address: 0, isMutable: false))
        XCTAssertEqual(SymbolStaticWord(identifier: "", address: 0), SymbolStaticWord(identifier: "", address: 0))
    }
    
    func testHash() {
        XCTAssertEqual(SymbolStaticWord(identifier: "", address: 0).hash, SymbolStaticWord(identifier: "", address: 0).hash)
    }
}
