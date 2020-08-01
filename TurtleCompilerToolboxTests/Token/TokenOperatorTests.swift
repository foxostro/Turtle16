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
        XCTAssertEqual(TokenOperator(sourceAnchor: nil, op: .minus).description, "<TokenOperator: sourceAnchor=nil, lexeme=\"\", op=minus>")
    }
    
    func testTokenOperatorIsNotEqualToSomeOtherNSObject() {
        let token = TokenOperator(sourceAnchor: nil, op: .minus)
        XCTAssertNotEqual(token, NSArray())
    }
    
    func testTokenOperatorIsNotEqualToTokenWithDifferentOperator() {
        let a = TokenOperator(sourceAnchor: nil, op: .minus)
        let b = TokenOperator(sourceAnchor: nil, op: .plus)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenOperatorIsNotEqualToTokenOfDifferentType() {
        let a = TokenOperator(sourceAnchor: nil, op: .minus)
        let b = TokenEOF(sourceAnchor: nil)
        XCTAssertNotEqual(a, b)
    }
    
    func testEquality() {
        XCTAssertEqual(TokenOperator(sourceAnchor: nil, op: .minus),
                       TokenOperator(sourceAnchor: nil, op: .minus))
    }
    
    func testHash() {
        XCTAssertEqual(TokenOperator(sourceAnchor: nil, op: .minus).hashValue,
                       TokenOperator(sourceAnchor: nil, op: .minus).hashValue)
    }
}
