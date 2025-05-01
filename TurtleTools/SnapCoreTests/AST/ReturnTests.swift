//
//  ReturnTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class ReturnTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(
            Return(),
            CommentNode(string: "")
        )
    }

    func testDoesNotEqualNodeWithDifferentExpression() {
        XCTAssertNotEqual(
            Return(LiteralInt(1)),
            Return(LiteralInt(2))
        )
    }

    func testHash() {
        XCTAssertEqual(
            Return().hashValue,
            Return().hashValue
        )
        XCTAssertEqual(
            Return(LiteralInt(1)).hashValue,
            Return(LiteralInt(1)).hashValue
        )
    }
}
