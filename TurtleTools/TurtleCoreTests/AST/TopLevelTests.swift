//
//  TopLevelTests.swift
//  TurtleCoreTests
//
//  Created by Andrew Fox on 6/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore
import XCTest

final class TopLevelTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(
            TopLevel(children: []),
            CommentNode(string: "")
        )
    }

    func testDoesNotEqualNodeWithDifferentChildren() {
        XCTAssertNotEqual(
            TopLevel(children: []),
            TopLevel(children: [CommentNode(string: "")])
        )
    }

    func testSame() {
        XCTAssertEqual(
            TopLevel(children: [CommentNode(string: "")]),
            TopLevel(children: [CommentNode(string: "")])
        )
    }

    func testHash() {
        XCTAssertEqual(
            TopLevel(children: [CommentNode(string: "")]).hashValue,
            TopLevel(children: [CommentNode(string: "")]).hashValue
        )
    }
}
