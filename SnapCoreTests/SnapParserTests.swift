//
//  SnapParserTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class SnapParserTests: XCTestCase {
    func tokenize(_ text: String) -> [Token] {
        let tokenizer = SnapLexer(withString: text)
        tokenizer.scanTokens()
        let tokens = tokenizer.tokens
        return tokens
    }
    
    func testEmptyProgramYieldsEmptyAST() {
        let parser = SnapParser(tokens: tokenize(""))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 0)
    }

    func testLabelDeclaration() {
        let parser = SnapParser(tokens: tokenize("label:"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "label")))
    }

    func testParseLabelNameIsANumber() {
        let parser = SnapParser(tokens: tokenize("123:"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }

    func testParseExtraneousColon() {
        let parser = SnapParser(tokens: tokenize(":"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }
    
    func testExtraneousComma() {
        let parser = SnapParser(tokens: tokenize(","))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }

    func testMultipleErrorsParsingInstructions() {
        let tokens = tokenize(",\n:\n")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors[0].line, Optional<Int>(1))
        XCTAssertEqual(parser.errors[0].message, "unexpected end of input")
        XCTAssertEqual(parser.errors[1].line, Optional<Int>(2))
        XCTAssertEqual(parser.errors[1].message, "unexpected end of input")
    }
    
    func testMalformedDeclaration_BareLetStatement() {
        let parser = SnapParser(tokens: tokenize("let"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected to find an identifier in constant declaration")
    }
    
    func testMalformedDeclaration_MissingAssignment() {
        let parser = SnapParser(tokens: tokenize("let foo"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "constants must be assigned a value")
    }
    
    func testMalformedDeclaration_MissingValue() {
        let tokens = tokenize("let foo =")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected value after '='")
    }
    
    func testMalformedDeclaration_BadTypeForValue_Identifier() {
        let parser = SnapParser(tokens: tokenize("let foo = bar"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `bar'")
    }
    
    func testMalformedDeclaration_BadTypeForValue_TooManyTokens() {
        let parser = SnapParser(tokens: tokenize("let foo = 1 2"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected to find the end of the statement: `2'")
    }
    
    func testWellFormedDeclaration() {
        let parser = SnapParser(tokens: tokenize("let foo = 1"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = ConstantDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"), expression: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
}
