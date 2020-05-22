//
//  ExpressionNodeTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class ExpressionTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        XCTAssertNotEqual(Expression.Literal(number: a), LabelDeclarationNode(identifier: foo))
    }
    
    func testLiteralEquality() {
        XCTAssertNotEqual(Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                          Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)))
        XCTAssertEqual(Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                       Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
        XCTAssertEqual(Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)).hashValue,
                       Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)).hashValue)
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
                                           expression: Expression.Literal(number: TokenNumber(lineNumber: 1,
                                                                                              lexeme: "1",
                                                                                              literal: 1))),
                          Expression.Unary(op: TokenOperator(lineNumber: 2, lexeme: "-", op: .minus),
                                           expression: Expression.Literal(number: TokenNumber(lineNumber: 1,
                                                                                              lexeme: "1",
                                                                                              literal: 1))))
        
        // Different expressions
        XCTAssertNotEqual(Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                           expression: Expression.Literal(number: TokenNumber(lineNumber: 1,
                                                                                              lexeme: "1",
                                                                                              literal: 1))),
                          Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                           expression: Expression.Literal(number: TokenNumber(lineNumber: 2,
                                                                                              lexeme: "2",
                                                                                              literal: 2))))
        
        // Same
        XCTAssertEqual(Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                        expression: Expression.Literal(number: TokenNumber(lineNumber: 1,
                                                                                           lexeme: "1",
                                                                                           literal: 1))),
                       Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                        expression: Expression.Literal(number: TokenNumber(lineNumber: 1,
                                                                                           lexeme: "1",
                                                                                           literal: 1))))
        
        // Same
        XCTAssertEqual(Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                        expression: Expression.Literal(number: TokenNumber(lineNumber: 1,
                                                                                           lexeme: "1",
                                                                                           literal: 1))).hashValue,
                       Expression.Unary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                        expression: Expression.Literal(number: TokenNumber(lineNumber: 1,
                                                                                           lexeme: "1",
                                                                                           literal: 1))).hashValue)
    }
    
    func testBinaryEquality() {
        // Different right expression
        XCTAssertNotEqual(Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))),
                       Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "9", literal: 9))))
        
        // Different left expression
        XCTAssertNotEqual(Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))),
                       Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "42", literal: 42)),
                                        right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))))
        
        // Different tokens
        XCTAssertNotEqual(Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))),
                       Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "-", op: .minus),
                                        left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))))
        
        // Same
        XCTAssertEqual(Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))),
                       Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))))
        
        // Hash
        XCTAssertEqual(Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))).hashValue,
                       Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                        left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                        right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2))).hashValue)
    }
}
