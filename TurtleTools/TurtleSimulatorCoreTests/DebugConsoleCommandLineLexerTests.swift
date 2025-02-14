//
//  DebugConsoleCommandLineLexerTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleSimulatorCore
import TurtleCore

final class DebugConsoleCommandLineLexerTests: XCTestCase {
    func testTokenizeEmptyString() {
        let text = ""
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = DebugConsoleCommandLineLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(sourceAnchor: lineMapper.anchor(0, 0))])
    }
    
    func testTokenizeNewLine() {
        let text = "\n"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = DebugConsoleCommandLineLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(sourceAnchor: lineMapper.anchor(0, 1)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeSomeNewLines() {
        let text = "\n\n\n"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = DebugConsoleCommandLineLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(sourceAnchor: lineMapper.anchor(0, 1)),
                                          TokenNewline(sourceAnchor: lineMapper.anchor(1, 2)),
                                          TokenNewline(sourceAnchor: lineMapper.anchor(2, 3)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeComma() {
        let text = ","
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = DebugConsoleCommandLineLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenComma(sourceAnchor: lineMapper.anchor(0, 1)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(1, 1))])
    }
    
    func testUnexpectedCharacter() {
        let tokenizer = DebugConsoleCommandLineLexer("'")
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(tokenizer.errors.first?.sourceAnchor, tokenizer.lineMapper.anchor(0, 1))
        XCTAssertEqual(tokenizer.errors.first?.message, "unexpected character: `''")
    }
    
    func testTokenizeIdentifier() {
        let text = "Bogus"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = DebugConsoleCommandLineLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: lineMapper.anchor(0, 5)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(5, 5))])
    }
    
    func testFailToTokenizeInvalidIdentifier() {
        let tokenizer = DebugConsoleCommandLineLexer("*")
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(tokenizer.errors.first?.sourceAnchor, tokenizer.lineMapper.anchor(0, 1))
        XCTAssertEqual(tokenizer.errors.first?.message, "unexpected character: `*'")
    }
    
    func testTokenizeDecimalLiteral() {
        let text = "123"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = DebugConsoleCommandLineLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: lineMapper.anchor(0, 3), literal: 123),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeNegativeDecimalLiteral() {
        let text = "-123"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = DebugConsoleCommandLineLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: lineMapper.anchor(0, 4), literal: -123),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeDollarHexadecimalLiteral() {
        let text = "$ff"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = DebugConsoleCommandLineLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: lineMapper.anchor(0, 3), literal: 255),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeHexadecimalLiteral() {
        let text = "0xff"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = DebugConsoleCommandLineLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: lineMapper.anchor(0, 4), literal: 255),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeHexadecimalLiteralCapital() {
        let text = "0xFF"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = DebugConsoleCommandLineLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: lineMapper.anchor(0, 4), literal: 255),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeBinaryLiteral() {
        let text = "0b11"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = DebugConsoleCommandLineLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: lineMapper.anchor(0, 4), literal: 3),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeLiteralCharacter() {
        let text = "'A'"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = DebugConsoleCommandLineLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: lineMapper.anchor(0, 3), literal: 65),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(3, 3))])
    }
    
    func testReadMemoryWithX_WithAddressAndBadLength() throws {
        let text = "x /foo 0x1000"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = DebugConsoleCommandLineLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [
            TokenIdentifier(sourceAnchor: lineMapper.anchor(0, 1)),
            TokenForwardSlash(sourceAnchor: lineMapper.anchor(2, 3)),
            TokenIdentifier(sourceAnchor: lineMapper.anchor(3, 6)),
            TokenNumber(sourceAnchor: lineMapper.anchor(7, 13), literal: 0x1000),
            TokenEOF(sourceAnchor: lineMapper.anchor(13, 13))
        ])
    }
    
    func testTokenizeQuotedLiteralString() {
        let text = "\"test\""
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = DebugConsoleCommandLineLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLiteralString(sourceAnchor: lineMapper.anchor(0, 6), literal: "test"),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(6, 6))])
    }
    
    func testTokenizeIdentifierWithDash() {
        let text = "load-program"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = DebugConsoleCommandLineLexer(text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: lineMapper.anchor(0, 12)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(12, 12))])
    }
}
