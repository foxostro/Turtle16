//
//  ReturnTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class ReturnTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(Return(sourceAnchor: nil, expression: nil),
                          AbstractSyntaxTreeNode(sourceAnchor: nil))
    }
    
    func testDoesNotEqualNodeWithDifferentExpression() {
        XCTAssertNotEqual(Return(sourceAnchor: nil, expression: Expression.LiteralWord(sourceAnchor: nil, value: 1)),
                          Return(sourceAnchor: nil, expression: Expression.LiteralWord(sourceAnchor: nil, value: 2)))
    }
    
    func testHash() {
        XCTAssertEqual(Return(sourceAnchor: nil, expression: nil).hashValue,
                       Return(sourceAnchor: nil, expression: nil).hashValue)
        XCTAssertEqual(Return(sourceAnchor: nil, expression: Expression.LiteralWord(sourceAnchor: nil, value: 1)).hashValue,
                       Return(sourceAnchor: nil, expression: Expression.LiteralWord(sourceAnchor: nil, value: 1)).hashValue)
    }
}
