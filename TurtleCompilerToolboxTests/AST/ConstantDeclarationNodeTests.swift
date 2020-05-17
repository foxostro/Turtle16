//
//  ConstantDeclarationNodeTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 5/16/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class ConstantDeclarationNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        let one = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        XCTAssertNotEqual(ConstantDeclarationNode(identifier: foo, number: one), LabelDeclarationNode(identifier: foo))
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        let bar = TokenIdentifier(lineNumber: 2, lexeme: "bar")
        let one = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        XCTAssertNotEqual(ConstantDeclarationNode(identifier: foo, number: one),
                          ConstantDeclarationNode(identifier: bar, number: one))
    }
    
    func testDoesNotEqualNodeWithDifferentNumber() {
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        let one = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let two = TokenNumber(lineNumber: 2, lexeme: "2", literal: 2)
        XCTAssertNotEqual(ConstantDeclarationNode(identifier: foo, number: one),
                          ConstantDeclarationNode(identifier: foo, number: two))
    }
}
