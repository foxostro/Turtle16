//
//  EvalStatementTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class EvalStatementTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"),
                                        expression: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))),
                          LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"))
        )
    }
    
    func testDoesNotEqualNodeWithDifferentLineNumber() {
        XCTAssertNotEqual(EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"),
                                        expression: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))),
                          EvalStatement(token: TokenEval(lineNumber: 2, lexeme: "eval"),
                                        expression: Expression.Literal(number: TokenNumber(lineNumber: 2, lexeme: "1", literal: 1)))
        )
    }
    
    func testDoesNotEqualNodeWithDifferentValue() {
        let token = TokenEval(lineNumber: 1, lexeme: "eval")
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)
        XCTAssertNotEqual(EvalStatement(token: token, expression: Expression.Literal(number: a)), EvalStatement(token: token, expression: Expression.Literal(number: b)))
    }
    
    func testDoesEqualNodeWithSameLineNumberAndValue() {
        XCTAssertEqual(EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"),
                                     expression: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))),
                       EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"),
                                     expression: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
        )
    }
}
