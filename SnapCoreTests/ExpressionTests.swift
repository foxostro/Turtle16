//
//  ExpressionNodeTests.swift
//  ExpressionTests
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class ExpressionTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        XCTAssertNotEqual(Expression.Literal(lineNumber: 1, number: a), LabelDeclarationNode(identifier: foo))
    }
    
    func testDoesNotEqualNodeWithDifferentLineNumber() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 1, lexeme: "1", literal: 2)
        XCTAssertNotEqual(Expression.Literal(lineNumber: 1, number: a), Expression.Literal(lineNumber: 2, number: b))
    }
    
    func testDoesNotEqualNodeWithDifferentValue() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 2, lexeme: "2", literal: 2)
        XCTAssertNotEqual(Expression.Literal(lineNumber: 1, number: a), Expression.Literal(lineNumber: 1, number: b))
    }
    
    func testDoesEqualNodeWithSameLineNumberAndValue() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        XCTAssertEqual(Expression.Literal(lineNumber: 1, number: a), Expression.Literal(lineNumber: 1, number: b))
    }
}
