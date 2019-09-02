//
//  TokenTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class TokenTests: XCTestCase {
    func testTokenDescription() {
        XCTAssertEqual(TokenMOV(lineNumber: 1, lexeme: "MOV").description, "<TokenMOV: lineNumber=1, lexeme=\"MOV\">")
    }
    
    func testTokenDescriptionWithLiteral() {
        XCTAssertEqual(TokenNumber(lineNumber: 1, lexeme: "123", literal: 123).description, "<TokenNumber: lineNumber=1, lexeme=\"123\", literal=123>")
    }
    
    func testTokensTestEqualityWithDifferentTypes() {
        XCTAssertNotEqual(TokenIdentifier(lineNumber: 1, lexeme: "123"),
                          TokenNumber(lineNumber: 1, lexeme: "123"))
    }
    
    func testTokensTestEqualityWithDifferentLines() {
        XCTAssertNotEqual(TokenNumber(lineNumber: 1, lexeme: "123", literal: 123),
                          TokenNumber(lineNumber: 2, lexeme: "123", literal: 1))
    }
    
    func testTokensTestEqualityWithDifferentLexemes() {
        XCTAssertNotEqual(TokenNumber(lineNumber: 1, lexeme: "456", literal: 123),
                          TokenNumber(lineNumber: 1, lexeme: "123", literal: 1))
    }
    
    func testTokensTestEqualityWithDifferentLiteralNullity() {
        XCTAssertNotEqual(TokenNumber(lineNumber: 1, lexeme: "123", literal: nil),
                          TokenNumber(lineNumber: 1, lexeme: "123", literal: 1))
    }
    
    func testTokensTestEqualityWithDifferentLiteralTypes() {
        XCTAssertNotEqual(TokenNumber(lineNumber: 1, lexeme: "123", literal: 1),
                          TokenNumber(lineNumber: 1, lexeme: "123", literal: ""))
    }
    
    func testTokensTestEqualityWithDifferentLiteralTypes2() {
        XCTAssertNotEqual(TokenNumber(lineNumber: 1, lexeme: "123", literal: ""),
                          TokenNumber(lineNumber: 1, lexeme: "123", literal: 1))
    }
    
    func testTokensTestEqualityWithDifferentLiteralTypes3() {
        XCTAssertNotEqual(TokenNumber(lineNumber: 1, lexeme: "123", literal: NSArray()),
                          TokenNumber(lineNumber: 1, lexeme: "123", literal: 1))
    }
    
    func testTokensTestEqualityWithDifferentLiteralInts() {
        XCTAssertNotEqual(TokenNumber(lineNumber: 1, lexeme: "123", literal: 1),
                          TokenNumber(lineNumber: 1, lexeme: "123", literal: 2))
    }
    
    func testTokensTestEqualityWithDifferentLiteralStrings() {
        XCTAssertNotEqual(TokenNumber(lineNumber: 1, lexeme: "123", literal: "a"),
                          TokenNumber(lineNumber: 1, lexeme: "123", literal: "b"))
    }
    
    func testTokensTestEqualityWithDifferentLiteralNSObjects() {
        XCTAssertNotEqual(TokenNumber( lineNumber: 1, lexeme: "123", literal: NSArray()),
                          TokenNumber(lineNumber: 1, lexeme: "123", literal: NSString()))
    }
    
    func testTokensEqual() {
        XCTAssertEqual(TokenNumber(lineNumber: 1, lexeme: "123", literal: 123),
                       TokenNumber(lineNumber: 1, lexeme: "123", literal: 123))
    }
    
    func testTokensEqualityTestWithDifferentTypes() {
        XCTAssertNotEqual(TokenNumber(lineNumber: 1, lexeme: "123", literal: 123),
                          NSString())
    }
}
