//
//  ParserTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class ParserTests: XCTestCase {
    func testParseEmptyProgramYieldsEmptyAST() {
        let parser = Parser()
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(children: []))
    }
    
    func testParseAnythingYieldsError() {
        let parser = Parser(tokens: [TokenNewline(),
                                     TokenNewline(),
                                     TokenEOF()])
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertEqual(parser.errors.count, 3)
        if parser.errors.count > 0 {
            XCTAssertEqual(parser.errors[0].message, "override consumeStatement() in a child class")
        }
        if parser.errors.count > 1 {
            XCTAssertEqual(parser.errors[1].message, "override consumeStatement() in a child class")
        }
        if parser.errors.count > 2 {
            XCTAssertEqual(parser.errors[2].message, "override consumeStatement() in a child class")
        }
        XCTAssertNil(parser.syntaxTree)
    }
    
    func testAdvanceSkipsPastNextToken() {
        let parser = Parser(tokens: [TokenNewline(),
                                     TokenEOF()])
        parser.advance()
        XCTAssertEqual(parser.peek(), TokenEOF())
        XCTAssertEqual(parser.previous, TokenNewline())
    }
    
    func testAdvanceWillNotAdvancePastTheEnd() {
        let parser = Parser(tokens: [TokenEOF()])
        parser.advance()
        XCTAssertEqual(parser.previous, TokenEOF())
        XCTAssertNil(parser.peek())
        parser.advance()
        XCTAssertNil(parser.previous)
        XCTAssertNil(parser.peek())
    }
    
    func testPeekLooksAhead() {
        let parser = Parser(tokens: [TokenNewline(),
                                     TokenEOF()])
        
        XCTAssertEqual(parser.peek(), TokenNewline())
        XCTAssertEqual(parser.peek(0), TokenNewline())
        XCTAssertEqual(parser.peek(1), TokenEOF())
        XCTAssertEqual(parser.peek(2), nil)
    }
    
    func testAcceptYieldsNilWhenThereAreNoTokens() {
        let parser = Parser()
        XCTAssertNil(parser.accept(TokenNewline.self))
    }
    
    func testAcceptYieldsNilWhenNextTokenFailsToMatchGivenType() {
        let parser = Parser(tokens: [TokenNewline(),
                                         TokenEOF()])
        XCTAssertNil(parser.accept(TokenComma.self))
    }
    
    func testWhenAcceptMatchesTheTypeThenItAdvances() {
        let parser = Parser(tokens: [TokenNewline(),
                                         TokenEOF()])
        XCTAssertEqual(parser.accept(TokenNewline.self), TokenNewline())
        XCTAssertEqual(parser.tokens, [TokenEOF()])
    }
    
    func testAcceptCanMatchAnArrayOfTypes() {
        let parser = Parser(tokens: [TokenComma(),
                                     TokenIdentifier(),
                                     TokenNewline(),
                                     TokenEOF()])
        XCTAssertNil(parser.accept([]))
        XCTAssertEqual(parser.accept([TokenComma.self, TokenIdentifier.self]), TokenComma())
        XCTAssertEqual(parser.accept([TokenComma.self, TokenIdentifier.self]), TokenIdentifier())
        XCTAssertNil(parser.accept([TokenComma.self, TokenIdentifier.self]))
    }
    
    func testExpectThrowsWhenTokenTypeFailsToMatch() {
        let parser = Parser(tokens: [TokenEOF()])
        XCTAssertThrowsError(try parser.expect(type: TokenComma.self, error: CompilerError(message: ""))) {
            XCTAssertNotNil($0 as? CompilerError)
        }
    }
    
    func testExpectCanMatchAgainstAnArrayOfTokenTypes() {
        let parser = Parser(tokens: [TokenComma(),
                                     TokenIdentifier(),
                                     TokenNewline(),
                                     TokenEOF()])
        XCTAssertThrowsError(try parser.expect(types: [],
                                               error: CompilerError(message: ""))) {
            XCTAssertNotNil($0 as? CompilerError)
        }
        XCTAssertEqual(try! parser.expect(types: [TokenComma.self, TokenIdentifier.self],
                                          error: CompilerError(message: "")),
                       TokenComma())
        XCTAssertEqual(try! parser.expect(types: [TokenComma.self, TokenIdentifier.self],
                                          error: CompilerError(message: "")),
                       TokenIdentifier())
        XCTAssertThrowsError(try parser.expect(types: [TokenComma.self, TokenIdentifier.self],
                                               error: CompilerError(message: ""))) {
            XCTAssertNotNil($0 as? CompilerError)
        }
    }
    
    func testUnexpectedEndOfInputErrorWithNoTokensRemaining() {
        let parser = Parser()
        let error = parser.unexpectedEndOfInputError()
        XCTAssertEqual(error.message, "unexpected end of input")
    }
    
    func testUnexpectedEndOfInputErrorWithNoPreviousToken() {
        let parser = Parser(tokens: [TokenNewline()])
        parser.advance()
        let error = parser.unexpectedEndOfInputError()
        XCTAssertEqual(error.message, "unexpected end of input")
    }
    
    func testUnexpectedEndOfInputErrorWithRemainingTokens() {
        let parser = Parser(tokens: [TokenNewline()])
        let error = parser.unexpectedEndOfInputError()
        XCTAssertEqual(error.message, "unexpected end of input")
    }
    
    func testAcceptWillTakeNewlinesWhenThatIsSpecified() {
        let parser = Parser(tokens: [TokenNewline(),
                                     TokenEOF()])
        XCTAssertEqual(parser.accept(TokenNewline.self), TokenNewline())
    }
    
    func testAcceptWillOtherwiseIgnoreNewlines_1() {
        let parser = Parser(tokens: [TokenNewline(),
                                     TokenComma(),
                                     TokenEOF()])
        XCTAssertEqual(parser.accept(TokenComma.self), TokenComma())
    }
    
    func testAcceptWillOtherwiseIgnoreNewlines_2() {
        let parser = Parser(tokens: [TokenNewline(),
                                     TokenComma(),
                                     TokenEOF()])
        XCTAssertEqual(parser.accept([TokenComma.self, TokenSemicolon.self]), TokenComma())
    }
    
    func testAcceptWillNotConsumeNewlinesWhenItFailsToMatch_1() {
        let parser = Parser(tokens: [TokenNewline(),
                                     TokenSemicolon(),
                                     TokenEOF()])
        XCTAssertNil(parser.accept(TokenComma.self))
        XCTAssertEqual(parser.peek(), TokenNewline())
    }
    
    func testAcceptWillNotConsumeNewlinesWhenItFailsToMatch_2() {
        let parser = Parser(tokens: [TokenNewline(),
                                     TokenSemicolon(),
                                     TokenEOF()])
        XCTAssertNil(parser.accept([TokenComma.self]))
        XCTAssertEqual(parser.peek(), TokenNewline())
    }
}
