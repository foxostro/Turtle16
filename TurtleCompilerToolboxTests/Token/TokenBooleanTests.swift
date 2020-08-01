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
        XCTAssertEqual(TokenBoolean(sourceAnchor: nil, literal: true).description, "<TokenBoolean: sourceAnchor=nil, lexeme=\"\", literal=true>")
    }
    
    func testTokenBooleanEquality() {
        let a = TokenBoolean(sourceAnchor: nil, literal: true)
        let b = TokenBoolean(sourceAnchor: nil, literal: true)
        XCTAssertEqual(a, b)
    }
    
    func testTokenBooleanIsNotEqualToSomeOtherNSObject() {
        let token = TokenBoolean(sourceAnchor: nil, literal: true)
        XCTAssertNotEqual(token, NSArray())
    }
    
    func testTokenBooleanIsNotEqualToTokenWithDifferentLiteral() {
        let a = TokenBoolean(sourceAnchor: nil, literal: true)
        let b = TokenBoolean(sourceAnchor: nil, literal: false)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenBooleanIsNotEqualToTokenOfDifferentType() {
        let a = TokenBoolean(sourceAnchor: nil, literal: true)
        let b = TokenEOF(sourceAnchor: nil)
        XCTAssertNotEqual(a, b)
    }
    
    func testHash() {
        XCTAssertEqual(TokenBoolean(sourceAnchor: nil, literal: true).hashValue,
                       TokenBoolean(sourceAnchor: nil, literal: true).hashValue)
    }
}
