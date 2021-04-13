//
//  TokenTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class TokenTests: XCTestCase {
    func testTokenDescription() {
        XCTAssertEqual(Token(sourceAnchor: nil).description, "<Token: sourceAnchor=nil, lexeme=\"\">")
    }
    
    func testTokenEquality() {
        let a = Token(sourceAnchor: nil)
        let b = Token(sourceAnchor: nil)
        XCTAssertEqual(a, b)
    }
    
    func testTokenEquality2() {
        let a = Token(sourceAnchor: nil)
        let b = Token(sourceAnchor: nil)
        XCTAssertTrue(a == b)
    }
    
    func testTokenIsNotEqualToNil() {
        let token = Token(sourceAnchor: nil)
        XCTAssertFalse(token.isEqual(nil))
    }
    
    func testTokenIsNotEqualToSomeOtherNSObject() {
        let token = Token(sourceAnchor: nil)
        XCTAssertFalse(token.isEqual(NSArray()))
    }
    
    func testTokenIsNotEqualToTokenOfDifferentType() {
        let a = Token(sourceAnchor: nil)
        let b = TokenEOF()
        XCTAssertNotEqual(a, b)
    }
    
    func testHash() {
        XCTAssertEqual(Token(sourceAnchor: nil).hashValue,
                       Token(sourceAnchor: nil).hashValue)
    }
}
