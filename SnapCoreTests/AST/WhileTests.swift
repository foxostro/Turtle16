//
//  WhileTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class WhileTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(While(sourceAnchor: nil,
                                condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                body: AbstractSyntaxTreeNode(sourceAnchor: nil)),
                          AbstractSyntaxTreeNode(sourceAnchor: nil))
    }
    
    func testDoesNotEqualNodeWithDifferentCondition() {
        XCTAssertNotEqual(While(sourceAnchor: nil,
                                condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                body: AbstractSyntaxTreeNode(sourceAnchor: nil)),
                          While(sourceAnchor: nil,
                                condition: Expression.LiteralWord(sourceAnchor: nil, value: 2),
                          body: AbstractSyntaxTreeNode(sourceAnchor: nil)))
    }
    
    func testDoesNotEqualNodeWithDifferentBody() {
        XCTAssertNotEqual(While(sourceAnchor: nil,
                                condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                body: Expression.LiteralWord(sourceAnchor: nil, value: 1)),
                          While(sourceAnchor: nil,
                                condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                body: AbstractSyntaxTreeNode(sourceAnchor: nil)))
    }
    
    func testSame() {
        XCTAssertEqual(While(sourceAnchor: nil,
                             condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                             body: Expression.LiteralWord(sourceAnchor: nil, value: 1)),
                       While(sourceAnchor: nil,
                             condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                             body: Expression.LiteralWord(sourceAnchor: nil, value: 1)))
    }
    
    func testHash() {
        XCTAssertEqual(While(sourceAnchor: nil,
                             condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                             body: Expression.LiteralWord(sourceAnchor: nil, value: 1)).hash,
                       While(sourceAnchor: nil,
                             condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                             body: Expression.LiteralWord(sourceAnchor: nil, value: 1)).hash)
    }
    
    func testGetters() {
        let stmt = While(sourceAnchor: nil,
                         condition: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                         body: Expression.LiteralWord(sourceAnchor: nil, value: 2))
        XCTAssertEqual(stmt.condition, Expression.LiteralWord(sourceAnchor: nil, value: 1))
        XCTAssertEqual(stmt.body, Expression.LiteralWord(sourceAnchor: nil, value: 2))
    }
}
