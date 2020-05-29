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
    
    func testMalformedConstantDeclaration_BareLetStatement() {
        let parser = SnapParser(tokens: tokenize("let"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected to find an identifier in constant declaration")
    }
    
    func testMalformedConstantDeclaration_MissingAssignment() {
        let parser = SnapParser(tokens: tokenize("let foo"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "constants must be assigned a value")
    }
    
    func testMalformedConstantDeclaration_MissingValue() {
        let tokens = tokenize("let foo =")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected value after '='")
    }
    
    func testMalformedConstantDeclaration_BadTypeForValue_TooManyTokens() {
        let parser = SnapParser(tokens: tokenize("let foo = 1 2"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected to find the end of the statement: `2'")
    }
    
    func testWellFormedConstantDeclaration() {
        let parser = SnapParser(tokens: tokenize("let foo = 1"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = ConstantDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"), expression: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testMalformedStaticVariableDeclaration_BareStatic() {
        let parser = SnapParser(tokens: tokenize("static"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected declaration")
    }
    
    func testMalformedStaticVariableDeclaration_BareStaticVar() {
        let parser = SnapParser(tokens: tokenize("static var"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected to find an identifier in variable declaration")
    }
    
    func testMalformedStaticVariableDeclaration_BareVar() {
        let parser = SnapParser(tokens: tokenize("var"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "currently only `static var' is supported")
    }
    
    func testMalformedStaticVariableDeclaration_MissingAssignment() {
        let parser = SnapParser(tokens: tokenize("static var foo"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "variables must be assigned an initial value")
    }
    
    func testMalformedStaticVariableDeclaration_MissingValue() {
        let tokens = tokenize("static var foo =")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected initial value after `='")
    }
    
    func testMalformedStaticVariableDeclaration_BadTypeForValue_TooManyTokens() {
        let parser = SnapParser(tokens: tokenize("static var foo = 1 2"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected to find the end of the statement: `2'")
    }
    
    func testWellFormedStaticVariableDeclaration() {
        let parser = SnapParser(tokens: tokenize("static var foo = 1"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = StaticDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"), expression: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testMalformedEvalStatement_MissingExpression() {
        let parser = SnapParser(tokens: tokenize("eval"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected to find an expression following `eval' statement")
    }
    
    func testWellformedEvalStatement() {
        let parser = SnapParser(tokens: tokenize("eval 1"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"),
                                     expression: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
        XCTAssertEqual(Optional<EvalStatement>(expected), ast.children.first)
    }
    
    func testEvalStatement_Identifier() {
        let parser = SnapParser(tokens: tokenize("eval foo"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"), expression: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")))
        XCTAssertEqual(Optional<EvalStatement>(expected), ast.children.first)
    }
    
    func testEvalStatement_Unary() {
        let parser = SnapParser(tokens: tokenize("eval -foo"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"), expression: Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus), expression: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))))
        XCTAssertEqual(Optional<EvalStatement>(expected), ast.children.first)
    }
    
    func testEvalStatement_Unary_OperandTypeMismatch() {
        let parser = SnapParser(tokens: tokenize("eval -,"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `,\'")
    }
    
    func testEvalStatement_Multiplication() {
        let parser = SnapParser(tokens: tokenize("eval 1 * -foo"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expression = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                           left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                           right: Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                                                   expression: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))))
        let expected = EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"), expression: expression)
        XCTAssertEqual(Optional<EvalStatement>(expected), ast.children.first)
    }
    
    func testEvalStatement_Division() {
        let parser = SnapParser(tokens: tokenize("eval 1 / -foo"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expression = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                           left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                           right: Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                                                   expression: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))))
        let expected = EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"), expression: expression)
        XCTAssertEqual(Optional<EvalStatement>(expected), ast.children.first)
    }
    
    func testEvalStatement_Addition() {
        let parser = SnapParser(tokens: tokenize("eval 1 + -foo"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expression = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                           left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                           right: Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                                                   expression: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))))
        let expected = EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"), expression: expression)
        XCTAssertEqual(Optional<EvalStatement>(expected), ast.children.first)
    }
    
    func testEvalStatement_Subtraction() {
        let parser = SnapParser(tokens: tokenize("eval 1 - -foo"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expression = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                           left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                           right: Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                                                   expression: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))))
        let expected = EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"), expression: expression)
        XCTAssertEqual(Optional<EvalStatement>(expected), ast.children.first)
    }
    
    func testEvalStatement_MultiplicationTakesPrecendenceOverAddition() {
        let parser = SnapParser(tokens: tokenize("eval 1 + 2 * 4"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expression = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                           left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                           right: Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                                                    left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)),
                                                                    right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "4", literal: 4))))
        let expected = EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"), expression: expression)
        XCTAssertEqual(Optional<EvalStatement>(expected), ast.children.first)
    }
    
    func testEvalStatement_MultiplicationTakesPrecendenceOverSubtraction() {
        let parser = SnapParser(tokens: tokenize("eval 1 - 2 * 4"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expression = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                           left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                           right: Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                                                    left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)),
                                                                    right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "4", literal: 4))))
        let expected = EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"), expression: expression)
        XCTAssertEqual(Optional<EvalStatement>(expected), ast.children.first)
    }
    
    func testEvalStatement_Modulus() {
        let parser = SnapParser(tokens: tokenize("eval 7 % 3"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expression = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                           left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "7", literal: 7)),
                                           right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "3", literal: 3)))
        let expected = EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"), expression: expression)
        XCTAssertEqual(Optional<EvalStatement>(expected), ast.children.first)
    }
    
    func testEvalStatement_ParenthesesProvideGrouping() {
        let parser = SnapParser(tokens: tokenize("eval (2-1)*4"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expression = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                           left: Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                                                   left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)),
                                                                   right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))),
                                           right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "4", literal: 4)))
        let expected = EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"), expression: expression)
        XCTAssertEqual(Optional<EvalStatement>(expected), ast.children.first)
    }
    
    func testEvalStatement_RightParenthesesMissing() {
        let parser = SnapParser(tokens: tokenize("eval (1+1"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected ')' after expression")
    }
}
