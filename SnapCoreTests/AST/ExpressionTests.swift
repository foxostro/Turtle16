//
//  ExpressionNodeTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class ExpressionTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(ExprUtils.makeLiteralInt(value: 1), AbstractSyntaxTreeNode())
    }
    
    func testLiteralWordEquality() {
        XCTAssertNotEqual(Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                          Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)))
        XCTAssertEqual(Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                       Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
        XCTAssertEqual(Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)).hashValue,
                       Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)).hashValue)
    }
    
    func testLiteralBooleanEquality() {
        XCTAssertNotEqual(Expression.LiteralBoolean(boolean: TokenBoolean(lineNumber: 1, lexeme: "true", literal: true)),
                          Expression.LiteralBoolean(boolean: TokenBoolean(lineNumber: 1, lexeme: "false", literal: false)))
        XCTAssertEqual(Expression.LiteralBoolean(boolean: TokenBoolean(lineNumber: 1, lexeme: "true", literal: true)),
                       Expression.LiteralBoolean(boolean: TokenBoolean(lineNumber: 1, lexeme: "true", literal: true)))
        XCTAssertEqual(Expression.LiteralBoolean(boolean: TokenBoolean(lineNumber: 1, lexeme: "true", literal: true)).hashValue,
                       Expression.LiteralBoolean(boolean: TokenBoolean(lineNumber: 1, lexeme: "true", literal: true)).hashValue)
    }
    
    func testIdentifierEquality() {
        XCTAssertNotEqual(Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")),
                          Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "bar")))
        XCTAssertEqual(Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")),
                       Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")))
        XCTAssertEqual(Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")).hashValue,
                       Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")).hashValue)
    }
    
    func testUnaryEquality() {
        // Different tokens
        XCTAssertNotEqual(Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                           expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1,
                                                                                                  lexeme: "1",
                                                                                                  literal: 1))),
                          Expression.Unary(op: TokenOperator(lineNumber: 2, lexeme: "-", op: .minus),
                                           expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1,
                                                                                                  lexeme: "1",
                                                                                                  literal: 1))))
        
        // Different expressions
        XCTAssertNotEqual(Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                           expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1,
                                                                                                  lexeme: "1",
                                                                                                  literal: 1))),
                          Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                           expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 2,
                                                                                                  lexeme: "2",
                                                                                                  literal: 2))))
        
        // Same
        XCTAssertEqual(Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                        expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1,
                                                                                               lexeme: "1",
                                                                                               literal: 1))),
                       Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                        expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1,
                                                                                               lexeme: "1",
                                                                                               literal: 1))))
        
        // Same
        XCTAssertEqual(Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                        expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1,
                                                                                               lexeme: "1",
                                                                                               literal: 1))).hashValue,
                       Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                        expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1,
                                                                                               lexeme: "1",
                                                                                               literal: 1))).hashValue)
    }
    
    func testBinaryEquality() {
        // Different right expression
        XCTAssertNotEqual(Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))),
                       Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "9", literal: 9))))
        
        // Different left expression
        XCTAssertNotEqual(Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))),
                       Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "42", literal: 42)),
                                        right: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))))
        
        // Different tokens
        XCTAssertNotEqual(Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))),
                       Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                        left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))))
        
        // Same
        XCTAssertEqual(Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))),
                       Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))))
        
        // Hash
        XCTAssertEqual(Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))).hashValue,
                       Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))).hashValue)
    }
    
    func testAssignmentEquality() {
        let foo = Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        let bar = Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "bar"))
        
        // Different right expression
        XCTAssertNotEqual(Expression.Assignment(lexpr: foo,
                                                tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                                rexpr: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))),
                          Expression.Assignment(lexpr: foo,
                                                tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                                rexpr: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))))
        
        // Different left identifier
        XCTAssertNotEqual(Expression.Assignment(lexpr: foo,
                                                tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                                rexpr: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))),
                          Expression.Assignment(lexpr: bar,
                                                tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                                rexpr: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))))
        
        // Same
        XCTAssertEqual(Expression.Assignment(lexpr: foo,
                                             tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                             rexpr: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))),
                       Expression.Assignment(lexpr: foo,
                                             tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                             rexpr: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))))
        
        // Hash
        XCTAssertEqual(Expression.Assignment(lexpr: foo,
                                             tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                             rexpr: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))).hash,
                       Expression.Assignment(lexpr: foo,
                                             tokenEqual: TokenEqual(lineNumber: 1, lexeme: "="),
                                             rexpr: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))).hash)
    }
    
    func testCallEquality() {
        // Different callee
        XCTAssertNotEqual(Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"),
                                          arguments: [ExprUtils.makeLiteralInt(value: 1)]),
                          Expression.Call(callee: ExprUtils.makeIdentifier(name: "bar"),
                                          arguments: [ExprUtils.makeLiteralInt(value: 1)]))
        // Different arguments
        XCTAssertNotEqual(Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"),
                                          arguments: [ExprUtils.makeLiteralInt(value: 1)]),
                          Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"),
                                          arguments: [ExprUtils.makeLiteralInt(value: 2)]))
        
        // Same
        XCTAssertEqual(Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"),
                                       arguments: [ExprUtils.makeLiteralInt(value: 1)]),
                       Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"),
                                       arguments: [ExprUtils.makeLiteralInt(value: 1)]))
        
        // Hash
        XCTAssertEqual(Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"),
                                       arguments: [ExprUtils.makeLiteralInt(value: 1)]).hash,
                       Expression.Call(callee: ExprUtils.makeIdentifier(name: "foo"),
                        arguments: [ExprUtils.makeLiteralInt(value: 1)]).hash)
    }
    
    func testAsEquality() {
        // Different expr
        XCTAssertNotEqual(Expression.As(expr: ExprUtils.makeIdentifier(name: "foo"),
                                        tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                        targetType: .u8),
                          Expression.As(expr: ExprUtils.makeIdentifier(name: "bar"),
                                        tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                        targetType: .u8))
        
        // Different "as" token
        XCTAssertNotEqual(Expression.As(expr: ExprUtils.makeIdentifier(name: "foo"),
                                        tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                        targetType: .u8),
                          Expression.As(expr: ExprUtils.makeIdentifier(name: "foo"),
                                        tokenAs: TokenAs(lineNumber: 2, lexeme: "as"),
                                        targetType: .u8))
        
        // Different target type
        XCTAssertNotEqual(Expression.As(expr: ExprUtils.makeIdentifier(name: "foo"),
                                        tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                        targetType: .u16),
                          Expression.As(expr: ExprUtils.makeIdentifier(name: "foo"),
                                        tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                        targetType: .u8))
        
        // Same
        XCTAssertEqual(Expression.As(expr: ExprUtils.makeIdentifier(name: "foo"),
                                     tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                     targetType: .u8),
                       Expression.As(expr: ExprUtils.makeIdentifier(name: "foo"),
                                     tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                     targetType: .u8))
        
        // Hash
        XCTAssertEqual(Expression.As(expr: ExprUtils.makeIdentifier(name: "foo"),
                                     tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                     targetType: .u8).hash,
                       Expression.As(expr: ExprUtils.makeIdentifier(name: "foo"),
                                     tokenAs: TokenAs(lineNumber: 1, lexeme: "as"),
                                     targetType: .u8).hash)
    }
    
    func testSubscriptEquality() {
        // Different identifier
        XCTAssertNotEqual(Expression.Subscript(tokenIdentifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                               tokenBracketLeft: TokenSquareBracketLeft(lineNumber: 1, lexeme: "["),
                                               expr: ExprUtils.makeLiteralInt(value: 0),
                                               tokenBracketRight: TokenSquareBracketRight(lineNumber: 1, lexeme: "]")),
                          Expression.Subscript(tokenIdentifier: TokenIdentifier(lineNumber: 1, lexeme: "bar"),
                                               tokenBracketLeft: TokenSquareBracketLeft(lineNumber: 1, lexeme: "["),
                                               expr: ExprUtils.makeLiteralInt(value: 0),
                                               tokenBracketRight: TokenSquareBracketRight(lineNumber: 1, lexeme: "]")))
        
        // Different expression
        XCTAssertNotEqual(Expression.Subscript(tokenIdentifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                               tokenBracketLeft: TokenSquareBracketLeft(lineNumber: 1, lexeme: "["),
                                               expr: ExprUtils.makeLiteralInt(value: 0),
                                               tokenBracketRight: TokenSquareBracketRight(lineNumber: 1, lexeme: "]")),
                          Expression.Subscript(tokenIdentifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                               tokenBracketLeft: TokenSquareBracketLeft(lineNumber: 1, lexeme: "["),
                                               expr: ExprUtils.makeLiteralInt(value: 1),
                                               tokenBracketRight: TokenSquareBracketRight(lineNumber: 1, lexeme: "]")))
        
        // Same
        XCTAssertEqual(Expression.Subscript(tokenIdentifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                            tokenBracketLeft: TokenSquareBracketLeft(lineNumber: 1, lexeme: "["),
                                            expr: ExprUtils.makeLiteralInt(value: 0),
                                            tokenBracketRight: TokenSquareBracketRight(lineNumber: 1, lexeme: "]")),
                       Expression.Subscript(tokenIdentifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                            tokenBracketLeft: TokenSquareBracketLeft(lineNumber: 1, lexeme: "["),
                                            expr: ExprUtils.makeLiteralInt(value: 0),
                                            tokenBracketRight: TokenSquareBracketRight(lineNumber: 1, lexeme: "]")))
        
        // Hash
        XCTAssertEqual(Expression.Subscript(tokenIdentifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                            tokenBracketLeft: TokenSquareBracketLeft(lineNumber: 1, lexeme: "["),
                                            expr: ExprUtils.makeLiteralInt(value: 0),
                                            tokenBracketRight: TokenSquareBracketRight(lineNumber: 1, lexeme: "]")).hash,
                       Expression.Subscript(tokenIdentifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                            tokenBracketLeft: TokenSquareBracketLeft(lineNumber: 1, lexeme: "["),
                                            expr: ExprUtils.makeLiteralInt(value: 0),
                                            tokenBracketRight: TokenSquareBracketRight(lineNumber: 1, lexeme: "]")).hash)
    }
    
    func testLiteralArrayEquality() {
        // Different explicit lengths
        XCTAssertNotEqual(Expression.LiteralArray(explicitType: .u8,
                                                  explicitCount: 1,
                                                  elements: [ExprUtils.makeLiteralInt(value: 0)]),
                          Expression.LiteralArray(explicitType: .u8,
                                                  explicitCount: 2,
                                                  elements: [ExprUtils.makeLiteralInt(value: 0)]))
        
        // Different explicit types
        XCTAssertNotEqual(Expression.LiteralArray(explicitType: .u16,
                                                  elements: [ExprUtils.makeLiteralInt(value: 0)]),
                          Expression.LiteralArray(explicitType: .u8,
                                                  elements: [ExprUtils.makeLiteralInt(value: 0)]))
        
        // Different element expressions
        XCTAssertNotEqual(Expression.LiteralArray(explicitType: .u8,
                                                  elements: [ExprUtils.makeLiteralInt(value: 0)]),
                          Expression.LiteralArray(explicitType: .u8,
                                                  elements: [ExprUtils.makeLiteralBoolean(value: false)]))
        
        // Same
        XCTAssertEqual(Expression.LiteralArray(explicitType: .u8,
                                               elements: [ExprUtils.makeLiteralInt(value: 0)]),
                       Expression.LiteralArray(explicitType: .u8,
                                               elements: [ExprUtils.makeLiteralInt(value: 0)]))
        
        // Same hashes
        XCTAssertEqual(Expression.LiteralArray(explicitType: .u8,
                                               elements: [ExprUtils.makeLiteralInt(value: 0)]).hash,
                       Expression.LiteralArray(explicitType: .u8,
                                               elements: [ExprUtils.makeLiteralInt(value: 0)]).hash)
    }
}
