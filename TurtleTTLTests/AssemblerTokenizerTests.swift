//
//  AssemblerTokenizerTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/19/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class AssemblerTokenizerTests: XCTestCase {
    func testTokenizeEmptyString() {
        let tokenizer = AssemblerTokenizer(withText: "")
        try! tokenizer.tokenize()
        XCTAssertTrue(tokenizer.tokens.count == 0)
    }
    
    func testTokenizeNewLine() {
        let tokenizer = AssemblerTokenizer(withText: "\n")
        try! tokenizer.tokenize()
        XCTAssertEqual(tokenizer.tokens.count, 1)
        let token = tokenizer.tokens.first!
        XCTAssertEqual(token.lineNumber, 1)
        XCTAssertEqual(token.type, .newline)
    }
    
    func testTokenizeTwoNewLines() {
        let tokenizer = AssemblerTokenizer(withText: "\n\n")
        try! tokenizer.tokenize()
        XCTAssertEqual(tokenizer.tokens.count, 2)
        XCTAssertEqual(tokenizer.tokens[0].lineNumber, 1)
        XCTAssertEqual(tokenizer.tokens[0].type, .newline)
        XCTAssertEqual(tokenizer.tokens[1].lineNumber, 2)
        XCTAssertEqual(tokenizer.tokens[1].type, .newline)
    }
    
    func testTokenizeSingleToken() {
        let tokenizer = AssemblerTokenizer(withText: "NOP")
        try! tokenizer.tokenize()
        XCTAssertEqual(tokenizer.tokens.count, 1)
        XCTAssertEqual(tokenizer.tokens[0].lineNumber, 1)
        XCTAssertEqual(tokenizer.tokens[0].type, .token)
        XCTAssertEqual(tokenizer.tokens[0].string, "NOP")
    }
    
    func testTokenizeMixOfTokenssAndNewlines() {
        let tokenizer = AssemblerTokenizer(withText: "FOO\nBAR\n\n")
        try! tokenizer.tokenize()
        XCTAssertEqual(tokenizer.tokens.count, 5)
        XCTAssertEqual(tokenizer.tokens[0].lineNumber, 1)
        XCTAssertEqual(tokenizer.tokens[0].type, .token)
        XCTAssertEqual(tokenizer.tokens[0].string, "FOO")
        XCTAssertEqual(tokenizer.tokens[1].lineNumber, 1)
        XCTAssertEqual(tokenizer.tokens[1].type, .newline)
        XCTAssertEqual(tokenizer.tokens[1].string, "\n")
        XCTAssertEqual(tokenizer.tokens[2].lineNumber, 2)
        XCTAssertEqual(tokenizer.tokens[2].type, .token)
        XCTAssertEqual(tokenizer.tokens[2].string, "BAR")
        XCTAssertEqual(tokenizer.tokens[3].lineNumber, 2)
        XCTAssertEqual(tokenizer.tokens[3].type, .newline)
        XCTAssertEqual(tokenizer.tokens[3].string, "\n")
        XCTAssertEqual(tokenizer.tokens[4].lineNumber, 3)
        XCTAssertEqual(tokenizer.tokens[4].type, .newline)
        XCTAssertEqual(tokenizer.tokens[4].string, "\n")
    }
    
    func testTokenizeLineOfWhitespaceSeparatedTokens() {
        let tokenizer = AssemblerTokenizer(withText: "FOO BAR $1 0x2")
        try! tokenizer.tokenize()
        XCTAssertEqual(tokenizer.tokens.count, 4)
        XCTAssertEqual(tokenizer.tokens[0].lineNumber, 1)
        XCTAssertEqual(tokenizer.tokens[0].type, .token)
        XCTAssertEqual(tokenizer.tokens[0].string, "FOO")
        XCTAssertEqual(tokenizer.tokens[1].lineNumber, 1)
        XCTAssertEqual(tokenizer.tokens[1].type, .token)
        XCTAssertEqual(tokenizer.tokens[1].string, "BAR")
        XCTAssertEqual(tokenizer.tokens[2].lineNumber, 1)
        XCTAssertEqual(tokenizer.tokens[2].type, .token)
        XCTAssertEqual(tokenizer.tokens[2].string, "$1")
        XCTAssertEqual(tokenizer.tokens[3].lineNumber, 1)
        XCTAssertEqual(tokenizer.tokens[3].type, .token)
        XCTAssertEqual(tokenizer.tokens[3].string, "0x2")
    }
    
    func testTokenizeLineWithComma() {
        let tokenizer = AssemblerTokenizer(withText: "FOO BAR, $1")
        try! tokenizer.tokenize()
        XCTAssertEqual(tokenizer.tokens.count, 4)
        XCTAssertEqual(tokenizer.tokens[0].lineNumber, 1)
        XCTAssertEqual(tokenizer.tokens[0].type, .token)
        XCTAssertEqual(tokenizer.tokens[0].string, "FOO")
        XCTAssertEqual(tokenizer.tokens[1].lineNumber, 1)
        XCTAssertEqual(tokenizer.tokens[1].type, .token)
        XCTAssertEqual(tokenizer.tokens[1].string, "BAR")
        XCTAssertEqual(tokenizer.tokens[2].lineNumber, 1)
        XCTAssertEqual(tokenizer.tokens[2].type, .token)
        XCTAssertEqual(tokenizer.tokens[2].string, ",")
        XCTAssertEqual(tokenizer.tokens[3].lineNumber, 1)
        XCTAssertEqual(tokenizer.tokens[3].type, .token)
        XCTAssertEqual(tokenizer.tokens[3].string, "$1")
    }
    
    func testTokenizeLineWithOnlyComment() {
        let tokenizer = AssemblerTokenizer(withText: "// comment here")
        try! tokenizer.tokenize()
        XCTAssertEqual(tokenizer.tokens.count, 0)
    }
    
    func testTokenizeLineWithComment() {
        let tokenizer = AssemblerTokenizer(withText: "FOO// comment here")
        try! tokenizer.tokenize()
        XCTAssertEqual(tokenizer.tokens.count, 1)
        XCTAssertEqual(tokenizer.tokens[0].lineNumber, 1)
        XCTAssertEqual(tokenizer.tokens[0].type, .token)
        XCTAssertEqual(tokenizer.tokens[0].string, "FOO")
    }
    
    func testTokenizeLineWithCommentAndNewline() {
        let tokenizer = AssemblerTokenizer(withText: "FOO// comment here\n")
        try! tokenizer.tokenize()
        XCTAssertEqual(tokenizer.tokens.count, 2)
        XCTAssertEqual(tokenizer.tokens[0].lineNumber, 1)
        XCTAssertEqual(tokenizer.tokens[0].type, .token)
        XCTAssertEqual(tokenizer.tokens[0].string, "FOO")
        XCTAssertEqual(tokenizer.tokens[1].lineNumber, 1)
        XCTAssertEqual(tokenizer.tokens[1].type, .newline)
        XCTAssertEqual(tokenizer.tokens[1].string, "\n")
    }
}
