//
//  SnapLexerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class SnapLexerTests: XCTestCase {
    func testTokenizeEmptyString() {
        let tokenizer = SnapLexer(withString: "")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeNewLine() {
        let tokenizer = SnapLexer(withString: "\n")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                          TokenEOF(lineNumber: 2, lexeme: "")])
    }
    
    func testTokenizeSomeNewLines() {
        let tokenizer = SnapLexer(withString: "\n\n\n")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                          TokenNewline(lineNumber: 2, lexeme: "\n"),
                                          TokenNewline(lineNumber: 3, lexeme: "\n"),
                                          TokenEOF(lineNumber: 4, lexeme: "")])
    }
    
    func testTokenizeComma() {
        let tokenizer = SnapLexer(withString: ",")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenComma(lineNumber: 1, lexeme: ","),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeComment() {
        let tokenizer = SnapLexer(withString: "// comment")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeCommaAndComment() {
        let tokenizer = SnapLexer(withString: ",// comment")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenComma(lineNumber: 1, lexeme: ","),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeCommentWithWhitespace() {
        let tokenizer = SnapLexer(withString: " \t  // comment\n")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                          TokenEOF(lineNumber: 2, lexeme: "")])
    }
    
    func testUnexpectedCharacter() {
        let tokenizer = SnapLexer(withString: "'")
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.first?.line, 1)
        XCTAssertEqual(tokenizer.errors.first?.message, "unexpected character: `''")
    }
    
    func testTokenizeIdentifier() {
        let tokenizer = SnapLexer(withString: "Bogus")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(lineNumber: 1, lexeme: "Bogus"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testFailToTokenizeInvalidIdentifier() {
        let tokenizer = SnapLexer(withString: "*")
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.first?.line, 1)
        XCTAssertEqual(tokenizer.errors.first?.message, "unexpected character: `*'")
    }
    
    func testTokenizeDecimalLiteral() {
        let tokenizer = SnapLexer(withString: "123")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "123", literal: 123),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeNegativeDecimalLiteral() {
        let tokenizer = SnapLexer(withString: "-123")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "-123", literal: -123),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeDollarHexadecimalLiteral() {
        let tokenizer = SnapLexer(withString: "$ff")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "$ff", literal: 255),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeHexadecimalLiteral() {
        let tokenizer = SnapLexer(withString: "0xff")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "0xff", literal: 255),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeHexadecimalLiteralCapital() {
        let tokenizer = SnapLexer(withString: "0XFF")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "0XFF", literal: 255),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeBinaryLiteral() {
        let tokenizer = SnapLexer(withString: "0b11")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "0b11", literal: 3),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeLiteralCharacter() {
        let tokenizer = SnapLexer(withString: "'A'")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "'A'", literal: 65),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeIdentifierWhichStartsWithA() {
        let tokenizer = SnapLexer(withString: "Animal")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(lineNumber: 1, lexeme: "Animal"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterA() {
        let tokenizer = SnapLexer(withString: "A")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "A", literal: .A),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterB() {
        let tokenizer = SnapLexer(withString: "B")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "B", literal: .B),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterC() {
        let tokenizer = SnapLexer(withString: "C")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "C", literal: .C),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterD() {
        let tokenizer = SnapLexer(withString: "D")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "D", literal: .D),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterE() {
        let tokenizer = SnapLexer(withString: "E")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "E", literal: .E),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterM() {
        let tokenizer = SnapLexer(withString: "M")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "M", literal: .M),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterP() {
        let tokenizer = SnapLexer(withString: "P")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "P", literal: .P),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterU() {
        let tokenizer = SnapLexer(withString: "U")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "U", literal: .U),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterV() {
        let tokenizer = SnapLexer(withString: "V")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "V", literal: .V),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterX() {
        let tokenizer = SnapLexer(withString: "X")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "X", literal: .X),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterY() {
        let tokenizer = SnapLexer(withString: "Y")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "Y", literal: .Y),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterNone() {
        let tokenizer = SnapLexer(withString: "_")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "_", literal: .NONE),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeColon() {
        let tokenizer = SnapLexer(withString: "label:")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(lineNumber: 1, lexeme: "label"),
                                          TokenColon(lineNumber: 1, lexeme: ":"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeADD() {
        let tokenizer = SnapLexer(withString: "ADD")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(lineNumber: 1, lexeme: "ADD"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeLet() {
        let tokenizer = SnapLexer(withString: "let")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLet(lineNumber: 1, lexeme: "let"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeEqualAdjacentToOtherTokens() {
        let tokenizer = SnapLexer(withString: "let foo=1")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLet(lineNumber: 1, lexeme: "let"),
                                          TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                          TokenEqual(lineNumber: 1, lexeme: "="),
                                          TokenNumber(lineNumber: 1, lexeme: "1", literal: 1),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeEqualByItself() {
        let tokenizer = SnapLexer(withString: "let foo =")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLet(lineNumber: 1, lexeme: "let"),
                                          TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                          TokenEqual(lineNumber: 1, lexeme: "="),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeReturn() {
        let tokenizer = SnapLexer(withString: "return")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenReturn(lineNumber: 1, lexeme: "return"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
}
