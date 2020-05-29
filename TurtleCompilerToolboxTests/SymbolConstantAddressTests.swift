//
//  SymbolConstantAddressTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 5/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class SymbolConstantAddressTests: XCTestCase {
    func testEquality() {
        XCTAssertFalse(SymbolConstantAddress(identifier: "", value: 0).isEqual(nil))
        XCTAssertNotEqual(SymbolConstantAddress(identifier: "", value: 0), NSObject())
        XCTAssertNotEqual(SymbolConstantAddress(identifier: "foo", value: 0), SymbolConstantAddress(identifier: "bar", value: 0))
        XCTAssertNotEqual(SymbolConstantAddress(identifier: "", value: 0), SymbolConstantAddress(identifier: "", value: 1))
        XCTAssertEqual(SymbolConstantAddress(identifier: "", value: 0), SymbolConstantAddress(identifier: "", value: 0))
    }
    
    func testHash() {
        XCTAssertEqual(SymbolConstantAddress(identifier: "", value: 0).hash, SymbolConstantAddress(identifier: "", value: 0).hash)
    }
}
