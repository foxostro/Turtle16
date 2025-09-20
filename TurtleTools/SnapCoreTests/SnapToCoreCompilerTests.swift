//
//  SnapToCoreCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class SnapToCoreCompilerTests: XCTestCase {
    func testExample() throws {
        let input = TopLevel(
            children: [
                CommentNode(string: "")
            ]
        )
        let expected = Block(
            symbols: Env(),
            children: [
                CommentNode(string: "")
            ]
        )

        let actual = try SnapToCoreCompiler().run(input).0
        XCTAssertEqual(expected, actual)
    }

    func testExpectTopLevelNodeAtRoot() throws {
        let input = CommentNode(string: "")
        XCTAssertThrowsError(try SnapToCoreCompiler().run(input).0)
    }
}
