//
//  TokenBooleanTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 6/5/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class TokenBooleanTests: XCTestCase {
    func testTokenBooleanDescription() {
        XCTAssertEqual(TokenBoolean(true).description, "<TokenBoolean: sourceAnchor=nil, lexeme=\"\", literal=true>")
    }
    
    func testTokenBooleanEquality() {
        let a = TokenBoolean(true)
        let b = TokenBoolean(true)
        XCTAssertEqual(a, b)
    }
    
    func testTokenBooleanIsNotEqualToSomeOtherNSObject() {
        let token = TokenBoolean(true)
        XCTAssertNotEqual(token, NSArray())
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
