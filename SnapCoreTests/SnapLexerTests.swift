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
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(0, 0))])
    }
    
    func testTokenizeNewLine() {
        let tokenizer = SnapLexer(withString: "\n")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeSomeNewLines() {
        let tokenizer = SnapLexer(withString: "\n\n\n")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                                          TokenNewline(sourceAnchor: tokenizer.lineMapper.anchor(1, 2)),
                                          TokenNewline(sourceAnchor: tokenizer.lineMapper.anchor(2, 3)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeComma() {
        let tokenizer = SnapLexer(withString: ",")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenComma(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeComment() {
        let tokenizer = SnapLexer(withString: "// comment")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(9, 9))])
    }
    
    func testTokenizeCommaAndComment() {
        let tokenizer = SnapLexer(withString: ",// comment")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenComma(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(10, 10))])
    }
    
    func testTokenizeCommentWithWhitespace() {
        let tokenizer = SnapLexer(withString: " \t  // comment\n")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(sourceAnchor: tokenizer.lineMapper.anchor(14, 15)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(15, 15))])
    }
    
    func testUnexpectedCharacter() {
        let tokenizer = SnapLexer(withString: "'")
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.first?.sourceAnchor, tokenizer.lineMapper.anchor(0, 1))
        XCTAssertEqual(tokenizer.errors.first?.message, "unexpected character: `''")
    }
    
    func testTokenizeIdentifier() {
        let tokenizer = SnapLexer(withString: "Bogus")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 5)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(5, 5))])
    }
    
    func testFailToTokenizeInvalidIdentifier() {
        let tokenizer = SnapLexer(withString: "@")
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.first?.sourceAnchor, tokenizer.lineMapper.anchor(0, 1))
        XCTAssertEqual(tokenizer.errors.first?.message, "unexpected character: `@'")
    }
    
    func testTokenizeDecimalLiteral() {
        let tokenizer = SnapLexer(withString: "123")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 3), literal: 123),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeNegativeDecimalLiteral() {
        let tokenizer = SnapLexer(withString: "-123")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .minus),
                                          TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(1, 4), literal: 123),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeZero() {
        let tokenizer = SnapLexer(withString: "0")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), literal: 0),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeDollarHexadecimalLiteral() {
        let tokenizer = SnapLexer(withString: "$ff")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 3), literal: 255),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeHexadecimalLiteral() {
        let tokenizer = SnapLexer(withString: "0xff")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 4), literal: 255),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeHexadecimalLiteralCapital() {
        let tokenizer = SnapLexer(withString: "0XFF")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 4), literal: 255),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeBinaryLiteral() {
        let tokenizer = SnapLexer(withString: "0b11")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 4), literal: 3),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeLiteralCharacter() {
        let tokenizer = SnapLexer(withString: "'A'")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 3), literal: 65),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeIdentifierWhichStartsWithA() {
        let tokenizer = SnapLexer(withString: "Animal")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 6)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(6, 6))])
    }
    
    func testTokenizeColon() {
        let tokenizer = SnapLexer(withString: "label:")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 5)),
                                          TokenColon(sourceAnchor: tokenizer.lineMapper.anchor(5, 6)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(6, 6))])
    }
    
    func testTokenizeSemicolon() {
        let tokenizer = SnapLexer(withString: ";")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenSemicolon(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeADD() {
        let tokenizer = SnapLexer(withString: "ADD")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeLet() {
        let tokenizer = SnapLexer(withString: "let")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLet(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeEqualAdjacentToOtherTokens() {
        let tokenizer = SnapLexer(withString: "let foo=1")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLet(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                                          TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(4, 7)),
                                          TokenEqual(sourceAnchor: tokenizer.lineMapper.anchor(7, 8)),
                                          TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(8, 9), literal: 1),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(9, 9))])
    }
    
    func testTokenizeEqualByItself() {
        let tokenizer = SnapLexer(withString: "let foo =")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLet(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                                          TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(4, 7)),
                                          TokenEqual(sourceAnchor: tokenizer.lineMapper.anchor(8, 9)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(9, 9))])
    }
    
    func testTokenizeDoubleEqual() {
        let tokenizer = SnapLexer(withString: "==")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 2), op: .eq),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))])
    }
    
    func testTokenizeNotEqual() {
        let tokenizer = SnapLexer(withString: "!=")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 2), op: .ne),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))])
    }
    
    func testTokenizeLessThan() {
        let tokenizer = SnapLexer(withString: "<")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .lt),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeGreaterThan() {
        let tokenizer = SnapLexer(withString: ">")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .gt),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeLessThanOrEqual() {
        let tokenizer = SnapLexer(withString: "<=")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 2), op: .le),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))])
    }
    
    func testTokenizeGreaterThanOrEqual() {
        let tokenizer = SnapLexer(withString: ">=")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 2), op: .ge),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))])
    }
    
    func testTokenizeReturn() {
        let tokenizer = SnapLexer(withString: "return")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenReturn(sourceAnchor: tokenizer.lineMapper.anchor(0, 6)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(6, 6))])
    }
    
    func testTokenizeUnaryNegation() {
        let tokenizer = SnapLexer(withString: "-foo")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .minus),
                                          TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(1, 4)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeUnaryAmpersand() {
        let tokenizer = SnapLexer(withString: "&foo")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .ampersand),
                                          TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(1, 4)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeAdditionSymbol() {
        let tokenizer = SnapLexer(withString: "+")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .plus),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeMultiplicationSymbol() {
        let tokenizer = SnapLexer(withString: "*")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .star),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeDivisionSymbol() {
        let tokenizer = SnapLexer(withString: "/")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .divide),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeModulusSymbol() {
        let tokenizer = SnapLexer(withString: "%")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .modulus),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeParentheses() {
        let tokenizer = SnapLexer(withString: "()")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenParenLeft(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                                          TokenParenRight(sourceAnchor: tokenizer.lineMapper.anchor(1, 2)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))])
    }
    
    func testTokenizeParentheses2() {
        let tokenizer = SnapLexer(withString: "(2-1)")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenParenLeft(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                                          TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(1, 2), literal: 2),
                                          TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(2, 3), op: .minus),
                                          TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(3, 4), literal: 1),
                                          TokenParenRight(sourceAnchor: tokenizer.lineMapper.anchor(4, 5)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(5, 5))])
    }
    
    func testTokenizeVar() {
        let tokenizer = SnapLexer(withString: "var")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenVar(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeIf() {
        let tokenizer = SnapLexer(withString: "if")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIf(sourceAnchor: tokenizer.lineMapper.anchor(0, 2)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))])
    }
    
    func testTokenizeElse() {
        let tokenizer = SnapLexer(withString: "else")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenElse(sourceAnchor: tokenizer.lineMapper.anchor(0, 4)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeCurlyBranches() {
        let tokenizer = SnapLexer(withString: "{}")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenCurlyLeft(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                                          TokenCurlyRight(sourceAnchor: tokenizer.lineMapper.anchor(1, 2)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))])
    }
    
    func testTokenizeWhile() {
        let tokenizer = SnapLexer(withString: "while")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenWhile(sourceAnchor: tokenizer.lineMapper.anchor(0, 5)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(5, 5))])
    }
    
    func testTokenizeFor() {
        let tokenizer = SnapLexer(withString: "for")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenFor(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeForRange() {
        let tokenizer = SnapLexer(withString: "forRange")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenForRange(sourceAnchor: tokenizer.lineMapper.anchor(0, 8)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(8, 8))])
    }
    
    func testTokenizeSingleCharacterIdentifier() {
        let tokenizer = SnapLexer(withString: "a")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeBooleanTrue() {
        let tokenizer = SnapLexer(withString: "true")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenBoolean(sourceAnchor: tokenizer.lineMapper.anchor(0, 4), literal: true),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeBooleanFalse() {
        let tokenizer = SnapLexer(withString: "false")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenBoolean(sourceAnchor: tokenizer.lineMapper.anchor(0, 5), literal: false),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(5, 5))])
    }
    
    func testTokenizeStatic() {
        let tokenizer = SnapLexer(withString: "static")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenStatic(sourceAnchor: tokenizer.lineMapper.anchor(0, 6)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(6, 6))])
    }
    
    func testTokenizeFunc() {
        let tokenizer = SnapLexer(withString: "func")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenFunc(sourceAnchor: tokenizer.lineMapper.anchor(0, 4)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeArrow() {
        let tokenizer = SnapLexer(withString: "->")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenArrow(sourceAnchor: tokenizer.lineMapper.anchor(0, 2)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))])
    }
    
    func testTokenizeUInt8() {
        let tokenizer = SnapLexer(withString: "u8")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenType(sourceAnchor: tokenizer.lineMapper.anchor(0, 2), type: .u8),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))])
    }
    
    func testTokenizeUInt16() {
        let tokenizer = SnapLexer(withString: "u16")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenType(sourceAnchor: tokenizer.lineMapper.anchor(0, 3), type: .u16),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeBool_1() {
        let tokenizer = SnapLexer(withString: "bool")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenType(sourceAnchor: tokenizer.lineMapper.anchor(0, 4), type: .bool),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeBool_2() {
        let tokenizer = SnapLexer(withString: "boolasdf")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 8)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(8, 8))])
    }
    
    func testTokenizeVoid() {
        let tokenizer = SnapLexer(withString: "void")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenType(sourceAnchor: tokenizer.lineMapper.anchor(0, 4), type: .void),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeAs_1() {
        let tokenizer = SnapLexer(withString: "as")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenAs(sourceAnchor: tokenizer.lineMapper.anchor(0, 2)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))])
    }
    
    func testTokenizeAs_2() {
        let tokenizer = SnapLexer(withString: "bass")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 4)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeAs_3() {
        let tokenizer = SnapLexer(withString: "asdf")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 4)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeSquareBrackets() {
        let tokenizer = SnapLexer(withString: "foo[[bar]]")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                                          TokenSquareBracketLeft(sourceAnchor: tokenizer.lineMapper.anchor(3, 4)),
                                          TokenSquareBracketLeft(sourceAnchor: tokenizer.lineMapper.anchor(4, 5)),
                                          TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(5, 8)),
                                          TokenSquareBracketRight(sourceAnchor: tokenizer.lineMapper.anchor(8, 9)),
                                          TokenSquareBracketRight(sourceAnchor: tokenizer.lineMapper.anchor(9, 10)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(10, 10))])
    }
    
    func testTokenizeQuotedLiteralString() {
        let tokenizer = SnapLexer(withString: "\"test\"")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLiteralString(sourceAnchor: tokenizer.lineMapper.anchor(0, 6),
                                                             literal: "test"),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(6, 6))])
    }
    
    func testTokenizeQuotedStringWithEscapeCharacters_DoubleQuote() {
        let tokenizer = SnapLexer(withString: #""\t\n\r\"\'\\\0""#)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLiteralString(sourceAnchor: tokenizer.lineMapper.anchor(0, 16),
                                                             literal: "\t\n\r\"\'\\\0"),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(16, 16))])
    }
    
    func testTokenizeUnderscore() {
        let tokenizer = SnapLexer(withString: "_")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenUnderscore(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeUnderscoreAdjacentToOtherTokens() {
        let tokenizer = SnapLexer(withString: "[_]")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenSquareBracketLeft(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                                          TokenUnderscore(sourceAnchor: tokenizer.lineMapper.anchor(1, 2)),
                                          TokenSquareBracketRight(sourceAnchor: tokenizer.lineMapper.anchor(2, 3)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeIdentifierWithUnderscore() {
        let tokenizer = SnapLexer(withString: "foo_bar")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 7)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(7, 7))])
    }
    
    func testTokenizeDoubleDot() {
        let tokenizer = SnapLexer(withString: "0..1")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), literal: 0),
                                          TokenDoubleDot(sourceAnchor: tokenizer.lineMapper.anchor(1, 3)),
                                          TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(3, 4), literal: 1),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeDot() {
        let tokenizer = SnapLexer(withString: "foo.bar")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                                          TokenDot(sourceAnchor: tokenizer.lineMapper.anchor(3, 4)),
                                          TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(4, 7)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(7, 7))])
    }
    
    func testTokenizeUndefined_1() {
        let tokenizer = SnapLexer(withString: "undefined")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenUndefined(sourceAnchor: tokenizer.lineMapper.anchor(0, 9)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(9, 9))])
    }
    
    func testTokenizeUndefined_2() {
        let tokenizer = SnapLexer(withString: "undefined1")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 10)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(10, 10))])
    }
    
    func testTokenizeStruct_1() {
        let tokenizer = SnapLexer(withString: "structure")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 9)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(9, 9))])
    }
    
    func testTokenizeStruct_2() {
        let tokenizer = SnapLexer(withString: "struct")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenStruct(sourceAnchor: tokenizer.lineMapper.anchor(0, 6)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(6, 6))])
    }
    
    func testTokenizeConst() {
        let tokenizer = SnapLexer(withString: "const")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenConst(sourceAnchor: tokenizer.lineMapper.anchor(0, 5)),
                                          TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(5, 5))])
    }
}
