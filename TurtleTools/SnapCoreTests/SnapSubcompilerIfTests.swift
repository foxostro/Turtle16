//
//  SnapSubcompilerIfTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/15/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class SnapSubcompilerIfTests: XCTestCase {
    func testFailCompileIfStatementWithNonbooleanCondition() {
        let node = If(
            condition: LiteralInt(0),
            then: Block(children: []),
            else: nil
        )
        XCTAssertThrowsError(try SnapSubcompilerIf().compile(if: node, symbols: Env())) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `integer constant 0' to type `bool'"
            )
        }
    }
}
