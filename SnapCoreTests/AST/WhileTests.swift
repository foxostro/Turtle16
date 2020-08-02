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
        XCTAssertNotEqual(While(condition: Expression.LiteralInt(1),
                                body: AbstractSyntaxTreeNode()),
                          AbstractSyntaxTreeNode())
    }
    
    func testDoesNotEqualNodeWithDifferentCondition() {
        XCTAssertNotEqual(While(condition: Expression.LiteralInt(1),
                                body: AbstractSyntaxTreeNode()),
                          While(condition: Expression.LiteralInt(2),
                          body: AbstractSyntaxTreeNode()))
    }
    
    func testDoesNotEqualNodeWithDifferentBody() {
        XCTAssertNotEqual(While(condition: Expression.LiteralInt(1),
                                body: Expression.LiteralInt(1)),
                          While(condition: Expression.LiteralInt(1),
                                body: AbstractSyntaxTreeNode()))
    }
    
    func testSame() {
        XCTAssertEqual(While(condition: Expression.LiteralInt(1),
                             body: Expression.LiteralInt(1)),
                       While(condition: Expression.LiteralInt(1),
                             body: Expression.LiteralInt(1)))
    }
    
    func testHash() {
        XCTAssertEqual(While(condition: Expression.LiteralInt(1),
                             body: Expression.LiteralInt(1)).hash,
                       While(condition: Expression.LiteralInt(1),
                             body: Expression.LiteralInt(1)).hash)
    }
    
    func testGetters() {
        let stmt = While(condition: Expression.LiteralInt(1),
                         body: Expression.LiteralInt(2))
        XCTAssertEqual(stmt.condition, Expression.LiteralInt(1))
        XCTAssertEqual(stmt.body, Expression.LiteralInt(2))
    }
}
