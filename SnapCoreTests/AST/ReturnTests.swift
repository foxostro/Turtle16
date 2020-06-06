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
        let token = TokenReturn(lineNumber: 1, lexeme: "return")
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        XCTAssertNotEqual(Return(token: token, expression: nil), LabelDeclarationNode(identifier: foo))
    }
    
    func testDoesNotEqualNodeWithDifferentLineNumber() {
        XCTAssertNotEqual(Return(token: TokenReturn(lineNumber: 1, lexeme: "return"), expression: nil), Return(token: TokenReturn(lineNumber: 2, lexeme: "return"), expression: nil))
    }
    
    func testDoesNotEqualNodeWithDifferentValue() {
        let token = TokenReturn(lineNumber: 1, lexeme: "return")
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)
        XCTAssertNotEqual(Return(token: token, expression: Expression.LiteralWord(number: a)), Return(token: token, expression: Expression.LiteralWord(number: b)))
    }
    
    func testDoesEqualNodeWithSameLineNumberAndValue() {
        let token = TokenReturn(lineNumber: 1, lexeme: "return")
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        XCTAssertEqual(Return(token: token, expression: nil), Return(token: TokenReturn(lineNumber: 1, lexeme: "return"), expression: nil))
        XCTAssertEqual(Return(token: token, expression: Expression.LiteralWord(number: a)), Return(token: TokenReturn(lineNumber: 1, lexeme: "return"), expression: Expression.LiteralWord(number: b)))
    }
    
    func testHash() {
        let token = TokenReturn(lineNumber: 1, lexeme: "return")
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        XCTAssertEqual(Return(token: token, expression: nil).hashValue,
                       Return(token: TokenReturn(lineNumber: 1, lexeme: "return"), expression: nil).hashValue)
        XCTAssertEqual(Return(token: token, expression: Expression.LiteralWord(number: a)).hashValue,
                       Return(token: TokenReturn(lineNumber: 1, lexeme: "return"), expression: Expression.LiteralWord(number: b)).hashValue)
    }
}
