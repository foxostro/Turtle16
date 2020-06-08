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
        XCTAssertNotEqual(ForLoop(initializerClause: ExprUtils.makeLiteralWord(value: 1),
                                  conditionClause: ExprUtils.makeLiteralWord(value: 1),
                                  incrementClause: ExprUtils.makeLiteralWord(value: 1),
                                  body: AbstractSyntaxTreeNode()),
                          AbstractSyntaxTreeNode())
    }
    
    func testDoesNotEqualNodeWithDifferentInitializerClause() {
        XCTAssertNotEqual(ForLoop(initializerClause: ExprUtils.makeLiteralWord(value: 1),
                                  conditionClause: ExprUtils.makeLiteralWord(value: 1),
                                  incrementClause: ExprUtils.makeLiteralWord(value: 1),
                                  body: AbstractSyntaxTreeNode()),
                          ForLoop(initializerClause: ExprUtils.makeLiteralWord(value: 2),
                                  conditionClause: ExprUtils.makeLiteralWord(value: 1),
                                  incrementClause: ExprUtils.makeLiteralWord(value: 1),
                                  body: AbstractSyntaxTreeNode()))
    }
    
    func testDoesNotEqualNodeWithDifferentConditionClause() {
        XCTAssertNotEqual(ForLoop(initializerClause: ExprUtils.makeLiteralWord(value: 1),
                                  conditionClause: ExprUtils.makeLiteralWord(value: 1),
                                  incrementClause: ExprUtils.makeLiteralWord(value: 1),
                                  body: AbstractSyntaxTreeNode()),
                          ForLoop(initializerClause: ExprUtils.makeLiteralWord(value: 1),
                                  conditionClause: ExprUtils.makeLiteralWord(value: 2),
                                  incrementClause: ExprUtils.makeLiteralWord(value: 1),
                                  body: AbstractSyntaxTreeNode()))
    }
    
    func testDoesNotEqualNodeWithDifferentIncrementClause() {
        XCTAssertNotEqual(ForLoop(initializerClause: ExprUtils.makeLiteralWord(value: 1),
                                  conditionClause: ExprUtils.makeLiteralWord(value: 1),
                                  incrementClause: ExprUtils.makeLiteralWord(value: 1),
                                  body: AbstractSyntaxTreeNode()),
                          ForLoop(initializerClause: ExprUtils.makeLiteralWord(value: 1),
                                  conditionClause: ExprUtils.makeLiteralWord(value: 1),
                                  incrementClause: ExprUtils.makeLiteralWord(value: 2),
                                  body: AbstractSyntaxTreeNode()))
    }
    
    func testDoesNotEqualNodeWithDifferentBody() {
        XCTAssertNotEqual(ForLoop(initializerClause: ExprUtils.makeLiteralWord(value: 1),
                                  conditionClause: ExprUtils.makeLiteralWord(value: 1),
                                  incrementClause: ExprUtils.makeLiteralWord(value: 1),
                                  body: AbstractSyntaxTreeNode()),
                          ForLoop(initializerClause: ExprUtils.makeLiteralWord(value: 1),
                                  conditionClause: ExprUtils.makeLiteralWord(value: 1),
                                  incrementClause: ExprUtils.makeLiteralWord(value: 1),
                                  body: ExprUtils.makeLiteralWord(value: 1)))
    }
    
    func testSame() {
        XCTAssertEqual(ForLoop(initializerClause: ExprUtils.makeLiteralWord(value: 1),
                               conditionClause: ExprUtils.makeLiteralWord(value: 1),
                               incrementClause: ExprUtils.makeLiteralWord(value: 1),
                               body: AbstractSyntaxTreeNode()),
                       ForLoop(initializerClause: ExprUtils.makeLiteralWord(value: 1),
                               conditionClause: ExprUtils.makeLiteralWord(value: 1),
                               incrementClause: ExprUtils.makeLiteralWord(value: 1),
                               body: AbstractSyntaxTreeNode()))
    }
    
    func testHash() {
        XCTAssertEqual(ForLoop(initializerClause: ExprUtils.makeLiteralWord(value: 1),
                               conditionClause: ExprUtils.makeLiteralWord(value: 1),
                               incrementClause: ExprUtils.makeLiteralWord(value: 1),
                               body: AbstractSyntaxTreeNode()).hash,
                       ForLoop(initializerClause: ExprUtils.makeLiteralWord(value: 1),
                               conditionClause: ExprUtils.makeLiteralWord(value: 1),
                               incrementClause: ExprUtils.makeLiteralWord(value: 1),
                               body: AbstractSyntaxTreeNode()).hash)
    }
    
    func testGetters() {
        let stmt = ForLoop(initializerClause: ExprUtils.makeLiteralWord(value: 1),
                           conditionClause: ExprUtils.makeLiteralWord(value: 2),
                           incrementClause: ExprUtils.makeLiteralWord(value: 3),
                           body: ExprUtils.makeLiteralWord(value: 4))
        XCTAssertEqual(stmt.initializerClause, ExprUtils.makeLiteralWord(value: 1))
        XCTAssertEqual(stmt.conditionClause, ExprUtils.makeLiteralWord(value: 2))
        XCTAssertEqual(stmt.incrementClause, ExprUtils.makeLiteralWord(value: 3))
        XCTAssertEqual(stmt.body, ExprUtils.makeLiteralWord(value: 4))
    }
}
