//
//  AssemblerLexerTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class AssemblerLexerTests: XCTestCase {
    func testTokenizeEmptyString() {
        let tokenizer = AssemblerLexer(withString: "")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeNewLine() {
        let tokenizer = AssemblerLexer(withString: "\n")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                          TokenEOF(lineNumber: 2, lexeme: "")])
    }
    
    func testTokenizeSomeNewLines() {
        let tokenizer = AssemblerLexer(withString: "\n\n\n")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                          TokenNewline(lineNumber: 2, lexeme: "\n"),
                                          TokenNewline(lineNumber: 3, lexeme: "\n"),
                                          TokenEOF(lineNumber: 4, lexeme: "")])
    }
    
    func testTokenizeComma() {
        let tokenizer = AssemblerLexer(withString: ",")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenComma(lineNumber: 1, lexeme: ","),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeComment() {
        let tokenizer = AssemblerLexer(withString: "// comment")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeCommaAndComment() {
        let tokenizer = AssemblerLexer(withString: ",// comment")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenComma(lineNumber: 1, lexeme: ","),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeCommentWithWhitespace() {
        let tokenizer = AssemblerLexer(withString: " \t  // comment\n")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                          TokenEOF(lineNumber: 2, lexeme: "")])
    }
    
    func testUnexpectedCharacter() {
        let tokenizer = AssemblerLexer(withString: "'")
        XCTAssertThrowsError(try tokenizer.scanTokens()) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "unexpected character: `''")
        }
    }
    
    func testTokenizeNOP() {
        let tokenizer = AssemblerLexer(withString: "NOP")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNOP(lineNumber: 1, lexeme: "NOP"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeCMP() {
        let tokenizer = AssemblerLexer(withString: "CMP")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenCMP(lineNumber: 1, lexeme: "CMP"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeHLT() {
        let tokenizer = AssemblerLexer(withString: "HLT")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenHLT(lineNumber: 1, lexeme: "HLT"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeJMP() {
        let tokenizer = AssemblerLexer(withString: "JMP")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenJMP(lineNumber: 1, lexeme: "JMP"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeJC() {
        let tokenizer = AssemblerLexer(withString: "JC")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenJC(lineNumber: 1, lexeme: "JC"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeIdentifier() {
        let tokenizer = AssemblerLexer(withString: "Bogus")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(lineNumber: 1, lexeme: "Bogus"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testFailToTokenizeInvalidIdentifier() {
        let tokenizer = AssemblerLexer(withString: "*")
        XCTAssertThrowsError(try tokenizer.scanTokens()) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "unexpected character: `*'")
        }
    }
    
    func testTokenizeDecimalLiteral() {
        let tokenizer = AssemblerLexer(withString: "123")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "123", literal: 123),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeNegativeDecimalLiteral() {
        let tokenizer = AssemblerLexer(withString: "-123")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "-123", literal: -123),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeDollarHexadecimalLiteral() {
        let tokenizer = AssemblerLexer(withString: "$ff")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "$ff", literal: 255),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeHexadecimalLiteral() {
        let tokenizer = AssemblerLexer(withString: "0xff")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "0xff", literal: 255),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeHexadecimalLiteralCapital() {
        let tokenizer = AssemblerLexer(withString: "0XFF")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "0XFF", literal: 255),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeIdentifierWhichStartsWithA() {
        let tokenizer = AssemblerLexer(withString: "Animal")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(lineNumber: 1, lexeme: "Animal"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterA() {
        let tokenizer = AssemblerLexer(withString: "A")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "A", literal: .A),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterB() {
        let tokenizer = AssemblerLexer(withString: "B")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "B", literal: .B),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterC() {
        let tokenizer = AssemblerLexer(withString: "C")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "C", literal: .C),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterD() {
        let tokenizer = AssemblerLexer(withString: "D")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "D", literal: .D),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterE() {
        let tokenizer = AssemblerLexer(withString: "E")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "E", literal: .E),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterF() {
        let tokenizer = AssemblerLexer(withString: "M")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "M", literal: .M),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterX() {
        let tokenizer = AssemblerLexer(withString: "X")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "X", literal: .X),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterY() {
        let tokenizer = AssemblerLexer(withString: "Y")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "Y", literal: .Y),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeColon() {
        let tokenizer = AssemblerLexer(withString: "label:")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(lineNumber: 1, lexeme: "label"),
                                          TokenColon(lineNumber: 1, lexeme: ":"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeADD() {
        let tokenizer = AssemblerLexer(withString: "ADD")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenADD(lineNumber: 1, lexeme: "ADD"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeLI() {
        let tokenizer = AssemblerLexer(withString: "LI")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLI(lineNumber: 1, lexeme: "LI"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeMOV() {
        let tokenizer = AssemblerLexer(withString: "MOV")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenMOV(lineNumber: 1, lexeme: "MOV"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
}
