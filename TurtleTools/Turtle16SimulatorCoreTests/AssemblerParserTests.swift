//
//  AssemblerParserTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 5/16/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import Turtle16SimulatorCore

class AssemblerParserTests: XCTestCase {
    func parse(_ text: String) -> AssemblerParser {
        let tokenizer = AssemblerLexer(text)
        tokenizer.scanTokens()
        let parser = AssemblerParser(tokens: tokenizer.tokens, lineMapper: tokenizer.lineMapper)
        parser.parse()
        return parser
    }
    
    func testEmptyProgramYieldsEmptyAST1() {
        let parser = parse("")
        XCTAssertFalse(parser.hasError)
        guard let ast = parser.syntaxTree else {
            XCTFail()
            return
        }
        XCTAssertEqual(ast.children.count, 0)
    }
    
    func testEmptyProgramYieldsEmptyAST2() {
        let parser = parse("\n")
        XCTAssertFalse(parser.hasError)
        guard let ast = parser.syntaxTree else {
            XCTFail()
            return
        }
        XCTAssertEqual(ast.children.count, 0)
    }
    
    func testParseExtraneousColon() {
        let parser = parse(":")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(0, 1))
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }
    
    func testExtraneousComma() {
        let parser = parse(",")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(0, 1))
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }
    
    func testParseOpcodeWithNoParameters() {
        let parser = parse("NOP\nHLT\n")
        XCTAssertFalse(parser.hasError)
        guard let ast = parser.syntaxTree else {
            XCTFail()
            return
        }
        XCTAssertEqual(ast.children.count, 2)
        XCTAssertEqual(ast.children[0], InstructionNode(instruction: "NOP", parameters: []))
        XCTAssertEqual(ast.children[1], InstructionNode(instruction: "HLT", parameters: []))
    }
    
    func testParseOpcodeWithOneParameter1() {
        let parser = parse("NOP $ffff")
        XCTAssertFalse(parser.hasError)
        guard let ast = parser.syntaxTree else {
            XCTFail()
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children.first, InstructionNode(instruction: "NOP", parameters: [
            ParameterNumber(value: 0xffff)
        ]))
    }
    
    func testParseOpcodeWithOneParameter2() {
        let parser = parse("NOP $ffff\n")
        XCTAssertFalse(parser.hasError)
        guard let ast = parser.syntaxTree else {
            XCTFail()
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children.first, InstructionNode(instruction: "NOP", parameters: [
            ParameterNumber(value: 0xffff)
        ]))
    }
    
    func testParseOpcodeWithThreeParameters() {
        let parser = parse("NOP 1, 2, foo")
        XCTAssertFalse(parser.hasError)
        guard let ast = parser.syntaxTree else {
            XCTFail()
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children.first, InstructionNode(instruction: "NOP", parameters: [
            ParameterNumber(value: 1),
            ParameterNumber(value: 2),
            ParameterIdentifier(value: "foo")
        ]))
    }
    
    func testParseOpcodeWithExtraneousComma1() {
        let parser = parse("NOP 1,")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "extraneous comma")
    }
    
    func testParseOpcodeWithExtraneousComma2() {
        let parser = parse("NOP 1,\n")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "extraneous comma")
    }
    
    func testParseAddressParameter() {
        let parser = parse("JR 1(r1)")
        XCTAssertFalse(parser.hasError)
        guard let ast = parser.syntaxTree else {
            XCTFail()
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children.first, InstructionNode(instruction: "JR", parameters: [
            ParameterAddress(offset: ParameterNumber(value: 1), identifier: ParameterIdentifier(value: "r1"))
        ]))
    }
    
    func testParseAddressParameterNegative() {
        let parser = parse("JR -1(r1)")
        XCTAssertFalse(parser.hasError)
        guard let ast = parser.syntaxTree else {
            XCTFail()
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children.first, InstructionNode(instruction: "JR", parameters: [
            ParameterAddress(offset: ParameterNumber(value: -1), identifier: ParameterIdentifier(value: "r1"))
        ]))
    }
    
    func testParseLabel() {
        let parser = parse("foo:")
        XCTAssertFalse(parser.hasError)
        guard let ast = parser.syntaxTree else {
            XCTFail()
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children.first, LabelDeclaration(identifier: "foo"))
    }
}
