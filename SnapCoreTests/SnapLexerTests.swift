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
        let tokenizer = SnapLexer(withString: "@")
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.first?.line, 1)
        XCTAssertEqual(tokenizer.errors.first?.message, "unexpected character: `@'")
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
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                          TokenNumber(lineNumber: 1, lexeme: "123", literal: 123),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeZero() {
        let tokenizer = SnapLexer(withString: "0")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "0", literal: 0),
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
    
    func testTokenizeColon() {
        let tokenizer = SnapLexer(withString: "label:")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(lineNumber: 1, lexeme: "label"),
                                          TokenColon(lineNumber: 1, lexeme: ":"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeSemicolon() {
        let tokenizer = SnapLexer(withString: ";")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenSemicolon(lineNumber: 1, lexeme: ";"),
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
    
    func testTokenizeDoubleEqual() {
        let tokenizer = SnapLexer(withString: "==")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(lineNumber: 1, lexeme: "==", op: .eq),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeNotEqual() {
        let tokenizer = SnapLexer(withString: "!=")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(lineNumber: 1, lexeme: "!=", op: .ne),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeLessThan() {
        let tokenizer = SnapLexer(withString: "<")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(lineNumber: 1, lexeme: "<", op: .lt),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeGreaterThan() {
        let tokenizer = SnapLexer(withString: ">")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(lineNumber: 1, lexeme: ">", op: .gt),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeLessThanOrEqual() {
        let tokenizer = SnapLexer(withString: "<=")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(lineNumber: 1, lexeme: "<=", op: .le),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeGreaterThanOrEqual() {
        let tokenizer = SnapLexer(withString: ">=")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(lineNumber: 1, lexeme: ">=", op: .ge),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeReturn() {
        let tokenizer = SnapLexer(withString: "return")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenReturn(lineNumber: 1, lexeme: "return"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeUnaryNegation() {
        let tokenizer = SnapLexer(withString: "-foo")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                          TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeAdditionSymbol() {
        let tokenizer = SnapLexer(withString: "+")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeMultiplicationSymbol() {
        let tokenizer = SnapLexer(withString: "*")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeDivisionSymbol() {
        let tokenizer = SnapLexer(withString: "/")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeModulusSymbol() {
        let tokenizer = SnapLexer(withString: "%")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeParentheses() {
        let tokenizer = SnapLexer(withString: "()")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenParenLeft(lineNumber: 1, lexeme: "("),
                                          TokenParenRight(lineNumber: 1, lexeme: ")"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeParentheses2() {
        let tokenizer = SnapLexer(withString: "(2-1)")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenParenLeft(lineNumber: 1, lexeme: "("),
                                          TokenNumber(lineNumber: 1, lexeme: "2", literal: 2),
                                          TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                          TokenNumber(lineNumber: 1, lexeme: "1", literal: 1),
                                          TokenParenRight(lineNumber: 1, lexeme: ")"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeVar() {
        let tokenizer = SnapLexer(withString: "var")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenVar(lineNumber: 1, lexeme: "var"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeIf() {
        let tokenizer = SnapLexer(withString: "if")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIf(lineNumber: 1, lexeme: "if"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeElse() {
        let tokenizer = SnapLexer(withString: "else")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenElse(lineNumber: 1, lexeme: "else"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeCurlyBranches() {
        let tokenizer = SnapLexer(withString: "{}")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenCurlyLeft(lineNumber: 1, lexeme: "{"),
                                          TokenCurlyRight(lineNumber: 1, lexeme: "}"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeWhile() {
        let tokenizer = SnapLexer(withString: "while")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenWhile(lineNumber: 1, lexeme: "while"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeFor() {
        let tokenizer = SnapLexer(withString: "for")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenFor(lineNumber: 1, lexeme: "for"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeSingleCharacterIdentifier() {
        let tokenizer = SnapLexer(withString: "a")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(lineNumber: 1, lexeme: "a"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeBooleanTrue() {
        let tokenizer = SnapLexer(withString: "true")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenBoolean(lineNumber: 1, lexeme: "true", literal: true),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeBooleanFalse() {
        let tokenizer = SnapLexer(withString: "false")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenBoolean(lineNumber: 1, lexeme: "false", literal: false),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
}
