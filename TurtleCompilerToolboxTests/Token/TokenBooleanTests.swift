//
//  TokenBooleanTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 6/5/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class TokenBooleanTests: XCTestCase {
    func testTokenBooleanDescription() {
        XCTAssertEqual(TokenBoolean(lineNumber: 1, lexeme: "true", literal: true).description, "<TokenBoolean: lineNumber=1, lexeme=\"true\", literal=true>")
    }
    
    func testTokenBooleanEquality() {
        let a = TokenBoolean(lineNumber: 1, lexeme: "true", literal: true)
        let b = TokenBoolean(lineNumber: 1, lexeme: "true", literal: true)
        XCTAssertEqual(a, b)
    }
    
    func testTokenBooleanIsNotEqualToSomeOtherNSObject() {
        let token = TokenBoolean(lineNumber: 1, lexeme: "true", literal: true)
        XCTAssertNotEqual(token, NSArray())
    }
    
    func testTokenBooleanIsNotEqualToTokenWithDifferentLineNumber() {
        let a = TokenBoolean(lineNumber: 1, lexeme: "true", literal: true)
        let b = TokenBoolean(lineNumber: 2, lexeme: "true", literal: true)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenBooleanIsNotEqualToTokenWithDifferentLexeme() {
        let a = TokenBoolean(lineNumber: 1, lexeme: "true", literal: true)
        let b = TokenBoolean(lineNumber: 1, lexeme: "foo", literal: true)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenBooleanIsNotEqualToTokenWithDifferentLiteral() {
        let a = TokenBoolean(lineNumber: 1, lexeme: "true", literal: true)
        let b = TokenBoolean(lineNumber: 1, lexeme: "true", literal: false)
        XCTAssertNotEqual(a, b)
    }
    
    func testTokenBooleanIsNotEqualToTokenOfDifferentType() {
        let a = TokenBoolean(lineNumber: 1, lexeme: "true", literal: true)
        let b = TokenEOF(lineNumber: 1)
        XCTAssertNotEqual(a, b)
    }
    
    func testHash() {
        XCTAssertEqual(TokenBoolean(lineNumber: 1, lexeme: "true", literal: true).hashValue,
                       TokenBoolean(lineNumber: 1, lexeme: "true", literal: true).hashValue)
    }
}
