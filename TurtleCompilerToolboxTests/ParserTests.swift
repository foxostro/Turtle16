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
        let parser = Parser()
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(sourceAnchor: nil, children: []))
    }
    
    func testParseAnythingYieldsError() {
        let parser = Parser(tokens: [TokenNewline(sourceAnchor: nil),
                                     TokenNewline(sourceAnchor: nil),
                                     TokenEOF(sourceAnchor: nil)])
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
        let parser = Parser(tokens: [TokenNewline(sourceAnchor: nil),
                                     TokenEOF(sourceAnchor: nil)])
        parser.advance()
        XCTAssertEqual(parser.peek(), TokenEOF(sourceAnchor: nil))
        XCTAssertEqual(parser.previous, TokenNewline(sourceAnchor: nil))
    }
    
    func testAdvanceWillNotAdvancePastTheEnd() {
        let parser = Parser(tokens: [TokenEOF(sourceAnchor: nil)])
        parser.advance()
        XCTAssertEqual(parser.previous, TokenEOF(sourceAnchor: nil))
        XCTAssertNil(parser.peek())
        parser.advance()
        XCTAssertNil(parser.previous)
        XCTAssertNil(parser.peek())
    }
    
    func testPeekLooksAhead() {
        let parser = Parser(tokens: [TokenNewline(sourceAnchor: nil),
                                     TokenEOF(sourceAnchor: nil)])
        
        XCTAssertEqual(parser.peek(), TokenNewline(sourceAnchor: nil))
        XCTAssertEqual(parser.peek(0), TokenNewline(sourceAnchor: nil))
        XCTAssertEqual(parser.peek(1), TokenEOF(sourceAnchor: nil))
        XCTAssertEqual(parser.peek(2), nil)
    }
    
    func testAcceptYieldsNilWhenThereAreNoTokens() {
        let parser = Parser()
        XCTAssertNil(parser.accept(TokenNewline.self))
    }
    
    func testAcceptYieldsNilWhenNextTokenFailsToMatchGivenType() {
        let parser = Parser(tokens: [TokenNewline(sourceAnchor: nil),
                                         TokenEOF(sourceAnchor: nil)])
        XCTAssertNil(parser.accept(TokenLet.self))
    }
    
    func testWhenAcceptMatchesTheTypeThenItAdvances() {
        let parser = Parser(tokens: [TokenNewline(sourceAnchor: nil),
                                         TokenEOF(sourceAnchor: nil)])
        XCTAssertEqual(parser.accept(TokenNewline.self), TokenNewline(sourceAnchor: nil))
        XCTAssertEqual(parser.tokens, [TokenEOF(sourceAnchor: nil)])
    }
    
    func testAcceptCanMatchAnArrayOfTypes() {
        let parser = Parser(tokens: [TokenLet(sourceAnchor: nil),
                                     TokenIdentifier(sourceAnchor: nil),
                                     TokenNewline(sourceAnchor: nil),
                                     TokenEOF(sourceAnchor: nil)])
        XCTAssertNil(parser.accept([]))
        XCTAssertEqual(parser.accept([TokenLet.self, TokenIdentifier.self]), TokenLet(sourceAnchor: nil))
        XCTAssertEqual(parser.accept([TokenLet.self, TokenIdentifier.self]), TokenIdentifier(sourceAnchor: nil))
        XCTAssertNil(parser.accept([TokenLet.self, TokenIdentifier.self]))
    }
    
    func testAcceptCanMatchASingleOperator() {
        let parser = Parser(tokens: [TokenOperator(sourceAnchor: nil, op: .plus),
                                     TokenOperator(sourceAnchor: nil, op: .minus),
                                     TokenNewline(sourceAnchor: nil),
                                     TokenEOF(sourceAnchor: nil)])
        XCTAssertNil(parser.accept(operator: .minus))
        XCTAssertEqual(parser.accept(operator: .plus), TokenOperator(sourceAnchor: nil, op: .plus))
        XCTAssertEqual(parser.accept(operator: .minus), TokenOperator(sourceAnchor: nil, op: .minus))
    }
    
    func testAcceptCanMatchAnArrayOfOperators() {
        let parser = Parser(tokens: [TokenOperator(sourceAnchor: nil, op: .plus),
                                     TokenOperator(sourceAnchor: nil, op: .minus),
                                     TokenNewline(sourceAnchor: nil),
                                     TokenEOF(sourceAnchor: nil)])
        XCTAssertNil(parser.accept(operators: []))
        XCTAssertNil(parser.accept(operators: [.eq, .divide]))
        XCTAssertEqual(parser.accept(operators: [.plus, .minus]), TokenOperator(sourceAnchor: nil, op: .plus))
        XCTAssertEqual(parser.accept(operators: [.plus, .minus]), TokenOperator(sourceAnchor: nil, op: .minus))
    }
    
    func testExpectThrowsWhenTokenTypeFailsToMatch() {
        let parser = Parser(tokens: [TokenEOF(sourceAnchor: nil)])
        XCTAssertThrowsError(try parser.expect(type: TokenLet.self, error: CompilerError(sourceAnchor: nil, message: ""))) {
            XCTAssertNotNil($0 as? CompilerError)
        }
    }
    
    func testExpectCanMatchAgainstAnArrayOfTokenTypes() {
        let parser = Parser(tokens: [TokenLet(sourceAnchor: nil),
                                     TokenIdentifier(sourceAnchor: nil),
                                     TokenNewline(sourceAnchor: nil),
                                     TokenEOF(sourceAnchor: nil)])
        XCTAssertThrowsError(try parser.expect(types: [],
                                               error: CompilerError(sourceAnchor: nil, message: ""))) {
            XCTAssertNotNil($0 as? CompilerError)
        }
        XCTAssertEqual(try! parser.expect(types: [TokenLet.self, TokenIdentifier.self],
                                          error: CompilerError(sourceAnchor: nil, message: "")),
                       TokenLet(sourceAnchor: nil))
        XCTAssertEqual(try! parser.expect(types: [TokenLet.self, TokenIdentifier.self],
                                          error: CompilerError(sourceAnchor: nil, message: "")),
                       TokenIdentifier(sourceAnchor: nil))
        XCTAssertThrowsError(try parser.expect(types: [TokenLet.self, TokenIdentifier.self],
                                               error: CompilerError(sourceAnchor: nil, message: ""))) {
            XCTAssertNotNil($0 as? CompilerError)
        }
    }
    
    func testUnexpectedEndOfInputErrorWithNoTokensRemaining() {
        let parser = Parser()
        let error = parser.unexpectedEndOfInputError()
        XCTAssertEqual(error.message, "unexpected end of input")
    }
    
    func testUnexpectedEndOfInputErrorWithNoPreviousToken() {
        let parser = Parser(tokens: [TokenNewline(sourceAnchor: nil)])
        parser.advance()
        let error = parser.unexpectedEndOfInputError()
        XCTAssertEqual(error.message, "unexpected end of input")
    }
    
    func testUnexpectedEndOfInputErrorWithRemainingTokens() {
        let parser = Parser(tokens: [TokenNewline(sourceAnchor: nil)])
        let error = parser.unexpectedEndOfInputError()
        XCTAssertEqual(error.message, "unexpected end of input")
    }
}
