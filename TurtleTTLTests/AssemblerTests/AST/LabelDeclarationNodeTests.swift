//
//  LabelDeclarationNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class LabelDeclarationNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let label = TokenIdentifier(lineNumber: 1, lexeme: "label")
        XCTAssertNotEqual(LabelDeclarationNode(identifier: label), InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "NOP"), parameters: ParameterListNode(parameters: [])))
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        let bar = TokenIdentifier(lineNumber: 2, lexeme: "bar")
        XCTAssertNotEqual(LabelDeclarationNode(identifier: foo),
                          LabelDeclarationNode(identifier: bar))
    }
}
