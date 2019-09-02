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
    func testTokenizeEmptyString() {
        let tokenizer = AssemblerScanner(withString: "")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeNewLine() {
        let tokenizer = AssemblerScanner(withString: "\n")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                          TokenEOF(lineNumber: 2, lexeme: "")])
    }
    
    func testTokenizeSomeNewLines() {
        let tokenizer = AssemblerScanner(withString: "\n\n\n")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                          TokenNewline(lineNumber: 2, lexeme: "\n"),
                                          TokenNewline(lineNumber: 3, lexeme: "\n"),
                                          TokenEOF(lineNumber: 4, lexeme: "")])
    }
    
    func testTokenizeComma() {
        let tokenizer = AssemblerScanner(withString: ",")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenComma(lineNumber: 1, lexeme: ","),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeComment() {
        let tokenizer = AssemblerScanner(withString: "// comment")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeCommaAndComment() {
        let tokenizer = AssemblerScanner(withString: ",// comment")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenComma(lineNumber: 1, lexeme: ","),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeCommentWithWhitespace() {
        let tokenizer = AssemblerScanner(withString: " \t  // comment\n")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                          TokenEOF(lineNumber: 2, lexeme: "")])
    }
    
    func testUnexpectedCharacter() {
        let tokenizer = AssemblerScanner(withString: "'")
        XCTAssertThrowsError(try tokenizer.scanTokens()) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "unexpected character: `''")
        }
    }
    
    func testTokenizeNOP() {
        let tokenizer = AssemblerScanner(withString: "NOP")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNOP(lineNumber: 1, lexeme: "NOP"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeCMP() {
        let tokenizer = AssemblerScanner(withString: "CMP")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenCMP(lineNumber: 1, lexeme: "CMP"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeHLT() {
        let tokenizer = AssemblerScanner(withString: "HLT")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenHLT(lineNumber: 1, lexeme: "HLT"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeJMP() {
        let tokenizer = AssemblerScanner(withString: "JMP")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenJMP(lineNumber: 1, lexeme: "JMP"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeJC() {
        let tokenizer = AssemblerScanner(withString: "JC")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenJC(lineNumber: 1, lexeme: "JC"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeIdentifier() {
        let tokenizer = AssemblerScanner(withString: "Bogus")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(lineNumber: 1, lexeme: "Bogus"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testFailToTokenizeInvalidIdentifier() {
        let tokenizer = AssemblerScanner(withString: "*")
        XCTAssertThrowsError(try tokenizer.scanTokens()) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "unexpected character: `*'")
        }
    }
    
    func testTokenizeDecimalLiteral() {
        let tokenizer = AssemblerScanner(withString: "123")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "123", literal: 123),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeNegativeDecimalLiteral() {
        let tokenizer = AssemblerScanner(withString: "-123")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "-123", literal: -123),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeDollarHexadecimalLiteral() {
        let tokenizer = AssemblerScanner(withString: "$ff")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "$ff", literal: 255),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeHexadecimalLiteral() {
        let tokenizer = AssemblerScanner(withString: "0xff")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "0xff", literal: 255),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeHexadecimalLiteralCapital() {
        let tokenizer = AssemblerScanner(withString: "0XFF")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenNumber(lineNumber: 1, lexeme: "0XFF", literal: 255),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeIdentifierWhichStartsWithA() {
        let tokenizer = AssemblerScanner(withString: "Animal")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(lineNumber: 1, lexeme: "Animal"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterA() {
        let tokenizer = AssemblerScanner(withString: "A")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "A", literal: "A"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterB() {
        let tokenizer = AssemblerScanner(withString: "B")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "B", literal: "B"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterC() {
        let tokenizer = AssemblerScanner(withString: "C")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "C", literal: "C"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterD() {
        let tokenizer = AssemblerScanner(withString: "D")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "D", literal: "D"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterE() {
        let tokenizer = AssemblerScanner(withString: "E")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "E", literal: "E"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterF() {
        let tokenizer = AssemblerScanner(withString: "M")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "M", literal: "M"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterX() {
        let tokenizer = AssemblerScanner(withString: "X")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "X", literal: "X"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeRegisterY() {
        let tokenizer = AssemblerScanner(withString: "Y")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenRegister(lineNumber: 1, lexeme: "Y", literal: "Y"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeColon() {
        let tokenizer = AssemblerScanner(withString: "label:")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenIdentifier(lineNumber: 1, lexeme: "label"),
                                          TokenColon(lineNumber: 1, lexeme: ":"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeADD() {
        let tokenizer = AssemblerScanner(withString: "ADD")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenADD(lineNumber: 1, lexeme: "ADD"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeLI() {
        let tokenizer = AssemblerScanner(withString: "LI")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenLI(lineNumber: 1, lexeme: "LI"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
    
    func testTokenizeMOV() {
        let tokenizer = AssemblerScanner(withString: "MOV")
        try! tokenizer.scanTokens()
        XCTAssertEqual(tokenizer.tokens, [TokenMOV(lineNumber: 1, lexeme: "MOV"),
                                          TokenEOF(lineNumber: 1, lexeme: "")])
    }
}
