//
//  AssemblerLexerTests.swift
//  TurtleAssemblerCoreTests
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleAssemblerCore
import TurtleCompilerToolbox

class AssemblerLexerTests: XCTestCase {
    func testTokenizeEmptyString() {
        let text = ""
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(sourceAnchor: lineMapper.anchor(0, 0))])
    }
    
    func testTokenizeNewLine() {
        let text = "\n"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(sourceAnchor: lineMapper.anchor(0, 1)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeSomeNewLines() {
        let text = "\n\n\n"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(sourceAnchor: lineMapper.anchor(0, 1)),
                                          TokenNewline(sourceAnchor: lineMapper.anchor(1, 2)),
                                          TokenNewline(sourceAnchor: lineMapper.anchor(2, 3)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeComma() {
        let text = ","
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenComma(sourceAnchor: lineMapper.anchor(0, 1)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeComment() {
        let text = "// comment"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(sourceAnchor: lineMapper.anchor(10, 10))])
    }
    
    func testTokenizeCommaAndComment() {
        let text = ",// comment"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenComma(sourceAnchor: lineMapper.anchor(0, 1)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(11, 11))])
    }
    
    func testTokenizeCommentWithWhitespace() {
        let text = " \t  // comment\n"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(sourceAnchor: lineMapper.anchor(14, 15)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(15, 15))])
    }
    
    func testUnexpectedCharacter() {
        let tokenizer = AssemblerLexer(withString: "'")
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(tokenizer.errors.first?.sourceAnchor, tokenizer.lineMapper.anchor(0, 1))
        XCTAssertEqual(tokenizer.errors.first?.message, "unexpected character: `''")
    }
    
    func testTokenizeIdentifier() {
        let text = "Bogus"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: lineMapper.anchor(0, 5)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(5, 5))])
    }
    
    func testFailToTokenizeInvalidIdentifier() {
        let tokenizer = AssemblerLexer(withString: "*")
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(tokenizer.errors.first?.sourceAnchor, tokenizer.lineMapper.anchor(0, 1))
        XCTAssertEqual(tokenizer.errors.first?.message, "unexpected character: `*'")
    }
    
    func testTokenizeDecimalLiteral() {
        let text = "123"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: lineMapper.anchor(0, 3), literal: 123),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeNegativeDecimalLiteral() {
        let text = "-123"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: lineMapper.anchor(0, 4), literal: -123),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeDollarHexadecimalLiteral() {
        let text = "$ff"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: lineMapper.anchor(0, 3), literal: 255),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeHexadecimalLiteral() {
        let text = "0xff"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: lineMapper.anchor(0, 4), literal: 255),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeHexadecimalLiteralCapital() {
        let text = "0xFF"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: lineMapper.anchor(0, 4), literal: 255),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeBinaryLiteral() {
        let text = "0b11"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: lineMapper.anchor(0, 4), literal: 3),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(4, 4))])
    }
    
    func testTokenizeLiteralCharacter() {
        let text = "'A'"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(sourceAnchor: lineMapper.anchor(0, 3), literal: 65),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeIdentifierWhichStartsWithA() {
        let text = "Animal"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: lineMapper.anchor(0, 6)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(6, 6))])
    }
    
    func testTokenizeRegisterA() {
        let text = "A"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(sourceAnchor: lineMapper.anchor(0, 1), literal: .A),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeRegisterB() {
        let text = "B"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(sourceAnchor: lineMapper.anchor(0, 1), literal: .B),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeRegisterC() {
        let text = "C"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(sourceAnchor: lineMapper.anchor(0, 1), literal: .C),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeRegisterD() {
        let text = "D"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(sourceAnchor: lineMapper.anchor(0, 1), literal: .D),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeRegisterE() {
        let text = "E"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(sourceAnchor: lineMapper.anchor(0, 1), literal: .E),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeRegisterM() {
        let text = "M"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(sourceAnchor: lineMapper.anchor(0, 1), literal: .M),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeRegisterP() {
        let text = "P"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(sourceAnchor: lineMapper.anchor(0, 1), literal: .P),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeRegisterU() {
        let text = "U"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(sourceAnchor: lineMapper.anchor(0, 1), literal: .U),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeRegisterV() {
        let text = "V"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(sourceAnchor: lineMapper.anchor(0, 1), literal: .V),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeRegisterX() {
        let text = "X"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(sourceAnchor: lineMapper.anchor(0, 1), literal: .X),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeRegisterY() {
        let text = "Y"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(sourceAnchor: lineMapper.anchor(0, 1), literal: .Y),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeRegisterNone() {
        let text = "_"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(sourceAnchor: lineMapper.anchor(0, 1), literal: .NONE),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(1, 1))])
    }
    
    func testTokenizeColon() {
        let text = "label:"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: lineMapper.anchor(0, 5)),
                                          TokenColon(sourceAnchor: lineMapper.anchor(5, 6)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(6, 6))])
    }
    
    func testTokenizeADD() {
        let text = "ADD"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(sourceAnchor: lineMapper.anchor(0, 3)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeLet() {
        let text = "let"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLet(sourceAnchor: lineMapper.anchor(0, 3)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(3, 3))])
    }
    
    func testTokenizeEqualAdjacentToOtherTokens() {
        let text = "let foo=1"
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLet(sourceAnchor: lineMapper.anchor(0, 3)),
                                          TokenIdentifier(sourceAnchor: lineMapper.anchor(4, 7)),
                                          TokenEqual(sourceAnchor: lineMapper.anchor(7, 8)),
                                          TokenNumber(sourceAnchor: lineMapper.anchor(8, 9), literal: 1),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(9, 9))])
    }
    
    func testTokenizeEqualByItself() {
        let text = "let foo ="
        let lineMapper = SourceLineRangeMapper(text: text)
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLet(sourceAnchor: lineMapper.anchor(0, 3)),
                                          TokenIdentifier(sourceAnchor: lineMapper.anchor(4, 7)),
                                          TokenEqual(sourceAnchor: lineMapper.anchor(8, 9)),
                                          TokenEOF(sourceAnchor: lineMapper.anchor(9, 9))])
    }
}
