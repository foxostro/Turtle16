//
//  LexerTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class LexerTests: XCTestCase {
    func testInitWithEmptyString() {
        let input = Lexer(withString: "")
        XCTAssertEqual(input.string, "")
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testInitWithOneCharacter() {
        let input = Lexer(withString: "a")
        XCTAssertEqual(input.string, "a")
        XCTAssertFalse(input.isAtEnd)
    }
    
    func testPeekEmptyString() {
        let input = Lexer(withString: "")
        XCTAssertEqual(input.peek(), nil)
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testPeekCharacter() {
        let input = Lexer(withString: "a")
        XCTAssertEqual(input.peek(), "a")
        XCTAssertFalse(input.isAtEnd)
    }
    
    func testPeekAheadAFewCharacters() {
        let input = Lexer(withString: "abcd")
        XCTAssertEqual(input.peek(2), "c")
    }
    
    func testAdvanceEmptyString() {
        let input = Lexer(withString: "")
        XCTAssertTrue(input.isAtEnd)
        XCTAssertEqual(input.advance(), nil)
    }
    
    func testAdvanceCharacter() {
        let input = Lexer(withString: "a")
        XCTAssertFalse(input.isAtEnd)
        XCTAssertEqual(input.advance(), "a")
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testMatchWhitespaceButNoneIsThere() {
        let input = Lexer(withString: "\n")
        XCTAssertEqual(input.match(characterSet: .whitespaces), nil)
        XCTAssertEqual(input.peek(), "\n")
    }
    
    func testMatchWhitespace() {
        let input = Lexer(withString: "  \t\n")
        XCTAssertEqual(input.match(characterSet: .whitespaces), "  \t")
        XCTAssertEqual(input.peek(), "\n")
    }
    
    func testAdvanceToNewlineWithEmptyString() {
        let input = Lexer(withString: "")
        input.advanceToNewline()
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testAdvanceToNewline() {
        let input = Lexer(withString: "abcd\n")
        input.advanceToNewline()
        XCTAssertEqual(input.peek(), "\n")
    }
    
    func testMatchBadPattern() {
        let input = Lexer(withString: "NOP $1\n")
        XCTAssertEqual(input.match(pattern: "["), nil)
    }
    
    func testMatchEmptyPattern() {
        let input = Lexer(withString: "NOP $1\n")
        XCTAssertEqual(input.match(pattern: ""), "")
    }
    
    func testMatchPattern() {
        let input = Lexer(withString: "NOP $1\n")
        XCTAssertEqual(input.match(pattern: "[A-Z]+"), "NOP")
    }
}
