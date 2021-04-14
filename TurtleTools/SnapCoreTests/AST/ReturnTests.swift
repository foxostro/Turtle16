//
//  ReturnTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class ReturnTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(Return(),
                          AbstractSyntaxTreeNode())
    }
    
    func testDoesNotEqualNodeWithDifferentExpression() {
        XCTAssertNotEqual(Return(Expression.LiteralInt(1)),
                          Return(Expression.LiteralInt(2)))
    }
    
    func testHash() {
        XCTAssertEqual(Return().hashValue,
                       Return().hashValue)
        XCTAssertEqual(Return(Expression.LiteralInt(1)).hashValue,
                       Return(Expression.LiteralInt(1)).hashValue)
    }
}
