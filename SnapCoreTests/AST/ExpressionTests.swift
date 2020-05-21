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
    
    func testLiteralEquality() {
        XCTAssertNotEqual(Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                          Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)))
        XCTAssertEqual(Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                       Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
    }
    
    func testIdentifierEquality() {
        XCTAssertNotEqual(Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")),
                          Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "bar")))
        XCTAssertEqual(Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")),
                       Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")))
    }
}
