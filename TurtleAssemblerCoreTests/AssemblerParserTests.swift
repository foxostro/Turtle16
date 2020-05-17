//
//  AssemblerParserTests.swift
//  TurtleAssemblerCoreTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleAssemblerCore

class AssemblerParserTests: XCTestCase {
    func tokenize(_ text: String) -> [Token] {
        let tokenizer = AssemblerLexer(withString: text)
        tokenizer.scanTokens()
        let tokens = tokenizer.tokens
        return tokens
    }
    
    func testEmptyProgramYieldsEmptyAST() {
        let parser = AssemblerParser(tokens: tokenize(""))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 0)
    }
    
    func testParseNOPYieldsSingleNOPNode() {
        let parser = AssemblerParser(tokens: tokenize("NOP"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "NOP"), parameters: ParameterListNode(parameters: [])))
    }

    func testParseTwoNOPsYieldsTwoNOPNodes() {
        let parser = AssemblerParser(tokens: tokenize("NOP\nNOP\n"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 2)
        XCTAssertEqual(ast.children[0], InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "NOP"), parameters: ParameterListNode(parameters: [])))
        XCTAssertEqual(ast.children[1], InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "NOP"), parameters: ParameterListNode(parameters: [])))
    }

    func testHLTParses() {
        let parser = AssemblerParser(tokens: tokenize("HLT"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0],
                       InstructionNode(instruction: TokenIdentifier(lineNumber: 0, lexeme: "HLT"),
                                       parameters: ParameterListNode(parameters: [])))
    }

    func testLabelDeclaration() {
        let parser = AssemblerParser(tokens: tokenize("label:"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "label")))
    }

    func testLabelDeclarationAtAnotherAddress() {
        let parser = AssemblerParser(tokens: tokenize("NOP\nlabel:"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 2)
        XCTAssertEqual(ast.children[0], InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "NOP"), parameters: ParameterListNode(parameters: [])))
        XCTAssertEqual(ast.children[1], LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 2, lexeme: "label")))
    }

    func testParseLabelNameIsANumber() {
        let parser = AssemblerParser(tokens: tokenize("123:"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }

    func testParseExtraneousColon() {
        let parser = AssemblerParser(tokens: tokenize(":"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }

    func testParseValidLI() {
        let parser = AssemblerParser(tokens: tokenize("LI D, 42"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0],
                       InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "LI"),
                                       parameters: ParameterListNode(parameters: [
                                        TokenRegister(lineNumber: 1, lexeme: "D", literal: .D),
                                        TokenNumber(lineNumber: 1, lexeme: "42", literal: 42),
                                       ])))
    }

    func testParseValidMOV() {
        let parser = AssemblerParser(tokens: tokenize("MOV D, A"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0],
                       InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "MOV"),
                                       parameters: ParameterListNode(parameters: [
                                        TokenRegister(lineNumber: 1, lexeme: "D", literal: .D),
                                        TokenRegister(lineNumber: 1, lexeme: "A", literal: .A),
                                       ])))
    }
    
    func testExtraneousComma() {
        let parser = AssemblerParser(tokens: tokenize(","))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }
    
    func testParameterListMalformedByHavingOnlyComma() {
        let parser = AssemblerParser(tokens: tokenize("MOV ,"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `MOV'")
    }
    
    func testParameterListMalformedWithTrailingComma() {
        let parser = AssemblerParser(tokens: tokenize("MOV A, B, C,"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testMultipleErrorsParsingInstructions() {
        let parser = AssemblerParser(tokens: tokenize("MOV ,\nMOV A, B, C,\n"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors[0].line, 1)
        XCTAssertEqual(parser.errors[0].message, "operand type mismatch: `MOV'")
        XCTAssertEqual(parser.errors[1].line, 2)
        XCTAssertEqual(parser.errors[1].message, "operand type mismatch: `MOV'")
    }
    
    func testMalformedDeclaration_BareLetStatement() {
        let parser = AssemblerParser(tokens: tokenize("let"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected to find an identifier in constant declaration")
    }
    
    func testMalformedDeclaration_MissingAssignment() {
        let parser = AssemblerParser(tokens: tokenize("let foo"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "constants must be assigned a value")
    }
    
    func testMalformedDeclaration_MissingValue() {
        let tokens = tokenize("let foo =")
        let parser = AssemblerParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected value after '='")
    }
    
    func testMalformedDeclaration_BadTypeForValue_Identifier() {
        let parser = AssemblerParser(tokens: tokenize("let foo = bar"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `bar'")
    }
    
    func testMalformedDeclaration_BadTypeForValue_Register() {
        let parser = AssemblerParser(tokens: tokenize("let foo = A"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `A'")
    }
    
    func testMalformedDeclaration_BadTypeForValue_TooManyTokens() {
        let parser = AssemblerParser(tokens: tokenize("let foo = 1 A"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `A'")
    }
    
    func testWellFormedDeclaration() {
        let parser = AssemblerParser(tokens: tokenize("let foo = 1"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0],
                       ConstantDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                               number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
    }
}
