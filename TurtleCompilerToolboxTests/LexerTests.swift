//
//  LexerTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class LexerTests: XCTestCase {
    func testInitWithEmptyString() {
        let input = LexerBase(withString: "")
        XCTAssertEqual(input.string, "")
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testInitWithOneCharacter() {
        let input = LexerBase(withString: "a")
        XCTAssertEqual(input.string, "a")
        XCTAssertFalse(input.isAtEnd)
    }
    
    func testPeekEmptyString() {
        let input = LexerBase(withString: "")
        XCTAssertEqual(input.peek(), nil)
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testPeekCharacter() {
        let input = LexerBase(withString: "a")
        XCTAssertEqual(input.peek(), "a")
        XCTAssertFalse(input.isAtEnd)
    }
    
    func testPeekAheadAFewCharacters() {
        let input = LexerBase(withString: "abcd")
        XCTAssertEqual(input.peek(2), "c")
    }
    
    func testAdvanceEmptyString() {
        let input = LexerBase(withString: "")
        XCTAssertTrue(input.isAtEnd)
        XCTAssertEqual(input.advance(), nil)
    }
    
    func testAdvanceCharacter() {
        let input = LexerBase(withString: "a")
        XCTAssertFalse(input.isAtEnd)
        XCTAssertEqual(input.advance(), "a")
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testMatchWhitespaceButNoneIsThere() {
        let input = LexerBase(withString: "\n")
        XCTAssertEqual(input.match(characterSet: .whitespaces), nil)
        XCTAssertEqual(input.peek(), "\n")
    }
    
    func testMatchWhitespace() {
        let input = LexerBase(withString: "  \t\n")
        XCTAssertEqual(input.match(characterSet: .whitespaces), "  \t")
        XCTAssertEqual(input.peek(), "\n")
    }
    
    func testAdvanceToNewlineWithEmptyString() {
        let input = LexerBase(withString: "")
        input.advanceToNewline()
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testAdvanceToNewline() {
        let input = LexerBase(withString: "abcd\n")
        input.advanceToNewline()
        XCTAssertEqual(input.peek(), "\n")
    }
    
    func testMatchBadPattern() {
        let input = LexerBase(withString: "NOP $1\n")
        XCTAssertEqual(input.match(pattern: "["), nil)
    }
    
    func testMatchEmptyPattern() {
        let input = LexerBase(withString: "NOP $1\n")
        XCTAssertEqual(input.match(pattern: ""), "")
    }
    
    func testMatchPattern() {
        let input = LexerBase(withString: "NOP $1\n")
        XCTAssertEqual(input.match(pattern: "[A-Z]+"), "NOP")
    }
    
    func testFailToMatchPattern() {
        let input = LexerBase(withString: "NOP $1\n")
        XCTAssertEqual(input.match(pattern: "A\\b"), nil)
    }
    
    func testScanTokensInEmptyString() {
        let tokenizer = LexerBase(withString: "")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testScanTokensWithNewlines() {
        let tokenizer = LexerBase(withString: "\n\n")
        tokenizer.rules = [
            LexerBase.Rule(pattern: "\n") {
                let token = TokenNewline(lineNumber: tokenizer.lineNumber, lexeme: $0)
                tokenizer.lineNumber += 1
                return token
            }
        ]
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                          TokenNewline(lineNumber: 2, lexeme: "\n"),
                                          TokenEOF(lineNumber: 3, lexeme: "")])
    }
    
    func testScanTokensYieldingUnexpectedCharacterError() {
        let tokenizer = LexerBase(withString: "@\n")
        tokenizer.rules = [
            LexerBase.Rule(pattern: "\n") {
                let token = TokenNewline(lineNumber: tokenizer.lineNumber, lexeme: $0)
                tokenizer.lineNumber += 1
                return token
            }
        ]
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.first?.line, 1)
        XCTAssertEqual(tokenizer.errors.first?.message, "unexpected character: `@'")
    }
    
    func testScanTokensYieldingMultipleUnexpectedCharacterErrors() {
        let tokenizer = LexerBase(withString: "@\n$\n")
        tokenizer.rules = [
            LexerBase.Rule(pattern: "\n") {
                let token = TokenNewline(lineNumber: tokenizer.lineNumber, lexeme: $0)
                tokenizer.lineNumber += 1
                return token
            }
        ]
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.count, 2)
        XCTAssertEqual(tokenizer.errors[0].line, 1)
        XCTAssertEqual(tokenizer.errors[0].message, "unexpected character: `@'")
        XCTAssertEqual(tokenizer.errors[1].line, 2)
        XCTAssertEqual(tokenizer.errors[1].message, "unexpected character: `$'")
    }
    
    func testScanTokensWithMoreThanOneRule() {
        let tokenizer = LexerBase(withString: ",\n")
        tokenizer.rules = [
            LexerBase.Rule(pattern: ",") {
                TokenComma(lineNumber: tokenizer.lineNumber, lexeme: $0)
            },
            LexerBase.Rule(pattern: "\n") {
                let token = TokenNewline(lineNumber: tokenizer.lineNumber, lexeme: $0)
                tokenizer.lineNumber += 1
                return token
            }
        ]
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenComma(lineNumber: 1, lexeme: ","),
                                          TokenNewline(lineNumber: 1, lexeme: "\n"),
                                          TokenEOF(lineNumber: 2, lexeme: "")])
    }
}
