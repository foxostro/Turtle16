//
//  IfTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class IfTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        XCTAssertNotEqual(If(condition: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                             then: AbstractSyntaxTreeNode(),
                             else: nil),
                          LabelDeclarationNode(identifier: foo))
    }
    
    func testDoesNotEqualNodeWithDifferentCondition() {
        XCTAssertNotEqual(If(condition: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                             then: AbstractSyntaxTreeNode(),
                             else: nil).hashValue,
                          If(condition: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)),
                             then: AbstractSyntaxTreeNode(),
                             else: nil).hashValue)
    }
    
    func testDoesNotEqualNodeWithDifferentThenBranch() {
        XCTAssertNotEqual(If(condition: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                             then: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                             else: nil).hashValue,
                          If(condition: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)),
                             then: AbstractSyntaxTreeNode(),
                             else: nil).hashValue)
    }
    
    func testDoesNotEqualNodeWithDifferentElseBranch() {
        XCTAssertNotEqual(If(condition: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                             then: AbstractSyntaxTreeNode(),
                             else: AbstractSyntaxTreeNode()),
                          If(condition: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)),
                             then: AbstractSyntaxTreeNode(),
                             else: nil))
    }
    
    func testHash() {
        XCTAssertEqual(If(condition: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                          then: AbstractSyntaxTreeNode(),
                          else: nil).hashValue,
                       If(condition: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                          then: AbstractSyntaxTreeNode(),
                          else: nil).hashValue)
    }
}
