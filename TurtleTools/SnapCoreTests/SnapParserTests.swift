//
//  SnapParserTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapParserTests: XCTestCase {
    func parse(_ text: String) -> SnapParser {
        let tokenizer = SnapLexer(text)
        tokenizer.scanTokens()
        let parser = SnapParser(tokens: tokenizer.tokens,
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

    func testLabelDeclaration() {
        let parser = parse("label:")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(0, 6))
        XCTAssertEqual(parser.errors.first?.message, "labels are not supported")
    }

    func testParseExtraneousColon() {
        // If we try to use a number as a label name then it will be interpreted
        // as a malformed expression.
        let parser = parse(":")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(0, 1))
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `:'")
    }
    
    func testExtraneousComma() {
        let parser = parse(",")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(0, 1))
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `,'")
    }

    func testMultipleErrorsParsingInstructions() {
        let parser = parse(",\n:\n")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.count, 2)
        XCTAssertEqual(parser.errors[0].sourceAnchor, parser.lineMapper.anchor(0, 1))
        XCTAssertEqual(parser.errors[0].message, "operand type mismatch: `,'")
        XCTAssertEqual(parser.errors[1].sourceAnchor, parser.lineMapper.anchor(2, 3))
        XCTAssertEqual(parser.errors[1].message, "operand type mismatch: `:'")
    }
    
    func testMalformedLetDeclaration_JustLet() {
        let parser = parse("let")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(0, 3))
        XCTAssertEqual(parser.errors.first?.message, "expected to find an identifier in let declaration")
    }
    
    func testMalformedLetDeclaration_MissingAssignment() {
        let parser = parse("let foo")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.text, "foo")
        XCTAssertEqual(parser.errors.first?.message, "constants must be assigned a value")
    }
    
    func testMalformedLetDeclaration_MissingValue() {
        let parser = parse("let foo =")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(8, 9))
        XCTAssertEqual(parser.errors.first?.message, "expected value after `='")
    }
    
    func testMalformedLetDeclaration_BadTypeForValue_TooManyTokens() {
        let parser = parse("let foo = 1 2")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(12, 13))
        XCTAssertEqual(parser.errors.first?.message, "expected to find the end of the statement: `2'")
    }
    
    func testWellFormedLetDeclaration() {
        let parser = parse("let foo = 1")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 11),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                      explicitType: nil,
                                      expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(10, 11), value: 1),
                                      storage: .automaticStorage,
                                      isMutable: false)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedLetDeclaration_WithExplicitType_U8() {
        let parser = parse("let foo: u8 = 1")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 15),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                      explicitType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(9, 11), typ: .u8),
                                      expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(14, 15), value: 1),
                                      storage: .automaticStorage,
                                      isMutable: false)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedArrayLiteralWithAndImplicitCount() {
        let parser = parse("[_]u16{foo}")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.LiteralArray(sourceAnchor: parser.lineMapper.anchor(0, 11),
                                               arrayType: Expression.ArrayType(sourceAnchor: parser.lineMapper.anchor(0, 6), count: nil, elementType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(3, 6), typ: .u16)),
                                               elements: [Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(7, 10), identifier: "foo")])
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedArrayLiteralOfNestedArrays() {
        let parser = parse("[_][_]u16{[_]u16{foo, foo}}")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        let innerArray = Expression.LiteralArray(sourceAnchor: parser.lineMapper.anchor(10, 26),
                                                 arrayType: Expression.ArrayType(sourceAnchor: parser.lineMapper.anchor(10, 16), count: nil, elementType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(13, 16), typ: .u16)),
                                                 elements: [Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(17, 20), identifier: "foo"),
                                                            Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(22, 25), identifier: "foo")])
        let expected = Expression.LiteralArray(sourceAnchor: parser.lineMapper.anchor(0, 27),
                                               arrayType: Expression.ArrayType(sourceAnchor: parser.lineMapper.anchor(0, 9), count: nil, elementType: Expression.ArrayType(sourceAnchor: parser.lineMapper.anchor(3, 9), count: nil, elementType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(6, 9), typ: .u16))),
                                               elements: [innerArray])
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedArrayLiteralWithExplicitTypeAndCount() {
        let parser = parse("[1]u16{foo}")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.LiteralArray(sourceAnchor: parser.lineMapper.anchor(0, 11),
                                               arrayType: Expression.ArrayType(sourceAnchor: parser.lineMapper.anchor(0, 6), count: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(1, 2), value: 1), elementType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(3, 6), typ: .u16)),
                                               elements: [Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(7, 10), identifier: "foo")])
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedLetDeclaration_ArrayOfU8_ExplicitType_ImplicitCount() {
        let parser = parse("let foo: [_]u8 = [_]u8{}")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let innerArray = Expression.LiteralArray(sourceAnchor: parser.lineMapper.anchor(17, 24),
                                                 arrayType: Expression.ArrayType(sourceAnchor: parser.lineMapper.anchor(17, 22), count: nil, elementType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(20, 22), typ: .u8)),
                                                 elements: [])
        
        // Note that the parser doesn't know that the expression will actually
        // yield a result of the the type [0]u8.
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 24),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                      explicitType: Expression.ArrayType(sourceAnchor: parser.lineMapper.anchor(9, 14), count: nil, elementType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(12, 14), typ: .u8)),
                                      expression: innerArray,
                                      storage: .automaticStorage,
                                      isMutable: false)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedLetDeclaration_ArrayOfU8_ExplicitCount() {
        let parser = parse("let foo: [0]u8 = [0]u8{}")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 24),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                      explicitType: Expression.ArrayType(sourceAnchor: parser.lineMapper.anchor(9, 14), count: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(10, 11), value: 0), elementType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(12, 14), typ: .u8)),
                                      expression: Expression.LiteralArray(sourceAnchor: parser.lineMapper.anchor(17, 24),
                                                                          arrayType: Expression.ArrayType(sourceAnchor: parser.lineMapper.anchor(17, 22), count: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(18, 19), value: 0), elementType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(20, 22), typ: .u8)),
                                                                          elements: []),
                                      storage: .automaticStorage,
                                      isMutable: false)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedLetDeclaration_ArrayOfU8_ImplicitType() {
        let parser = parse("let foo = [0]u8{1}")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 18),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                      explicitType: nil,
                                      expression: Expression.LiteralArray(sourceAnchor: parser.lineMapper.anchor(10, 18),
                                                                          arrayType: Expression.ArrayType(sourceAnchor: parser.lineMapper.anchor(10, 15), count: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(11, 12), value: 0), elementType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(13, 15), typ: .u8)),
                                                                          elements: [
                                        Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(16, 17), value: 1)
                                      ]),
                                      storage: .automaticStorage,
                                      isMutable: false)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedLetDeclaration_ArrayOfU8_MoreThanOneElement() {
        let parser = parse("let foo = [_]u8{1, 2, 3}")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        let arr = Expression.LiteralArray(sourceAnchor: parser.lineMapper.anchor(10, 24),
                                          arrayType: Expression.ArrayType(sourceAnchor: parser.lineMapper.anchor(10, 15), count: nil, elementType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(13, 15), typ: .u8)),
                                          elements: [
            Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(16, 17), value: 1),
            Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(19, 20), value: 2),
            Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(22, 23), value: 3)
        ])
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 24),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                      explicitType: nil,
                                      expression: arr,
                                      storage: .automaticStorage,
                                      isMutable: false)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedLetDeclaration_ArrayOfU8InitializedFromQuotedString() {
        let parser = parse("""
let foo = "Hello, World!"
""")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        let str = Expression.LiteralString(sourceAnchor: parser.lineMapper.anchor(10, 25),
                                          value: "Hello, World!")
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 25),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                      explicitType: nil,
                                      expression: str,
                                      storage: .automaticStorage,
                                      isMutable: false)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedLetDeclaration_DynamicArrayOfU8_ExplicitType() {
        let parser = parse("""
let foo: []u8 = bar
""")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 19),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                      explicitType: Expression.DynamicArrayType(sourceAnchor: parser.lineMapper.anchor(9, 13), elementType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(11, 13), typ: .u8)),
                                      expression: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(16, 19), identifier: "bar"),
                                      storage: .automaticStorage,
                                      isMutable: false)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedLetDeclaration_VariableOfUndefinedValue() {
        let parser = parse("""
let foo: [1]u8 = undefined
""")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        XCTAssertEqual(ast.children.count, 1)
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 26),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                      explicitType: Expression.ArrayType(sourceAnchor: parser.lineMapper.anchor(9, 14), count: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(10, 11), value: 1), elementType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(12, 14), typ: .u8)),
                                      expression: nil,
                                      storage: .automaticStorage,
                                      isMutable: false)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testMalformedVariableDeclaration_BareVar() {
        let parser = parse("var")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(0, 3))
        XCTAssertEqual(parser.errors.first?.message, "expected to find an identifier in variable declaration")
    }
    
    func testMalformedVariableDeclaration_MissingAssignment() {
        let parser = parse("var foo")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(4, 7))
        XCTAssertEqual(parser.errors.first?.message, "variables must be assigned an initial value")
    }
    
    func testMalformedVariableDeclaration_MissingValue() {
        let parser = parse("var foo =")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(8, 9))
        XCTAssertEqual(parser.errors.first?.message, "expected initial value after `='")
    }
    
    func testMalformedVariableDeclaration_BadTypeForValue_TooManyTokens() {
        let parser = parse("var foo = 1 2")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(12, 13))
        XCTAssertEqual(parser.errors.first?.message, "expected to find the end of the statement: `2'")
    }
    
    func testWellFormedVariableDeclaration() {
        let parser = parse("var foo = 1")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 11),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                      explicitType: nil,
                                      expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(10, 11), value: 1),
                                      storage: .automaticStorage,
                                      isMutable: true)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedVariableDeclaration_WithExplicitType() {
        let parser = parse("var foo: u8 = 1")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 15),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                      explicitType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(9, 11), typ: .u8),
                                      expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(14, 15), value: 1),
                                      storage: .automaticStorage,
                                      isMutable: true)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testMalformedStaticVariableDeclaration() {
        let parser = parse("static foo")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(0, 6))
        XCTAssertEqual(parser.errors.first?.message, "expected declaration")
    }
    
    func testWellFormedStaticVariableDeclaration() {
        let parser = parse("static var foo = 1")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 18),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(11, 14), identifier: "foo"),
                                      explicitType: nil,
                                      expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(17, 18), value: 1),
                                      storage: .staticStorage,
                                      isMutable: true)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedStaticVariableDeclaration_Constant() {
        let parser = parse("static let foo = 1")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 18),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(11, 14), identifier: "foo"),
                                      explicitType: nil,
                                      expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(17, 18), value: 1),
                                      storage: .staticStorage,
                                      isMutable: false)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testExpressionStatement_Literal_Number() {
        let parser = parse("1")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1)
        XCTAssertEqual(expected, ast.children.first)
    }
    
    func testExpressionStatement_Literal_Boolean() {
        let parser = parse("true")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.LiteralBool(sourceAnchor: parser.lineMapper.anchor(0, 4), value: true)
        XCTAssertEqual(expected, ast.children.first)
    }
    
    func testExpressionStatement_Identifier() {
        let parser = parse("foo")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3), identifier: "foo")
        XCTAssertEqual(expected, ast.children.first)
    }
    
    func testExpressionStatement_Unary_Identifier() {
        let parser = parse("-foo")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Unary(sourceAnchor: parser.lineMapper.anchor(0, 4),
                                        op: .minus,
                                        expression: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(1, 4), identifier: "foo"))
        XCTAssertEqual(expected, ast.children.first)
    }
    
    func testExpressionStatement_Unary_Boolean() {
        // We'll flag this as a type error during semantic analysis. The parser,
        // however, has no problem with it.
        let parser = parse("-false")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Unary(sourceAnchor: parser.lineMapper.anchor(0, 6),
                                        op: .minus,
                                        expression: Expression.LiteralBool(sourceAnchor: parser.lineMapper.anchor(1, 6), value: false))
        XCTAssertEqual(expected, ast.children.first)
    }
    
    func testExpressionStatement_Unary_Ampersand() {
        let parser = parse("&foo")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Unary(sourceAnchor: parser.lineMapper.anchor(0, 4),
                                        op: .ampersand,
                                        expression: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(1, 4), identifier: "foo"))
        XCTAssertEqual(expected, ast.children.first)
    }
    
    func testExpressionStatement_Unary_OperandTypeMismatch() {
        let parser = parse("-,")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "operand type mismatch: `,'")
    }
    
    func testExpressionStatement_Multiplication() {
        let parser = parse("1 * -foo")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 8),
                                         op: .star,
                                         left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                         right: Expression.Unary(sourceAnchor: parser.lineMapper.anchor(4, 8),
                                                                 op: .minus,
                                                                 expression: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "foo")))
        XCTAssertEqual(expected, ast.children.first)
    }
    
    func testExpressionStatement_Division() {
        let parser = parse("1 / -foo")
        XCTAssertFalse(parser.hasError)
        
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        
        guard let ast = parser.syntaxTree else {
            XCTFail("no syntax tree")
            return
        }
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 8),
                                         op: .divide,
                                         left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                         right: Expression.Unary(sourceAnchor: parser.lineMapper.anchor(4, 8),
                                                                 op: .minus,
                                                                 expression: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "foo")))
        XCTAssertEqual(expected, ast.children.first)
    }
    
    func testExpressionStatement_Addition() {
        let parser = parse("1 + -foo")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 8),
                                         op: .plus,
                                         left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                         right: Expression.Unary(sourceAnchor: parser.lineMapper.anchor(4, 8),
                                                                 op: .minus,
                                                                 expression: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "foo")))
        XCTAssertEqual(expected, ast.children.first)
    }
    
    func testExpressionStatement_Subtraction() {
        let parser = parse("1 - -foo")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 8),
                                         op: .minus,
                                         left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                         right: Expression.Unary(sourceAnchor: parser.lineMapper.anchor(4, 8),
                                                                 op: .minus,
                                                                 expression: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "foo")))
        XCTAssertEqual(expected, ast.children.first)
    }
    
    func testExpressionStatement_MultiplicationTakesPrecendenceOverAddition() {
        let parser = parse("1 + 2 * 4")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 9),
                                         op: .plus,
                                         left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                         right: Expression.Binary(sourceAnchor: parser.lineMapper.anchor(4, 9),
                                                                  op: .star,
                                                                  left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(4, 5), value: 2),
                                                                  right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(8, 9), value: 4)))
        XCTAssertEqual(expected, ast.children.first)
    }
    
    func testExpressionStatement_MultiplicationTakesPrecendenceOverSubtraction() {
        let parser = parse("1 - 2 * 4")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 9),
                                         op: .minus,
                                         left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                         right: Expression.Binary(sourceAnchor: parser.lineMapper.anchor(4, 9),
                                                                  op: .star,
                                                                  left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(4, 5), value: 2),
                                                                  right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(8, 9), value: 4)))
        XCTAssertEqual(expected, ast.children.first)
    }
    
    func testExpressionStatement_Modulus() {
        let parser = parse("7 % 3")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 5),
                                         op: .modulus,
                                         left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 7),
                                         right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(4, 5), value: 3))
        XCTAssertEqual(expected, ast.children.first)
    }
    
    func testExpressionStatement_ParenthesesProvideGrouping() {
        let parser = parse("(2-1)*4")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 1)
        
        let expected = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 7),
                                         op: .star,
                                         left: Expression.Group(sourceAnchor: parser.lineMapper.anchor(0, 5), expression:
                                            Expression.Binary(sourceAnchor: parser.lineMapper.anchor(1, 4),
                                                              op: .minus,
                                                              left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(1, 2), value: 2),
                                                              right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(3, 4), value: 1))),
                                         right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(6, 7), value: 4))
        XCTAssertEqual(expected, ast?.children.first)
    }
    
    func testExpressionStatement_RightParenthesesMissing() {
        let parser = parse("(1+1")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected `)' after expression")
    }
    
    func testExpressionStatement_AssignmentExpression() {
        let parser = parse("""
var foo = 1
foo = 2
""")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 2)
        
        let expected = Expression.Assignment(sourceAnchor: parser.lineMapper.anchor(12+0, 12+7),
                                             lexpr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(12+0, 12+3), identifier: "foo"),
                                             rexpr: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(12+6, 12+7), value: 2))
        XCTAssertEqual(expected, ast?.children.last)
    }
        
    func testExpressionStatement_Comparison_Equals() {
        let parser = parse("1 + 2 == 3")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        XCTAssertEqual(ast?.children.count, 1)

        let inner = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 5),
                                      op: .plus,
                                      left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                      right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(4, 5), value: 2))
        let expected = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 10),
                                         op: .eq,
                                         left: inner,
                                         right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(9, 10), value: 3))
        XCTAssertEqual(expected, ast?.children.first)
    }
        
    func testExpressionStatement_Comparison_NotEqual() {
        let parser = parse("1 + 2 != 3")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        XCTAssertEqual(ast?.children.count, 1)
        let inner = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 5),
                                      op: .plus,
                                      left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                      right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(4, 5), value: 2))
        let expected = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 10),
                                         op: .ne,
                                         left: inner,
                                         right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(9, 10), value: 3))
        XCTAssertEqual(expected, ast?.children.first)
    }
        
    func testExpressionStatement_Comparison_LessThan() {
        let parser = parse("1 + 2 < 3")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        XCTAssertEqual(ast?.children.count, 1)
        let inner = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 5),
                                      op: .plus,
                                      left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                      right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(4, 5), value: 2))
        let expected = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 9),
                                         op: .lt,
                                         left: inner,
                                         right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(8, 9), value: 3))
        XCTAssertEqual(expected, ast?.children.first)
    }
        
    func testExpressionStatement_Comparison_GreaterThan() {
        let parser = parse("1 + 2 > 3")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        XCTAssertEqual(ast?.children.count, 1)
        let inner = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 5),
                                      op: .plus,
                                      left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                      right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(4, 5), value: 2))
        let expected = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 9),
                                         op: .gt,
                                         left: inner,
                                         right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(8, 9), value: 3))
        XCTAssertEqual(expected, ast?.children.first)
    }
        
    func testExpressionStatement_Comparison_LessThanOrEqualTo() {
        let parser = parse("1 + 2 <= 3")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        XCTAssertEqual(ast?.children.count, 1)
        let inner = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 5),
                                      op: .plus,
                                      left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                      right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(4, 5), value: 2))
        let expected = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 10),
                                         op: .le,
                                         left: inner,
                                         right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(9, 10), value: 3))
        XCTAssertEqual(expected, ast?.children.first)
    }
        
    func testExpressionStatement_Comparison_GreaterThanOrEqualTo() {
        let parser = parse("1 + 2 >= 3")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        XCTAssertEqual(ast?.children.count, 1)
        let inner = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 5),
                                      op: .plus,
                                      left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                      right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(4, 5), value: 2))
        let expected = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 10),
                                         op: .ge,
                                         left: inner,
                                         right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(9, 10), value: 3))
        XCTAssertEqual(expected, ast?.children.first)
    }
        
    func testMalformedIfStatement_MissingCondition_1() {
        let parser = parse("if")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.text, "if")
        XCTAssertEqual(parser.errors.first?.message, "expected condition after `if'")
    }
        
    func testMalformedIfStatement_MissingCondition_2() {
        let parser = parse("if {")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.text, "if")
        XCTAssertEqual(parser.errors.first?.message, "expected condition after `if'")
    }
        
    func testMalformedIfStatement_MissingOpeningBraceForThenBranch() {
        let parser = parse("if 1")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected newline")
    }
        
    func testMalformedIfStatement_MissingStatementForThenBranch() {
        let parser = parse("if 1 {\n")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected `}' after `then' branch")
    }
        
    func testMalformedIfStatement_MissingClosingBraceOfThenBranch() {
        let parser = parse("""
if 1 {
    var foo = 2
""")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "expected `}' after `then' branch")
    }
        
    func testWellformedIfStatement_NoElseBranch() {
        let parser = parse("""
if 1 {
    var foo = 2
}
""")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree
        
        XCTAssertEqual(ast?.children.count, 1)
        
        let expected = If(sourceAnchor: parser.lineMapper.anchor(0, 24),
                          condition: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(3, 4), value: 1),
                          then: Block(sourceAnchor: parser.lineMapper.anchor(5, 24), children: [
                            VarDeclaration(sourceAnchor: parser.lineMapper.anchor(11, 22),
                                           identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(15, 18), identifier: "foo"),
                                           explicitType: nil,
                                           expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(21, 22), value: 2),
                                           storage: .automaticStorage,
                                           isMutable: true)
                          ]),
                          else: nil)
        XCTAssertEqual(Optional<If>(expected), ast?.children.first)
    }
        
    func testMalformedIfStatement_MissingOpeningBraceForElseBranch_1() {
        let parser = parse("""
if 1 {
    var foo = 2
} else
""")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }
        
    func testMalformedIfStatement_MissingOpeningBraceForElseBranch_2() {
        let parser = parse("""
if 1 {
    var foo = 2
}
else
""")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }
        
    func testMalformedIfStatement_MissingStatementForElseBranch() {
        let parser = parse("""
if 1 {
    var foo = 2
} else {

""")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.lineNumbers, 2..<3)
        XCTAssertEqual(parser.errors.first?.message, "expected `}' after `else' branch")
    }
        
    func testMalformedIfStatement_MissingClosingBraceOfElseBranch() {
        let parser = parse("""
if 1 {
    1
} else {
    var foo = 2
""")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.lineNumbers, 3..<4)
        XCTAssertEqual(parser.errors.first?.message, "expected `}' after `else' branch")
    }
        
    func testWellformedIfStatement_IncludingElseBranch() {
        let parser = parse("""
if 1 {
    2
} else {
    3
    4
}
5
""")
        XCTAssertFalse(parser.hasError)
        
        XCTAssertEqual(parser.syntaxTree?.children, [
            If(sourceAnchor: parser.lineMapper.anchor(0, 35),
               condition: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(3, 4), value: 1),
               then: Block(sourceAnchor: parser.lineMapper.anchor(5, 14), children: [
                Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(11, 12), value: 2)
               ]),
               else: Block(sourceAnchor: parser.lineMapper.anchor(20, 35), children: [
                Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(26, 27), value: 3),
                Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(32, 33), value: 4)
               ])),
            Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(36, 37), value: 5)])
    }
        
    func testWellformedIfStatement_IncludingElseBranch_2() {
        let parser = parse("""
if 1 {
} else {
}
""")
        XCTAssertFalse(parser.hasError)
        
        XCTAssertEqual(parser.syntaxTree?.children,
                       [If(sourceAnchor: parser.lineMapper.anchor(0, 17),
                           condition: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(3, 4), value: 1),
                           then: Block(sourceAnchor: parser.lineMapper.anchor(5, 8), children: []),
                           else: Block(sourceAnchor: parser.lineMapper.anchor(14, 17), children: []))
        ])
    }
        
    func testWellformedIfStatement_IncludingElseBranch_3() {
        let parser = parse("""
if 1 {
}
else {
}
""")
        XCTAssertFalse(parser.hasError)
        
        XCTAssertEqual(parser.syntaxTree?.children,
                       [If(sourceAnchor: parser.lineMapper.anchor(0, 17),
                           condition: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(3, 4), value: 1),
                           then: Block(sourceAnchor: parser.lineMapper.anchor(5, 8), children: []),
                           else: Block(sourceAnchor: parser.lineMapper.anchor(14, 17), children: []))
        ])
    }
        
    func testWellformedIfStatement_IncludingElseBranch_4() {
        let parser = parse("""
if 1
    let foo = 1
else
    let bar = 1
""")
        XCTAssertFalse(parser.hasError)
        
        XCTAssertEqual(parser.syntaxTree?.children, [
            If(sourceAnchor: parser.lineMapper.anchor(0, 41),
               condition: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(3, 4), value: 1),
               then: Block(sourceAnchor: parser.lineMapper.anchor(4, 20), children: [
                VarDeclaration(sourceAnchor: parser.lineMapper.anchor(9, 20),
                               identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(13, 16), identifier: "foo"),
                               explicitType: nil,
                               expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(19, 20), value: 1),
                               storage: .automaticStorage,
                               isMutable: false)
               ]),
               else: Block(sourceAnchor: parser.lineMapper.anchor(30, 41), children: [
                VarDeclaration(sourceAnchor: parser.lineMapper.anchor(30, 41),
                               identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(34, 37), identifier: "bar"),
                               explicitType: nil,
                               expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(40, 41), value: 1),
                               storage: .automaticStorage,
                               isMutable: false)
               ]))
        ])
    }
        
    func testWellformedIfStatement_SingleStatementBodyWithoutElseClause() {
        let parser = parse("""
if 1
    let foo = 1
""")
        XCTAssertFalse(parser.hasError)
        
        XCTAssertEqual(parser.syntaxTree?.children, [
            If(sourceAnchor: parser.lineMapper.anchor(0, 20),
               condition: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(3, 4), value: 1),
               then: Block(sourceAnchor: parser.lineMapper.anchor(4, 20), children: [
                VarDeclaration(sourceAnchor: parser.lineMapper.anchor(9, 20),
                               identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(13, 16), identifier: "foo"),
                               explicitType: nil,
                               expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(19, 20), value: 1),
                               storage: .automaticStorage,
                               isMutable: false)
               ]),
               else: nil)
        ])
    }
    
    func testMalformedWhileStatement_MissingCondition_1() {
        let parser = parse("while")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(parser.errors.first?.message, "expected condition after `while'")
    }
        
    func testMalformedWhileStatement_MissingCondition_2() {
        let parser = parse("while {")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(parser.errors.first?.message, "expected condition after `while'")
    }
        
    func testMalformedWhileStatement_MissingOpeningBraceBeforeBody() {
        let parser = parse("while 1")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(parser.errors.first?.message, "expected newline or curly brace after `while' condition")
    }
        
    func testMalformedWhileStatement_MissingStatementInBodyBlock() {
        let parser = parse("while 1 {\n")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(parser.errors.first?.message, "expected `}' after `while' body")
    }
        
    func testMalformedWhileStatement_MissingClosingBraceOfThenBranch() {
        let parser = parse("""
while 1 {
    var foo = 2
""")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.lineNumbers, 1..<2)
        XCTAssertEqual(parser.errors.first?.message, "expected `}' after `while' body")
    }
        
    func testWellformedWhileStatement() {
        let parser = parse("""
while 1 {
    var foo = 2
}
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            While(sourceAnchor: parser.lineMapper.anchor(0, 27),
                  condition: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(6, 7), value: 1),
                  body: Block(sourceAnchor: parser.lineMapper.anchor(8, 27), children: [
                    VarDeclaration(sourceAnchor: parser.lineMapper.anchor(14, 25),
                                   identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(18, 21), identifier: "foo"),
                                   explicitType: nil,
                                   expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(24, 25), value: 2),
                                   storage: .automaticStorage,
                                   isMutable: true)
                  ]))
        ])
    }
        
    func testWellformedWhileStatement_EmptyBody_1() {
        let parser = parse("""
while 1 {
}
""")
        XCTAssertFalse(parser.hasError)
        
        XCTAssertEqual(parser.syntaxTree?.children, [
            While(sourceAnchor: parser.lineMapper.anchor(0, 11),
                  condition: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(6, 7), value: 1),
                  body: Block(sourceAnchor: parser.lineMapper.anchor(8, 11), children: []))
        ])
    }
        
    func testWellformedWhileStatement_EmptyBody_2() {
        let parser = parse("""
while 1 {}
""")
        XCTAssertFalse(parser.hasError)
        
        XCTAssertEqual(parser.syntaxTree?.children, [
            While(sourceAnchor: parser.lineMapper.anchor(0, 10),
                  condition: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(6, 7), value: 1),
                  body: Block(sourceAnchor: parser.lineMapper.anchor(8, 10), children: []))
        ])
    }
        
    func testStandaloneBlockStatements() {
        let parser = parse("""
{
    var foo = i
}
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Block(sourceAnchor: parser.lineMapper.anchor(0, 19), children: [
                VarDeclaration(sourceAnchor: parser.lineMapper.anchor(6, 17),
                               identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(10, 13), identifier: "foo"),
                               explicitType: nil,
                               expression: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(16, 17), identifier: "i"),
                               storage: .automaticStorage,
                               isMutable: true)
            ])
        ])
    }
        
    func testStandaloneBlockStatementsWithoutNewlines() {
        let parser = parse("{var foo = i}")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Block(sourceAnchor: parser.lineMapper.anchor(0, 13), children: [
                VarDeclaration(sourceAnchor: parser.lineMapper.anchor(1, 12),
                               identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "foo"),
                               explicitType: nil,
                               expression: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(11, 12), identifier: "i"),
                               storage: .automaticStorage,
                               isMutable: true)
            ])
        ])
    }
        
    func testStandaloneBlockStatementIsEmpty() {
        let parser = parse("{}")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Block(sourceAnchor: parser.lineMapper.anchor(0, 2), children: [])
        ])
    }
    
    func testStandaloneBlockStatementsAreNested() {
        let parser = parse("""
{
    {
        var bar = i
    }
}
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Block(sourceAnchor: parser.lineMapper.anchor(0, 35), children: [
                Block(sourceAnchor: parser.lineMapper.anchor(6, 33), children: [
                    VarDeclaration(sourceAnchor: parser.lineMapper.anchor(16, 27),
                                   identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(20, 23), identifier: "bar"),
                                   explicitType: nil,
                                   expression: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(26, 27), identifier: "i"),
                                   storage: .automaticStorage,
                                   isMutable: true)
                ])
            ])
        ])
    }
    
    func testStandaloneBlockStatementsAreNestedAndEmpty() {
        let parser = parse("{{}}")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Block(sourceAnchor: parser.lineMapper.anchor(0, 4), children: [
                Block(sourceAnchor: parser.lineMapper.anchor(1, 3), children: [])
            ])
        ])
    }
    
    func testParseFunctionCallWithNoArguments() {
        let parser = parse("foo()")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Expression.Call(sourceAnchor: parser.lineMapper.anchor(0, 5),
                            callee: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3), identifier: "foo"),
                            arguments: [])
        ])
    }
    
    func testParseFunctionCallWithOneArgument() {
        let parser = parse("foo(1)")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Expression.Call(sourceAnchor: parser.lineMapper.anchor(0, 6),
                            callee: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3), identifier: "foo"),
                            arguments: [Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(4, 5), value: 1)])
        ])
    }
    
    func testParseFunctionCallWithTwoArgument() {
        let parser = parse("foo(1, 2)")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Expression.Call(sourceAnchor: parser.lineMapper.anchor(0, 9),
                            callee: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3), identifier: "foo"),
                            arguments: [Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(4, 5), value: 1),
                                        Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(7, 8), value: 2)])
        ])
    }
    
    func testParseFunctionCallInExpression() {
        let parser = parse("1 + foo(1, 2)")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 13),
                              op: .plus,
                              left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                              right: Expression.Call(sourceAnchor: parser.lineMapper.anchor(4, 13),
                                                     callee: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                                     arguments: [Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(8, 9), value: 1),
                                                                 Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(11, 12), value: 2)]))
            
        ])
    }
    
    func testFailToParseFunctionDefinition_MissingIdentifier_1() {
        let parser = parse("func")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(parser.errors.first?.message, "expected identifier in function declaration")
    }
    
    func testFailToParseFunctionDefinition_MissingIdentifier_2() {
        let parser = parse("func 123")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(parser.errors.first?.message, "expected identifier in function declaration")
    }
    
    func testFailToParseFunctionDefinition_MissingArgumentListLeftParen() {
        let parser = parse("func foo")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(parser.errors.first?.message, "expected `(' in argument list of function declaration")
    }
    
    func testFailToParseFunctionDefinition_MissingArgumentListRightParen() {
        let parser = parse("func foo(")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(parser.errors.first?.message, "expected parameter name followed by `:'")
    }
    
    func testFailToParseFunctionDefinition_MissingFunctionBody() {
        let parser = parse("func foo()")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(parser.errors.first?.message, "expected `{' in body of function declaration")
    }
    
    func testFailToParseFunctionDefinition_MalformedFunctionBody() {
        let parser = parse("func foo() {\n")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(parser.errors.first?.message, "expected `}' after function body")
    }
    
    func testParseFunctionDefinition_ZeroArgsAndVoidReturnValue() {
        let parser = parse("func foo() {}")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 13), children: [
            FunctionDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 13),
                                identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "foo"),
                                functionType: Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(0, 13), name: "foo", returnType: Expression.PrimitiveType(.void), arguments: []),
                                argumentNames: [],
                                body: Block(sourceAnchor: parser.lineMapper.anchor(11, 13), children: []))
        ]))
    }
    
    func testParseFunctionDefinition_ZeroArgsAndReturnValueGIvenThroughIdentifier() {
        let parser = parse("func foo() -> wat {}")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 20), children: [
            FunctionDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 20),
                                identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "foo"),
                                functionType: Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(0, 20), name: "foo", returnType: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(14, 17), identifier: "wat"), arguments: []),
                                argumentNames: [],
                                body: Block(sourceAnchor: parser.lineMapper.anchor(18, 20), children: []))
        ]))
    }
    
    func testParseFunctionDefinition_ZeroArgsAndUInt8ReturnValue() {
        let parser = parse("func foo() -> u8 {}")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 19), children: [
            FunctionDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 19),
                                identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "foo"),
                                functionType: Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(0, 19), name: "foo", returnType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(14, 16), typ: .u8), arguments: []),
                                argumentNames: [],
                                body: Block(sourceAnchor: parser.lineMapper.anchor(17, 19), children: []))
        ]))
    }
    
    func testParseFunctionDefinition_ZeroArgsAndExplicitVoidReturnValue() {
        let parser = parse("func foo() -> void {}")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 21), children: [
            FunctionDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 21),
                                identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "foo"),
                                functionType: Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(0, 21), name: "foo", returnType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(14, 18), typ: .void), arguments: []),
                                argumentNames: [],
                                body: Block(sourceAnchor: parser.lineMapper.anchor(19, 21), children: []))
        ]))
    }
    
    func testFailToParseFunctionDefinition_ParameterIsNotAnIdentifier() {
        let parser = parse("func foo(123) {}")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.text, "123")
        XCTAssertEqual(parser.errors.first?.message, "expected parameter name followed by `:'")
    }
    
    func testFailToParseFunctionDefinition_ParameterIsMissingAnExplicitType() {
        let parser = parse("func foo(bar) {}")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.text, "bar")
        XCTAssertEqual(parser.errors.first?.message, "parameter requires an explicit type")
    }
    
    func testParseFunctionDefinition_OneArg() {
        let parser = parse("func foo(bar: u8) {}")
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 20), children: [
            FunctionDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 20),
                                identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "foo"),
                                functionType: Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(0, 20), name: "foo", returnType: Expression.PrimitiveType(.void), arguments: [Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(14, 16), typ: .u8)]),
                                argumentNames: ["bar"],
                                body: Block(sourceAnchor: parser.lineMapper.anchor(18, 20), children: []))
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParseFunctionDefinition_TwoArgs() {
        let parser = parse("func foo(bar: u8, baz: bool) {}")
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 31), children: [
            FunctionDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 31),
                                identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "foo"),
                                functionType: Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(0, 31), name: "foo", returnType: Expression.PrimitiveType(.void), arguments: [Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(14, 16), typ: .u8), Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(23, 27), typ: .bool(.mutableBool))]),
                                argumentNames: ["bar", "baz"],
                                body: Block(sourceAnchor: parser.lineMapper.anchor(29, 31), children: []))
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParseFunctionDefinition_ArgWithVoidType() {
        // The parser will permit the following.
        // The typechecker should reject it later.
        let parser = parse("func foo(bar: void) {}")
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 22), children: [
            FunctionDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 22),
                                identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "foo"),
                                functionType: Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(0, 22), name: "foo", returnType: Expression.PrimitiveType(.void), arguments: [Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(14, 18), typ: .void)]),
                                argumentNames: ["bar"],
                                body: Block(sourceAnchor: parser.lineMapper.anchor(20, 22), children: []))
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParseFunctionDefinition_Generic() {
        let parser = parse("""
            func identity[T](a: T) -> T {
                return a
            }
            """)
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        let functionType = Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(0, 44),
                                                   name: "identity",
                                                   returnType: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(26, 27),
                                                                                     identifier: "T"),
                                                   arguments: [
                                                      Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(20, 21),
                                                                                        identifier: "T")
                                                   ])
        let expected = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 44), children: [
            FunctionDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 44),
                                identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 13),
                                                                  identifier: "identity"),
                                functionType: functionType,
                                argumentNames: ["a"],
                                typeArguments: [
                                    Expression.GenericTypeArgument(sourceAnchor: parser.lineMapper.anchor(14, 15),
                                                                   identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(14, 15),
                                                                                                     identifier: "T"),
                                                                   constraints: [])
                                ],
                                body: Block(sourceAnchor: parser.lineMapper.anchor(28, 44),
                                            children: [
                                              Return(sourceAnchor: parser.lineMapper.anchor(34, 42),
                                                     expression: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(41, 42),
                                                                                       identifier: "a"))
                                            ]))
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParseReturn() {
        let parser = parse("return 1")
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 8), children: [
            Return(sourceAnchor: parser.lineMapper.anchor(0, 8),
                   expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(7, 8), value: 1))
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParsePeekMemory() {
        let parser = parse("peekMemory(0x0010)")
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 18), children: [
            Expression.Call(sourceAnchor: parser.lineMapper.anchor(0, 18),
                            callee: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 10),
                                                          identifier: "peekMemory"),
                            arguments: [Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(11, 17),
                                                               value: 0x0010)])
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParsePokeMemory() {
        let parser = parse("pokeMemory(0x0010, 0xab)")
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 24), children: [
            Expression.Call(sourceAnchor: parser.lineMapper.anchor(0, 24),
                            callee: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 10), identifier: "pokeMemory"),
                            arguments: [Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(11, 17), value: 0x0010),
                                        Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(19, 23), value: 0xab)])
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParsePeekPeripheral() {
        let parser = parse("peekPeripheral(0xffff, 7)")
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 25), children: [
            Expression.Call(sourceAnchor: parser.lineMapper.anchor(0, 25),
                            callee: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 14), identifier: "peekPeripheral"),
                            arguments: [Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(15, 21), value: 0xffff),
                                        Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(23, 24), value: 7)])
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParsePokePeripheral() {
        let parser = parse("pokePeripheral(0xffff, 0xff, 0)")
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 31), children: [
            Expression.Call(sourceAnchor: parser.lineMapper.anchor(0, 31),
                            callee: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 14), identifier: "pokePeripheral"),
                            arguments: [Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(15, 21), value: 0xffff),
                                        Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(23, 27), value: 0xff),
                                        Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(29, 30), value: 0)])
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParseValidSubscriptExpression() {
        let parser = parse("foo[1+2]")
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 8), children: [
            Expression.Subscript(sourceAnchor: parser.lineMapper.anchor(0, 8),
                                 subscriptable: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3), identifier: "foo"),
                                 argument: Expression.Binary(sourceAnchor: parser.lineMapper.anchor(4, 7),
                                                             op: .plus,
                                                             left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(4, 5), value: 1),
                                                             right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(6, 7), value: 2)))
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParseValidSubscriptExpression_Nested() {
        let parser = parse("foo[foo[0]]")
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 11), children: [
            Expression.Subscript(sourceAnchor: parser.lineMapper.anchor(0, 11),
                                 subscriptable: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3), identifier: "foo"),
                                 argument: Expression.Subscript(sourceAnchor: parser.lineMapper.anchor(4, 10),
                                                                subscriptable: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                                                argument: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(8, 9), value: 0)))
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testFailedToGetProperty_ExpectedMemberNameFollowingDot() {
        let parser = parse("foo.")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(3, 4))
        XCTAssertEqual(parser.errors.first?.message, "expected member name following `.'")
    }
    
    func testGetProperty_1() {
        let parser = parse("foo.bar")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let expected = Expression.Get(sourceAnchor: parser.lineMapper.anchor(0, 7),
                                      expr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3), identifier: "foo"),
                                      member: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "bar"))
        XCTAssertEqual(ast.children.first, expected)
    }
    
    func testGetProperty_2() {
        let parser = parse("foo.bar.baz")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let first = Expression.Get(sourceAnchor: parser.lineMapper.anchor(0, 7),
                                      expr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3), identifier: "foo"),
                                      member: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "bar"))
        let secnd = Expression.Get(sourceAnchor: parser.lineMapper.anchor(0, 11),
                                      expr: first,
                                      member: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(8, 11), identifier: "baz"))
        XCTAssertEqual(ast.children.first, secnd)
    }
    
    func testMalformedStructMissingIdentifier() {
        let parser = parse("struct")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(6, 6))
        XCTAssertEqual(parser.errors.first?.message, "expected identifier in struct declaration")
    }
    
    func testMalformedStructCannotUseKeywordAsidentifier() {
        let parser = parse("struct false {}")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(7, 12))
        XCTAssertEqual(parser.errors.first?.message, "expected identifier in struct declaration")
    }
    
    func testMalformedStructMissingOpeningLeftCurly() {
        let parser = parse("struct foo")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(10, 10))
        XCTAssertEqual(parser.errors.first?.message, "expected `{' in struct")
    }
    
    func testMalformedStructMissingClosingRightCurly() {
        let parser = parse("struct foo{\n")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(11, 12))
        XCTAssertEqual(parser.errors.first?.message, "expected `}' in struct")
    }
    
    func testWellFormedEmptyStructDeclaration() {
        let parser = parse("""
struct foo {
}
""")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let expected = StructDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 14),
                                         identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(7, 10), identifier: "foo"),
                                         members: [])
        XCTAssertEqual(ast.children.first, expected)
    }
    
    func testWellFormedStructDeclarationWithOneMember() {
        let parser = parse("""
struct foo {
    bar: u8
}
""")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let expected = StructDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 26),
                                         identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(7, 10), identifier: "foo"),
                                         members: [
                                            StructDeclaration.Member(name: "bar",
                                                                     type: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(22, 24), typ: .u8))
                                         ])
        XCTAssertEqual(ast.children.first, expected)
    }
    
    func testWellFormedStructDeclarationWithSeveralMembers() {
        let parser = parse("""
struct foo {
    bar: u8,
    baz: u16,
    qux: bool
}
""")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let expected = StructDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 55),
                                         identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(7, 10), identifier: "foo"),
                                         members: [
                                            StructDeclaration.Member(name: "bar",
                                                                     type: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(22, 24), typ: .u8)),
                                            StructDeclaration.Member(name: "baz",
                                                                     type: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(35, 38), typ: .u16)),
                                            StructDeclaration.Member(name: "qux",
                                                                     type: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(49, 53), typ: .bool(.mutableBool))),
                                         ])
        XCTAssertEqual(ast.children.first, expected)
    }
    
    func testWellFormedStructDeclarationWithSeveralMembers_DifferentWhitespace() {
        let parser = parse("""
struct foo { bar: u8, baz: u16, qux: bool }
""")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let expected = StructDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 43),
                                         identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(7, 10), identifier: "foo"),
                                         members: [
                                            StructDeclaration.Member(name: "bar",
                                                                     type: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(18, 20), typ: .u8)),
                                            StructDeclaration.Member(name: "baz",
                                                                     type: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(27, 30), typ: .u16)),
                                            StructDeclaration.Member(name: "qux",
                                                                     type: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(37, 41), typ: .bool(.mutableBool))),
                                         ])
        XCTAssertEqual(ast.children.first, expected)
    }
    
    func testWellFormedStructInitializerExpression_WithNoArguments() {
        typealias StructInitializer = Expression.StructInitializer
        typealias Argument = Expression.StructInitializer.Argument
        
        let parser = parse("""
Foo {}
""")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let expected = StructInitializer(sourceAnchor: parser.lineMapper.anchor(0, 6),
                                         identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3), identifier: "Foo"),
                                         arguments: [])
        XCTAssertEqual(ast.children.first, expected)
    }
    
    func testMalformedStructInitializerExpression_ArgumentNameMissingDot() {
        typealias StructInitializer = Expression.StructInitializer
        typealias Argument = Expression.StructInitializer.Argument
        
        let parser = parse("""
Foo { foo }
""")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(6, 9))
        XCTAssertEqual(parser.errors.first?.message, "malformed argument to struct initializer: expected `.'")
    }
    
    func testMalformedStructInitializerExpression_ArgumentMissingIdentifier() {
        typealias StructInitializer = Expression.StructInitializer
        typealias Argument = Expression.StructInitializer.Argument
        
        let parser = parse("""
Foo { . }
""")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(8, 9))
        XCTAssertEqual(parser.errors.first?.message, "malformed argument to struct initializer: expected identifier")
    }
    
    func testMalformedStructInitializerExpression_ArgumentMissingEqual() {
        typealias StructInitializer = Expression.StructInitializer
        typealias Argument = Expression.StructInitializer.Argument
        
        let parser = parse("""
Foo { .foo }
""")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(11, 12))
        XCTAssertEqual(parser.errors.first?.message, "malformed argument to struct initializer: expected `='")
    }
    
    func testMalformedStructInitializerExpression_ArgumentMissingExpression() {
        typealias StructInitializer = Expression.StructInitializer
        typealias Argument = Expression.StructInitializer.Argument
        
        let parser = parse("""
Foo { .foo = }
""")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(13, 14))
        XCTAssertEqual(parser.errors.first?.message, "malformed argument to struct initializer: expected expression")
    }
    
    func testWellFormedStructInitializerExpression_WithOneArgument() {
        typealias StructInitializer = Expression.StructInitializer
        typealias Argument = Expression.StructInitializer.Argument
        
        let parser = parse("""
Foo { .bar = 1 + 1 }
""")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let expected = StructInitializer(sourceAnchor: parser.lineMapper.anchor(0, 20),
                                         identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3), identifier: "Foo"),
                                         arguments: [
                                            Argument(name: "bar", expr: Expression.Binary(sourceAnchor: parser.lineMapper.anchor(13, 18), op: .plus, left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(13, 14), value: 1), right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(17, 18), value: 1))),
                                         ])
        XCTAssertEqual(ast.children.first, expected)
    }
    
    func testWellFormedStructInitializerExpression_WithMultipleArguments() {
        typealias StructInitializer = Expression.StructInitializer
        typealias Argument = Expression.StructInitializer.Argument
        
        let parser = parse("""
Foo { .bar = 1 +
             1,
      .baz = 2, .qux = false }
""")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let expected = StructInitializer(sourceAnchor: parser.lineMapper.anchor(0, 63),
                                         identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3), identifier: "Foo"),
                                         arguments: [
                                            Argument(name: "bar", expr: Expression.Binary(sourceAnchor: parser.lineMapper.anchor(13, 31), op: .plus, left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(13, 14), value: 1), right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(30, 31), value: 1))),
                                            Argument(name: "baz", expr: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(46, 47), value: 2)),
                                            Argument(name: "qux", expr: Expression.LiteralBool(sourceAnchor: parser.lineMapper.anchor(56, 61), value: false)),
                                         ])
        XCTAssertEqual(ast.children.first, expected)
    }
    
    func testWellFormedStructInitializerExpression_GenericTypeApplication() {
        let parser = parse("Foo@[u16] {}")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let foo = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3),
                                        identifier: "Foo")
        let u16 = Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(5, 8),
                                           typ: .u16)
        let app = Expression.GenericTypeApplication(sourceAnchor: parser.lineMapper.anchor(0, 9),
                                                    identifier: foo,
                                                    arguments: [u16])
        let expected = Expression.StructInitializer(sourceAnchor: parser.lineMapper.anchor(0, 12),
                                                    expr: app,
                                                    arguments: [])
        XCTAssertEqual(ast.children.first, expected)
    }
    
    func testMalformedPointerExpressionType_MissingPointeeType() {
        let parser = parse("""
let foo: * = undefined
""")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        // There's no special error mesage for this case. Just ensure it works.
    }
    
    func testWellformedPointerExpressionType() {
        let parser = parse("""
let foo: *wat = undefined
""")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let foo = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo")
        let wat = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(10, 13), identifier: "wat")
        let expectedType = Expression.PointerType(sourceAnchor: parser.lineMapper.anchor(9, 13), typ: wat)
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 25),
                                      identifier: foo,
                                      explicitType: expectedType,
                                      expression: nil,
                                      storage: .automaticStorage,
                                      isMutable: false)
        XCTAssertEqual(ast.children.first, expected)
    }
    
    func testWellformedPointerExpressionType_PointerToConst() {
        let parser = parse("""
let foo: *const wat = undefined
""")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let foo = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo")
        let wat = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(16, 19), identifier: "wat")
        let expectedType = Expression.PointerType(sourceAnchor: parser.lineMapper.anchor(9, 19), typ: Expression.ConstType(sourceAnchor: parser.lineMapper.anchor(10, 19), typ: wat))
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 31),
                                      identifier: foo,
                                      explicitType: expectedType,
                                      expression: nil,
                                      storage: .automaticStorage,
                                      isMutable: false)
        XCTAssertEqual(ast.children.first, expected)
    }
    
    func testWellFormedRangeExpression() {
        // The parser has special syntax to generate a value of the builtin
        // Range type. Under the hood, Range is just another struct type and
        // the syntax evaluates to a struct-initializer expression.
        let parser = parse("0..1")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        typealias Arg = Expression.StructInitializer.Argument
        XCTAssertEqual(ast.children, [
            Expression.StructInitializer(sourceAnchor: parser.lineMapper.anchor(0, 4),
                                         identifier: Expression.Identifier("Range"),
                                         arguments: [
                                            Arg(name: "begin", expr: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 0)),
                                            Arg(name: "limit", expr: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(3, 4), value: 1))
                                         ])
        ])
    }
    
    func test_ARangeExpressionCannotHaveStructInitializerInTheLimitExpression() {
        typealias Arg = Expression.StructInitializer.Argument
        
        let parser = parse("0 .. Foo\n{ }")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        
        XCTAssertEqual(ast.children, [
            Expression.StructInitializer(sourceAnchor: parser.lineMapper.anchor(0, 8),
                                         identifier: Expression.Identifier("Range"),
                                         arguments: [
                                            Arg(name: "begin", expr: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 0)),
                                            Arg(name: "limit", expr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "Foo"))
                                         ]),
            Block(sourceAnchor: parser.lineMapper.anchor(9, 12), children: [])
        ])
    }
        
    func testWellformedForRangeStatement() {
        let parser = parse("""
for i in 0..10 {
    var foo = i
}
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            ForIn(sourceAnchor: parser.lineMapper.anchor(0, 34),
                  identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 5), identifier: "i"),
                  sequenceExpr: Expression.StructInitializer(sourceAnchor: parser.lineMapper.anchor(9, 14), identifier: Expression.Identifier("Range"), arguments: [
                    Expression.StructInitializer.Argument(name: "begin", expr: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(9, 10), value: 0)),
                    Expression.StructInitializer.Argument(name: "limit", expr: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(12, 14), value: 10))
                  ]),
                  body: Block(sourceAnchor: parser.lineMapper.anchor(15, 34), children: [
                    VarDeclaration(sourceAnchor: parser.lineMapper.anchor(21, 32),
                                   identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(25, 28), identifier: "foo"),
                                   explicitType: nil,
                                   expression: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(31, 32), identifier: "i"),
                                   storage: .automaticStorage,
                                   isMutable: true)
                ]))
        ])
    }
    
    func testMalformedImplDeclarationWithoutIdentifier() {
        let parser = parse("impl")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(4, 4))
        XCTAssertEqual(parser.errors.first?.message, "expected a type")
    }
    
    func testMalformedImplDeclarationWithoutBracesAfterIdentifier() {
        let parser = parse("impl Foo")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(8, 8))
        XCTAssertEqual(parser.errors.first?.message, "expected `{' in impl declaration")
    }
    
    func testWellformedImplDeclaration_Empty() {
        let parser = parse("""
impl Foo {
}
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Impl(sourceAnchor: parser.lineMapper.anchor(0, 10),
                 typeArguments: [],
                 structTypeExpr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "Foo"),
                 children: [])
        ])
    }
    
    func testMalformedImplDeclaration_MissingClosingBrace() {
        let parser = parse("""
impl Foo {

""")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(11, 11))
        XCTAssertEqual(parser.errors.first?.message, "unexpected end of input")
    }
    
    func testMalformedImplDeclaration_CannotContainIf() {
        let parser = parse("""
impl Foo {
    if
}
""")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(15, 17))
        XCTAssertEqual(parser.errors.first?.message, "`if' is not permitted in impl declaration")
    }
    
    func testMalformedImplDeclaration_CannotContainBlock() {
        let parser = parse("""
impl Foo {
    {}
}
""")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(15, 16))
        XCTAssertEqual(parser.errors.first?.message, "block is not permitted in impl declaration")
    }
    
    func testMalformedImplDeclaration_CannotContainImpl() {
        let parser = parse("""
impl Foo {
    impl
}
""")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(15, 19))
        XCTAssertEqual(parser.errors.first?.message, "impl declarations may not contain other impl declarations")
    }
    
    func testMalformedImplDeclaration_CannotContainExpression() {
        let parser = parse("""
impl Foo {
    1+2
}
""")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(15, 18))
        XCTAssertEqual(parser.errors.first?.message, "expression statement is not permitted in impl declaration")
    }
    
    func testWellformedImplStatement_WithOneFunction() {
        let parser = parse("""
impl Foo {
    func doSomething() {
    }
}
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Impl(sourceAnchor: parser.lineMapper.anchor(0, 10),
                 typeArguments: [],
                 structTypeExpr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "Foo"),
                 children: [
                    FunctionDeclaration(sourceAnchor: parser.lineMapper.anchor(15, 41),
                                        identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(20, 31), identifier: "doSomething"),
                                        functionType: Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(15, 41), name: "doSomething", returnType: Expression.PrimitiveType(.void), arguments: []),
                                        argumentNames: [],
                                        body: Block(sourceAnchor: parser.lineMapper.anchor(34, 41), children: []))
                 ])
        ])
    }
    
    func testWellformedImplStatement_WithTwoFunctions() {
        let parser = parse("""
impl Foo {
    func doSomething1() {
    }


    func doSomething2() {
    }
}
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Impl(sourceAnchor: parser.lineMapper.anchor(0, 10),
                 typeArguments: [],
                 structTypeExpr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "Foo"),
                 children: [
                    FunctionDeclaration(sourceAnchor: parser.lineMapper.anchor(15, 42),
                                        identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(20, 32), identifier: "doSomething1"),
                                        functionType: Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(15, 42), name: "doSomething1", returnType: Expression.PrimitiveType(.void), arguments: []),
                                        argumentNames: [],
                                        body: Block(sourceAnchor: parser.lineMapper.anchor(35, 42), children: [])),
                    FunctionDeclaration(sourceAnchor: parser.lineMapper.anchor(49, 76),
                                        identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(54, 66), identifier: "doSomething2"),
                                        functionType: Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(49, 76), name: "doSomething2", returnType: Expression.PrimitiveType(.void), arguments: []),
                                        argumentNames: [],
                                        body: Block(sourceAnchor: parser.lineMapper.anchor(69, 76), children: []))
                 ])
        ])
    }
    
    func testWellformedMethodCall() {
        let parser = parse("""
Foo.doSomething1()
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Expression.Call(sourceAnchor: parser.lineMapper.anchor(0, 18),
                            callee: Expression.Get(sourceAnchor: parser.lineMapper.anchor(0, 16),
                                                   expr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3),
                                                                               identifier: "Foo"),
                                                   member: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 16),
                                                                                 identifier: "doSomething1")),
                            arguments: [])
        ])
    }
    
    func testWellformedUnionTypeExpression_TwoTypes() {
        let parser = parse("var foo: u8 | bool = undefined")
        XCTAssertFalse(parser.hasError)
        let unionType = Expression.UnionType(sourceAnchor: parser.lineMapper.anchor(9, 18), members: [
            Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(9, 11), typ: .u8),
            Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(14, 18), typ: .bool(.mutableBool))
        ])
        XCTAssertEqual(parser.syntaxTree?.children, [
            VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 30),
                           identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                           explicitType: unionType,
                           expression: nil,
                           storage: .automaticStorage,
                           isMutable: true)
        ])
    }
    
    func testWellformedUnionTypeExpression_ThreeTypes() {
        let parser = parse("var foo: u8 | bool | Foo = undefined")
        XCTAssertFalse(parser.hasError)
        let unionType = Expression.UnionType(sourceAnchor: parser.lineMapper.anchor(9, 24), members: [
            Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(9, 11), typ: .u8),
            Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(14, 18), typ: .bool(.mutableBool)),
            Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(21, 24), identifier: "Foo")
        ])
        XCTAssertEqual(parser.syntaxTree?.children, [
            VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 36),
                           identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                           explicitType: unionType,
                           expression: nil,
                           storage: .automaticStorage,
                           isMutable: true)
        ])
    }
    
    func testWellformedUnionTypeExpression_WithPointerType() {
        let parser = parse("var foo: *u8 | None = undefined")
        XCTAssertFalse(parser.hasError)
        let unionType = Expression.UnionType(sourceAnchor: parser.lineMapper.anchor(9, 19), members: [
            Expression.PointerType(sourceAnchor: parser.lineMapper.anchor(9, 12), typ: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(10, 12), typ: .u8)),
            Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(15, 19), identifier: "None")
        ])
        XCTAssertEqual(parser.syntaxTree?.children, [
            VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 31),
                           identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                           explicitType: unionType,
                           expression: nil,
                           storage: .automaticStorage,
                           isMutable: true)
        ])
    }
    
    func testWellformedIsExpression() {
        let parser = parse("foo is u8")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Expression.Is(sourceAnchor: parser.lineMapper.anchor(0, 9),
                          expr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3), identifier: "foo"),
                          testType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(7, 9), typ: .u8))
        ])
    }
    
    func testWellformedTypealiasStatement() {
        let parser = parse("typealias Foo = Bar")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Typealias(sourceAnchor: parser.lineMapper.anchor(0, 19),
                      lexpr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(10, 13), identifier: "Foo"),
                      rexpr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(16, 19), identifier: "Bar"))
        ])
    }
    
    func testMatchStatement_Empty() {
        let parser = parse("""
match expr { }
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Match(sourceAnchor: parser.lineMapper.anchor(0, 14),
                  expr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(6, 10), identifier: "expr"),
                  clauses: [],
                  elseClause: nil)
        ])
    }
    
    func testMatchStatement_OnlyElseClause() {
        let parser = parse("""
match expr {
    else -> {}
}
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Match(sourceAnchor: parser.lineMapper.anchor(0, 29),
                  expr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(6, 10), identifier: "expr"),
                  clauses: [],
                  elseClause: Block(sourceAnchor: parser.lineMapper.anchor(25, 27), children: []))
        ])
    }
    
    func testMatchStatement_OneClauseOnly() {
        let parser = parse("""
match expr {
    (foo: u8) -> {}
}
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Match(sourceAnchor: parser.lineMapper.anchor(0, 34),
                  expr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(6, 10), identifier: "expr"),
                  clauses: [
                    Match.Clause(sourceAnchor: parser.lineMapper.anchor(17, 32),
                                 valueIdentifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(18, 21), identifier: "foo"),
                                 valueType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(23, 25), typ: .u8),
                                 block: Block(sourceAnchor: parser.lineMapper.anchor(30, 32), children: []))
                  ],
                  elseClause: nil)
        ])
    }
    
    func testMatchStatement_OneClauseAndElse() {
        let parser = parse("""
match expr {
    (foo: u8) -> {},
    else -> {}
}
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Match(sourceAnchor: parser.lineMapper.anchor(0, 50),
                  expr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(6, 10), identifier: "expr"),
                  clauses: [
                    Match.Clause(sourceAnchor: parser.lineMapper.anchor(17, 32),
                                 valueIdentifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(18, 21), identifier: "foo"),
                                 valueType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(23, 25), typ: .u8),
                                 block: Block(sourceAnchor: parser.lineMapper.anchor(30, 32), children: []))
                  ],
                  elseClause: Block(sourceAnchor: parser.lineMapper.anchor(46, 48), children: []))
        ])
    }
    
    func testMatchStatement_TwoClauses() {
        let parser = parse("""
match expr {
    (foo: u8) -> {},
    (foo: *bool) -> {},
    else -> {}
}
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Match(sourceAnchor: parser.lineMapper.anchor(0, 74),
                  expr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(6, 10), identifier: "expr"),
                  clauses: [
                    Match.Clause(sourceAnchor: parser.lineMapper.anchor(17, 32),
                                 valueIdentifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(18, 21), identifier: "foo"),
                                 valueType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(23, 25), typ: .u8),
                                 block: Block(sourceAnchor: parser.lineMapper.anchor(30, 32), children: [])),
                    Match.Clause(sourceAnchor: parser.lineMapper.anchor(38, 56),
                                 valueIdentifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(39, 42), identifier: "foo"),
                                 valueType: Expression.PointerType(sourceAnchor: parser.lineMapper.anchor(44, 49), typ: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(45, 49), typ: .bool(.mutableBool))),
                                 block: Block(sourceAnchor: parser.lineMapper.anchor(54, 56), children: []))
                  ],
                  elseClause: Block(sourceAnchor: parser.lineMapper.anchor(70, 72), children: []))
        ])
    }
    
    func testWellFormedPublicVariableDeclaration() {
        let parser = parse("public var foo = 1")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 18),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(11, 14), identifier: "foo"),
                                      explicitType: nil,
                                      expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(17, 18), value: 1),
                                      storage: .automaticStorage,
                                      isMutable: true,
                                      visibility: .publicVisibility)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedPrivateVariableDeclaration() {
        let parser = parse("private var foo = 1")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 19),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(12, 15), identifier: "foo"),
                                      explicitType: nil,
                                      expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(18, 19), value: 1),
                                      storage: .automaticStorage,
                                      isMutable: true,
                                      visibility: .privateVisibility)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedPublicStaticVariableDeclaration() {
        let parser = parse("public static var foo = 1")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 25),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(18, 21), identifier: "foo"),
                                      explicitType: nil,
                                      expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(24, 25), value: 1),
                                      storage: .staticStorage,
                                      isMutable: true,
                                      visibility: .publicVisibility)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedPrivateStaticVariableDeclaration() {
        let parser = parse("private static var foo = 1")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 26),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(19, 22), identifier: "foo"),
                                      explicitType: nil,
                                      expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(25, 26), value: 1),
                                      storage: .staticStorage,
                                      isMutable: true,
                                      visibility: .privateVisibility)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedStaticPublicVariableDeclaration() {
        let parser = parse("static public var foo = 1")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 25),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(18, 21), identifier: "foo"),
                                      explicitType: nil,
                                      expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(24, 25), value: 1),
                                      storage: .staticStorage,
                                      isMutable: true,
                                      visibility: .publicVisibility)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedStaticPrivateVariableDeclaration() {
        let parser = parse("static private var foo = 1")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 26),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(19, 22), identifier: "foo"),
                                      explicitType: nil,
                                      expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(25, 26), value: 1),
                                      storage: .staticStorage,
                                      isMutable: true,
                                      visibility: .privateVisibility)
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testWellFormedPublicStructDeclaration() {
        let parser = parse("""
public struct foo {
}
""")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let expected = StructDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 21),
                                         identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(14, 17), identifier: "foo"),
                                         members: [],
                                         visibility: .publicVisibility)
        XCTAssertEqual(ast.children.first, expected)
    }
    
    func testWellFormedPrivateStructDeclaration() {
        let parser = parse("""
private struct foo {
}
""")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let expected = StructDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 22),
                                         identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(15, 18), identifier: "foo"),
                                         members: [],
                                         visibility: .privateVisibility)
        XCTAssertEqual(ast.children.first, expected)
    }
    
    func testWellFormedStructDeclaration_Generic() {
        let parser = parse("""
            struct Foo[T] {
            }
            """)
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let expected = StructDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 17),
                                         identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(7, 10),
                                                                           identifier: "Foo"),
                                         typeArguments: [
                                            Expression.GenericTypeArgument(sourceAnchor: parser.lineMapper.anchor(11, 12),
                                                                           identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(11, 12),
                                                                                                             identifier: "T"),
                                                                           constraints: [])
                                         ],
                                         members: [])
        XCTAssertEqual(ast.children.first, expected)
    }
    
    func testWellformedPublicTypealiasStatement() {
        let parser = parse("public typealias Foo = Bar")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Typealias(sourceAnchor: parser.lineMapper.anchor(0, 26),
                      lexpr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(17, 20), identifier: "Foo"),
                      rexpr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(23, 26), identifier: "Bar"),
                      visibility: .publicVisibility)
        ])
    }
    
    func testWellformedPrivateTypealiasStatement() {
        let parser = parse("private typealias Foo = Bar")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Typealias(sourceAnchor: parser.lineMapper.anchor(0, 27),
                      lexpr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(18, 21), identifier: "Foo"),
                      rexpr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(24, 27), identifier: "Bar"),
                      visibility: .privateVisibility)
        ])
    }
    
    func testWellformedPublicFunctionDeclaration() {
        let parser = parse("public func foo() {}")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 20), children: [
            FunctionDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 20),
                                identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(12, 15), identifier: "foo"),
                                functionType: Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(0, 20), name: "foo", returnType: Expression.PrimitiveType(.void), arguments: []),
                                argumentNames: [],
                                body: Block(sourceAnchor: parser.lineMapper.anchor(18, 20), children: []),
                                visibility: .publicVisibility)
        ]))
    }
    
    func testWellformedPrivateFunctionDeclaration() {
        let parser = parse("private func foo() {}")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 21), children: [
            FunctionDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 21),
                                identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(13, 16), identifier: "foo"),
                                functionType: Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(0, 21), name: "foo", returnType: Expression.PrimitiveType(.void), arguments: []),
                                argumentNames: [],
                                body: Block(sourceAnchor: parser.lineMapper.anchor(19, 21), children: []),
                                visibility: .privateVisibility)
        ]))
    }
    
    func testMalformedAssertStatementMissingExpression() {
        let parser = parse("assert()")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(0, 8))
        XCTAssertEqual(parser.errors.first?.message, "expected expression in assert statement")
    }
    
    func testWellformedAssertStatement() {
        let parser = parse("assert(0 == 1)")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 14), children: [
            Assert(sourceAnchor: parser.lineMapper.anchor(0, 14),
                   condition: Expression.Binary(sourceAnchor: parser.lineMapper.anchor(7, 13), op: .eq, left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(7, 8), value: 0), right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(12, 13), value: 1)),
                   message: "assertion failed: `0 == 1' on line 1")
        ]))
    }
    
    func testWellformedTestDeclaration() {
        let parser = parse("""
test "foo" {
}
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 14), children: [
            TestDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 14), name: "foo", body: Block(sourceAnchor: parser.lineMapper.anchor(11, 14), children: []))
        ]))
    }
    
    func testWellformedImportStatement() {
        let parser = parse("""
import foo
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 10), children: [
            Import(sourceAnchor: parser.lineMapper.anchor(0, 10), moduleName: "foo")
        ]))
    }
    
    func testWellformedFunctionPointerExpressionType() {
        let parser = parse("""
let foo: func (u8) -> u8 = undefined
""")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let foo = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo")
        let fn = Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(9, 24), name: nil, returnType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(22, 24), typ: .u8), arguments: [Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(15, 17), typ: .u8)])
        let expectedType = Expression.PointerType(sourceAnchor: parser.lineMapper.anchor(9, 24), typ: fn)
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 36),
                                      identifier: foo,
                                      explicitType: expectedType,
                                      expression: nil,
                                      storage: .automaticStorage,
                                      isMutable: false)
        XCTAssertEqual(ast.children.first, expected)
    }
    
    func testGetArrayFromStructAndSubscriptIt() {
        let parser = parse("""
foo.bar[0]
""")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let foo = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3), identifier: "foo")
        let bar = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "bar")
        let zero = Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(8, 9), value: 0)
        let getExpr = Expression.Get(sourceAnchor: parser.lineMapper.anchor(0, 7), expr: foo, member: bar)
        let expr = Expression.Subscript(sourceAnchor: parser.lineMapper.anchor(0, 10),
                                        subscriptable: getExpr,
                                        argument: zero)
        XCTAssertEqual(ast.children.first, expr)
    }
    
    func testParseBitcast() {
        let parser = parse("""
foo bitcastAs *Bar
""")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let expr = Expression.Bitcast(sourceAnchor: parser.lineMapper.anchor(0, 18),
                                      expr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3), identifier: "foo"),
                                      targetType: Expression.PointerType(sourceAnchor: parser.lineMapper.anchor(14, 18), typ: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(15, 18), identifier: "Bar")))
        XCTAssertEqual(ast.children.first, expr)
    }
    
    func testParseWellformedTrait() {
        let parser = parse("""
trait Foo {
    func foo(a: u8, b: u8) -> u8
    func bar(self: *Foo) -> u8
}
""")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let foo = TraitDeclaration.Member(name: "foo", type:  Expression.PointerType(sourceAnchor: parser.lineMapper.anchor(16, 44), typ: Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(16, 44), name: nil, returnType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(42, 44), typ: .u8), arguments: [
            Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(28, 30), typ: .u8),
            Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(35, 37), typ: .u8)
        ])))
        let bar = TraitDeclaration.Member(name: "bar", type:  Expression.PointerType(sourceAnchor: parser.lineMapper.anchor(49, 75), typ: Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(49, 75), name: nil, returnType: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(73, 75), typ: .u8), arguments: [
            Expression.PointerType(sourceAnchor: parser.lineMapper.anchor(64, 68), typ: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(65, 68), identifier: "Foo"))
        ])))
        let expr = TraitDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 77),
                                    identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(6, 9), identifier: "Foo"),
                                    members: [
                                        foo, bar
                                    ],
                                    visibility: .privateVisibility)
        XCTAssertEqual(ast.children.first, expr)
    }
    
    func testParseWellformedTrait_Generic() {
        let parser = parse("""
            trait Foo[T] {
            }
            """)
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertNotNil(parser.syntaxTree)
        guard let ast = parser.syntaxTree else {
            return
        }
        XCTAssertEqual(ast.children.count, 1)
        let expr = TraitDeclaration(
            sourceAnchor: parser.lineMapper.anchor(0, 16),
            identifier: Expression.Identifier(
                sourceAnchor: parser.lineMapper.anchor(6, 9),
                identifier: "Foo"),
            typeArguments: [
                Expression.GenericTypeArgument(
                    sourceAnchor: parser.lineMapper.anchor(10, 11),
                    identifier: Expression.Identifier(
                        sourceAnchor: parser.lineMapper.anchor(10, 11),
                        identifier: "T"),
                    constraints: [])
            ],
            members: [],
            visibility: .privateVisibility)
        XCTAssertEqual(ast.children.first, expr)
    }
    
    func testImplForStatement() {
        let parser = parse("""
impl Serial for SerialFake {
    func puts(self: *SerialFake, s: []const u8) {
    }
}
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            ImplFor(sourceAnchor: parser.lineMapper.anchor(0, 28),
                    typeArguments: [],
                    traitTypeExpr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 11), identifier: "Serial"),
                    structTypeExpr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(16, 26), identifier: "SerialFake"),
                    children: [
                        FunctionDeclaration(sourceAnchor: parser.lineMapper.anchor(33, 84),
                                            identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(38, 42), identifier: "puts"),
                                            functionType: Expression.FunctionType(sourceAnchor: parser.lineMapper.anchor(33, 84), name: "puts", returnType: Expression.PrimitiveType(.void), arguments: [
                                                Expression.PointerType(sourceAnchor: parser.lineMapper.anchor(49, 60), typ: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(50, 60), identifier: "SerialFake")),
                                                Expression.DynamicArrayType(sourceAnchor: parser.lineMapper.anchor(65, 75), elementType: Expression.ConstType(sourceAnchor: parser.lineMapper.anchor(67, 75), typ: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(73, 75), typ: .u8)))
                                            ]),
                                            argumentNames: ["self", "s"],
                                            body: Block(sourceAnchor: parser.lineMapper.anchor(77, 84))),
                    ])
        ])
    }
    
    func testImplForStatementWithGenericTypeArguments() {
        let parser = parse("""
            impl[T] Serial for SerialFake {
            }
            """)
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        XCTAssertEqual(parser.syntaxTree?.children, [
            ImplFor(sourceAnchor: parser.lineMapper.anchor(0, 31),
                    typeArguments: [Expression.GenericTypeArgument(sourceAnchor: parser.lineMapper.anchor(5, 6),
                                                                   identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 6), identifier: "T"),
                                                                   constraints: [])],
                    traitTypeExpr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(8, 14), identifier: "Serial"),
                    structTypeExpr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(19, 29), identifier: "SerialFake"),
                    children: [])
        ])
    }
    
    func testBugWhereTypeExpressionPrecedenceEasilyLeadsToUnexpectedTypes() {
        let parser = parse("typealias Foo = []const u8 | None")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Typealias(sourceAnchor: parser.lineMapper.anchor(0, 33),
                      lexpr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(10, 13), identifier: "Foo"),
                      rexpr: Expression.UnionType(sourceAnchor: parser.lineMapper.anchor(16, 33), members: [
                        Expression.DynamicArrayType(sourceAnchor: parser.lineMapper.anchor(16, 26), elementType: Expression.ConstType(sourceAnchor: parser.lineMapper.anchor(18, 26), typ: Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(24, 26), typ: .u8))),
                        Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(29, 33), identifier: "None")
                      ]))
        ])
    }
    
    func testExpressionStatement_BitwiseNegation() {
        let parser = parse("~0b10101010")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children,
                       [Expression.Unary(sourceAnchor: parser.lineMapper.anchor(0, 11),
                                         op: .tilde,
                                         expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(1, 11), value: 0b10101010))])
    }
    
    func testExpressionStatement_LogicalNot() {
        let parser = parse("!0b10101010")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children,
                       [Expression.Unary(sourceAnchor: parser.lineMapper.anchor(0, 11),
                                         op: .bang,
                                         expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(1, 11), value: 0b10101010))])
    }
    
    func testExpressionStatement_BitwiseXor() {
        let parser = parse("1^2")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children,
                       [Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 3),
                                          op: .caret,
                                          left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                          right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(2, 3), value: 2))])
    }
    
    func testExpressionStatement_BitwiseAnd() {
        let parser = parse("1&2")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children,
                       [Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 3),
                                          op: .ampersand,
                                          left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                          right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(2, 3), value: 2))])
    }
    
    func testExpressionStatement_BitwiseOr() {
        let parser = parse("1|2")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children,
                       [Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 3),
                                          op: .pipe,
                                          left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                          right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(2, 3), value: 2))])
    }
    
    func testExpressionStatement_LogicalANd() {
        let parser = parse("true && false")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children,
                       [Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 13),
                                          op: .doubleAmpersand,
                                          left: Expression.LiteralBool(sourceAnchor: parser.lineMapper.anchor(0, 4), value: true),
                                          right: Expression.LiteralBool(sourceAnchor: parser.lineMapper.anchor(8, 13), value: false))])
    }
    
    func testExpressionStatement_LogicalOr() {
        let parser = parse("true || false")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children,
                       [Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 13),
                                          op: .doublePipe,
                                          left: Expression.LiteralBool(sourceAnchor: parser.lineMapper.anchor(0, 4), value: true),
                                          right: Expression.LiteralBool(sourceAnchor: parser.lineMapper.anchor(8, 13), value: false))])
    }
    
    func testExpressionStatement_BitwiseLeftShift() {
        let parser = parse("1<<2")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children,
                       [Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 4),
                                          op: .leftDoubleAngle,
                                          left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                          right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(3, 4), value: 2))])
    }
    
    func testExpressionStatement_BitwiseRightShift() {
        let parser = parse("1>>2")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children,
                       [Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 4),
                                          op: .rightDoubleAngle,
                                          left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                          right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(3, 4), value: 2))])
    }
    
    func testRangeExpressionCombinedWithGetExpressionInLimit() {
        // This test tracks a bug in the parser where the start and limit parts
        // of the expression do not parse as expected when they contain a Get
        // expression.
        let parser = parse("0..self.arr.count")
        let zero = Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 0)
        let s = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(3, 7), identifier: "self")
        let arr = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(8, 11), identifier: "arr")
        let s_arr = Expression.Get(sourceAnchor: parser.lineMapper.anchor(3, 11), expr: s, member: arr)
        let count = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(12, 17), identifier: "count")
        let s_arr_count = Expression.Get(sourceAnchor: parser.lineMapper.anchor(3, 17), expr: s_arr, member: count)
        let range = Expression.StructInitializer(sourceAnchor: parser.lineMapper.anchor(0, 17),
                                                 identifier: Expression.Identifier("Range"),
                                                 arguments: [
                                                    Expression.StructInitializer.Argument(name: "begin", expr: zero),
                                                    Expression.StructInitializer.Argument(name: "limit", expr: s_arr_count)
                                                 ])
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [range])
    }
    
    func testRangeExpressionCombinedWithGetExpressionInBegin() {
        // This test tracks a bug in the parser where the start and limit parts
        // of the expression do not parse as expected when they contain a Get
        // expression.
        let parser = parse("self.arr.count..0")
        let zero = Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(16, 17), value: 0)
        let s = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 4), identifier: "self")
        let arr = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "arr")
        let s_arr = Expression.Get(sourceAnchor: parser.lineMapper.anchor(0, 8), expr: s, member: arr)
        let count = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(9, 14), identifier: "count")
        let s_arr_count = Expression.Get(sourceAnchor: parser.lineMapper.anchor(0, 14), expr: s_arr, member: count)
        let range = Expression.StructInitializer(sourceAnchor: parser.lineMapper.anchor(0, 17),
                                                 identifier: Expression.Identifier("Range"),
                                                 arguments: [
                                                    Expression.StructInitializer.Argument(name: "begin", expr: s_arr_count),
                                                    Expression.StructInitializer.Argument(name: "limit", expr: zero)
                                                 ])
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [range])
    }
    
    func testAsm_MalformedMissingLeftParen() {
        let parser = parse("asm")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(3, 3))
        XCTAssertEqual(parser.errors.first?.message, "expected `(' in asm statement")
    }
    
    func testAsm_MalformedMissingString() {
        let parser = parse("asm(1")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(4, 5))
        XCTAssertEqual(parser.errors.first?.message, "expected string literal containing assembly code in asm statement")
    }
    
    func testAsm_MalformedMissingRightParen() {
        let parser = parse("asm(\"\"")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor, parser.lineMapper.anchor(6, 6))
        XCTAssertEqual(parser.errors.first?.message, "expected `)' in asm statement")
    }
    
    func testAsm_WellFormed() {
        let parser = parse("""
            asm("")
            """)
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 7), children: [
            Asm(sourceAnchor: parser.lineMapper.anchor(0, 7), assemblyCode: "")
        ]))
    }
    
    func testSizeOf() {
        let parser = parse("sizeof(foo)")
        XCTAssertFalse(parser.hasError)
        let foo = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(7, 10), identifier: "foo")
        let sz = Expression.SizeOf(sourceAnchor: parser.lineMapper.anchor(0, 11), expr: foo)
        let top = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 11), children: [sz])
        XCTAssertEqual(parser.syntaxTree, top)
    }
    
    func testGenericTypeApplication_Empty() {
        let parser = parse("let a: foo@[] = undefined")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        let foo = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(7, 10),
                                        identifier: "foo")
        let app = Expression.GenericTypeApplication(sourceAnchor: parser.lineMapper.anchor(7, 13),
                                                    identifier: foo,
                                                    arguments: [])
        let a = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 5),
                                      identifier: "a")
        let varDecl = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 25),
                                     identifier: a,
                                     explicitType: app,
                                     expression: nil,
                                     storage: .automaticStorage,
                                     isMutable: false)
        let top = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 25),
                           children: [varDecl])
        XCTAssertEqual(parser.syntaxTree, top)
    }
    
    func testGenericTypeApplication_OneTypeArgument() {
        let parser = parse("let a: foo@[T] = undefined")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        let foo = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(7, 10),
                                        identifier: "foo")
        let arg = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(12, 13),
                                        identifier: "T")
        let app = Expression.GenericTypeApplication(sourceAnchor: parser.lineMapper.anchor(7, 14),
                                                    identifier: foo,
                                                    arguments: [arg])
        let a = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 5),
                                      identifier: "a")
        let varDecl = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 26),
                                     identifier: a,
                                     explicitType: app,
                                     expression: nil,
                                     storage: .automaticStorage,
                                     isMutable: false)
        let top = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 26),
                           children: [varDecl])
        XCTAssertEqual(parser.syntaxTree, top)
    }
    
    func testGenericTypeApplication_TwoTypeArguments() {
        let parser = parse("let a: foo@[U,V] = undefined")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        let foo = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(7, 10),
                                        identifier: "foo")
        let arg0 = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(12, 13),
                                         identifier: "U")
        let arg1 = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(14, 15),
                                         identifier: "V")
        let app = Expression.GenericTypeApplication(sourceAnchor: parser.lineMapper.anchor(7, 16),
                                                    identifier: foo,
                                                    arguments: [arg0, arg1])
        let a = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 5),
                                      identifier: "a")
        let varDecl = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 28),
                                     identifier: a,
                                     explicitType: app,
                                     expression: nil,
                                     storage: .automaticStorage,
                                     isMutable: false)
        let top = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 28),
                           children: [varDecl])
        XCTAssertEqual(parser.syntaxTree, top)
    }
    
    func testGenericTypeApplication_InGetExpr() {
        let parser = parse("Point.add@[u16]")
        XCTAssertFalse(parser.hasError)
        guard !parser.hasError else {
            let omnibus = CompilerError.makeOmnibusError(fileName: nil, errors: parser.errors)
            print(omnibus.localizedDescription)
            return
        }
        let point = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 5),
                                          identifier: "Point")
        let add = Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(6, 9),
                                        identifier: "add")
        let u16 = Expression.PrimitiveType(sourceAnchor: parser.lineMapper.anchor(11, 14),
                                           typ: .u16)
        let app = Expression.GenericTypeApplication(sourceAnchor: parser.lineMapper.anchor(6, 15),
                                                    identifier: add,
                                                    arguments: [u16])
        let get = Expression.Get(sourceAnchor: parser.lineMapper.anchor(0, 15),
                                 expr: point,
                                 member: app)
        let top = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 15),
                           children: [get])
        XCTAssertEqual(parser.syntaxTree, top)
    }
    
    func testBackslashNewlineExtendsParsingTheLine() {
        let parser = parse("""
                           1 \
                           + 2
                           """)
        XCTAssertFalse(parser.hasError)
        guard let ast = parser.syntaxTree, ast.children.count == 1 else {
            XCTFail()
            return
        }
        
        let expected = Expression.Binary(sourceAnchor: parser.lineMapper.anchor(0, 5),
                                         op: .plus,
                                         left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                         right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(4, 5), value: 2))
        XCTAssertEqual(expected, ast.children.first)
    }
}
