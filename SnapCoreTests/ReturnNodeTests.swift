//
//  ReturnNodeTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class ReturnNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        XCTAssertNotEqual(ReturnNode(lineNumber: 1), LabelDeclarationNode(identifier: foo))
    }
    
    func testDoesNotEqualNodeWithDifferentLineNumber() {
        XCTAssertNotEqual(ReturnNode(lineNumber: 1), ReturnNode(lineNumber: 2))
    }
    
    func testDoesNotEqualNodeWithDifferentValue() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 2, lexeme: "2", literal: 2)
        XCTAssertNotEqual(ReturnNode(lineNumber: 1, value: a), ReturnNode(lineNumber: 1, value: b))
    }
    
    func testDoesEqualNodeWithSameLineNumberAndValue() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        XCTAssertEqual(ReturnNode(lineNumber: 1), ReturnNode(lineNumber: 1))
        XCTAssertEqual(ReturnNode(lineNumber: 1, value: a), ReturnNode(lineNumber: 1, value: b))
    }
}
