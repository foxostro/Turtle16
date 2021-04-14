//
//  IfTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class IfTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(If(condition: Expression.LiteralInt(1),
                             then: AbstractSyntaxTreeNode(),
                             else: nil),
                          AbstractSyntaxTreeNode())
    }
    
    func testDoesNotEqualNodeWithDifferentCondition() {
        XCTAssertNotEqual(If(condition: Expression.LiteralInt(1),
                             then: AbstractSyntaxTreeNode(),
                             else: nil),
                          If(condition: Expression.LiteralInt(2),
                             then: AbstractSyntaxTreeNode(),
                             else: nil))
    }
    
    func testDoesNotEqualNodeWithDifferentThenBranch() {
        XCTAssertNotEqual(If(condition: Expression.LiteralInt(1),
                             then: Expression.LiteralInt(1),
                             else: nil),
                          If(condition: Expression.LiteralInt(2),
                             then: AbstractSyntaxTreeNode(),
                             else: nil))
    }
    
    func testDoesNotEqualNodeWithDifferentElseBranch() {
        XCTAssertNotEqual(If(condition: Expression.LiteralInt(1),
                             then: AbstractSyntaxTreeNode(),
                             else: AbstractSyntaxTreeNode()),
                          If(condition: Expression.LiteralInt(2),
                             then: AbstractSyntaxTreeNode(),
                             else: nil))
    }
    
    func testSame() {
        XCTAssertEqual(If(condition: Expression.LiteralInt(1),
                          then: AbstractSyntaxTreeNode(),
                          else: AbstractSyntaxTreeNode()),
                       If(condition: Expression.LiteralInt(1),
                          then: AbstractSyntaxTreeNode(),
                          else: AbstractSyntaxTreeNode()))
    }
    
    func testHash() {
        XCTAssertEqual(If(condition: Expression.LiteralInt(1),
                          then: AbstractSyntaxTreeNode(),
                          else: nil).hash,
                       If(condition: Expression.LiteralInt(1),
                          then: AbstractSyntaxTreeNode(),
                          else: nil).hash)
    }
    
    func testGetters() {
        let stmt = If(condition: Expression.LiteralInt(1),
                      then: Expression.LiteralInt(2),
                      else: Expression.LiteralInt(3))
        XCTAssertEqual(stmt.condition, Expression.LiteralInt(1))
        XCTAssertEqual(stmt.thenBranch, Expression.LiteralInt(2))
        XCTAssertEqual(stmt.elseBranch, Expression.LiteralInt(3))
    }
    
    func testElseGetterWithNilBranch() {
        let stmt = If(condition: Expression.LiteralInt(1),
                      then: Expression.LiteralInt(2),
                      else: nil)
        XCTAssertNil(stmt.elseBranch)
    }
}
