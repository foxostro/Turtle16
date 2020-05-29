//
//  SymbolConstantWordTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 5/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class SymbolConstantWordTests: XCTestCase {
    func testEquality() {
        XCTAssertFalse(SymbolConstantWord(identifier: "", value: 0).isEqual(nil))
        XCTAssertNotEqual(SymbolConstantWord(identifier: "", value: 0), NSObject())
        XCTAssertNotEqual(SymbolConstantWord(identifier: "foo", value: 0), SymbolConstantWord(identifier: "bar", value: 0))
        XCTAssertNotEqual(SymbolConstantWord(identifier: "", value: 0), SymbolConstantWord(identifier: "", value: 1))
        XCTAssertEqual(SymbolConstantWord(identifier: "", value: 0), SymbolConstantWord(identifier: "", value: 0))
    }
    
    func testHash() {
        XCTAssertEqual(SymbolConstantWord(identifier: "", value: 0).hash, SymbolConstantWord(identifier: "", value: 0).hash)
    }
}
