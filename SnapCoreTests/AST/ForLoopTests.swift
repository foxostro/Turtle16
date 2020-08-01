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
        XCTAssertNotEqual(ForLoop(sourceAnchor: nil,
                                  initializerClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  conditionClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  incrementClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  body: AbstractSyntaxTreeNode(sourceAnchor: nil)),
                          AbstractSyntaxTreeNode(sourceAnchor: nil))
    }
    
    func testDoesNotEqualNodeWithDifferentInitializerClause() {
        XCTAssertNotEqual(ForLoop(sourceAnchor: nil,
                                  initializerClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  conditionClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  incrementClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  body: AbstractSyntaxTreeNode(sourceAnchor: nil)),
                          ForLoop(sourceAnchor: nil,
                                  initializerClause: Expression.LiteralWord(sourceAnchor: nil, value: 2),
                                  conditionClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  incrementClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  body: AbstractSyntaxTreeNode(sourceAnchor: nil)))
    }
    
    func testDoesNotEqualNodeWithDifferentConditionClause() {
        XCTAssertNotEqual(ForLoop(sourceAnchor: nil,
                                  initializerClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  conditionClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  incrementClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  body: AbstractSyntaxTreeNode(sourceAnchor: nil)),
                          ForLoop(sourceAnchor: nil,
                                  initializerClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  conditionClause: Expression.LiteralWord(sourceAnchor: nil, value: 2),
                                  incrementClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  body: AbstractSyntaxTreeNode(sourceAnchor: nil)))
    }
    
    func testDoesNotEqualNodeWithDifferentIncrementClause() {
        XCTAssertNotEqual(ForLoop(sourceAnchor: nil,
                                  initializerClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  conditionClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  incrementClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  body: AbstractSyntaxTreeNode(sourceAnchor: nil)),
                          ForLoop(sourceAnchor: nil,
                                  initializerClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  conditionClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  incrementClause: Expression.LiteralWord(sourceAnchor: nil, value: 2),
                                  body: AbstractSyntaxTreeNode(sourceAnchor: nil)))
    }
    
    func testDoesNotEqualNodeWithDifferentBody() {
        XCTAssertNotEqual(ForLoop(sourceAnchor: nil,
                                  initializerClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  conditionClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  incrementClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  body: AbstractSyntaxTreeNode(sourceAnchor: nil)),
                          ForLoop(sourceAnchor: nil,
                                  initializerClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  conditionClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  incrementClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                  body: Expression.LiteralWord(sourceAnchor: nil, value: 1)))
    }
    
    func testSame() {
        XCTAssertEqual(ForLoop(sourceAnchor: nil,
                               initializerClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                               conditionClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                               incrementClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                               body: AbstractSyntaxTreeNode(sourceAnchor: nil)),
                       ForLoop(sourceAnchor: nil,
                               initializerClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                               conditionClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                               incrementClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                               body: AbstractSyntaxTreeNode(sourceAnchor: nil)))
    }
    
    func testHash() {
        XCTAssertEqual(ForLoop(sourceAnchor: nil,
                               initializerClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                               conditionClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                               incrementClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                               body: AbstractSyntaxTreeNode(sourceAnchor: nil)).hash,
                       ForLoop(sourceAnchor: nil,
                               initializerClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                               conditionClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                               incrementClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                               body: AbstractSyntaxTreeNode(sourceAnchor: nil)).hash)
    }
    
    func testGetters() {
        let stmt = ForLoop(sourceAnchor: nil,
                           initializerClause: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                           conditionClause: Expression.LiteralWord(sourceAnchor: nil, value: 2),
                           incrementClause: Expression.LiteralWord(sourceAnchor: nil, value: 3),
                           body: Expression.LiteralWord(sourceAnchor: nil, value: 4))
        XCTAssertEqual(stmt.initializerClause, Expression.LiteralWord(sourceAnchor: nil, value: 1))
        XCTAssertEqual(stmt.conditionClause, Expression.LiteralWord(sourceAnchor: nil, value: 2))
        XCTAssertEqual(stmt.incrementClause, Expression.LiteralWord(sourceAnchor: nil, value: 3))
        XCTAssertEqual(stmt.body, Expression.LiteralWord(sourceAnchor: nil, value: 4))
    }
}
