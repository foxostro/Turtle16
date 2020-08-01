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
    
    func testPeekPastTheEnd() {
        let input = Lexer(withString: "a")
        XCTAssertEqual(input.peek(2), nil)
    }
    
    func testIsAtEnd() {
        let input = Lexer(withString: "")
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testAdvanceEmptyString() {
        let input = Lexer(withString: "")
        input.advance()
        XCTAssertTrue(input.isAtEnd)
    }
    
    func testAdvanceCharacter() {
        let input = Lexer(withString: "a")
        input.advance()
        XCTAssertTrue(input.isAtEnd)
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
    
    func testAdvancePastNewline() {
        let input = Lexer(withString: "abcd\nefgh")
        input.advanceToNewline()
        input.advance()
        XCTAssertEqual(input.peek(0), "e")
        XCTAssertEqual(input.peek(1), "f")
    }
    
    func testMatchBadPattern() {
        let input = Lexer(withString: "NOP $1\n")
        XCTAssertEqual(input.match(pattern: "["), nil)
    }
    
    func testMatchEmptyPattern() {
        let text = "NOP $1\n"
        let lineMapper = SourceLineRangeMapper(text: text)
        let input = Lexer(withString: text)
        XCTAssertEqual(input.match(pattern: ""), lineMapper.anchor(0, 0))
    }
    
    func testMatchPattern() {
        let text = "NOP $1\n"
        let lineMapper = SourceLineRangeMapper(text: text)
        let input = Lexer(withString: text)
        XCTAssertEqual(input.match(pattern: "[A-Z]+"), lineMapper.anchor(0, 3))
    }
    
    func testFailToMatchPattern() {
        let input = Lexer(withString: "NOP $1\n")
        XCTAssertEqual(input.match(pattern: "A\\b"), nil)
    }
    
    func testScanTokensInEmptyString() {
        let text = ""
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = Lexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(sourceAnchor: lineMapper.anchor(0, 0))])
    }
    
    func testScanTokensWithNewlines() {
        let text = "\n\n"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = Lexer(withString: text)
        tokenizer.rules = [
            Lexer.Rule(pattern: "\n") {
                TokenNewline(sourceAnchor: $0)
            }
        ]
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(sourceAnchor: lineMapper.anchor(0, 1)),
                                          TokenNewline(sourceAnchor: lineMapper.anchor(1, 2)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(2, 2))])
    }
    
    func testScanTokensYieldingUnexpectedCharacterError() {
        let tokenizer = Lexer(withString: "@\n")
        tokenizer.rules = [
            Lexer.Rule(pattern: "\n") {
                TokenNewline(sourceAnchor: $0)
            }
        ]
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(tokenizer.errors.first?.message, "unexpected character: `@'")
    }
    
    func testScanTokensYieldingMultipleUnexpectedCharacterErrors() {
        let tokenizer = Lexer(withString: "@\n$\n")
        tokenizer.rules = [
            Lexer.Rule(pattern: "\n") {
                TokenNewline(sourceAnchor: $0)
            }
        ]
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.count, 2)
        XCTAssertEqual(tokenizer.errors[0].sourceAnchor?.text, "@")
        XCTAssertEqual(tokenizer.errors[0].sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(tokenizer.errors[0].message, "unexpected character: `@'")
        XCTAssertEqual(tokenizer.errors[1].sourceAnchor?.text, "$")
        XCTAssertEqual(tokenizer.errors[1].sourceAnchor?.lineNumbers, 1..<2)
        XCTAssertEqual(tokenizer.errors[1].message, "unexpected character: `$'")
    }
    
    func testScanTokensWithMoreThanOneRule() {
        let text = ",\n"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = Lexer(withString: text)
        tokenizer.rules = [
            Lexer.Rule(pattern: ",") {
                TokenComma(sourceAnchor: $0)
            },
            Lexer.Rule(pattern: "\n") {
                TokenNewline(sourceAnchor: $0)
            }
        ]
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenComma(sourceAnchor: lineMapper.anchor(0, 1)),
                                          TokenNewline(sourceAnchor: lineMapper.anchor(1, 2)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(2, 2))])
    }
}
