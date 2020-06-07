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
    
    func testMalformedLetDeclaration_JustLet() {
        let parser = SnapParser(tokens: tokenize("let"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected to find an identifier in let declaration")
    }
    
    func testMalformedLetDeclaration_MissingAssignment() {
        let parser = SnapParser(tokens: tokenize("let foo"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "immutable variables must be assigned a value")
    }
    
    func testMalformedLetDeclaration_MissingValue() {
        let tokens = tokenize("let foo =")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected value after '='")
    }
    
    func testMalformedLetDeclaration_BadTypeForValue_TooManyTokens() {
        let parser = SnapParser(tokens: tokenize("let foo = 1 2"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected to find the end of the statement: `2'")
    }
    
    func testWellFormedLetDeclaration() {
        let parser = SnapParser(tokens: tokenize("let foo = 1"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = LetDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"), expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testMalformedStaticVariableDeclaration_BareVar() {
        let parser = SnapParser(tokens: tokenize("var"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected to find an identifier in variable declaration")
    }
    
    func testMalformedStaticVariableDeclaration_MissingAssignment() {
        let parser = SnapParser(tokens: tokenize("var foo"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "variables must be assigned an initial value")
    }
    
    func testMalformedStaticVariableDeclaration_MissingValue() {
        let tokens = tokenize("var foo =")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected initial value after `='")
    }
    
    func testMalformedStaticVariableDeclaration_BadTypeForValue_TooManyTokens() {
        let parser = SnapParser(tokens: tokenize("var foo = 1 2"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected to find the end of the statement: `2'")
    }
    
    func testWellFormedStaticVariableDeclaration() {
        let parser = SnapParser(tokens: tokenize("var foo = 1"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"), expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testExpressionStatement_Literal_Number() {
        let parser = SnapParser(tokens: tokenize("1"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_Literal_Boolean() {
        let parser = SnapParser(tokens: tokenize("true"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.LiteralBoolean(boolean: TokenBoolean(lineNumber: 1, lexeme: "true", literal: true))
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
    
    func testExpressionStatement_Unary_Identifier() {
        let parser = SnapParser(tokens: tokenize("-foo"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus), expression: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_Unary_Boolean() {
        // We'll flag this as a type error during semantic analysis. The parser,
        // however, has no problem with it.
        let parser = SnapParser(tokens: tokenize("-false"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus), expression: Expression.LiteralBoolean(boolean: TokenBoolean(lineNumber: 1, lexeme: "false", literal: false)))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_Unary_OperandTypeMismatch() {
        let parser = SnapParser(tokens: tokenize("-,"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `,'")
    }
    
    func testExpressionStatement_Multiplication() {
        let parser = SnapParser(tokens: tokenize("1 * -foo"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                         left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
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
                                         left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
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
                                         left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
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
                                         left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
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
                                         left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                         right: Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                                                  left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)),
                                                                  right: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "4", literal: 4))))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_MultiplicationTakesPrecendenceOverSubtraction() {
        let parser = SnapParser(tokens: tokenize("1 - 2 * 4"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                         left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                         right: Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                                                  left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)),
                                                                  right: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "4", literal: 4))))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_Modulus() {
        let parser = SnapParser(tokens: tokenize("7 % 3"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                         left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "7", literal: 7)),
                                         right: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "3", literal: 3)))
        XCTAssertEqual(Optional<Expression>(expected), ast.children.first)
    }
    
    func testExpressionStatement_ParenthesesProvideGrouping() {
        let parser = SnapParser(tokens: tokenize("(2-1)*4"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 1)
        
        let expected = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                         left: Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                                                 left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)),
                                                                 right: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))),
                                         right: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "4", literal: 4)))
        XCTAssertEqual(Optional<Expression>(expected), ast?.children.first)
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
var foo = 1
foo = 2
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 2)
        
        let expected = Expression.Assignment(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                                             expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 2, lexeme: "2", literal: 2)))
        XCTAssertEqual(Optional<Expression>(expected), ast?.children.last)
    }
        
    func testExpressionStatement_Comparison_Equals() {
        let tokens = tokenize("1 + 2 == 3")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 1)
        
        let expected = ExprUtils.makeComparisonEq(left: ExprUtils.makeAdd(left: ExprUtils.makeLiteralWord(value: 1),
                                                                          right: ExprUtils.makeLiteralWord(value: 2)),
                                                  right: ExprUtils.makeLiteralWord(value: 3))
        XCTAssertEqual(Optional<Expression>(expected), ast?.children.first)
    }
        
    func testExpressionStatement_Comparison_NotEqual() {
        let tokens = tokenize("1 + 2 != 3")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 1)
        
        let expected = ExprUtils.makeComparisonNe(left: ExprUtils.makeAdd(left: ExprUtils.makeLiteralWord(value: 1),
                                                                          right: ExprUtils.makeLiteralWord(value: 2)),
                                                  right: ExprUtils.makeLiteralWord(value: 3))
        XCTAssertEqual(Optional<Expression>(expected), ast?.children.first)
    }
        
    func testExpressionStatement_Comparison_LessThan() {
        let tokens = tokenize("1 + 2 < 3")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 1)
        
        let expected = ExprUtils.makeComparisonLt(left: ExprUtils.makeAdd(left: ExprUtils.makeLiteralWord(value: 1),
                                                                          right: ExprUtils.makeLiteralWord(value: 2)),
                                                  right: ExprUtils.makeLiteralWord(value: 3))
        XCTAssertEqual(Optional<Expression>(expected), ast?.children.first)
    }
        
    func testExpressionStatement_Comparison_GreaterThan() {
        let tokens = tokenize("1 + 2 > 3")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 1)
        
        let expected = ExprUtils.makeComparisonGt(left: ExprUtils.makeAdd(left: ExprUtils.makeLiteralWord(value: 1),
                                                                          right: ExprUtils.makeLiteralWord(value: 2)),
                                                  right: ExprUtils.makeLiteralWord(value: 3))
        XCTAssertEqual(Optional<Expression>(expected), ast?.children.first)
    }
        
    func testExpressionStatement_Comparison_LessThanOrEqualTo() {
        let tokens = tokenize("1 + 2 <= 3")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 1)
        
        let expected = ExprUtils.makeComparisonLe(left: ExprUtils.makeAdd(left: ExprUtils.makeLiteralWord(value: 1),
                                                                          right: ExprUtils.makeLiteralWord(value: 2)),
                                                  right: ExprUtils.makeLiteralWord(value: 3))
        XCTAssertEqual(Optional<Expression>(expected), ast?.children.first)
    }
        
    func testExpressionStatement_Comparison_GreaterThanOrEqualTo() {
        let tokens = tokenize("1 + 2 >= 3")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 1)
        
        let expected = ExprUtils.makeComparisonGe(left: ExprUtils.makeAdd(left: ExprUtils.makeLiteralWord(value: 1),
                                                                          right: ExprUtils.makeLiteralWord(value: 2)),
                                                  right: ExprUtils.makeLiteralWord(value: 3))
        XCTAssertEqual(Optional<Expression>(expected), ast?.children.first)
    }
        
    func testMalformedIfStatement_MissingCondition_1() {
        let parser = SnapParser(tokens: tokenize("if"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected condition after `if'")
    }
        
    func testMalformedIfStatement_MissingCondition_2() {
        let parser = SnapParser(tokens: tokenize("if {"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected condition after `if'")
    }
        
    func testMalformedIfStatement_MissingOpeningBraceForThenBranch() {
        let parser = SnapParser(tokens: tokenize("if 1"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected newline")
    }
        
    func testMalformedIfStatement_MissingStatementForThenBranch() {
        let parser = SnapParser(tokens: tokenize("if 1 {\n"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected `}' after `then' branch")
    }
        
    func testMalformedIfStatement_MissingClosingBraceOfThenBranch() {
        let tokens = tokenize("""
if 1 {
    var foo = 2
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected `}' after `then' branch")
    }
        
    func testWellformedIfStatement_NoElseBranch() {
        let tokens = tokenize("""
if 1 {
    var foo = 2
}
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 1)
        
        let expected = If(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                          then: VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                                               expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 2, lexeme: "2", literal: 2))),
                          else: nil)
        XCTAssertEqual(Optional<If>(expected), ast?.children.first)
    }
        
    func testMalformedIfStatement_MissingOpeningBraceForElseBranch_1() {
        let tokens = tokenize("""
if 1 {
    var foo = 2
} else
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected newline")
    }
        
    func testMalformedIfStatement_MissingOpeningBraceForElseBranch_2() {
        let tokens = tokenize("""
if 1 {
    var foo = 2
}
else
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected newline")
    }
        
    func testMalformedIfStatement_MissingStatementForElseBranch() {
        let tokens = tokenize("""
if 1 {
    var foo = 2
} else {

""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected `}' after `else' branch")
    }
        
    func testMalformedIfStatement_MissingClosingBraceOfElseBranch() {
        let tokens = tokenize("""
if 1 {
    1
} else {
    var foo = 2
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected `}' after `else' branch")
    }
        
    func testWellformedIfStatement_IncludingElseBranch() {
        let tokens = tokenize("""
if 1 {
    2
} else {
    3
    4
}
5
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        
        XCTAssertEqual(parser.syntaxTree?.children,
                       [If(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                          then: Expression.LiteralWord(number: TokenNumber(lineNumber: 2, lexeme: "2", literal: 2)),
                          else: AbstractSyntaxTreeNode(children: [
                            Expression.LiteralWord(number: TokenNumber(lineNumber: 4, lexeme: "3", literal: 3)),
                            Expression.LiteralWord(number: TokenNumber(lineNumber: 5, lexeme: "4", literal: 4))
                          ])),
                        Expression.LiteralWord(number: TokenNumber(lineNumber: 7, lexeme: "5", literal: 5))])
    }
        
    func testWellformedIfStatement_IncludingElseBranch_2() {
        let tokens = tokenize("""
if 1 {
} else {
}
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        
        XCTAssertEqual(parser.syntaxTree?.children,
                       [If(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                          then: AbstractSyntaxTreeNode(),
                          else: AbstractSyntaxTreeNode())
        ])
    }
        
    func testWellformedIfStatement_IncludingElseBranch_3() {
        let tokens = tokenize("""
if 1 {
}
else {
}
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        
        XCTAssertEqual(parser.syntaxTree?.children,
                       [If(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                          then: AbstractSyntaxTreeNode(),
                          else: AbstractSyntaxTreeNode())
        ])
    }
        
    func testWellformedIfStatement_IncludingElseBranch_4() {
        let tokens = tokenize("""
if 1
    let foo = 1
else
    let bar = 1
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        
        XCTAssertEqual(parser.syntaxTree?.children,
                       [If(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                          then: LetDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"), expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 2, lexeme: "1", literal: 1))),
                          else: LetDeclaration(identifier: TokenIdentifier(lineNumber: 4, lexeme: "bar"), expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 4, lexeme: "1", literal: 1))))
        ])
    }
        
    func testWellformedIfStatement_SingleStatementBodyWithoutElseClause() {
        let tokens = tokenize("""
if 1
    let foo = 1
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        
        XCTAssertEqual(parser.syntaxTree?.children,
                       [If(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                          then: LetDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"), expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 2, lexeme: "1", literal: 1))),
                          else: nil)
        ])
    }
    
    func testMalformedWhileStatement_MissingCondition_1() {
        let parser = SnapParser(tokens: tokenize("while"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected condition after `while'")
    }
        
    func testMalformedWhileStatement_MissingCondition_2() {
        let parser = SnapParser(tokens: tokenize("while {"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected condition after `while'")
    }
        
    func testMalformedWhileStatement_MissingOpeningBraceBeforeBody() {
        let parser = SnapParser(tokens: tokenize("while 1"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected newline")
    }
        
    func testMalformedWhileStatement_MissingStatementInBodyBlock() {
        let parser = SnapParser(tokens: tokenize("while 1 {\n"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected `}' after `while' body")
    }
        
    func testMalformedWhileStatement_MissingClosingBraceOfThenBranch() {
        let tokens = tokenize("""
while 1 {
    var foo = 2
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected `}' after `while' body")
    }
        
    func testWellformedWhileStatement() {
        let tokens = tokenize("""
while 1 {
    var foo = 2
}
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children,
                       [While(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                              body: VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                                                   expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 2, lexeme: "2", literal: 2))))])
    }
        
    func testWellformedWhileStatement_EmptyBody_1() {
        let tokens = tokenize("""
while 1 {
}
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        
        XCTAssertEqual(parser.syntaxTree?.children,
                       [While(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                              body: AbstractSyntaxTreeNode())
        ])
    }
        
    func testWellformedWhileStatement_EmptyBody_2() {
        let tokens = tokenize("""
while 1 {}
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        
        XCTAssertEqual(parser.syntaxTree?.children,
                       [While(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                              body: AbstractSyntaxTreeNode())
        ])
    }
        
    func testWellformedForLoopStatement() {
        let tokens = tokenize("""
for var i = 0; i < 10; i = i + 1 {
    var foo = i
}
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            ForLoop(initializerClause: VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "i"),
                                                      expression: ExprUtils.makeLiteralWord(value: 0)),
                    conditionClause: ExprUtils.makeComparisonLt(left: ExprUtils.makeIdentifier(name: "i"),
                                                                right: ExprUtils.makeLiteralWord(value: 10)),
                    incrementClause: ExprUtils.makeAssignment(name: "i", right: ExprUtils.makeAdd(left: ExprUtils.makeIdentifier(name: "i"), right: ExprUtils.makeLiteralWord(value: 1))),
                    body: VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                                         expression: ExprUtils.makeIdentifier(lineNumber: 2, name: "i")))
        ])
    }
        
    func testStandaloneBlockStatements() {
        let tokens = tokenize("""
{
    var foo = i
}
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            AbstractSyntaxTreeNode(children: [
                VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                expression: ExprUtils.makeIdentifier(lineNumber: 2, name: "i"))
            ])
        ])
    }
        
    func testStandaloneBlockStatementsWithoutNewlines() {
        let tokens = tokenize("{var foo = i}")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            AbstractSyntaxTreeNode(children: [
                VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                               expression: ExprUtils.makeIdentifier(lineNumber: 1, name: "i"))
            ])
        ])
    }
        
    func testStandaloneBlockStatementIsEmpty() {
        let tokens = tokenize("{}")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            AbstractSyntaxTreeNode(children: [])
        ])
    }
    
    func testStandaloneBlockStatementsAreNested() {
        let tokens = tokenize("""
{
    {
        var bar = i
    }
}
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            AbstractSyntaxTreeNode(children: [
                AbstractSyntaxTreeNode(children: [
                    VarDeclaration(identifier: TokenIdentifier(lineNumber: 3, lexeme: "bar"),
                                   expression: ExprUtils.makeIdentifier(lineNumber: 3, name: "i"))
                ])
            ])
        ])
    }
    
    func testStandaloneBlockStatementsAreNestedAndEmpty() {
        let tokens = tokenize("{{}}")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            AbstractSyntaxTreeNode(children: [
                AbstractSyntaxTreeNode(children: [
                ])
            ])
        ])
    }
}
