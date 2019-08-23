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
    typealias Token = AssemblerScanner.Token
    
    func testDoesNotEqualAnotherNodeType() {
        let label = Token(type: .identifier, lineNumber: 1, lexeme: "label")
        XCTAssertNotEqual(LabelDeclarationNode(identifier: label), NOPNode())
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        let foo = Token(type: .identifier, lineNumber: 1, lexeme: "foo")
        let bar = Token(type: .identifier, lineNumber: 2, lexeme: "bar")
        XCTAssertNotEqual(LabelDeclarationNode(identifier: foo),
                          LabelDeclarationNode(identifier: bar))
    }
}
