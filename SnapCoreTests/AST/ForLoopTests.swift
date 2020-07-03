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
        XCTAssertNotEqual(ForLoop(initializerClause: ExprUtils.makeLiteralInt(value: 1),
                                  conditionClause: ExprUtils.makeLiteralInt(value: 1),
                                  incrementClause: ExprUtils.makeLiteralInt(value: 1),
                                  body: AbstractSyntaxTreeNode()),
                          AbstractSyntaxTreeNode())
    }
    
    func testDoesNotEqualNodeWithDifferentInitializerClause() {
        XCTAssertNotEqual(ForLoop(initializerClause: ExprUtils.makeLiteralInt(value: 1),
                                  conditionClause: ExprUtils.makeLiteralInt(value: 1),
                                  incrementClause: ExprUtils.makeLiteralInt(value: 1),
                                  body: AbstractSyntaxTreeNode()),
                          ForLoop(initializerClause: ExprUtils.makeLiteralInt(value: 2),
                                  conditionClause: ExprUtils.makeLiteralInt(value: 1),
                                  incrementClause: ExprUtils.makeLiteralInt(value: 1),
                                  body: AbstractSyntaxTreeNode()))
    }
    
    func testDoesNotEqualNodeWithDifferentConditionClause() {
        XCTAssertNotEqual(ForLoop(initializerClause: ExprUtils.makeLiteralInt(value: 1),
                                  conditionClause: ExprUtils.makeLiteralInt(value: 1),
                                  incrementClause: ExprUtils.makeLiteralInt(value: 1),
                                  body: AbstractSyntaxTreeNode()),
                          ForLoop(initializerClause: ExprUtils.makeLiteralInt(value: 1),
                                  conditionClause: ExprUtils.makeLiteralInt(value: 2),
                                  incrementClause: ExprUtils.makeLiteralInt(value: 1),
                                  body: AbstractSyntaxTreeNode()))
    }
    
    func testDoesNotEqualNodeWithDifferentIncrementClause() {
        XCTAssertNotEqual(ForLoop(initializerClause: ExprUtils.makeLiteralInt(value: 1),
                                  conditionClause: ExprUtils.makeLiteralInt(value: 1),
                                  incrementClause: ExprUtils.makeLiteralInt(value: 1),
                                  body: AbstractSyntaxTreeNode()),
                          ForLoop(initializerClause: ExprUtils.makeLiteralInt(value: 1),
                                  conditionClause: ExprUtils.makeLiteralInt(value: 1),
                                  incrementClause: ExprUtils.makeLiteralInt(value: 2),
                                  body: AbstractSyntaxTreeNode()))
    }
    
    func testDoesNotEqualNodeWithDifferentBody() {
        XCTAssertNotEqual(ForLoop(initializerClause: ExprUtils.makeLiteralInt(value: 1),
                                  conditionClause: ExprUtils.makeLiteralInt(value: 1),
                                  incrementClause: ExprUtils.makeLiteralInt(value: 1),
                                  body: AbstractSyntaxTreeNode()),
                          ForLoop(initializerClause: ExprUtils.makeLiteralInt(value: 1),
                                  conditionClause: ExprUtils.makeLiteralInt(value: 1),
                                  incrementClause: ExprUtils.makeLiteralInt(value: 1),
                                  body: ExprUtils.makeLiteralInt(value: 1)))
    }
    
    func testSame() {
        XCTAssertEqual(ForLoop(initializerClause: ExprUtils.makeLiteralInt(value: 1),
                               conditionClause: ExprUtils.makeLiteralInt(value: 1),
                               incrementClause: ExprUtils.makeLiteralInt(value: 1),
                               body: AbstractSyntaxTreeNode()),
                       ForLoop(initializerClause: ExprUtils.makeLiteralInt(value: 1),
                               conditionClause: ExprUtils.makeLiteralInt(value: 1),
                               incrementClause: ExprUtils.makeLiteralInt(value: 1),
                               body: AbstractSyntaxTreeNode()))
    }
    
    func testHash() {
        XCTAssertEqual(ForLoop(initializerClause: ExprUtils.makeLiteralInt(value: 1),
                               conditionClause: ExprUtils.makeLiteralInt(value: 1),
                               incrementClause: ExprUtils.makeLiteralInt(value: 1),
                               body: AbstractSyntaxTreeNode()).hash,
                       ForLoop(initializerClause: ExprUtils.makeLiteralInt(value: 1),
                               conditionClause: ExprUtils.makeLiteralInt(value: 1),
                               incrementClause: ExprUtils.makeLiteralInt(value: 1),
                               body: AbstractSyntaxTreeNode()).hash)
    }
    
    func testGetters() {
        let stmt = ForLoop(initializerClause: ExprUtils.makeLiteralInt(value: 1),
                           conditionClause: ExprUtils.makeLiteralInt(value: 2),
                           incrementClause: ExprUtils.makeLiteralInt(value: 3),
                           body: ExprUtils.makeLiteralInt(value: 4))
        XCTAssertEqual(stmt.initializerClause, ExprUtils.makeLiteralInt(value: 1))
        XCTAssertEqual(stmt.conditionClause, ExprUtils.makeLiteralInt(value: 2))
        XCTAssertEqual(stmt.incrementClause, ExprUtils.makeLiteralInt(value: 3))
        XCTAssertEqual(stmt.body, ExprUtils.makeLiteralInt(value: 4))
    }
}
