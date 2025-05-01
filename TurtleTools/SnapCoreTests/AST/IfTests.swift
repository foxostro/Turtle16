//
//  IfTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class IfTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(
            If(
                condition: LiteralInt(1),
                then: CommentNode(string: ""),
                else: nil
            ),
            CommentNode(string: "")
        )
    }

    func testDoesNotEqualNodeWithDifferentCondition() {
        XCTAssertNotEqual(
            If(
                condition: LiteralInt(1),
                then: CommentNode(string: ""),
                else: nil
            ),
            If(
                condition: LiteralInt(2),
                then: CommentNode(string: ""),
                else: nil
            )
        )
    }

    func testDoesNotEqualNodeWithDifferentThenBranch() {
        XCTAssertNotEqual(
            If(
                condition: LiteralInt(1),
                then: LiteralInt(1),
                else: nil
            ),
            If(
                condition: LiteralInt(2),
                then: CommentNode(string: ""),
                else: nil
            )
        )
    }

    func testDoesNotEqualNodeWithDifferentElseBranch() {
        XCTAssertNotEqual(
            If(
                condition: LiteralInt(1),
                then: CommentNode(string: ""),
                else: CommentNode(string: "")
            ),
            If(
                condition: LiteralInt(2),
                then: CommentNode(string: ""),
                else: nil
            )
        )
    }

    func testSame() {
        XCTAssertEqual(
            If(
                condition: LiteralInt(1),
                then: CommentNode(string: ""),
                else: CommentNode(string: "")
            ),
            If(
                condition: LiteralInt(1),
                then: CommentNode(string: ""),
                else: CommentNode(string: "")
            )
        )
    }

    func testHash() {
        XCTAssertEqual(
            If(
                condition: LiteralInt(1),
                then: CommentNode(string: ""),
                else: nil
            ).hashValue,
            If(
                condition: LiteralInt(1),
                then: CommentNode(string: ""),
                else: nil
            ).hashValue
        )
    }

    func testGetters() {
        let stmt = If(
            condition: LiteralInt(1),
            then: LiteralInt(2),
            else: LiteralInt(3)
        )
        XCTAssertEqual(stmt.condition, LiteralInt(1))
        XCTAssertEqual(stmt.thenBranch, LiteralInt(2))
        XCTAssertEqual(stmt.elseBranch, LiteralInt(3))
    }

    func testElseGetterWithNilBranch() {
        let stmt = If(
            condition: LiteralInt(1),
            then: LiteralInt(2),
            else: nil
        )
        XCTAssertNil(stmt.elseBranch)
    }
}
