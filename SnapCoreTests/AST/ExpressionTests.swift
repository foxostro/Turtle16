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
        XCTAssertNotEqual(Expression.Literal(number: a), LabelDeclarationNode(identifier: foo))
    }
    
    func testDoesNotEqualExpressionWithDifferentLineNumber() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 1, lexeme: "1", literal: 2)
        XCTAssertNotEqual(Expression.Literal(number: a), Expression.Literal(number: b))
    }
    
    func testDoesNotEqualExpressionWithDifferentValue() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 2, lexeme: "2", literal: 2)
        XCTAssertNotEqual(Expression.Literal(number: a), Expression.Literal(number: b))
    }
    
    func testDoesEqualExpressionWithSameLineNumberAndValue() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        XCTAssertEqual(Expression.Literal(number: a), Expression.Literal(number: b))
    }
}
