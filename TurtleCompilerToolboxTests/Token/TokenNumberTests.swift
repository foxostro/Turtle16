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
        XCTAssertEqual(TokenNumber(lineNumber: 1, lexeme: "1", literal: 1).description, "<TokenNumber: lineNumber=1, lexeme=\"1\", literal=1>")
    }
    
    func testTokenNumberEquality() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        XCTAssertEqual(a, b)
    }
    
    func testTokenNumberIsNotEqualToSomeOtherNSObject() {
        let token = TokenNumber(lineNumber: 42, lexeme: "1", literal: 1)
        XCTAssertNotEqual(token, NSArray())
    }
    
    func testTokenNumberIsNotEqualToTokenWithDifferentLineNumber() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 2, lexeme: "1", literal: 1)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenNumberIsNotEqualToTokenWithDifferentLexeme() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 1, lexeme: "2", literal: 1)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenNumberIsNotEqualToTokenWithDifferentLiteral() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 1, lexeme: "1", literal: 2)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenNumberIsNotEqualToTokenOfDifferentType() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenEOF(lineNumber: 1)
        XCTAssertNotEqual(a, b)
    }
    
    func testHash() {
        XCTAssertEqual(TokenNumber(lineNumber: 1, lexeme: "1", literal: 1).hashValue,
                       TokenNumber(lineNumber: 1, lexeme: "1", literal: 1).hashValue)
    }
}
