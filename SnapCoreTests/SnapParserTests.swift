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
    func parse(_ text: String) -> SnapParser {
        let tokenizer = SnapLexer(withString: text)
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
        XCTAssertEqual(parser.errors.first?.message, "immutable variables must be assigned a value")
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
                                      storage: .stackStorage,
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
                                      explicitType: .u8,
                                      expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(14, 15), value: 1),
                                      storage: .stackStorage,
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
                                               explicitType: .u16,
                                               explicitCount: nil,
                                               elements: [Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(7, 10), identifier: "foo")])
        let actual = ast.children[0]
        XCTAssertEqual(expected, actual)
    }
    
    func testMalformedArrayLiteralWithBadCount() {
        let parser = parse("[bar]u16{foo}")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.text, "bar")
        XCTAssertEqual(parser.errors.first?.message, "expected integer literal for the array count")
    }
    
    func testWellFormedArrayLiteralOfNestedArrays() {
        let parser = parse("[_][_]u16{[_]u16{foo, foo}}")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
        XCTAssertEqual(ast.children.count, 1)
        let innerArray = Expression.LiteralArray(sourceAnchor: parser.lineMapper.anchor(10, 26),
                                                 explicitType: .u16,
                                                 explicitCount: nil,
                                                 elements: [Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(17, 20), identifier: "foo"),
                                                            Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(22, 25), identifier: "foo")])
        let expected = Expression.LiteralArray(sourceAnchor: parser.lineMapper.anchor(0, 27),
                                               explicitType: .array(count: nil, elementType: .u16),
                                               explicitCount: nil,
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
                                               explicitType: .u16,
                                               explicitCount: 1,
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
                                                 explicitType: .u8,
                                                 explicitCount: nil,
                                                 elements: [])
        
        // Note that the parser doesn't know that the expression will actually
        // yield a result of the the type [0]u8.
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 24),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                      explicitType: .array(count: nil, elementType: .u8),
                                      expression: innerArray,
                                      storage: .stackStorage,
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
                                      explicitType: .array(count: 0, elementType: .u8),
                                      expression: Expression.LiteralArray(sourceAnchor: parser.lineMapper.anchor(17, 24),
                                                                          explicitType: .u8,
                                                                          explicitCount: 0,
                                                                          elements: []),
                                      storage: .stackStorage,
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
                                                                          explicitType: .u8,
                                                                          explicitCount: 0,
                                                                          elements: [
                                        Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(16, 17), value: 1)
                                      ]),
                                      storage: .stackStorage,
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
                                          explicitType: .u8,
                                          explicitCount: nil,
                                          elements: [
            Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(16, 17), value: 1),
            Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(19, 20), value: 2),
            Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(22, 23), value: 3)
        ])
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 24),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                      explicitType: nil,
                                      expression: arr,
                                      storage: .stackStorage,
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
        let elements = "Hello, World!".utf8.map({
            Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(10, 25), value: Int($0))
        })
        let arr = Expression.LiteralArray(sourceAnchor: parser.lineMapper.anchor(10, 25),
                                          explicitType: .u8,
                                          explicitCount: nil,
                                          elements: elements)
        let expected = VarDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 25),
                                      identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                      explicitType: nil,
                                      expression: arr,
                                      storage: .stackStorage,
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
                                      explicitType: .dynamicArray(elementType: .u8),
                                      expression: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(16, 19), identifier: "bar"),
                                      storage: .stackStorage,
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
                                      explicitType: .array(count: 1, elementType: .u8),
                                      expression: nil,
                                      storage: .stackStorage,
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
                                      storage: .stackStorage,
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
                                      explicitType: .u8,
                                      expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(14, 15), value: 1),
                                      storage: .stackStorage,
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
    
    func testWellFormedStaticVariableDeclaration_Immutable() {
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
                                         op: .multiply,
                                         left: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(0, 1), value: 1),
                                         right: Expression.Unary(sourceAnchor: parser.lineMapper.anchor(4, 8),
                                                                 op: .minus,
                                                                 expression: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "foo")))
        XCTAssertEqual(expected, ast.children.first)
    }
    
    func testExpressionStatement_Division() {
        let parser = parse("1 / -foo")
        XCTAssertFalse(parser.hasError)
        let ast = parser.syntaxTree!
        
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
                                                                  op: .multiply,
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
                                                                  op: .multiply,
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
                                         op: .multiply,
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
                                           storage: .stackStorage,
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
        XCTAssertEqual(parser.errors.first?.message, "expected newline")
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
        XCTAssertEqual(parser.errors.first?.message, "expected newline")
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
                               storage: .stackStorage,
                               isMutable: false)
               ]),
               else: Block(sourceAnchor: parser.lineMapper.anchor(25, 41), children: [
                VarDeclaration(sourceAnchor: parser.lineMapper.anchor(30, 41),
                               identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(34, 37), identifier: "bar"),
                               explicitType: nil,
                               expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(40, 41), value: 1),
                               storage: .stackStorage,
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
                               storage: .stackStorage,
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
                                   storage: .stackStorage,
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
        
    func testWellformedForLoopStatement() {
        let parser = parse("""
for var i = 0; i < 10; i = i + 1 {
    var foo = i
}
""")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree?.children, [
            Block(sourceAnchor: parser.lineMapper.anchor(0, 52), children: [
                ForLoop(sourceAnchor: parser.lineMapper.anchor(0, 52),
                        initializerClause: VarDeclaration(sourceAnchor: parser.lineMapper.anchor(4, 13),
                                                          identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(8, 9), identifier: "i"),
                                                          explicitType: nil,
                                                          expression: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(12, 13), value: 0),
                                                          storage: .stackStorage,
                                                          isMutable: true),
                        conditionClause: Expression.Binary(sourceAnchor: parser.lineMapper.anchor(15, 21),
                                                           op: .lt,
                                                           left: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(15, 16), identifier: "i"),
                                                           right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(19, 21), value: 10)),
                        incrementClause: Expression.Assignment(sourceAnchor: parser.lineMapper.anchor(23, 32),
                                                               lexpr: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(23, 24), identifier: "i"),
                                                               rexpr: Expression.Binary(sourceAnchor: parser.lineMapper.anchor(27, 32),
                                                                                        op: .plus,
                                                                                        left: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(27, 28), identifier: "i"),
                                                                                        right: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(31, 32), value: 1))),
                        body: Block(sourceAnchor: parser.lineMapper.anchor(33, 52), children: [
                            VarDeclaration(sourceAnchor: parser.lineMapper.anchor(39, 50),
                                           identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(43, 46), identifier: "foo"),
                                           explicitType: nil,
                                           expression: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(49, 50), identifier: "i"),
                                           storage: .stackStorage,
                                           isMutable: true)
                        ]))
            ])
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
                               storage: .stackStorage,
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
                               storage: .stackStorage,
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
                                   storage: .stackStorage,
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
                                functionType: FunctionType(returnType: .void, arguments: []),
                                body: Block(sourceAnchor: parser.lineMapper.anchor(11, 13), children: []))
        ]))
    }
    
    func testFailToParseFunctionDefinition_InvalidReturnType() {
        let parser = parse("func foo() -> wat {}")
        XCTAssertTrue(parser.hasError)
        XCTAssertNil(parser.syntaxTree)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(parser.errors.first?.sourceAnchor?.text, "wat")
        XCTAssertEqual(parser.errors.first?.message, "use of undeclared type `wat'")
    }
    
    func testParseFunctionDefinition_ZeroArgsAndUInt8ReturnValue() {
        let parser = parse("func foo() -> u8 {}")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 19), children: [
            FunctionDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 19),
                                identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "foo"),
                                functionType: FunctionType(returnType: .u8, arguments: []),
                                body: Block(sourceAnchor: parser.lineMapper.anchor(17, 19), children: []))
        ]))
    }
    
    func testParseFunctionDefinition_ZeroArgsAndExplicitVoidReturnValue() {
        let parser = parse("func foo() -> void {}")
        XCTAssertFalse(parser.hasError)
        XCTAssertEqual(parser.syntaxTree, TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 21), children: [
            FunctionDeclaration(sourceAnchor: parser.lineMapper.anchor(0, 21),
                                identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(5, 8), identifier: "foo"),
                                functionType: FunctionType(returnType: .void, arguments: []),
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
                                functionType: FunctionType(returnType: .void, arguments: [FunctionType.Argument(name: "bar", type: .u8)]),
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
                                functionType: FunctionType(returnType: .void, arguments: [FunctionType.Argument(name: "bar", type: .u8), FunctionType.Argument(name: "baz", type: .bool)]),
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
                                functionType: FunctionType(returnType: .void, arguments: [FunctionType.Argument(name: "bar", type: .void)]),
                                body: Block(sourceAnchor: parser.lineMapper.anchor(20, 22), children: []))
        ])
        XCTAssertEqual(parser.syntaxTree, expected)
    }
    
    func testParseReturn() {
        let parser = parse("return 1")
        XCTAssertFalse(parser.hasError)
        let expected = TopLevel(sourceAnchor: parser.lineMapper.anchor(0, 6), children: [
            Return(sourceAnchor: parser.lineMapper.anchor(0, 6),
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
                                 identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3), identifier: "foo"),
                                 expr: Expression.Binary(sourceAnchor: parser.lineMapper.anchor(4, 7),
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
                                 identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(0, 3), identifier: "foo"),
                                 expr: Expression.Subscript(sourceAnchor: parser.lineMapper.anchor(4, 10),
                                                            identifier: Expression.Identifier(sourceAnchor: parser.lineMapper.anchor(4, 7), identifier: "foo"),
                                                            expr: Expression.LiteralInt(sourceAnchor: parser.lineMapper.anchor(8, 9), value: 0)))
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
}
