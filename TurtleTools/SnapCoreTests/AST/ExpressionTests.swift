//
//  ExpressionNodeTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class ExpressionTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(Expression.LiteralInt(1),
                          CommentNode(string: ""))
    }
    
    func testLiteralWordEquality() {
        XCTAssertNotEqual(Expression.LiteralInt(1),
                          Expression.LiteralInt(2))
        XCTAssertEqual(Expression.LiteralInt(1),
                       Expression.LiteralInt(1))
        XCTAssertEqual(Expression.LiteralInt(1).hashValue,
                       Expression.LiteralInt(1).hashValue)
    }
    
    func testLiteralBooleanEquality() {
        XCTAssertNotEqual(Expression.LiteralBool(true),
                          Expression.LiteralBool(false))
        XCTAssertEqual(Expression.LiteralBool(true),
                       Expression.LiteralBool(true))
        XCTAssertEqual(Expression.LiteralBool(true).hashValue,
                       Expression.LiteralBool(true).hashValue)
    }
    
    func testIdentifierEquality() {
        XCTAssertNotEqual(Expression.Identifier("foo"),
                          Expression.Identifier("bar"))
        XCTAssertEqual(Expression.Identifier("foo"),
                       Expression.Identifier("foo"))
        XCTAssertEqual(Expression.Identifier("foo").hashValue,
                       Expression.Identifier("foo").hashValue)
    }
    
    func testGroupEquality() {
        // Different expressions
        XCTAssertNotEqual(Expression.Group(Expression.LiteralInt(1)),
                          Expression.Group(Expression.LiteralInt(2)))
        
        // Same
        XCTAssertEqual(Expression.Group(Expression.LiteralInt(1)),
                       Expression.Group(Expression.LiteralInt(1)))
        
        // Same
        XCTAssertEqual(Expression.Group(Expression.LiteralInt(1)).hashValue,
                       Expression.Group(Expression.LiteralInt(1)).hashValue)
    }
    
    func testUnaryEquality() {
        // Different expressions
        XCTAssertNotEqual(Expression.Unary(op: .minus,
                                           expression: Expression.LiteralInt(1)),
                          Expression.Unary(op: .minus,
                                           expression: Expression.LiteralInt(2)))
        
        // Same
        XCTAssertEqual(Expression.Unary(op: .minus,
                                        expression: Expression.LiteralInt(1)),
                       Expression.Unary(op: .minus,
                                        expression: Expression.LiteralInt(1)))
        
        // Same
        XCTAssertEqual(Expression.Unary(op: .minus,
                                        expression: Expression.LiteralInt(1)).hashValue,
                       Expression.Unary(op: .minus,
                                        expression: Expression.LiteralInt(1)).hashValue)
    }
    
    func testBinaryEquality() {
        // Different right expression
        XCTAssertNotEqual(Expression.Binary(op: .plus,
                                            left: Expression.LiteralInt(1),
                                            right: Expression.LiteralInt(2)),
                          Expression.Binary(op: .plus,
                                            left: Expression.LiteralInt(1),
                                            right: Expression.LiteralInt(9)))
        
        // Different left expression
        XCTAssertNotEqual(Expression.Binary(op: .plus,
                                            left: Expression.LiteralInt(1),
                                            right: Expression.LiteralInt(2)),
                          Expression.Binary(op: .plus,
                                            left: Expression.LiteralInt(42),
                                            right: Expression.LiteralInt(2)))
        
        // Different tokens
        XCTAssertNotEqual(Expression.Binary(op: .plus,
                                            left: Expression.LiteralInt(1),
                                            right: Expression.LiteralInt(2)),
                          Expression.Binary(op: .minus,
                                            left: Expression.LiteralInt(1),
                                            right: Expression.LiteralInt(2)))
        
        // Same
        XCTAssertEqual(Expression.Binary(op: .plus,
                                         left: Expression.LiteralInt(1),
                                         right: Expression.LiteralInt(2)),
                        Expression.Binary(op: .plus,
                                          left: Expression.LiteralInt(1),
                                          right: Expression.LiteralInt(2)))
        
        // Hash
        XCTAssertEqual(Expression.Binary(op: .plus,
                                         left: Expression.LiteralInt(1),
                                         right: Expression.LiteralInt(2)).hashValue,
                       Expression.Binary(op: .plus,
                                         left: Expression.LiteralInt(1),
                                         right: Expression.LiteralInt(2)).hashValue)
    }
    
    func testAssignmentEquality() {
        let foo = Expression.Identifier("foo")
        let bar = Expression.Identifier("bar")
        
        // Different right expression
        XCTAssertNotEqual(Expression.Assignment(lexpr: foo,
                                                rexpr: Expression.LiteralInt(1)),
                          Expression.Assignment(lexpr: foo,
                                                rexpr: Expression.LiteralInt(2)))
        
        // Different left identifier
        XCTAssertNotEqual(Expression.Assignment(lexpr: foo,
                                                rexpr: Expression.LiteralInt(1)),
                          Expression.Assignment(lexpr: bar,
                                                rexpr: Expression.LiteralInt(1)))
        
        // Same
        XCTAssertEqual(Expression.Assignment(lexpr: foo,
                                             rexpr: Expression.LiteralInt(1)),
                       Expression.Assignment(lexpr: foo,
                                             rexpr: Expression.LiteralInt(1)))
        
        // Hash
        XCTAssertEqual(Expression.Assignment(lexpr: foo,
                                             rexpr: Expression.LiteralInt(1)).hash,
                       Expression.Assignment(lexpr: foo,
                                             rexpr: Expression.LiteralInt(1)).hash)
    }
    
    func testCallEquality() {
        // Different callee
        XCTAssertNotEqual(Expression.Call(callee: Expression.Identifier("foo"),
                                          arguments: [Expression.LiteralInt(1)]),
                          Expression.Call(callee: Expression.Identifier("bar"),
                                          arguments: [Expression.LiteralInt(1)]))
        // Different arguments
        XCTAssertNotEqual(Expression.Call(callee: Expression.Identifier("foo"),
                                          arguments: [Expression.LiteralInt(1)]),
                          Expression.Call(callee: Expression.Identifier("foo"),
                                          arguments: [Expression.LiteralInt(2)]))
        
        // Same
        XCTAssertEqual(Expression.Call(callee: Expression.Identifier("foo"),
                                       arguments: [Expression.LiteralInt(1)]),
                       Expression.Call(callee: Expression.Identifier("foo"),
                                       arguments: [Expression.LiteralInt(1)]))
        
        // Hash
        XCTAssertEqual(Expression.Call(callee: Expression.Identifier("foo"),
                                       arguments: [Expression.LiteralInt(1)]).hash,
                       Expression.Call(callee: Expression.Identifier("foo"),
                                       arguments: [Expression.LiteralInt(1)]).hash)
    }
    
    func testAsEquality() {
        // Different expr
        XCTAssertNotEqual(Expression.As(expr: Expression.Identifier("foo"),
                                        targetType: Expression.PrimitiveType(.u8)),
                          Expression.As(expr: Expression.Identifier("bar"),
                                        targetType: Expression.PrimitiveType(.u8)))
        
        // Different target type
        XCTAssertNotEqual(Expression.As(expr: Expression.Identifier("foo"),
                                        targetType: Expression.PrimitiveType(.u16)),
                          Expression.As(expr: Expression.Identifier("foo"),
                                        targetType: Expression.PrimitiveType(.u8)))
        
        // Same
        XCTAssertEqual(Expression.As(expr: Expression.Identifier("foo"),
                                     targetType: Expression.PrimitiveType(.u8)),
                       Expression.As(expr: Expression.Identifier("foo"),
                                     targetType: Expression.PrimitiveType(.u8)))
        
        // Hash
        XCTAssertEqual(Expression.As(expr: Expression.Identifier("foo"),
                                     targetType: Expression.PrimitiveType(.u8)).hash,
                       Expression.As(expr: Expression.Identifier("foo"),
                                     targetType: Expression.PrimitiveType(.u8)).hash)
    }
    
    func testSubscriptEquality() {
        // Different identifier
        XCTAssertNotEqual(Expression.Subscript(subscriptable: Expression.Identifier("foo"),
                                               argument: Expression.LiteralInt(0)),
                          Expression.Subscript(subscriptable: Expression.Identifier("bar"),
                                               argument: Expression.LiteralInt(0)))
        
        // Different expression
        XCTAssertNotEqual(Expression.Subscript(subscriptable: Expression.Identifier("foo"),
                                               argument: Expression.LiteralInt(0)),
                          Expression.Subscript(subscriptable: Expression.Identifier("foo"),
                                               argument: Expression.LiteralInt(1)))
        
        // Same
        XCTAssertEqual(Expression.Subscript(subscriptable: Expression.Identifier("foo"),
                                            argument: Expression.LiteralInt(0)),
                       Expression.Subscript(subscriptable: Expression.Identifier("foo"),
                                            argument: Expression.LiteralInt(0)))
        
        // Hash
        XCTAssertEqual(Expression.Subscript(subscriptable: Expression.Identifier("foo"),
                                            argument: Expression.LiteralInt(0)).hash,
                       Expression.Subscript(subscriptable: Expression.Identifier("foo"),
                                            argument: Expression.LiteralInt(0)).hash)
    }
    
    func testLiteralArrayEquality() {
        // Different explicit lengths
        XCTAssertNotEqual(Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.u8)),
                                                  elements: [Expression.LiteralInt(0)]),
                          Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(2), elementType: Expression.PrimitiveType(.u8)),
                                                  elements: [Expression.LiteralInt(0)]))
        
        // Different explicit types
        XCTAssertNotEqual(Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u16)),
                                                  elements: [Expression.LiteralInt(0)]),
                          Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8)),
                                                  elements: [Expression.LiteralInt(0)]))
        
        // Different element expressions
        XCTAssertNotEqual(Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8)),
                                                  elements: [Expression.LiteralInt(0)]),
                          Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8)),
                                                  elements: [Expression.LiteralBool(false)]))
        
        // Same
        XCTAssertEqual(Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8)),
                                               elements: [Expression.LiteralInt(0)]),
                       Expression.LiteralArray(arrayType: Expression.ArrayType(count: nil, elementType: Expression.PrimitiveType(.u8)),
                                               elements: [Expression.LiteralInt(0)]))
        
        // Same hashes
        XCTAssertEqual(Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.u8)),
                                               elements: [Expression.LiteralInt(0)]).hash,
                       Expression.LiteralArray(arrayType: Expression.ArrayType(count: Expression.LiteralInt(1), elementType: Expression.PrimitiveType(.u8)),
                                               elements: [Expression.LiteralInt(0)]).hash)
    }
    
    func testGetEquality() {
        // Different expressions
        XCTAssertNotEqual(Expression.Get(expr: Expression.Identifier("foo"),
                                         member: Expression.Identifier("foo")),
                          Expression.Get(expr: Expression.Identifier("bar"),
                                         member: Expression.Identifier("foo")))
        
        // Different members
        XCTAssertNotEqual(Expression.Get(expr: Expression.Identifier("foo"),
                                         member: Expression.Identifier("foo")),
                          Expression.Get(expr: Expression.Identifier("foo"),
                                         member: Expression.Identifier("bar")))
        
        // Same
        XCTAssertEqual(Expression.Get(expr: Expression.Identifier("foo"),
                                      member: Expression.Identifier("foo")),
                       Expression.Get(expr: Expression.Identifier("foo"),
                                      member: Expression.Identifier("foo")))
        
        // Same
        XCTAssertEqual(Expression.Get(expr: Expression.Identifier("foo"),
                                      member: Expression.Identifier("foo")).hashValue,
                       Expression.Get(expr: Expression.Identifier("foo"),
                                      member: Expression.Identifier("foo")).hashValue)
    }
    
    func testPrimitiveTypeEquality() {
        // Different underlying types
        XCTAssertNotEqual(Expression.PrimitiveType(.u8),
                          Expression.PrimitiveType(.bool(.mutableBool)))
        
        // Same
        XCTAssertEqual(Expression.PrimitiveType(.u8),
                       Expression.PrimitiveType(.u8))
        
        // Same hashes
        XCTAssertEqual(Expression.PrimitiveType(.u8).hash,
                       Expression.PrimitiveType(.u8).hash)
    }
}
