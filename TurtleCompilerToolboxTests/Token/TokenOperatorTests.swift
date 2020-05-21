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
        XCTAssertEqual(TokenOperator(lineNumber: 1, lexeme: "-", op: .minus).description, "<TokenOperator: lineNumber=1, lexeme=\"-\", op=minus>")
    }
    
    func testTokenOperatorIsNotEqualToSomeOtherNSObject() {
        let token = TokenOperator(lineNumber: 42, lexeme: "-", op: .minus)
        XCTAssertNotEqual(token, NSArray())
    }
    
    func testTokenOperatorIsNotEqualToTokenWithDifferentLineNumber() {
        let a = TokenOperator(lineNumber: 1, lexeme: "-", op: .minus)
        let b = TokenOperator(lineNumber: 2, lexeme: "-", op: .minus)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenOperatorIsNotEqualToTokenWithDifferentLexeme() {
        let a = TokenOperator(lineNumber: 1, lexeme: "-", op: .minus)
        let b = TokenOperator(lineNumber: 1, lexeme: "neg", op: .minus)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenOperatorIsNotEqualToTokenWithDifferentOperator() {
        let a = TokenOperator(lineNumber: 1, lexeme: "-", op: .minus)
        let b = TokenOperator(lineNumber: 1, lexeme: "-", op: .plus)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenOperatorIsNotEqualToTokenOfDifferentType() {
        let a = TokenOperator(lineNumber: 1, lexeme: "-", op: .minus)
        let b = TokenEOF(lineNumber: 1)
        XCTAssertNotEqual(a, b)
    }
    
    func testEquality() {
        XCTAssertEqual(TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                       TokenOperator(lineNumber: 1, lexeme: "-", op: .minus))
    }
    
    func testHash() {
        XCTAssertEqual(TokenOperator(lineNumber: 1, lexeme: "-", op: .minus).hashValue,
                       TokenOperator(lineNumber: 1, lexeme: "-", op: .minus).hashValue)
    }
}
