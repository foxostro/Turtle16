//
//  ForLoopTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/6/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class ForLoopTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(ForLoop(initializerClause: Expression.LiteralInt(1),
                                  conditionClause: Expression.LiteralInt(1),
                                  incrementClause: Expression.LiteralInt(1),
                                  body: AbstractSyntaxTreeNode()),
                          AbstractSyntaxTreeNode())
    }
    
    func testDoesNotEqualNodeWithDifferentInitializerClause() {
        XCTAssertNotEqual(ForLoop(initializerClause: Expression.LiteralInt(1),
                                  conditionClause: Expression.LiteralInt(1),
                                  incrementClause: Expression.LiteralInt(1),
                                  body: AbstractSyntaxTreeNode()),
                          ForLoop(initializerClause: Expression.LiteralInt(2),
                                  conditionClause: Expression.LiteralInt(1),
                                  incrementClause: Expression.LiteralInt(1),
                                  body: AbstractSyntaxTreeNode()))
    }
    
    func testDoesNotEqualNodeWithDifferentConditionClause() {
        XCTAssertNotEqual(ForLoop(initializerClause: Expression.LiteralInt(1),
                                  conditionClause: Expression.LiteralInt(1),
                                  incrementClause: Expression.LiteralInt(1),
                                  body: AbstractSyntaxTreeNode()),
                          ForLoop(initializerClause: Expression.LiteralInt(1),
                                  conditionClause: Expression.LiteralInt(2),
                                  incrementClause: Expression.LiteralInt(1),
                                  body: AbstractSyntaxTreeNode()))
    }
    
    func testDoesNotEqualNodeWithDifferentIncrementClause() {
        XCTAssertNotEqual(ForLoop(initializerClause: Expression.LiteralInt(1),
                                  conditionClause: Expression.LiteralInt(1),
                                  incrementClause: Expression.LiteralInt(1),
                                  body: AbstractSyntaxTreeNode()),
                          ForLoop(initializerClause: Expression.LiteralInt(1),
                                  conditionClause: Expression.LiteralInt(1),
                                  incrementClause: Expression.LiteralInt(2),
                                  body: AbstractSyntaxTreeNode()))
    }
    
    func testDoesNotEqualNodeWithDifferentBody() {
        XCTAssertNotEqual(ForLoop(initializerClause: Expression.LiteralInt(1),
                                  conditionClause: Expression.LiteralInt(1),
                                  incrementClause: Expression.LiteralInt(1),
                                  body: AbstractSyntaxTreeNode()),
                          ForLoop(initializerClause: Expression.LiteralInt(1),
                                  conditionClause: Expression.LiteralInt(1),
                                  incrementClause: Expression.LiteralInt(1),
                                  body: Expression.LiteralInt(1)))
    }
    
    func testSame() {
        XCTAssertEqual(ForLoop(initializerClause: Expression.LiteralInt(1),
                               conditionClause: Expression.LiteralInt(1),
                               incrementClause: Expression.LiteralInt(1),
                               body: AbstractSyntaxTreeNode()),
                       ForLoop(initializerClause: Expression.LiteralInt(1),
                               conditionClause: Expression.LiteralInt(1),
                               incrementClause: Expression.LiteralInt(1),
                               body: AbstractSyntaxTreeNode()))
    }
    
    func testHash() {
        XCTAssertEqual(ForLoop(initializerClause: Expression.LiteralInt(1),
                               conditionClause: Expression.LiteralInt(1),
                               incrementClause: Expression.LiteralInt(1),
                               body: AbstractSyntaxTreeNode()).hash,
                       ForLoop(initializerClause: Expression.LiteralInt(1),
                               conditionClause: Expression.LiteralInt(1),
                               incrementClause: Expression.LiteralInt(1),
                               body: AbstractSyntaxTreeNode()).hash)
    }
    
    func testGetters() {
        let stmt = ForLoop(initializerClause: Expression.LiteralInt(1),
                           conditionClause: Expression.LiteralInt(2),
                           incrementClause: Expression.LiteralInt(3),
                           body: Expression.LiteralInt(4))
        XCTAssertEqual(stmt.initializerClause, Expression.LiteralInt(1))
        XCTAssertEqual(stmt.conditionClause, Expression.LiteralInt(2))
        XCTAssertEqual(stmt.incrementClause, Expression.LiteralInt(3))
        XCTAssertEqual(stmt.body, Expression.LiteralInt(4))
    }
}
