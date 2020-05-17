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
        XCTAssertEqual(Token(lineNumber: 42, lexeme: "foo").description, "<Token: lineNumber=42, lexeme=\"foo\">")
    }
    
    func testTokenEquality() {
        let a = Token(lineNumber: 1, lexeme: "")
        let b = Token(lineNumber: 1, lexeme: "")
        XCTAssertEqual(a, b)
    }
    
    func testTokenIsNotEqualToSomeOtherNSObject() {
        let token = Token(lineNumber: 42, lexeme: "foo")
        XCTAssertNotEqual(token, NSArray())
    }
    
    func testTokenIsNotEqualToTokenWithDifferentLineNumber() {
        let a = Token(lineNumber: 1, lexeme: "")
        let b = Token(lineNumber: 2, lexeme: "")
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenIsNotEqualToTokenWithDifferentLexeme() {
        let a = Token(lineNumber: 1, lexeme: "foo")
        let b = Token(lineNumber: 1, lexeme: "bar")
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenIsNotEqualToTokenOfDifferentType() {
        let a = Token(lineNumber: 1, lexeme: "")
        let b = TokenEOF(lineNumber: 1)
        XCTAssertNotEqual(a, b)
    }
}
