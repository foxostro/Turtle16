//
//  CompilerPassAssertTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassAssertTests: XCTestCase {
    func testTransformAssert() throws {
        let expected = If(
            condition: Binary(
                op: .eq,
                left: LiteralBool(false),
                right: LiteralBool(false)
            ),
            then: Block(
                children: [
                    Call(
                        callee: Identifier("__panic"),
                        arguments: [LiteralString("false")]
                    )
                ])
        )
        let input = Assert(condition: LiteralBool(false), message: "false")
        let actual = try input.assertPass()
        XCTAssertEqual(actual, expected)
    }
}
