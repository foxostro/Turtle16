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
        let tokenizer = AssemblerLexer(withString: "")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeNewLine() {
        let tokenizer = AssemblerLexer(withString: "\n")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                          TokenEOF(lineNumber: 2, lexeme: "")])
    }
    
    func testTokenizeSomeNewLines() {
        let tokenizer = AssemblerLexer(withString: "\n\n\n")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                          TokenNewline(lineNumber: 2, lexeme: "\n"),
                                          TokenNewline(lineNumber: 3, lexeme: "\n"),
                                          TokenEOF(lineNumber: 4, lexeme: "")])
    }
    
    func testTokenizeComma() {
        let tokenizer = AssemblerLexer(withString: ",")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenComma(lineNumber: 1, lexeme: ","),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeComment() {
        let tokenizer = AssemblerLexer(withString: "// comment")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeCommaAndComment() {
        let tokenizer = AssemblerLexer(withString: ",// comment")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenComma(lineNumber: 1, lexeme: ","),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeCommentWithWhitespace() {
        let tokenizer = AssemblerLexer(withString: " \t  // comment\n")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                          TokenEOF(lineNumber: 2, lexeme: "")])
    }
    
    func testUnexpectedCharacter() {
        let tokenizer = AssemblerLexer(withString: "'")
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.first?.line, 1)
        XCTAssertEqual(tokenizer.errors.first?.message, "unexpected character: `''")
    }
    
    func testTokenizeIdentifier() {
        let tokenizer = AssemblerLexer(withString: "Bogus")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(lineNumber: 1, lexeme: "Bogus"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testFailToTokenizeInvalidIdentifier() {
        let tokenizer = AssemblerLexer(withString: "*")
        tokenizer.scanTokens()
        XCTAssertTrue(tokenizer.hasError)
        XCTAssertEqual(tokenizer.errors.first?.line, 1)
        XCTAssertEqual(tokenizer.errors.first?.message, "unexpected character: `*'")
    }
    
    func testTokenizeDecimalLiteral() {
        let tokenizer = AssemblerLexer(withString: "123")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "123", literal: 123),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeNegativeDecimalLiteral() {
        let tokenizer = AssemblerLexer(withString: "-123")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "-123", literal: -123),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeDollarHexadecimalLiteral() {
        let tokenizer = AssemblerLexer(withString: "$ff")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "$ff", literal: 255),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeHexadecimalLiteral() {
        let tokenizer = AssemblerLexer(withString: "0xff")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "0xff", literal: 255),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeHexadecimalLiteralCapital() {
        let tokenizer = AssemblerLexer(withString: "0XFF")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "0XFF", literal: 255),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeBinaryLiteral() {
        let tokenizer = AssemblerLexer(withString: "0b11")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "0b11", literal: 3),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeLiteralCharacter() {
        let tokenizer = AssemblerLexer(withString: "'A'")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "'A'", literal: 65),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeIdentifierWhichStartsWithA() {
        let tokenizer = AssemblerLexer(withString: "Animal")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(lineNumber: 1, lexeme: "Animal"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterA() {
        let tokenizer = AssemblerLexer(withString: "A")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "A", literal: .A),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterB() {
        let tokenizer = AssemblerLexer(withString: "B")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "B", literal: .B),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterC() {
        let tokenizer = AssemblerLexer(withString: "C")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "C", literal: .C),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterD() {
        let tokenizer = AssemblerLexer(withString: "D")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "D", literal: .D),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterE() {
        let tokenizer = AssemblerLexer(withString: "E")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "E", literal: .E),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterM() {
        let tokenizer = AssemblerLexer(withString: "M")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "M", literal: .M),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterP() {
        let tokenizer = AssemblerLexer(withString: "P")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "P", literal: .P),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterU() {
        let tokenizer = AssemblerLexer(withString: "U")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "U", literal: .U),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterV() {
        let tokenizer = AssemblerLexer(withString: "V")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "V", literal: .V),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterX() {
        let tokenizer = AssemblerLexer(withString: "X")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "X", literal: .X),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterY() {
        let tokenizer = AssemblerLexer(withString: "Y")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "Y", literal: .Y),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterNone() {
        let tokenizer = AssemblerLexer(withString: "_")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "_", literal: .NONE),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeColon() {
        let tokenizer = AssemblerLexer(withString: "label:")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(lineNumber: 1, lexeme: "label"),
                                          TokenColon(lineNumber: 1, lexeme: ":"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeADD() {
        let tokenizer = AssemblerLexer(withString: "ADD")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(lineNumber: 1, lexeme: "ADD"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeLet() {
        let tokenizer = AssemblerLexer(withString: "let")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLet(lineNumber: 1, lexeme: "let"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeEqualAdjacentToOtherTokens() {
        let tokenizer = AssemblerLexer(withString: "let foo=1")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLet(lineNumber: 1, lexeme: "let"),
                                          TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                          TokenEqual(lineNumber: 1, lexeme: "="),
                                          TokenNumber(lineNumber: 1, lexeme: "1", literal: 1),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeEqualByItself() {
        let tokenizer = AssemblerLexer(withString: "let foo =")
        tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLet(lineNumber: 1, lexeme: "let"),
                                          TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                          TokenEqual(lineNumber: 1, lexeme: "="),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
}
