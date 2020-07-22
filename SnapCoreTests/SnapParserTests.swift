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
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "labels are not supported")
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
        XCTAssertEqual(parser.errors.first?.message, "expected value after `='")
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
        
        let expected = VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                      explicitType: nil,
                                      expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                      storage: .stackStorage,
                                      isMutable: false)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedLetDeclaration_WithExplicitType_U8() {
        let parser = SnapParser(tokens: tokenize("let foo: u8 = 1"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                      explicitType: .u8,
                                      expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                      storage: .stackStorage,
                                      isMutable: false)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedLetDeclaration_ArrayOfU8_ExplicitType() {
        let parser = SnapParser(tokens: tokenize("let foo: [u8] = []"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        // Note that the parser doesn't know that the expression will actually
        // yield a result of the the type [0, u8]. It only knows the explicit
        // type is given as [u8].
        let expected = VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                      explicitType: .array(count: nil, elementType: .u8),
                                      expression: ExprUtils.makeArray(elements: []),
                                      storage: .stackStorage,
                                      isMutable: false)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedLetDeclaration_ArrayOfU8_ImplicitType() {
        let parser = SnapParser(tokens: tokenize("let foo = [1]"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                      explicitType: nil,
                                      expression: ExprUtils.makeArray(elements: [ExprUtils.makeLiteralInt(value: 1)]),
                                      storage: .stackStorage,
                                      isMutable: false)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedLetDeclaration_ArrayOfU8_MoreThanOneElement() {
        let parser = SnapParser(tokens: tokenize("let foo = [1, 2, 3]"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        let arr = ExprUtils.makeArray(elements: [ExprUtils.makeLiteralInt(value: 1),
                                                 ExprUtils.makeLiteralInt(value: 2),
                                                 ExprUtils.makeLiteralInt(value: 3)])
        let expected = VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                      explicitType: nil,
                                      expression: arr,
                                      storage: .stackStorage,
                                      isMutable: false)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testMalformedVariableDeclaration_EmptyArrayLiteralRequiresExplicitType() {
        let parser = SnapParser(tokens: tokenize("let foo = []"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "empty array literal requires an explicit type")
    }
    
    func testMalformedVariableDeclaration_BareVar() {
        let parser = SnapParser(tokens: tokenize("var"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected to find an identifier in variable declaration")
    }
    
    func testMalformedVariableDeclaration_MissingAssignment() {
        let parser = SnapParser(tokens: tokenize("var foo"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "variables must be assigned an initial value")
    }
    
    func testMalformedVariableDeclaration_MissingValue() {
        let tokens = tokenize("var foo =")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected initial value after `='")
    }
    
    func testMalformedVariableDeclaration_BadTypeForValue_TooManyTokens() {
        let parser = SnapParser(tokens: tokenize("var foo = 1 2"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected to find the end of the statement: `2'")
    }
    
    func testWellFormedVariableDeclaration() {
        let parser = SnapParser(tokens: tokenize("var foo = 1"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                      explicitType: nil,
                                      expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                      storage: .stackStorage,
                                      isMutable: true)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedVariableDeclaration_WithExplicitType() {
        let parser = SnapParser(tokens: tokenize("var foo: u8 = 1"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                      explicitType: .u8,
                                      expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                      storage: .stackStorage,
                                      isMutable: true)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testMalformedStaticVariableDeclaration() {
        let parser = SnapParser(tokens: tokenize("static foo"))
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected declaration")
    }
    
    func testWellFormedStaticVariableDeclaration() {
        let parser = SnapParser(tokens: tokenize("static var foo = 1"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                      explicitType: nil,
                                      expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                      storage: .staticStorage,
                                      isMutable: true)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedStaticVariableDeclaration_Immutable() {
        let parser = SnapParser(tokens: tokenize("static let foo = 1"))
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                      explicitType: nil,
                                      expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                      storage: .staticStorage,
                                      isMutable: false)
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
        XCTAssertEqual(parser.errors.first?.message, "expected `)' after expression")
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
        
        let expected = ExprUtils.makeComparisonEq(left: ExprUtils.makeAdd(left: ExprUtils.makeLiteralInt(value: 1),
                                                                          right: ExprUtils.makeLiteralInt(value: 2)),
                                                  right: ExprUtils.makeLiteralInt(value: 3))
        XCTAssertEqual(Optional<Expression>(expected), ast?.children.first)
    }
        
    func testExpressionStatement_Comparison_NotEqual() {
        let tokens = tokenize("1 + 2 != 3")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 1)
        
        let expected = ExprUtils.makeComparisonNe(left: ExprUtils.makeAdd(left: ExprUtils.makeLiteralInt(value: 1),
                                                                          right: ExprUtils.makeLiteralInt(value: 2)),
                                                  right: ExprUtils.makeLiteralInt(value: 3))
        XCTAssertEqual(Optional<Expression>(expected), ast?.children.first)
    }
        
    func testExpressionStatement_Comparison_LessThan() {
        let tokens = tokenize("1 + 2 < 3")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 1)
        
        let expected = ExprUtils.makeComparisonLt(left: ExprUtils.makeAdd(left: ExprUtils.makeLiteralInt(value: 1),
                                                                          right: ExprUtils.makeLiteralInt(value: 2)),
                                                  right: ExprUtils.makeLiteralInt(value: 3))
        XCTAssertEqual(Optional<Expression>(expected), ast?.children.first)
    }
        
    func testExpressionStatement_Comparison_GreaterThan() {
        let tokens = tokenize("1 + 2 > 3")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 1)
        
        let expected = ExprUtils.makeComparisonGt(left: ExprUtils.makeAdd(left: ExprUtils.makeLiteralInt(value: 1),
                                                                          right: ExprUtils.makeLiteralInt(value: 2)),
                                                  right: ExprUtils.makeLiteralInt(value: 3))
        XCTAssertEqual(Optional<Expression>(expected), ast?.children.first)
    }
        
    func testExpressionStatement_Comparison_LessThanOrEqualTo() {
        let tokens = tokenize("1 + 2 <= 3")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 1)
        
        let expected = ExprUtils.makeComparisonLe(left: ExprUtils.makeAdd(left: ExprUtils.makeLiteralInt(value: 1),
                                                                          right: ExprUtils.makeLiteralInt(value: 2)),
                                                  right: ExprUtils.makeLiteralInt(value: 3))
        XCTAssertEqual(Optional<Expression>(expected), ast?.children.first)
    }
        
    func testExpressionStatement_Comparison_GreaterThanOrEqualTo() {
        let tokens = tokenize("1 + 2 >= 3")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 1)
        
        let expected = ExprUtils.makeComparisonGe(left: ExprUtils.makeAdd(left: ExprUtils.makeLiteralInt(value: 1),
                                                                          right: ExprUtils.makeLiteralInt(value: 2)),
                                                  right: ExprUtils.makeLiteralInt(value: 3))
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
                          then: Block(children: [
                            VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                                           explicitType: nil,
                                           expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 2, lexeme: "2", literal: 2)),
                                           storage: .stackStorage,
                                           isMutable: true)
                          ]),
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
        
        XCTAssertEqual(parser.syntaxTree?.children, [
            If(condition: ExprUtils.makeLiteralInt(lineNumber: 1, value: 1),
               then: Block(children: [
                ExprUtils.makeLiteralInt(lineNumber: 2, value: 2)
               ]),
               else: Block(children: [
                ExprUtils.makeLiteralInt(lineNumber: 4, value: 3),
                ExprUtils.makeLiteralInt(lineNumber: 5, value: 4)
               ])),
            ExprUtils.makeLiteralInt(lineNumber: 7, value: 5)])
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
                          then: Block(),
                          else: Block())
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
                          then: Block(),
                          else: Block())
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
        
        XCTAssertEqual(parser.syntaxTree?.children, [
            If(condition: ExprUtils.makeLiteralInt(lineNumber: 1, value: 1),
               then: Block(children: [
                VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                               explicitType: nil,
                               expression: ExprUtils.makeLiteralInt(lineNumber: 2, value: 1),
                               storage: .stackStorage,
                               isMutable: false)
               ]),
               else: Block(children: [
                VarDeclaration(identifier: TokenIdentifier(lineNumber: 4, lexeme: "bar"),
                               explicitType: nil,
                               expression: ExprUtils.makeLiteralInt(lineNumber: 4, value: 1),
                               storage: .stackStorage,
                               isMutable: false)
               ]))
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
        
        XCTAssertEqual(parser.syntaxTree?.children, [
            If(condition: ExprUtils.makeLiteralInt(lineNumber: 1, value: 1),
               then: Block(children: [
                VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                               explicitType: nil,
                               expression: ExprUtils.makeLiteralInt(lineNumber: 2, value: 1),
                               storage: .stackStorage,
                               isMutable: false)
               ]),
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
        XCTAssertEqual(parser.syntaxTree?.children, [
            While(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                  body: Block(children: [
                    VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                                   explicitType: nil,
                                   expression: ExprUtils.makeLiteralInt(lineNumber: 2, value: 2),
                                   storage: .stackStorage,
                                   isMutable: true)
                  ]))
        ])
    }
        
    func testWellformedWhileStatement_EmptyBody_1() {
        let tokens = tokenize("""
while 1 {
}
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        
        XCTAssertEqual(parser.syntaxTree?.children, [
            While(condition: ExprUtils.makeLiteralInt(value: 1), body: Block())
        ])
    }
        
    func testWellformedWhileStatement_EmptyBody_2() {
        let tokens = tokenize("""
while 1 {}
""")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        
        XCTAssertEqual(parser.syntaxTree?.children, [
            While(condition: ExprUtils.makeLiteralInt(value: 1), body: Block())
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
            Block(children: [
                ForLoop(initializerClause: VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "i"),
                                                          explicitType: nil,
                                                          expression: ExprUtils.makeLiteralInt(value: 0),
                                                          storage: .stackStorage,
                                                          isMutable: true),
                        conditionClause: ExprUtils.makeComparisonLt(left: ExprUtils.makeIdentifier(name: "i"),
                                                                    right: ExprUtils.makeLiteralInt(value: 10)),
                        incrementClause: ExprUtils.makeAssignment(name: "i", right: ExprUtils.makeAdd(left: ExprUtils.makeIdentifier(name: "i"), right: ExprUtils.makeLiteralInt(value: 1))),
                        body: Block(children: [
                            VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                                           explicitType: nil,
                                           expression: ExprUtils.makeIdentifier(lineNumber: 2, name: "i"),
                                           storage: .stackStorage,
                                           isMutable: true)
                        ]))
            ])
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
            Block(children: [
                VarDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                               explicitType: nil,
                               expression: ExprUtils.makeIdentifier(lineNumber: 2, name: "i"),
                               storage: .stackStorage,
                               isMutable: true)
            ])
        ])
    }
        
    func testStandaloneBlockStatementsWithoutNewlines() {
        let tokens = tokenize("{var foo = i}")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Block(children: [
                VarDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                               explicitType: nil,
                               expression: ExprUtils.makeIdentifier(lineNumber: 1, name: "i"),
                               storage: .stackStorage,
                               isMutable: true)
            ])
        ])
    }
        
    func testStandaloneBlockStatementIsEmpty() {
        let tokens = tokenize("{}")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Block(children: [])
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
            Block(children: [
                Block(children: [
                    VarDeclaration(identifier: TokenIdentifier(lineNumber: 3, lexeme: "bar"),
                                   explicitType: nil,
                                   expression: ExprUtils.makeIdentifier(lineNumber: 3, name: "i"),
                                   storage: .stackStorage,
                                   isMutable: true)
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
            Block(children: [
                Block(children: [
                ])
            ])
        ])
    }
    
    func testParseFunctionCallWithNoArguments() {
        let tokens = tokenize("foo()")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"), arguments: [])
        ])
    }
    
    func testParseFunctionCallWithOneArgument() {
        let tokens = tokenize("foo(1)")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"),
                            arguments: [ExprUtils.makeLiteralInt(value: 1)])
        ])
    }
    
    func testParseFunctionCallWithTwoArgument() {
        let tokens = tokenize("foo(1, 2)")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"),
                            arguments: [ExprUtils.makeLiteralInt(value: 1),
                                        ExprUtils.makeLiteralInt(value: 2)])
        ])
    }
    
    func testParseFunctionCallInExpression() {
        let tokens = tokenize("1 + foo(1, 2)")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                              left: ExprUtils.makeLiteralInt(value: 1),
                              right: Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"),
                                                     arguments: [ExprUtils.makeLiteralInt(value: 1),
                                                                 ExprUtils.makeLiteralInt(value: 2)]))
            
        ])
    }
    
    func testFailToParseFunctionDefinition_MissingIdentifier_1() {
        let tokens = tokenize("func")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected identifier in function declaration")
    }
    
    func testFailToParseFunctionDefinition_MissingIdentifier_2() {
        let tokens = tokenize("func 123")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected identifier in function declaration")
    }
    
    func testFailToParseFunctionDefinition_MissingArgumentListLeftParen() {
        let tokens = tokenize("func foo")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected `(' in argument list of function declaration")
    }
    
    func testFailToParseFunctionDefinition_MissingArgumentListRightParen() {
        let tokens = tokenize("func foo(")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected parameter name followed by `:'")
    }
    
    func testFailToParseFunctionDefinition_MissingFunctionBody() {
        let tokens = tokenize("func foo()")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected `{' in body of function declaration")
    }
    
    func testFailToParseFunctionDefinition_MalformedFunctionBody() {
        let tokens = tokenize("func foo() {\n")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected `}' after function body")
    }
    
    func testParseFunctionDefinition_ZeroArgsAndVoidReturnValue() {
        let tokens = tokenize("func foo() {}")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .void, arguments: []),
                                body: Block())
        ]))
    }
    
    func testFailToParseFunctionDefinition_InvalidReturnType() {
        let tokens = tokenize("func foo() -> wat {}")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "use of undeclared type `wat'")
    }
    
    func testParseFunctionDefinition_ZeroArgsAndUInt8ReturnValue() {
        let tokens = tokenize("func foo() -> u8 {}")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block())
        ]))
    }
    
    func testParseFunctionDefinition_ZeroArgsAndExplicitVoidReturnValue() {
        let tokens = tokenize("func foo() -> void {}")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .void, arguments: []),
                                body: Block())
        ]))
    }
    
    func testFailToParseFunctionDefinition_ParameterIsNotAnIdentifier() {
        let tokens = tokenize("func foo(123) {}")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected parameter name followed by `:'")
    }
    
    func testFailToParseFunctionDefinition_ParameterIsMissingAnExplicitType() {
        let tokens = tokenize("func foo(bar) {}")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "parameter requires an explicit type")
    }
    
    func testParseFunctionDefinition_OneArg() {
        let tokens = tokenize("func foo(bar: u8) {}")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .void, arguments: [FunctionType.Argument(name: "bar", type: .u8)]),
                                body: Block())
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParseFunctionDefinition_TwoArgs() {
        let tokens = tokenize("func foo(bar: u8, baz: bool) {}")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .void, arguments: [FunctionType.Argument(name: "bar", type: .u8), FunctionType.Argument(name: "baz", type: .bool)]),
                                body: Block())
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParseFunctionDefinition_ArgWithVoidType() {
        // The parser will permit the following.
        // The typechecker should reject it later.
        let tokens = tokenize("func foo(bar: void) {}")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(children: [
            FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                functionType: FunctionType(returnType: .void, arguments: [FunctionType.Argument(name: "bar", type: .void)]),
                                body: Block())
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParseReturn() {
        let tokens = tokenize("return 1")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(children: [
            Return(token: TokenReturn(lineNumber: 1, lexeme: "return"), expression: ExprUtils.makeLiteralInt(value: 1))
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParsePeekMemory() {
        let tokens = tokenize("peekMemory(0x0010)")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(children: [
            Expression.Call(callee: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "peekMemory")), arguments: [Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0x0010", literal: 0x0010))])
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParsePokeMemory() {
        let tokens = tokenize("pokeMemory(0x0010, 0xab)")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(children: [
            Expression.Call(callee: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "pokeMemory")), arguments: [Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0x0010", literal: 0x0010)), Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0xab", literal: 0xab))])
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParsePeekPeripheral() {
        let tokens = tokenize("peekPeripheral(0xffff, 7)")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(children: [
            Expression.Call(callee: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "peekPeripheral")), arguments: [Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0xffff", literal: 0xffff)), Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "7", literal: 7))])
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParsePokePeripheral() {
        let tokens = tokenize("pokePeripheral(0xffff, 0xff, 0)")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(children: [
            Expression.Call(callee: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "pokePeripheral")), arguments: [Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0xffff", literal: 0xffff)), Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0xff", literal: 0xff)), Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "0", literal: 0))])
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParseValidSubscriptExpression() {
        let tokens = tokenize("foo[1+2]")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(children: [
            ExprUtils.makeSubscript(identifier: "foo",
                                    expr: ExprUtils.makeAdd(left: ExprUtils.makeLiteralInt(value: 1),
                                                            right: ExprUtils.makeLiteralInt(value: 2)))
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParseValidSubscriptExpression_Nested() {
        let tokens = tokenize("foo[foo[0]]")
        let parser = SnapParser(tokens: tokens)
        parser.parse()
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(children: [
            ExprUtils.makeSubscript(identifier: "foo",
                                    expr: ExprUtils.makeSubscript(identifier: "foo",
                                                                  expr: ExprUtils.makeLiteralInt(value: 0)))
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
}
