//
//  SnapSubcompilerAssertTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapSubcompilerAssertTests: XCTestCase {
    func testTransformAssert() throws {
        let input = makeAssertFalse()
        let result = try? SnapSubcompilerAssert().compile(input)
        let expected = makeAssertFalseResult()
        XCTAssertEqual(result, expected)
    }
    
    fileprivate func makeAssertFalse() -> Assert {
        return Assert(condition: Expression.LiteralBool(false), message: "false")
    }
    
    fileprivate func makeAssertFalseResult() -> AbstractSyntaxTreeNode {
        let panic = Expression.Call(callee: Expression.Identifier("panic"), arguments: [
            Expression.LiteralString("false")
        ])
        let condition = Expression.Binary(op: .eq,
                                          left: Expression.LiteralBool(false),
                                          right: Expression.LiteralBool(false))
        return If(condition: condition, then: Block(children: [panic]))
    }
}
