//
//  TokenNumberTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 9/3/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class TokenNumberTests: XCTestCase {
    func testTokenNumberDescription() {
        XCTAssertEqual(TokenNumber(sourceAnchor: nil, literal: 1).description, "<TokenNumber: sourceAnchor=nil, lexeme=\"\", literal=1>")
    }
    
    func testTokenNumberEquality() {
        let a = TokenNumber(sourceAnchor: nil, literal: 1)
        let b = TokenNumber(sourceAnchor: nil, literal: 1)
        XCTAssertEqual(a, b)
    }
    
    func testTokenNumberIsNotEqualToSomeOtherNSObject() {
        let token = TokenNumber(sourceAnchor: nil, literal: 1)
        XCTAssertNotEqual(token, NSArray())
    }
    
    func testTokenNumberIsNotEqualToTokenWithDifferentLiteral() {
        let a = TokenNumber(sourceAnchor: nil, literal: 1)
        let b = TokenNumber(sourceAnchor: nil, literal: 2)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenNumberIsNotEqualToTokenOfDifferentType() {
        let a = TokenNumber(sourceAnchor: nil, literal: 1)
        let b = TokenEOF(sourceAnchor: nil)
        XCTAssertNotEqual(a, b)
    }
    
    func testHash() {
        XCTAssertEqual(TokenNumber(sourceAnchor: nil, literal: 1).hashValue,
                       TokenNumber(sourceAnchor: nil, literal: 1).hashValue)
    }
}
