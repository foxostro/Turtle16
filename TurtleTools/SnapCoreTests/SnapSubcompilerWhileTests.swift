//
//  SnapSubcompilerWhileTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/15/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapSubcompilerWhileTests: XCTestCase {
    func testFailCompileIfStatementWithNonbooleanCondition() {
        let node = While(condition: Expression.LiteralInt(0),
                         body: Block(children: []))
        XCTAssertThrowsError(try SnapSubcompilerWhile().compile(while: node, symbols: SymbolTable())) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot convert value of type `integer constant 0' to type `bool'")
        }
    }
}
