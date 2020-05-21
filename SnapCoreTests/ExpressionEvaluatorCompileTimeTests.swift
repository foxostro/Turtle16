//
//  ExpressionEvaluatorCompileTimeTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class ExpressionEvaluatorCompileTimeTests: XCTestCase {
    func testEvaluateLiteralNumber() {
        let expression = Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        let eval = ExpressionEvaluatorCompileTime()
        var actual: Int?
        XCTAssertNoThrow(actual = try eval.evaluate(expression: expression))
        XCTAssertEqual(1, actual)
    }
            
    func testEvaluationFailsWithUnresolvedIdentifier() {
        let expression = Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        let eval = ExpressionEvaluatorCompileTime()
        XCTAssertThrowsError(try eval.evaluate(expression: expression)) {
            XCTAssertNotNil($0 as? ExpressionEvaluatorCompileTime.MustBeCompileTimeConstantError)
        }
    }
}
