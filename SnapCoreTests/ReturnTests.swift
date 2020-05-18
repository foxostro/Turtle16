//
//  ReturnTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class ReturnTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        XCTAssertNotEqual(Return(lineNumber: 1, expression: nil), LabelDeclarationNode(identifier: foo))
    }
    
    func testDoesNotEqualNodeWithDifferentLineNumber() {
        XCTAssertNotEqual(Return(lineNumber: 1, expression: nil), Return(lineNumber: 2, expression: nil))
    }
    
    func testDoesNotEqualNodeWithDifferentValue() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 2, lexeme: "2", literal: 2)
        XCTAssertNotEqual(Return(lineNumber: 1, expression: Expression.Literal(lineNumber: 1, number: a)), Return(lineNumber: 1, expression: Expression.Literal(lineNumber: 1, number: b)))
    }
    
    func testDoesEqualNodeWithSameLineNumberAndValue() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        XCTAssertEqual(Return(lineNumber: 1, expression: nil), Return(lineNumber: 1, expression: nil))
        XCTAssertEqual(Return(lineNumber: 1, expression: Expression.Literal(lineNumber: 1, number: a)), Return(lineNumber: 1, expression: Expression.Literal(lineNumber: 1, number: b)))
    }
}
