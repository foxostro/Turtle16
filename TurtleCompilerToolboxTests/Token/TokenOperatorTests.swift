//
//  TokenOperatorTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 5/21/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class TokenOperatorTests: XCTestCase {
    func testDescription() {
        XCTAssertEqual(TokenOperator(op: .minus).description, "<TokenOperator: sourceAnchor=nil, lexeme=\"\", op=minus>")
    }
    
    func testTokenOperatorIsNotEqualToSomeOtherNSObject() {
        let token = TokenOperator(op: .minus)
        XCTAssertNotEqual(token, NSArray())
    }
    
    func testTokenOperatorIsNotEqualToTokenWithDifferentOperator() {
        let a = TokenOperator(op: .minus)
        let b = TokenOperator(op: .plus)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenOperatorIsNotEqualToTokenOfDifferentType() {
        let a = TokenOperator(op: .minus)
        let b = TokenEOF()
        XCTAssertNotEqual(a, b)
    }
    
    func testEquality() {
        XCTAssertEqual(TokenOperator(op: .minus),
                       TokenOperator(op: .minus))
    }
    
    func testHash() {
        XCTAssertEqual(TokenOperator(op: .minus).hashValue,
                       TokenOperator(op: .minus).hashValue)
    }
}
