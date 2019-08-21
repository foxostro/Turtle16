//
//  AssemblerScannerTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class AssemblerScannerTests: XCTestCase {
    typealias Token = AssemblerScanner.Token
    
    func testTokenizeEmptyString() {
        let tokenizer = AssemblerScanner(withString: "")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [Token(type: .eof,
                                                lineNumber: 1,
                                                lexeme: "")])
    }
    
    func testTokenizeNewLine() {
        let tokenizer = AssemblerScanner(withString: "\n")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [Token(type: .newline,
                                                lineNumber: 1,
                                                lexeme: "\n"),
                                          Token(type: .eof,
                                                lineNumber: 2,
                                                lexeme: "")])
    }
    
    func testTokenizeSomeNewLines() {
        let tokenizer = AssemblerScanner(withString: "\n\n\n")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [Token(type: .newline,
                                                lineNumber: 1,
                                                lexeme: "\n"),
                                          Token(type: .newline,
                                                lineNumber: 2,
                                                lexeme: "\n"),
                                          Token(type: .newline,
                                                lineNumber: 3,
                                                lexeme: "\n"),
                                          Token(type: .eof,
                                                lineNumber: 4,
                                                lexeme: "")])
    }
    
    func testTokenizeComma() {
        let tokenizer = AssemblerScanner(withString: ",")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [Token(type: .comma,
                                                lineNumber: 1,
                                                lexeme: ","),
                                          Token(type: .eof,
                                                lineNumber: 1,
                                                lexeme: "")])
    }
    
    func testTokenizeComment() {
        let tokenizer = AssemblerScanner(withString: "// comment")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [Token(type: .eof,
                                                lineNumber: 1,
                                                lexeme: "")])
    }
    
    func testTokenizeCommaAndComment() {
        let tokenizer = AssemblerScanner(withString: ",// comment")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [Token(type: .comma,
                                                lineNumber: 1,
                                                lexeme: ","),
                                          Token(type: .eof,
                                                lineNumber: 1,
                                                lexeme: "")])
    }
    
    func testTokenizeCommentWithWhitespace() {
        let tokenizer = AssemblerScanner(withString: " \t  // comment\n")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [Token(type: .newline,
                                                lineNumber: 1,
                                                lexeme: "\n"),
                                          Token(type: .eof,
                                                lineNumber: 2,
                                                lexeme: "")])
    }
    
    func testUnexpectedCharacter() {
        let tokenizer = AssemblerScanner(withString: "'")
        XCTAssertThrowsError(try tokenizer.scanTokens()) { e in
            let error = e as! AssemblerScanner.AssemblerScannerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "unexpected character: `''")
        }
    }
    
    func testTokenizeNOP() {
        let tokenizer = AssemblerScanner(withString: "NOP")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [Token(type: .nop,
                                                lineNumber: 1,
                                                lexeme: "NOP"),
                                          Token(type: .eof,
                                                lineNumber: 1,
                                                lexeme: "")])
    }
    
    func testTokenizeCMP() {
        let tokenizer = AssemblerScanner(withString: "CMP")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [Token(type: .cmp,
                                                lineNumber: 1,
                                                lexeme: "CMP"),
                                          Token(type: .eof,
                                                lineNumber: 1,
                                                lexeme: "")])
    }
    
    func testTokenizeHLT() {
        let tokenizer = AssemblerScanner(withString: "HLT")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [Token(type: .hlt,
                                                lineNumber: 1,
                                                lexeme: "HLT"),
                                          Token(type: .eof,
                                                lineNumber: 1,
                                                lexeme: "")])
    }
    
    func testTokenizeIdentifier() {
        let tokenizer = AssemblerScanner(withString: "Bogus")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [Token(type: .identifier,
                                                lineNumber: 1,
                                                lexeme: "Bogus"),
                                          Token(type: .eof,
                                                lineNumber: 1,
                                                lexeme: "")])
    }
    
    func testFailToTokenizeInvalidIdentifier() {
        let tokenizer = AssemblerScanner(withString: "*")
        XCTAssertThrowsError(try tokenizer.scanTokens()) { e in
            let error = e as! AssemblerScanner.AssemblerScannerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "unexpected character: `*'")
        }
    }
    
    func testTokenizeDecimalLiteral() {
        let tokenizer = AssemblerScanner(withString: "123")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [Token(type: .number,
                                                lineNumber: 1,
                                                lexeme: "123",
                                                literal: 123),
                                          Token(type: .eof,
                                                lineNumber: 1,
                                                lexeme: "")])
    }
    
    func testTokenizeDollarHexadecimalLiteral() {
        let tokenizer = AssemblerScanner(withString: "$ff")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [Token(type: .number,
                                                lineNumber: 1,
                                                lexeme: "$ff",
                                                literal: 255),
                                          Token(type: .eof,
                                                lineNumber: 1,
                                                lexeme: "")])
    }
    
    func testTokenizeHexadecimalLiteral() {
        let tokenizer = AssemblerScanner(withString: "0xff")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [Token(type: .number,
                                                lineNumber: 1,
                                                lexeme: "0xff",
                                                literal: 255),
                                          Token(type: .eof,
                                                lineNumber: 1,
                                                lexeme: "")])
    }
}
