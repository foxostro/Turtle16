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
        XCTAssertNotEqual(Expression.LiteralWord(sourceAnchor: nil, value: 1),
                          AbstractSyntaxTreeNode(sourceAnchor: nil))
    }
    
    func testLiteralWordEquality() {
        XCTAssertNotEqual(Expression.LiteralWord(sourceAnchor: nil, value: 1),
                          Expression.LiteralWord(sourceAnchor: nil, value: 2))
        XCTAssertEqual(Expression.LiteralWord(sourceAnchor: nil, value: 1),
                       Expression.LiteralWord(sourceAnchor: nil, value: 1))
        XCTAssertEqual(Expression.LiteralWord(sourceAnchor: nil, value: 1).hashValue,
                       Expression.LiteralWord(sourceAnchor: nil, value: 1).hashValue)
    }
    
    func testLiteralBooleanEquality() {
        XCTAssertNotEqual(Expression.LiteralBoolean(sourceAnchor: nil, value: true),
                          Expression.LiteralBoolean(sourceAnchor: nil, value: false))
        XCTAssertEqual(Expression.LiteralBoolean(sourceAnchor: nil, value: true),
                       Expression.LiteralBoolean(sourceAnchor: nil, value: true))
        XCTAssertEqual(Expression.LiteralBoolean(sourceAnchor: nil, value: true).hashValue,
                       Expression.LiteralBoolean(sourceAnchor: nil, value: true).hashValue)
    }
    
    func testIdentifierEquality() {
        XCTAssertNotEqual(Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                          Expression.Identifier(sourceAnchor: nil, identifier: "bar"))
        XCTAssertEqual(Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                       Expression.Identifier(sourceAnchor: nil, identifier: "foo"))
        XCTAssertEqual(Expression.Identifier(sourceAnchor: nil, identifier: "foo").hashValue,
                       Expression.Identifier(sourceAnchor: nil, identifier: "foo").hashValue)
    }
    
    func testGroupEquality() {
        // Different expressions
        XCTAssertNotEqual(Expression.Group(sourceAnchor: nil,
                                           expression: Expression.LiteralWord(sourceAnchor: nil, value: 1)),
                          Expression.Group(sourceAnchor: nil,
                                           expression: Expression.LiteralWord(sourceAnchor: nil, value: 2)))
        
        // Same
        XCTAssertEqual(Expression.Group(sourceAnchor: nil,
                                        expression: Expression.LiteralWord(sourceAnchor: nil, value: 1)),
                       Expression.Group(sourceAnchor: nil,
                                        expression: Expression.LiteralWord(sourceAnchor: nil, value: 1)))
        
        // Same
        XCTAssertEqual(Expression.Group(sourceAnchor: nil,
                                        expression: Expression.LiteralWord(sourceAnchor: nil, value: 1)).hashValue,
                       Expression.Group(sourceAnchor: nil,
                                        expression: Expression.LiteralWord(sourceAnchor: nil, value: 1)).hashValue)
    }
    
    func testUnaryEquality() {
        // Different expressions
        XCTAssertNotEqual(Expression.Unary(sourceAnchor: nil,
                                           op: .minus,
                                           expression: Expression.LiteralWord(sourceAnchor: nil, value: 1)),
                          Expression.Unary(sourceAnchor: nil,
                                           op: .minus,
                                           expression: Expression.LiteralWord(sourceAnchor: nil, value: 2)))
        
        // Same
        XCTAssertEqual(Expression.Unary(sourceAnchor: nil,
                                        op: .minus,
                                        expression: Expression.LiteralWord(sourceAnchor: nil, value: 1)),
                       Expression.Unary(sourceAnchor: nil,
                                        op: .minus,
                                        expression: Expression.LiteralWord(sourceAnchor: nil, value: 1)))
        
        // Same
        XCTAssertEqual(Expression.Unary(sourceAnchor: nil,
                                        op: .minus,
                                        expression: Expression.LiteralWord(sourceAnchor: nil, value: 1)).hashValue,
                       Expression.Unary(sourceAnchor: nil,
                                        op: .minus,
                                        expression: Expression.LiteralWord(sourceAnchor: nil, value: 1)).hashValue)
    }
    
    func testBinaryEquality() {
        // Different right expression
        XCTAssertNotEqual(Expression.Binary(sourceAnchor: nil,
                                            op: .plus,
                                            left: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                            right: Expression.LiteralWord(sourceAnchor: nil, value: 2)),
                          Expression.Binary(sourceAnchor: nil,
                                            op: .plus,
                                            left: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                            right: Expression.LiteralWord(sourceAnchor: nil, value: 9)))
        
        // Different left expression
        XCTAssertNotEqual(Expression.Binary(sourceAnchor: nil,
                                            op: .plus,
                                            left: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                            right: Expression.LiteralWord(sourceAnchor: nil, value: 2)),
                          Expression.Binary(sourceAnchor: nil,
                                            op: .plus,
                                            left: Expression.LiteralWord(sourceAnchor: nil, value: 42),
                                            right: Expression.LiteralWord(sourceAnchor: nil, value: 2)))
        
        // Different tokens
        XCTAssertNotEqual(Expression.Binary(sourceAnchor: nil,
                                            op: .plus,
                                            left: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                            right: Expression.LiteralWord(sourceAnchor: nil, value: 2)),
                          Expression.Binary(sourceAnchor: nil,
                                            op: .minus,
                                            left: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                            right: Expression.LiteralWord(sourceAnchor: nil, value: 2)))
        
        // Same
        XCTAssertEqual(Expression.Binary(sourceAnchor: nil,
                                         op: .plus,
                                         left: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                         right: Expression.LiteralWord(sourceAnchor: nil, value: 2)),
                        Expression.Binary(sourceAnchor: nil,
                                          op: .plus,
                                          left: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                          right: Expression.LiteralWord(sourceAnchor: nil, value: 2)))
        
        // Hash
        XCTAssertEqual(Expression.Binary(sourceAnchor: nil,
                                         op: .plus,
                                         left: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                         right: Expression.LiteralWord(sourceAnchor: nil, value: 2)).hashValue,
                       Expression.Binary(sourceAnchor: nil,
                                         op: .plus,
                                         left: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                         right: Expression.LiteralWord(sourceAnchor: nil, value: 2)).hashValue)
    }
    
    func testAssignmentEquality() {
        let foo = Expression.Identifier(sourceAnchor: nil, identifier: "foo")
        let bar = Expression.Identifier(sourceAnchor: nil, identifier: "bar")
        
        // Different right expression
        XCTAssertNotEqual(Expression.Assignment(sourceAnchor: nil,
                                                lexpr: foo,
                                                rexpr: Expression.LiteralWord(sourceAnchor: nil, value: 1)),
                          Expression.Assignment(sourceAnchor: nil,
                                                lexpr: foo,
                                                rexpr: Expression.LiteralWord(sourceAnchor: nil, value: 2)))
        
        // Different left identifier
        XCTAssertNotEqual(Expression.Assignment(sourceAnchor: nil,
                                                lexpr: foo,
                                                rexpr: Expression.LiteralWord(sourceAnchor: nil, value: 1)),
                          Expression.Assignment(sourceAnchor: nil,
                                                lexpr: bar,
                                                rexpr: Expression.LiteralWord(sourceAnchor: nil, value: 1)))
        
        // Same
        XCTAssertEqual(Expression.Assignment(sourceAnchor: nil,
                                             lexpr: foo,
                                             rexpr: Expression.LiteralWord(sourceAnchor: nil, value: 1)),
                       Expression.Assignment(sourceAnchor: nil,
                                             lexpr: foo,
                                             rexpr: Expression.LiteralWord(sourceAnchor: nil, value: 1)))
        
        // Hash
        XCTAssertEqual(Expression.Assignment(sourceAnchor: nil,
                                             lexpr: foo,
                                             rexpr: Expression.LiteralWord(sourceAnchor: nil, value: 1)).hash,
                       Expression.Assignment(sourceAnchor: nil,
                                             lexpr: foo,
                                             rexpr: Expression.LiteralWord(sourceAnchor: nil, value: 1)).hash)
    }
    
    func testCallEquality() {
        // Different callee
        XCTAssertNotEqual(Expression.Call(sourceAnchor: nil,
                                          callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                          arguments: [Expression.LiteralWord(sourceAnchor: nil, value: 1)]),
                          Expression.Call(sourceAnchor: nil,
                                          callee: Expression.Identifier(sourceAnchor: nil, identifier: "bar"),
                                          arguments: [Expression.LiteralWord(sourceAnchor: nil, value: 1)]))
        // Different arguments
        XCTAssertNotEqual(Expression.Call(sourceAnchor: nil,
                                          callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                          arguments: [Expression.LiteralWord(sourceAnchor: nil, value: 1)]),
                          Expression.Call(sourceAnchor: nil,
                                          callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                          arguments: [Expression.LiteralWord(sourceAnchor: nil, value: 2)]))
        
        // Same
        XCTAssertEqual(Expression.Call(sourceAnchor: nil,
                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                       arguments: [Expression.LiteralWord(sourceAnchor: nil, value: 1)]),
                       Expression.Call(sourceAnchor: nil,
                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                       arguments: [Expression.LiteralWord(sourceAnchor: nil, value: 1)]))
        
        // Hash
        XCTAssertEqual(Expression.Call(sourceAnchor: nil,
                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                       arguments: [Expression.LiteralWord(sourceAnchor: nil, value: 1)]).hash,
                       Expression.Call(sourceAnchor: nil,
                                       callee: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                        arguments: [Expression.LiteralWord(sourceAnchor: nil, value: 1)]).hash)
    }
    
    func testAsEquality() {
        // Different expr
        XCTAssertNotEqual(Expression.As(sourceAnchor: nil,
                                        expr: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                        targetType: .u8),
                          Expression.As(sourceAnchor: nil,
                                        expr: Expression.Identifier(sourceAnchor: nil, identifier: "bar"),
                                        targetType: .u8))
        
        // Different target type
        XCTAssertNotEqual(Expression.As(sourceAnchor: nil,
                                        expr: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                        targetType: .u16),
                          Expression.As(sourceAnchor: nil,
                                        expr: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                        targetType: .u8))
        
        // Same
        XCTAssertEqual(Expression.As(sourceAnchor: nil,
                                     expr: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                     targetType: .u8),
                       Expression.As(sourceAnchor: nil,
                                     expr: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                     targetType: .u8))
        
        // Hash
        XCTAssertEqual(Expression.As(sourceAnchor: nil,
                                     expr: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                     targetType: .u8).hash,
                       Expression.As(sourceAnchor: nil,
                                     expr: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                     targetType: .u8).hash)
    }
    
    func testSubscriptEquality() {
        // Different identifier
        XCTAssertNotEqual(Expression.Subscript(sourceAnchor: nil,
                                               identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                               expr: Expression.LiteralWord(sourceAnchor: nil, value: 0)),
                          Expression.Subscript(sourceAnchor: nil,
                                               identifier: Expression.Identifier(sourceAnchor: nil, identifier: "bar"),
                                               expr: Expression.LiteralWord(sourceAnchor: nil, value: 0)))
        
        // Different expression
        XCTAssertNotEqual(Expression.Subscript(sourceAnchor: nil,
                                               identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                               expr: Expression.LiteralWord(sourceAnchor: nil, value: 0)),
                          Expression.Subscript(sourceAnchor: nil,
                                               identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                               expr: Expression.LiteralWord(sourceAnchor: nil, value: 1)))
        
        // Same
        XCTAssertEqual(Expression.Subscript(sourceAnchor: nil,
                                            identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                            expr: Expression.LiteralWord(sourceAnchor: nil, value: 0)),
                       Expression.Subscript(sourceAnchor: nil,
                                            identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                            expr: Expression.LiteralWord(sourceAnchor: nil, value: 0)))
        
        // Hash
        XCTAssertEqual(Expression.Subscript(sourceAnchor: nil,
                                            identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                            expr: Expression.LiteralWord(sourceAnchor: nil, value: 0)).hash,
                       Expression.Subscript(sourceAnchor: nil,
                                            identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                            expr: Expression.LiteralWord(sourceAnchor: nil, value: 0)).hash)
    }
    
    func testLiteralArrayEquality() {
        // Different explicit lengths
        XCTAssertNotEqual(Expression.LiteralArray(sourceAnchor: nil,
                                                  explicitType: .u8,
                                                  explicitCount: 1,
                                                  elements: [Expression.LiteralWord(sourceAnchor: nil, value: 0)]),
                          Expression.LiteralArray(sourceAnchor: nil,
                                                  explicitType: .u8,
                                                  explicitCount: 2,
                                                  elements: [Expression.LiteralWord(sourceAnchor: nil, value: 0)]))
        
        // Different explicit types
        XCTAssertNotEqual(Expression.LiteralArray(sourceAnchor: nil,
                                                  explicitType: .u16,
                                                  explicitCount: nil,
                                                  elements: [Expression.LiteralWord(sourceAnchor: nil, value: 0)]),
                          Expression.LiteralArray(sourceAnchor: nil,
                                                  explicitType: .u8,
                                                  explicitCount: nil,
                                                  elements: [Expression.LiteralWord(sourceAnchor: nil, value: 0)]))
        
        // Different element expressions
        XCTAssertNotEqual(Expression.LiteralArray(sourceAnchor: nil,
                                                  explicitType: .u8,
                                                  explicitCount: nil,
                                                  elements: [Expression.LiteralWord(sourceAnchor: nil, value: 0)]),
                          Expression.LiteralArray(sourceAnchor: nil,
                                                  explicitType: .u8,
                                                  explicitCount: nil,
                                                  elements: [Expression.LiteralBoolean(sourceAnchor: nil, value: false)]))
        
        // Same
        XCTAssertEqual(Expression.LiteralArray(sourceAnchor: nil,
                                               explicitType: .u8,
                                               explicitCount: nil,
                                               elements: [Expression.LiteralWord(value: 0)]),
                       Expression.LiteralArray(sourceAnchor: nil,
                                               explicitType: .u8,
                                               explicitCount: nil,
                                               elements: [Expression.LiteralWord(value: 0)]))
        
        // Same hashes
        XCTAssertEqual(Expression.LiteralArray(sourceAnchor: nil,
                                               explicitType: .u8,
                                               explicitCount: 1,
                                               elements: [Expression.LiteralWord(value: 0)]).hash,
                       Expression.LiteralArray(sourceAnchor: nil,
                                               explicitType: .u8,
                                               explicitCount: 1,
                                               elements: [Expression.LiteralWord(value: 0)]).hash)
    }
}
