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
    
    func testFailToMatchPattern() {
        let input = Lexer(withString: "NOP $1\n")
        XCTAssertEqual(input.match(pattern: "A\\b"), nil)
    }
    
    func testScanTokensInEmptyString() {
        let tokenizer = Lexer(withString: "")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testScanTokensWithNewlines() {
        let tokenizer = Lexer(withString: "\n\n")
        tokenizer.rules = [
            Lexer.Rule(pattern: "\n") {
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
        let tokenizer = Lexer(withString: "@\n")
        tokenizer.rules = [
            Lexer.Rule(pattern: "\n") {
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
        let tokenizer = Lexer(withString: "@\n$\n")
        tokenizer.rules = [
            Lexer.Rule(pattern: "\n") {
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
        let tokenizer = Lexer(withString: ",\n")
        tokenizer.rules = [
            Lexer.Rule(pattern: ",") {
                TokenComma(lineNumber: tokenizer.lineNumber, lexeme: $0)
            },
            Lexer.Rule(pattern: "\n") {
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
