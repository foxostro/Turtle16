//
//  ParserTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 9/3/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class ParserTests: XCTestCase {
    func testParseEmptyProgramYieldsEmptyAST() {
        let parser = ParserBase()
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, AbstractSyntaxTreeNode())
    }
    
    func testParseAnythingYieldsError() {
        let parser = ParserBase(tokens: [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                         TokenNewline(lineNumber: 2, lexeme: "\n"),
                                         TokenEOF(lineNumber: 3)])
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
        let parser = ParserBase(tokens: [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                         TokenEOF(lineNumber: 2)])
        parser.advance()
        XCTAssertEqual(parser.peek(), TokenEOF(lineNumber: 2))
        XCTAssertEqual(parser.previous, TokenNewline(lineNumber: 1, lexeme: "\n"))
    }
    
    func testAdvanceWillNotAdvancePastTheEnd() {
        let parser = ParserBase(tokens: [TokenEOF(lineNumber: 2)])
        parser.advance()
        XCTAssertEqual(parser.previous, TokenEOF(lineNumber: 2))
        XCTAssertNil(parser.peek())
        parser.advance()
        XCTAssertNil(parser.previous)
        XCTAssertNil(parser.peek())
    }
    
    func testPeekLooksAhead() {
        let parser = ParserBase(tokens: [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                         TokenEOF(lineNumber: 2)])
        
        XCTAssertEqual(parser.peek(), TokenNewline(lineNumber: 1, lexeme: "\n"))
        XCTAssertEqual(parser.peek(0), TokenNewline(lineNumber: 1, lexeme: "\n"))
        XCTAssertEqual(parser.peek(1), TokenEOF(lineNumber: 2))
        XCTAssertEqual(parser.peek(2), nil)
    }
    
    func testAcceptYieldsNilWhenThereAreNoTokens() {
        let parser = ParserBase()
        XCTAssertNil(parser.accept(TokenNewline.self))
    }
    
    func testAcceptYieldsNilWhenNextTokenFailsToMatchGivenType() {
        let parser = ParserBase(tokens: [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                         TokenEOF(lineNumber: 2)])
        XCTAssertNil(parser.accept(TokenLet.self))
    }
    
    func testWhenAcceptMatchesTheTypeThenItAdvances() {
        let parser = ParserBase(tokens: [TokenNewline(lineNumber: 1, lexeme: "\n"),
                                         TokenEOF(lineNumber: 2)])
        XCTAssertEqual(parser.accept(TokenNewline.self), TokenNewline(lineNumber: 1, lexeme: "\n"))
        XCTAssertEqual(parser.tokens, [TokenEOF(lineNumber: 2)])
    }
    
    func testAcceptCanMatchAnArrayOfTypes() {
        let parser = ParserBase(tokens: [TokenLet(lineNumber: 1, lexeme: "let"),
                                         TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                         TokenNewline(lineNumber: 1, lexeme: "\n"),
                                         TokenEOF(lineNumber: 2)])
        XCTAssertNil(parser.accept([]))
        XCTAssertEqual(parser.accept([TokenLet.self, TokenIdentifier.self]), TokenLet(lineNumber: 1, lexeme: "let"))
        XCTAssertEqual(parser.accept([TokenLet.self, TokenIdentifier.self]), TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        XCTAssertNil(parser.accept([TokenLet.self, TokenIdentifier.self]))
    }
    
    func testAcceptCanMatchASingleOperator() {
        let parser = ParserBase(tokens: [TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                         TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                         TokenNewline(lineNumber: 1, lexeme: "\n"),
                                         TokenEOF(lineNumber: 2)])
        XCTAssertNil(parser.accept(operator: .minus))
        XCTAssertEqual(parser.accept(operator: .plus), TokenOperator(lineNumber: 1, lexeme: "+", op: .plus))
        XCTAssertEqual(parser.accept(operator: .minus), TokenOperator(lineNumber: 1, lexeme: "-", op: .minus))
    }
    
    func testAcceptCanMatchAnArrayOfOperators() {
        let parser = ParserBase(tokens: [TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                         TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                         TokenNewline(lineNumber: 1, lexeme: "\n"),
                                         TokenEOF(lineNumber: 2)])
        XCTAssertNil(parser.accept(operators: []))
        XCTAssertNil(parser.accept(operators: [.eq, .divide]))
        XCTAssertEqual(parser.accept(operators: [.plus, .minus]), TokenOperator(lineNumber: 1, lexeme: "+", op: .plus))
        XCTAssertEqual(parser.accept(operators: [.plus, .minus]), TokenOperator(lineNumber: 1, lexeme: "-", op: .minus))
    }
    
    func testExpectThrowsWhenTokenTypeFailsToMatch() {
        let parser = ParserBase(tokens: [TokenEOF(lineNumber: 1)])
        XCTAssertThrowsError(try parser.expect(type: TokenLet.self, error: CompilerError(message: ""))) {
            XCTAssertNotNil($0 as? CompilerError)
        }
    }
    
    func testExpectCanMatchAgainstAnArrayOfTokenTypes() {
        let parser = ParserBase(tokens: [TokenLet(lineNumber: 1, lexeme: "let"),
                                         TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                         TokenNewline(lineNumber: 1, lexeme: "\n"),
                                         TokenEOF(lineNumber: 2)])
        XCTAssertThrowsError(try parser.expect(types: [],
                                               error: CompilerError(message: ""))) {
            XCTAssertNotNil($0 as? CompilerError)
        }
        XCTAssertEqual(try! parser.expect(types: [TokenLet.self, TokenIdentifier.self],
                                          error: CompilerError(message: "")),
                       TokenLet(lineNumber: 1, lexeme: "let"))
        XCTAssertEqual(try! parser.expect(types: [TokenLet.self, TokenIdentifier.self],
                                          error: CompilerError(message: "")),
                       TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        XCTAssertThrowsError(try parser.expect(types: [TokenLet.self, TokenIdentifier.self],
                                               error: CompilerError(message: ""))) {
            XCTAssertNotNil($0 as? CompilerError)
        }
    }
    
    func testUnexpectedEndOfInputErrorWithNoTokensRemaining() {
        let parser = ParserBase()
        let error = parser.unexpectedEndOfInputError()
        XCTAssertEqual(error.message, "unexpected end of input")
        XCTAssertNil(error.line)
    }
    
    func testUnexpectedEndOfInputErrorWithNoPreviousToken() {
        let parser = ParserBase(tokens: [TokenNewline(lineNumber: 1, lexeme: "\n")])
        parser.advance()
        let error = parser.unexpectedEndOfInputError()
        XCTAssertEqual(error.message, "unexpected end of input")
        XCTAssertEqual(error.line, 1)
    }
    
    func testUnexpectedEndOfInputErrorWithRemainingTokens() {
        let parser = ParserBase(tokens: [TokenNewline(lineNumber: 2, lexeme: "\n")])
        let error = parser.unexpectedEndOfInputError()
        XCTAssertEqual(error.message, "unexpected end of input")
        XCTAssertEqual(error.line, 2)
    }
}
