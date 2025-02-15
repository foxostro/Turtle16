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

final class SnapSubcompilerAssertTests: XCTestCase {
    func testTransformAssert() throws {
        let input = makeAssertFalse()
        let result = try? SnapSubcompilerAssert().compile(nil, input)
        let expected = makeAssertFalseResult()
        XCTAssertEqual(result, expected)
    }
    
    fileprivate func makeAssertFalse() -> Assert {
        return Assert(condition: LiteralBool(false), message: "false")
    }
    
    fileprivate func makeAssertFalseResult() -> AbstractSyntaxTreeNode {
        let panic = Call(callee: Identifier("__panic"), arguments: [
            LiteralString("false")
        ])
        let condition = Binary(op: .eq,
                                          left: LiteralBool(false),
                                          right: LiteralBool(false))
        return If(condition: condition, then: Block(children: [panic]))
    }
}
