//
//  SymbolTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 5/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class SymbolTests: XCTestCase {
    func testEquality() {
        XCTAssertFalse(Symbol(identifier: "").isEqual(nil))
        XCTAssertNotEqual(Symbol(identifier: ""), NSObject())
        XCTAssertNotEqual(Symbol(identifier: "foo"), Symbol(identifier: "bar"))
        XCTAssertTrue(Symbol(identifier: "") == Symbol(identifier: ""))
        XCTAssertEqual(Symbol(identifier: ""), Symbol(identifier: ""))
    }
    
    func testHash() {
        XCTAssertEqual(Symbol(identifier: "").hash, Symbol(identifier: "").hash)
    }
}
