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
    
    func testDoesEqualNodeWithSameLineNumber() {
        XCTAssertEqual(ReturnNode(lineNumber: 1), ReturnNode(lineNumber: 1))
    }
}
