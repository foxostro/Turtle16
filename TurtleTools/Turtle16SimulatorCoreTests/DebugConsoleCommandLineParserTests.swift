//
//  DebugConsoleCommandLineParserTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore
import TurtleCore

class DebugConsoleCommandLineParserTests: XCTestCase {
    func parse(_ text: String) -> DebugConsoleCommandLineParser {
        let tokenizer = DebugConsoleCommandLineLexer(text)
        tokenizer.scanTokens()
        let parser = DebugConsoleCommandLineParser(tokens: tokenizer.tokens, lineMapper: tokenizer.lineMapper)
        parser.parse()
        return parser
    }
    
    func testEmptyProgramYieldsEmptyAST() {
        let parser = parse("")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
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
    
    func testParseStepYieldsSingleCommandNode() {
        let parser = parse("step")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], InstructionNode(instruction: "step", parameters: ParameterList(parameters: [])))
    }
    
    func testParseS() {
        let parser = parse("s")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], InstructionNode(instruction: "s", parameters: ParameterList(parameters: [])))
    }

    func testParseTwoStepsYieldsTwoCommandNodes() {
        let parser = parse("step\nstep\n")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 2)
        XCTAssertEqual(ast.children[0], InstructionNode(instruction: "step", parameters: ParameterList(parameters: [])))
        XCTAssertEqual(ast.children[1], InstructionNode(instruction: "step", parameters: ParameterList(parameters: [])))
    }
    
    func testParseStepWithParameter() {
        let parser = parse("step 1\n")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children.first, InstructionNode(instruction: "step", parameters: ParameterList(parameters: [
            ParameterNumber(value: 1)
        ])))
    }
    
    func testParseQuit() {
        let parser = parse("quit\n")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children.first, InstructionNode(instruction: "quit", parameters: ParameterList(parameters: [])))
    }
    
    func testReadMemoryWithX_WithAddressAndBadLength() throws {
        let parser = parse("x /foo 0x1000")
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children.first, InstructionNode(instruction: "x",
                                                           parameters: ParameterList(parameters: [ParameterSlashed(child: ParameterIdentifier(value: "foo")), ParameterNumber(value: 0x1000)])))
    }
    
    func testLoad() throws {
        let parser = parse("load \"foo\"")
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children.first, InstructionNode(instruction: "load",
                                                           parameters: ParameterList(parameters: [ParameterString(value: "foo")])))
    }
    
    func testSave() throws {
        let parser = parse("save \"foo\"")
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children.first, InstructionNode(instruction: "save",
                                                           parameters: ParameterList(parameters: [ParameterString(value: "foo")])))
    }
}
