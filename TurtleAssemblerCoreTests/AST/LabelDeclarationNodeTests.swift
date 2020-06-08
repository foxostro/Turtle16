//
//  LabelDeclarationNodeTests.swift
//  TurtleAssemblerCoreTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox
import TurtleAssemblerCore

class LabelDeclarationNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let label = TokenIdentifier(lineNumber: 1, lexeme: "label")
        XCTAssertNotEqual(LabelDeclarationNode(identifier: label), AbstractSyntaxTreeNode())
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        let bar = TokenIdentifier(lineNumber: 2, lexeme: "bar")
        XCTAssertNotEqual(LabelDeclarationNode(identifier: foo),
                          LabelDeclarationNode(identifier: bar))
    }
    
    func testEquality() {
        XCTAssertEqual(LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")),
                       LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")))
    }
    
    func testHash() {
        XCTAssertEqual(LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")).hashValue,
                       LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")).hashValue)
    }
}
