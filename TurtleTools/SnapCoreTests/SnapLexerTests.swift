//
//  SnapLexerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class SnapLexerTests: XCTestCase {
    func testTokenizeEmptyString() {
        let tokenizer = SnapLexer("")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(0, 0))]
        )
    }

    func testTokenizeNewLine() {
        let tokenizer = SnapLexer("\n")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenNewline(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))
            ]
        )
    }

    func testTokenizeSomeNewLines() {
        let tokenizer = SnapLexer("\n\n\n")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenNewline(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                TokenNewline(sourceAnchor: tokenizer.lineMapper.anchor(1, 2)),
                TokenNewline(sourceAnchor: tokenizer.lineMapper.anchor(2, 3)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))
            ]
        )
    }

    func testTokenizeComma() {
        let tokenizer = SnapLexer(",")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenComma(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))
            ]
        )
    }

    func testTokenizeComment() {
        let tokenizer = SnapLexer("// comment")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(10, 10))]
        )
    }

    func testTokenizeCommaAndComment() {
        let tokenizer = SnapLexer(",// comment")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenComma(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(11, 11))
            ]
        )
    }

    func testTokenizeCommentWithWhitespace() {
        let tokenizer = SnapLexer(" \t  // comment\n")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenNewline(sourceAnchor: tokenizer.lineMapper.anchor(14, 15)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(15, 15))
            ]
        )
    }

    func testUnexpectedCharacter() {
        let tokenizer = SnapLexer("'")
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.first?.sourceAnchor, tokenizer.lineMapper.anchor(0, 1))
        XCTAssertEqual(tokenizer.errors.first?.message, "unexpected character: `''")
    }

    func testTokenizeIdentifier() {
        let tokenizer = SnapLexer("Bogus")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 5)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(5, 5))
            ]
        )
    }

    func testFailToTokenizeInvalidIdentifier() {
        let tokenizer = SnapLexer("`")
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.first?.sourceAnchor, tokenizer.lineMapper.anchor(0, 1))
        XCTAssertEqual(tokenizer.errors.first?.message, "unexpected character: ``'")
    }

    func testTokenizeDecimalLiteral() {
        let tokenizer = SnapLexer("123")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 3), literal: 123),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))
            ]
        )
    }

    func testTokenizeNegativeDecimalLiteral() {
        let tokenizer = SnapLexer("-123")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .minus),
                TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(1, 4), literal: 123),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeZero() {
        let tokenizer = SnapLexer("0")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), literal: 0),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))
            ]
        )
    }

    func testTokenizeDollarHexadecimalLiteral() {
        let tokenizer = SnapLexer("$ff")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 3), literal: 255),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))
            ]
        )
    }

    func testTokenizeHexadecimalLiteral() {
        let tokenizer = SnapLexer("0xff")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 4), literal: 255),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeHexadecimalLiteralCapital() {
        let tokenizer = SnapLexer("0XFF")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 4), literal: 255),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeBinaryLiteral() {
        let tokenizer = SnapLexer("0b11")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 4), literal: 3),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeLiteralCharacter() {
        let tokenizer = SnapLexer("'A'")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 3), literal: 65),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))
            ]
        )
    }

    func testTokenizeLiteralCharacterEscapeSequence() {
        let tokenizer = SnapLexer("'\\n'")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 4), literal: 10),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeIdentifierWhichStartsWithA() {
        let tokenizer = SnapLexer("Animal")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 6)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(6, 6))
            ]
        )
    }

    func testTokenizeColon() {
        let tokenizer = SnapLexer("label:")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 5)),
                TokenColon(sourceAnchor: tokenizer.lineMapper.anchor(5, 6)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(6, 6))
            ]
        )
    }

    func testTokenizeSemicolon() {
        let tokenizer = SnapLexer(";")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenSemicolon(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))
            ]
        )
    }

    func testTokenizeADD() {
        let tokenizer = SnapLexer("ADD")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))
            ]
        )
    }

    func testTokenizeLet() {
        let tokenizer = SnapLexer("let")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenLet(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))
            ]
        )
    }

    func testTokenizeEqualAdjacentToOtherTokens() {
        let tokenizer = SnapLexer("let foo=1")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenLet(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(4, 7)),
                TokenEqual(sourceAnchor: tokenizer.lineMapper.anchor(7, 8)),
                TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(8, 9), literal: 1),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(9, 9))
            ]
        )
    }

    func testTokenizeEqualByItself() {
        let tokenizer = SnapLexer("let foo =")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenLet(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(4, 7)),
                TokenEqual(sourceAnchor: tokenizer.lineMapper.anchor(8, 9)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(9, 9))
            ]
        )
    }

    func testTokenizeDoubleEqual() {
        let tokenizer = SnapLexer("==")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 2), op: .eq),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizeNotEqual() {
        let tokenizer = SnapLexer("!=")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 2), op: .ne),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizeLeftDoubleAngle() {
        let tokenizer = SnapLexer("<<")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(
                    sourceAnchor: tokenizer.lineMapper.anchor(0, 2),
                    op: .leftDoubleAngle
                ),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizeLessThan() {
        let tokenizer = SnapLexer("<")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .lt),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))
            ]
        )
    }

    func testTokenizeGreaterThan() {
        let tokenizer = SnapLexer(">")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .gt),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))
            ]
        )
    }

    func testTokenizeRightDoubleAngle() {
        let tokenizer = SnapLexer(">>")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(
                    sourceAnchor: tokenizer.lineMapper.anchor(0, 2),
                    op: .rightDoubleAngle
                ),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizeLessThanOrEqual() {
        let tokenizer = SnapLexer("<=")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 2), op: .le),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizeGreaterThanOrEqual() {
        let tokenizer = SnapLexer(">=")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 2), op: .ge),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizeReturn() {
        let tokenizer = SnapLexer("return")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenReturn(sourceAnchor: tokenizer.lineMapper.anchor(0, 6)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(6, 6))
            ]
        )
    }

    func testTokenizeUnaryNegation() {
        let tokenizer = SnapLexer("-foo")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .minus),
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(1, 4)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeUnaryAmpersand() {
        let tokenizer = SnapLexer("&foo")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .ampersand),
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(1, 4)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeDoubleAmpersand() {
        let tokenizer = SnapLexer("&&")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(
                    sourceAnchor: tokenizer.lineMapper.anchor(0, 2),
                    op: .doubleAmpersand
                ),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizeUnaryBang() {
        let tokenizer = SnapLexer("!foo")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .bang),
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(1, 4)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeDoublePipe() {
        let tokenizer = SnapLexer("||")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 2), op: .doublePipe),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizePipe() {
        let tokenizer = SnapLexer("|")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .pipe),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))
            ]
        )
    }

    func testTokenizeAdditionSymbol() {
        let tokenizer = SnapLexer("+")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .plus),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))
            ]
        )
    }

    func testTokenizeMultiplicationSymbol() {
        let tokenizer = SnapLexer("*")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .star),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))
            ]
        )
    }

    func testTokenizeDivisionSymbol() {
        let tokenizer = SnapLexer("/")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .divide),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))
            ]
        )
    }

    func testTokenizeModulusSymbol() {
        let tokenizer = SnapLexer("%")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .modulus),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))
            ]
        )
    }

    func testTokenizeParentheses() {
        let tokenizer = SnapLexer("()")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenParenLeft(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                TokenParenRight(sourceAnchor: tokenizer.lineMapper.anchor(1, 2)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizeParentheses2() {
        let tokenizer = SnapLexer("(2-1)")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenParenLeft(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(1, 2), literal: 2),
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(2, 3), op: .minus),
                TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(3, 4), literal: 1),
                TokenParenRight(sourceAnchor: tokenizer.lineMapper.anchor(4, 5)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(5, 5))
            ]
        )
    }

    func testTokenizeVar() {
        let tokenizer = SnapLexer("var")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenVar(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))
            ]
        )
    }

    func testTokenizeIf() {
        let tokenizer = SnapLexer("if")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIf(sourceAnchor: tokenizer.lineMapper.anchor(0, 2)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizeElse() {
        let tokenizer = SnapLexer("else")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenElse(sourceAnchor: tokenizer.lineMapper.anchor(0, 4)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeCurlyBranches() {
        let tokenizer = SnapLexer("{}")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenCurlyLeft(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                TokenCurlyRight(sourceAnchor: tokenizer.lineMapper.anchor(1, 2)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizeWhile() {
        let tokenizer = SnapLexer("while")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenWhile(sourceAnchor: tokenizer.lineMapper.anchor(0, 5)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(5, 5))
            ]
        )
    }

    func testTokenizeFor() {
        let tokenizer = SnapLexer("for")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenFor(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))
            ]
        )
    }

    func testTokenizeIn() {
        let tokenizer = SnapLexer("in")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIn(sourceAnchor: tokenizer.lineMapper.anchor(0, 2)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizeSingleCharacterIdentifier() {
        let tokenizer = SnapLexer("a")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))
            ]
        )
    }

    func testTokenizeBooleanTrue() {
        let tokenizer = SnapLexer("true")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenBoolean(sourceAnchor: tokenizer.lineMapper.anchor(0, 4), literal: true),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeBooleanFalse() {
        let tokenizer = SnapLexer("false")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenBoolean(sourceAnchor: tokenizer.lineMapper.anchor(0, 5), literal: false),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(5, 5))
            ]
        )
    }

    func testTokenizeStatic() {
        let tokenizer = SnapLexer("static")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenStatic(sourceAnchor: tokenizer.lineMapper.anchor(0, 6)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(6, 6))
            ]
        )
    }

    func testTokenizeFunc() {
        let tokenizer = SnapLexer("func")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenFunc(sourceAnchor: tokenizer.lineMapper.anchor(0, 4)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeArrow() {
        let tokenizer = SnapLexer("->")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenArrow(sourceAnchor: tokenizer.lineMapper.anchor(0, 2)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizeUInt8() {
        let tokenizer = SnapLexer("u8")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenType(sourceAnchor: tokenizer.lineMapper.anchor(0, 2), type: .u8),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizeUInt16() {
        let tokenizer = SnapLexer("u16")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenType(sourceAnchor: tokenizer.lineMapper.anchor(0, 3), type: .u16),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))
            ]
        )
    }

    func testTokenizeInt8() {
        let tokenizer = SnapLexer("i8")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenType(sourceAnchor: tokenizer.lineMapper.anchor(0, 2), type: .i8),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizeInt16() {
        let tokenizer = SnapLexer("i16")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenType(sourceAnchor: tokenizer.lineMapper.anchor(0, 3), type: .i16),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))
            ]
        )
    }

    func testTokenizeBool_1() {
        let tokenizer = SnapLexer("bool")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenType(sourceAnchor: tokenizer.lineMapper.anchor(0, 4), type: .bool),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeBool_2() {
        let tokenizer = SnapLexer("boolasdf")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 8)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(8, 8))
            ]
        )
    }

    func testTokenizeVoid() {
        let tokenizer = SnapLexer("void")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenType(sourceAnchor: tokenizer.lineMapper.anchor(0, 4), type: .void),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeAs_1() {
        let tokenizer = SnapLexer("as")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenAs(sourceAnchor: tokenizer.lineMapper.anchor(0, 2)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizeAs_2() {
        let tokenizer = SnapLexer("bass")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 4)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeAs_3() {
        let tokenizer = SnapLexer("asdf")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 4)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeBitcast() {
        let tokenizer = SnapLexer("bitcastAs")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenBitcastAs(sourceAnchor: tokenizer.lineMapper.anchor(0, 9)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(9, 9))
            ]
        )
    }

    func testTokenizeSquareBrackets() {
        let tokenizer = SnapLexer("foo[[bar]]")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                TokenSquareBracketLeft(sourceAnchor: tokenizer.lineMapper.anchor(3, 4)),
                TokenSquareBracketLeft(sourceAnchor: tokenizer.lineMapper.anchor(4, 5)),
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(5, 8)),
                TokenSquareBracketRight(sourceAnchor: tokenizer.lineMapper.anchor(8, 9)),
                TokenSquareBracketRight(sourceAnchor: tokenizer.lineMapper.anchor(9, 10)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(10, 10))
            ]
        )
    }

    func testTokenizeQuotedLiteralString() {
        let tokenizer = SnapLexer("\"test\"")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenLiteralString(
                    sourceAnchor: tokenizer.lineMapper.anchor(0, 6),
                    literal: "test"
                ),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(6, 6))
            ]
        )
    }

    func testTokenizeQuotedStringWithEscapeCharacters_DoubleQuote() {
        let tokenizer = SnapLexer(#""\t\n\r\"\'\\\0""#)
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenLiteralString(
                    sourceAnchor: tokenizer.lineMapper.anchor(0, 16),
                    literal: "\t\n\r\"\'\\\0"
                ),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(16, 16))
            ]
        )
    }

    func testTokenizeMultilineStringLiteral_OneLine() {
        let tokenizer = SnapLexer(
            """
            \"\"\"test\"\"\"
            """
        )
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenLiteralString(
                    sourceAnchor: tokenizer.lineMapper.anchor(0, 10),
                    literal: "test"
                ),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(10, 10))
            ]
        )
    }

    func testTokenizeMultilineStringLiteral_NoLeadingWhitespace() {
        let tokenizer = SnapLexer(
            """
            \"\"\"
            test
            \"\"\"
            """
        )
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenLiteralString(
                    sourceAnchor: tokenizer.lineMapper.anchor(0, 12),
                    literal: "test"
                ),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(12, 12))
            ]
        )
    }

    func testTokenizeMultilineStringLiteral_WithLeadingWhitespace() {
        let tokenizer = SnapLexer(
            """
            \"\"\"
                foo
                bar
                \"\"\"
            """
        )
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenLiteralString(
                    sourceAnchor: tokenizer.lineMapper.anchor(0, 27),
                    literal: "foo\nbar"
                ),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(27, 27))
            ]
        )
    }

    func testTokenizeUnderscore() {
        let tokenizer = SnapLexer("_")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenUnderscore(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))
            ]
        )
    }

    func testTokenizeUnderscoreAdjacentToOtherTokens() {
        let tokenizer = SnapLexer("[_]")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenSquareBracketLeft(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                TokenUnderscore(sourceAnchor: tokenizer.lineMapper.anchor(1, 2)),
                TokenSquareBracketRight(sourceAnchor: tokenizer.lineMapper.anchor(2, 3)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))
            ]
        )
    }

    func testTokenizeIdentifierWithUnderscore() {
        let tokenizer = SnapLexer("foo_bar")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 7)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(7, 7))
            ]
        )
    }

    func testTokenizeDoubleDot() {
        let tokenizer = SnapLexer("0..1")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), literal: 0),
                TokenDoubleDot(sourceAnchor: tokenizer.lineMapper.anchor(1, 3)),
                TokenNumber(sourceAnchor: tokenizer.lineMapper.anchor(3, 4), literal: 1),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeDot() {
        let tokenizer = SnapLexer("foo.bar")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                TokenDot(sourceAnchor: tokenizer.lineMapper.anchor(3, 4)),
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(4, 7)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(7, 7))
            ]
        )
    }

    func testTokenizeUndefined_1() {
        let tokenizer = SnapLexer("undefined")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenUndefined(sourceAnchor: tokenizer.lineMapper.anchor(0, 9)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(9, 9))
            ]
        )
    }

    func testTokenizeUndefined_2() {
        let tokenizer = SnapLexer("undefined1")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 10)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(10, 10))
            ]
        )
    }

    func testTokenizeStruct_1() {
        let tokenizer = SnapLexer("structure")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 9)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(9, 9))
            ]
        )
    }

    func testTokenizeStruct_2() {
        let tokenizer = SnapLexer("struct")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenStruct(sourceAnchor: tokenizer.lineMapper.anchor(0, 6)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(6, 6))
            ]
        )
    }

    func testTokenizeConst() {
        let tokenizer = SnapLexer("const")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenConst(sourceAnchor: tokenizer.lineMapper.anchor(0, 5)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(5, 5))
            ]
        )
    }

    func testTokenizeImpl() {
        let tokenizer = SnapLexer("impl")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenImpl(sourceAnchor: tokenizer.lineMapper.anchor(0, 4)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeIs() {
        let tokenizer = SnapLexer("is")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIs(sourceAnchor: tokenizer.lineMapper.anchor(0, 2)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))
            ]
        )
    }

    func testTokenizeTypealias() {
        let tokenizer = SnapLexer("typealias")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenTypealias(sourceAnchor: tokenizer.lineMapper.anchor(0, 9)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(9, 9))
            ]
        )
    }

    func testTokenizeMatch() {
        let tokenizer = SnapLexer("match")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenMatch(sourceAnchor: tokenizer.lineMapper.anchor(0, 5)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(5, 5))
            ]
        )
    }

    func testTokenizePublic() {
        let tokenizer = SnapLexer("public")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenPublic(sourceAnchor: tokenizer.lineMapper.anchor(0, 6)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(6, 6))
            ]
        )
    }

    func testTokenizePrivate() {
        let tokenizer = SnapLexer("private")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenPrivate(sourceAnchor: tokenizer.lineMapper.anchor(0, 7)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(7, 7))
            ]
        )
    }

    func testTokenizeAssert() {
        let tokenizer = SnapLexer("assert")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenAssert(sourceAnchor: tokenizer.lineMapper.anchor(0, 6)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(6, 6))
            ]
        )
    }

    func testTokenizeIdentifierWithLeadingUnderscores() {
        let tokenizer = SnapLexer("__testMain")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenIdentifier(sourceAnchor: tokenizer.lineMapper.anchor(0, 10)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(10, 10))
            ]
        )
    }

    func testTokenizeTest() {
        let tokenizer = SnapLexer("test")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenTest(sourceAnchor: tokenizer.lineMapper.anchor(0, 4)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(4, 4))
            ]
        )
    }

    func testTokenizeImport() {
        let tokenizer = SnapLexer("import")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenImport(sourceAnchor: tokenizer.lineMapper.anchor(0, 6)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(6, 6))
            ]
        )
    }

    func testTokenizeTrait() {
        let tokenizer = SnapLexer("trait")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenTrait(sourceAnchor: tokenizer.lineMapper.anchor(0, 5)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(5, 5))
            ]
        )
    }

    func testTokenizeCaret() {
        let tokenizer = SnapLexer("^")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .caret),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))
            ]
        )
    }

    func testTokenizeTilde() {
        let tokenizer = SnapLexer("~")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenOperator(sourceAnchor: tokenizer.lineMapper.anchor(0, 1), op: .tilde),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))
            ]
        )
    }

    func testTokenizeAsm() {
        let tokenizer = SnapLexer("asm")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenAsm(sourceAnchor: tokenizer.lineMapper.anchor(0, 3)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(3, 3))
            ]
        )
    }

    func testTokenizeSizeof() {
        let tokenizer = SnapLexer("sizeof")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenSizeof(sourceAnchor: tokenizer.lineMapper.anchor(0, 6)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(6, 6))
            ]
        )
    }

    func testTokenizeAt() {
        let tokenizer = SnapLexer("@")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [
                TokenAt(sourceAnchor: tokenizer.lineMapper.anchor(0, 1)),
                TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(1, 1))
            ]
        )
    }

    func testTokenizeBackslashNewLine() {
        let tokenizer = SnapLexer("\\\n")
        tokenizer.scanTokens()
        XCTAssertEqual(
            tokenizer.tokens,
            [TokenEOF(sourceAnchor: tokenizer.lineMapper.anchor(2, 2))]
        )
    }
}
