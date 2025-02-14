//
//  TokenBooleanTests.swift
//  TurtleCoreTests
//
//  Created by Andrew Fox on 6/5/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore

class TokenBooleanTests: XCTestCase {
    func testTokenBooleanDescription() {
        XCTAssertEqual(TokenBoolean(true).description, "<TokenBoolean: sourceAnchor=nil, lexeme=\"\", literal=true>")
    }
    
    func testTokenBooleanEquality() {
        let a = TokenBoolean(true)
        let b = TokenBoolean(true)
        XCTAssertEqual(a, b)
    }
    
    func testTokenBooleanIsNotEqualToTokenWithDifferentLiteral() {
        let a = TokenBoolean(true)
        let b = TokenBoolean(false)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenBooleanIsNotEqualToTokenOfDifferentType() {
        let a = TokenBoolean(true)
        let b = TokenEOF()
        XCTAssertNotEqual(a, b)
    }
    
    func testHash() {
        XCTAssertEqual(TokenBoolean(true).hashValue,
                       TokenBoolean(true).hashValue)
    }
}
