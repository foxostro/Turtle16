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
    
    func testParseNOPYieldsSingleNOPNode() {
        let parser = SnapParser(tokens: tokenize("NOP"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "NOP"), parameters: ParameterListNode(parameters: [])))
    }

    func testParseTwoNOPsYieldsTwoNOPNodes() {
        let parser = SnapParser(tokens: tokenize("NOP\nNOP\n"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 2)
        XCTAssertEqual(ast.children[0], InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "NOP"), parameters: ParameterListNode(parameters: [])))
        XCTAssertEqual(ast.children[1], InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "NOP"), parameters: ParameterListNode(parameters: [])))
    }

    func testHLTParses() {
        let parser = SnapParser(tokens: tokenize("HLT"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0],
                       InstructionNode(instruction: TokenIdentifier(lineNumber: 0, lexeme: "HLT"),
                                       parameters: ParameterListNode(parameters: [])))
    }

    func testLabelDeclaration() {
        let parser = SnapParser(tokens: tokenize("label:"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "label")))
    }

    func testLabelDeclarationAtAnotherAddress() {
        let parser = SnapParser(tokens: tokenize("NOP\nlabel:"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 2)
        XCTAssertEqual(ast.children[0], InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "NOP"), parameters: ParameterListNode(parameters: [])))
        XCTAssertEqual(ast.children[1], LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 2, lexeme: "label")))
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

    func testParseValidLI() {
        let parser = SnapParser(tokens: tokenize("LI D, 42"))
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
        let parser = SnapParser(tokens: tokenize("MOV D, A"))
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
        let parser = SnapParser(tokens: tokenize(","))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }
    
    func testParameterListMalformedByHavingOnlyComma() {
        let parser = SnapParser(tokens: tokenize("MOV ,"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `MOV'")
    }
    
    func testParameterListMalformedWithTrailingComma() {
        let parser = SnapParser(tokens: tokenize("MOV A, B, C,"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.line, 1)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testMultipleErrorsParsingInstructions() {
        let parser = SnapParser(tokens: tokenize("MOV ,\nMOV A, B, C,\n"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors[0].line, 1)
        XCTAssertEqual(parser.errors[0].message, "operand type mismatch: `MOV'")
        XCTAssertEqual(parser.errors[1].line, 2)
        XCTAssertEqual(parser.errors[1].message, "operand type mismatch: `MOV'")
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
    
    func testMalformedDeclaration_BadTypeForValue_Register() {
        let parser = SnapParser(tokens: tokenize("let foo = A"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `A'")
    }
    
    func testMalformedDeclaration_BadTypeForValue_TooManyTokens() {
        let parser = SnapParser(tokens: tokenize("let foo = 1 A"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `A'")
    }
    
    func testWellFormedDeclaration() {
        let parser = SnapParser(tokens: tokenize("let foo = 1"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0],
                       ConstantDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                               number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
    }
    
    func testWellformedBareReturnStatement() {
        let parser = SnapParser(tokens: tokenize("return"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], ReturnNode(lineNumber: 1))
    }
    
    func testWellformedReturnStatement_OneOperand() {
        let parser = SnapParser(tokens: tokenize("return 42"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertEqual(ast.children[0], ReturnNode(lineNumber: 1, value: TokenNumber(lineNumber: 1, lexeme: "42", literal: 42)))
    }
    
    func testMalformedReturnStatement_MultipleOperands() {
        let parser = SnapParser(tokens: tokenize("return 42 foo"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "`return' accepts exactly one or zero operands")
    }
}
