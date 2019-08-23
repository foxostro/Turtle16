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
        XCTAssertEqual(Token(type: .mov, lineNumber: 1, lexeme: "MOV").description, "<Token: type=mov, lineNumber=1, lexeme=\"MOV\">")
    }
    
    func testTokenDescriptionWithLiteral() {
        XCTAssertEqual(Token(type: .number, lineNumber: 1, lexeme: "123", literal: 123).description, "<Token: type=number, lineNumber=1, lexeme=\"123\", literal=123>")
    }
    
    func testTokensTestEqualityWithDifferentTypes() {
        XCTAssertNotEqual(Token(type: .identifier, lineNumber: 1, lexeme: "123"),
                          Token(type: .number, lineNumber: 1, lexeme: "123"))
    }
    
    func testTokensTestEqualityWithDifferentLines() {
        XCTAssertNotEqual(Token(type: .number, lineNumber: 1, lexeme: "123", literal: 123),
                          Token(type: .number, lineNumber: 2, lexeme: "123", literal: 1))
    }
    
    func testTokensTestEqualityWithDifferentLexemes() {
        XCTAssertNotEqual(Token(type: .number, lineNumber: 1, lexeme: "456", literal: 123),
                          Token(type: .number, lineNumber: 1, lexeme: "123", literal: 1))
    }
    
    func testTokensTestEqualityWithDifferentLiteralNullity() {
        XCTAssertNotEqual(Token(type: .number, lineNumber: 1, lexeme: "123", literal: nil),
                          Token(type: .number, lineNumber: 1, lexeme: "123", literal: 1))
    }
    
    func testTokensTestEqualityWithDifferentLiteralTypes() {
        XCTAssertNotEqual(Token(type: .number, lineNumber: 1, lexeme: "123", literal: 1),
                          Token(type: .number, lineNumber: 1, lexeme: "123", literal: ""))
    }
    
    func testTokensTestEqualityWithDifferentLiteralTypes2() {
        XCTAssertNotEqual(Token(type: .number, lineNumber: 1, lexeme: "123", literal: ""),
                          Token(type: .number, lineNumber: 1, lexeme: "123", literal: 1))
    }
    
    func testTokensTestEqualityWithDifferentLiteralTypes3() {
        XCTAssertNotEqual(Token(type: .number, lineNumber: 1, lexeme: "123", literal: NSArray()),
                          Token(type: .number, lineNumber: 1, lexeme: "123", literal: 1))
    }
    
    func testTokensTestEqualityWithDifferentLiteralInts() {
        XCTAssertNotEqual(Token(type: .number, lineNumber: 1, lexeme: "123", literal: 1),
                          Token(type: .number, lineNumber: 1, lexeme: "123", literal: 2))
    }
    
    func testTokensTestEqualityWithDifferentLiteralStrings() {
        XCTAssertNotEqual(Token(type: .number, lineNumber: 1, lexeme: "123", literal: "a"),
                          Token(type: .number, lineNumber: 1, lexeme: "123", literal: "b"))
    }
    
    func testTokensTestEqualityWithDifferentLiteralNSObjects() {
        XCTAssertNotEqual(Token(type: .number, lineNumber: 1, lexeme: "123", literal: NSArray()),
                          Token(type: .number, lineNumber: 1, lexeme: "123", literal: NSString()))
    }
    
    func testTokensEqual() {
        XCTAssertEqual(Token(type: .number, lineNumber: 1, lexeme: "123", literal: 123),
                       Token(type: .number, lineNumber: 1, lexeme: "123", literal: 123))
    }
    
    func testTokensEqualityTestWithDifferentTypes() {
        XCTAssertNotEqual(Token(type: .number, lineNumber: 1, lexeme: "123", literal: 123),
                          NSString())
    }
}
