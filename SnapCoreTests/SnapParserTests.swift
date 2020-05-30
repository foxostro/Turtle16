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
        // If we try to use a number as a label name then it will be interpreted
        // as a malformed expression.
        let parser = SnapParser(tokens: tokenize("123:"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected to find the end of the statement: `:'")
    }

    func testParseExtraneousColon() {
        // If we try to use a number as a label name then it will be interpreted
        // as a malformed expression.
        let parser = SnapParser(tokens: tokenize(":"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `:'")
    }
    
    func testExtraneousComma() {
        let parser = SnapParser(tokens: tokenize(","))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `,'")
    }

    func testMultipleErrorsParsingInstructions() {
        let tokens = tokenize(",\n:\n")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors[0].line, Optional<Int>(1))
        XCTAssertEqual(parser.errors[0].message, "operand type mismatch: `,'")
        XCTAssertEqual(parser.errors[1].line, Optional<Int>(2))
        XCTAssertEqual(parser.errors[1].message, "operand type mismatch: `:'")
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
        
        let expected = VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"), expression: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testExpressionStatement_Literal() {
        let parser = SnapParser(tokens: tokenize("1"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_Identifier() {
        let parser = SnapParser(tokens: tokenize("foo"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_Unary() {
        let parser = SnapParser(tokens: tokenize("-foo"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus), expression: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_Unary_OperandTypeMismatch() {
        let parser = SnapParser(tokens: tokenize("-,"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `,\'")
    }
    
    func testExpressionStatement_Multiplication() {
        let parser = SnapParser(tokens: tokenize("1 * -foo"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                         left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                         right: Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                                                 expression: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_Division() {
        let parser = SnapParser(tokens: tokenize("1 / -foo"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "/", op: .divide),
                                         left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                         right: Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                                                 expression: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_Addition() {
        let parser = SnapParser(tokens: tokenize("1 + -foo"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                         left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                         right: Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                                                 expression: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_Subtraction() {
        let parser = SnapParser(tokens: tokenize("1 - -foo"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                         left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                         right: Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                                                 expression: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_MultiplicationTakesPrecendenceOverAddition() {
        let parser = SnapParser(tokens: tokenize("1 + 2 * 4"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                         left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                         right: Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                                                  left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)),
                                                                  right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "4", literal: 4))))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_MultiplicationTakesPrecendenceOverSubtraction() {
        let parser = SnapParser(tokens: tokenize("1 - 2 * 4"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                         left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                         right: Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                                                  left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)),
                                                                  right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "4", literal: 4))))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_Modulus() {
        let parser = SnapParser(tokens: tokenize("7 % 3"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                         left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "7", literal: 7)),
                                         right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "3", literal: 3)))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_ParenthesesProvideGrouping() {
        let parser = SnapParser(tokens: tokenize("(2-1)*4"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                         left: Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                                                 left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)),
                                                                 right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))),
                                         right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "4", literal: 4)))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_RightParenthesesMissing() {
        let parser = SnapParser(tokens: tokenize("(1+1"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected ')' after expression")
    }
    
    func testExpressionStatement_AssignmentExpression() {
        let tokens = tokenize("""
static var foo = 1
foo = 1
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 2)
        
        let expected = Expression.Assignment(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                                             expression: Expression.Literal(number: TokenNumber(lineNumber: 2, lexeme: "1", literal: 1)))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.last)
    }
}
