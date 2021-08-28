//
//  AssemblerParserTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleSimulatorCore

class AssemblerParserTests: XCTestCase {
    func parse(_ text: String) -> AssemblerParser {
        let tokenizer = AssemblerLexer(text)
        tokenizer.scanTokens()
        let parser = AssemblerParser(tokens: tokenizer.tokens,
                                     lineMapper: tokenizer.lineMapper)
        parser.parse()
        return parser
    }
    
    func testEmptyProgramYieldsEmptyAST() {
        let parser = parse("")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 0)
    }
    
    func testParseNOPYieldsSingleNOPNode() {
        let parser = parse("NOP")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], TurtleTTLInstructionNode(instruction: "NOP", parameters: []))
    }

    func testParseTwoNOPsYieldsTwoNOPNodes() {
        let parser = parse("NOP\nNOP\n")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 2)
        XCTAssertEqual(ast.children[0],
                       TurtleTTLInstructionNode(sourceAnchor: parser.lineMapper.anchor(0, 3),
                                       instruction: "NOP",
                                       parameters: []))
        XCTAssertEqual(ast.children[1],
                       TurtleTTLInstructionNode(sourceAnchor: parser.lineMapper.anchor(4, 7),
                                       instruction: "NOP",
                                       parameters: []))
    }

    func testHLTParses() {
        let parser = parse("HLT")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0],
                       TurtleTTLInstructionNode(sourceAnchor: parser.lineMapper.anchor(0, 3),
                                       instruction: "HLT",
                                       parameters: []))
    }

    func testLabelDeclaration() {
        let parser = parse("label:")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0],
                       LabelDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 6),
                                            identifier: "label"))
    }

    func testLabelDeclarationAtAnotherAddress() {
        let parser = parse("NOP\nlabel:")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 2)
        XCTAssertEqual(ast.children[0],
                       TurtleTTLInstructionNode(sourceAnchor: parser.lineMapper.anchor(0, 3),
                                       instruction: "NOP",
                                       parameters: []))
        XCTAssertEqual(ast.children[1],
                       LabelDeclaration(sourceAnchor: parser.lineMapper.anchor(4, 10),
                                            identifier: "label"))
    }

    func testParseLabelNameIsANumber() {
        let parser = parse("123:")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(0, 3))
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }

    func testParseExtraneousColon() {
        let parser = parse(":")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(0, 1))
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }

    func testParseValidLI() {
        let parser = parse("LI D, 42")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0],
                       TurtleTTLInstructionNode(sourceAnchor: parser.lineMapper.anchor(0, 8),
                                       instruction: "LI",
                                       parameters: [
                                        ParameterRegister(sourceAnchor: parser.lineMapper.anchor(3, 4), value: .D),
                                        ParameterNumber(sourceAnchor: parser.lineMapper.anchor(6, 8), value: 42),
                                       ]))
    }

    func testParseValidMOV() {
        let parser = parse("MOV D, A")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0],
                       TurtleTTLInstructionNode(sourceAnchor: parser.lineMapper.anchor(0, 8),
                                       instruction: "MOV",
                                       parameters: [
                                        ParameterRegister(sourceAnchor: parser.lineMapper.anchor(4, 5), value: .D),
                                        ParameterRegister(sourceAnchor: parser.lineMapper.anchor(7, 8), value: .A),
                                       ]))
    }
    
    func testExtraneousComma() {
        let parser = parse(",")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(0, 1))
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }
    
    func testParameterListMalformedByHavingOnlyComma() {
        let parser = parse("MOV ,")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(4, 5))
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `,'")
    }
    
    func testParameterListMalformedWithTrailingComma() {
        let parser = parse("MOV A, B, C,")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(11, 12))
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `,'")
    }

    func testMultipleErrorsParsingInstructions() {
        let parser = parse("MOV ,\nMOV A, B, C,\n")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors[0].sourceAnchor, parser.lineMapper.anchor(4, 5))
        XCTAssertEqual(parser.errors[0].message, "operand type mismatch: `,'")
        XCTAssertEqual(parser.errors[1].sourceAnchor, parser.lineMapper.anchor(17, 18))
        XCTAssertEqual(parser.errors[1].message, "operand type mismatch: `,'")
    }
    
    func testMalformedDeclaration_BareLetStatement() {
        let parser = parse("let")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(0, 3))
        XCTAssertEqual(parser.errors.first?.message, "expected to find an identifier in constant declaration")
    }
    
    func testMalformedDeclaration_MissingAssignment() {
        let parser = parse("let foo")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(4, 7))
        XCTAssertEqual(parser.errors.first?.message, "constants must be assigned a value")
    }
    
    func testMalformedDeclaration_MissingValue() {
        let parser = parse("let foo =")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(8, 9))
        XCTAssertEqual(parser.errors.first?.message, "expected value after `='")
    }
    
    func testMalformedDeclaration_BadTypeForValue_Identifier() {
        let parser = parse("let foo = bar")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(10, 13))
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `bar'")
    }
    
    func testMalformedDeclaration_BadTypeForValue_Register() {
        let parser = parse("let foo = A")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(10, 11))
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `A'")
    }
    
    func testMalformedDeclaration_BadTypeForValue_TooManyTokens() {
        let parser = parse("let foo = 1 A")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(12, 13))
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `A'")
    }
    
    func testWellFormedDeclaration() {
        let parser = parse("let foo = 1")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0],
                       ConstantDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 11),
                                               identifier: "foo",
                                               value: 1))
    }
}
