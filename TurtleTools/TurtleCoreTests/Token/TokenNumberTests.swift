//
//  TokenNumberTests.swift
//  TurtleCoreTests
//
//  Created by Andrew Fox on 9/3/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore

class TokenNumberTests: XCTestCase {
    func testTokenNumberDescription() {
        XCTAssertEqual(TokenNumber(literal: 1).description, "<TokenNumber: sourceAnchor=nil, lexeme=\"\", literal=1>")
    }
    
    func testTokenNumberEquality() {
        let a = TokenNumber(literal: 1)
        let b = TokenNumber(literal: 1)
        XCTAssertEqual(a, b)
    }
    
    func testTokenNumberIsNotEqualToSomeOtherNSObject() {
        let token = TokenNumber(literal: 1)
        XCTAssertNotEqual(token, NSArray())
    }
    
    func testTokenNumberIsNotEqualToTokenWithDifferentLiteral() {
        let a = TokenNumber(literal: 1)
        let b = TokenNumber(literal: 2)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenNumberIsNotEqualToTokenOfDifferentType() {
        let a = TokenNumber(literal: 1)
        let b = TokenEOF()
        XCTAssertNotEqual(a, b)
    }
    
    func testHash() {
        XCTAssertEqual(TokenNumber(literal: 1).hashValue,
                       TokenNumber(literal: 1).hashValue)
    }
}
