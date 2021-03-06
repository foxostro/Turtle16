//
//  TokenTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class TokenTests: XCTestCase {
    func testTokenDescription() {
        XCTAssertEqual(Token(sourceAnchor: nil).description, "<Token: sourceAnchor=nil, lexeme=\"\">")
    }
    
    func testTokenEquality() {
        let a = Token(sourceAnchor: nil)
        let b = Token(sourceAnchor: nil)
        XCTAssertEqual(a, b)
    }
    
    func testTokenIsNotEqualToSomeOtherNSObject() {
        let token = Token(sourceAnchor: nil)
        XCTAssertNotEqual(token, NSArray())
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
