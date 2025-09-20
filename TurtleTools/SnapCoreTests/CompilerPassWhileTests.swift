//
//  CompilerPassWhileTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 1/16/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassWhileTests: XCTestCase {
    func testFailCompileIfStatementWithNonbooleanCondition() {
        let node = Block(
            children: [
                While(
                    condition: LiteralInt(0),
                    body: Block()
                )
            ]
        )
        XCTAssertThrowsError(try node.whilePass()) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "cannot convert value of type `integer constant 0' to type `bool'"
            )
        }
    }
}
