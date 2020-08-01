//
//  IfTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class IfTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(If(sourceAnchor: nil,
                             condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                             then: AbstractSyntaxTreeNode(sourceAnchor: nil),
                             else: nil),
                          AbstractSyntaxTreeNode(sourceAnchor: nil))
    }
    
    func testDoesNotEqualNodeWithDifferentCondition() {
        XCTAssertNotEqual(If(sourceAnchor: nil,
                             condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                             then: AbstractSyntaxTreeNode(sourceAnchor: nil),
                             else: nil),
                          If(sourceAnchor: nil,
                             condition: Expression.LiteralWord(sourceAnchor: nil, value: 2),
                             then: AbstractSyntaxTreeNode(sourceAnchor: nil),
                             else: nil))
    }
    
    func testDoesNotEqualNodeWithDifferentThenBranch() {
        XCTAssertNotEqual(If(sourceAnchor: nil,
                             condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                             then: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                             else: nil),
                          If(sourceAnchor: nil,
                             condition: Expression.LiteralWord(sourceAnchor: nil, value: 2),
                             then: AbstractSyntaxTreeNode(sourceAnchor: nil),
                             else: nil))
    }
    
    func testDoesNotEqualNodeWithDifferentElseBranch() {
        XCTAssertNotEqual(If(sourceAnchor: nil,
                             condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                             then: AbstractSyntaxTreeNode(sourceAnchor: nil),
                             else: AbstractSyntaxTreeNode(sourceAnchor: nil)),
                          If(sourceAnchor: nil,
                             condition: Expression.LiteralWord(sourceAnchor: nil, value: 2),
                             then: AbstractSyntaxTreeNode(sourceAnchor: nil),
                             else: nil))
    }
    
    func testSame() {
        XCTAssertEqual(If(sourceAnchor: nil,
                          condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                          then: AbstractSyntaxTreeNode(sourceAnchor: nil),
                          else: AbstractSyntaxTreeNode(sourceAnchor: nil)),
                       If(sourceAnchor: nil,
                          condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                          then: AbstractSyntaxTreeNode(sourceAnchor: nil),
                          else: AbstractSyntaxTreeNode(sourceAnchor: nil)))
    }
    
    func testHash() {
        XCTAssertEqual(If(sourceAnchor: nil,
                          condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                          then: AbstractSyntaxTreeNode(sourceAnchor: nil),
                          else: nil).hash,
                       If(sourceAnchor: nil,
                          condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                          then: AbstractSyntaxTreeNode(sourceAnchor: nil),
                          else: nil).hash)
    }
    
    func testGetters() {
        let stmt = If(sourceAnchor: nil,
                      condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                      then: Expression.LiteralWord(sourceAnchor: nil, value: 2),
                      else: Expression.LiteralWord(sourceAnchor: nil, value: 3))
        XCTAssertEqual(stmt.condition, Expression.LiteralWord(sourceAnchor: nil, value: 1))
        XCTAssertEqual(stmt.thenBranch, Expression.LiteralWord(sourceAnchor: nil, value: 2))
        XCTAssertEqual(stmt.elseBranch, Expression.LiteralWord(sourceAnchor: nil, value: 3))
    }
    
    func testElseGetterWithNilBranch() {
        let stmt = If(sourceAnchor: nil,
                      condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                      then: Expression.LiteralWord(sourceAnchor: nil, value: 2),
                      else: nil)
        XCTAssertNil(stmt.elseBranch)
    }
}
