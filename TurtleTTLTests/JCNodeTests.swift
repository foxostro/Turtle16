//
//  JCNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class JCNodeTests: XCTestCase {
    typealias Token = AssemblerScanner.Token
    
    func testDoesNotEqualAnotherNodeType() {
        let label = Token(type: .identifier, lineNumber: 1, lexeme: "label")
        XCTAssertNotEqual(JCNode(token: label), NOPNode())
    }
    
    func testDoesNotEqualLabelWithDifferentIdentifier() {
        let foo = Token(type: .identifier, lineNumber: 1, lexeme: "foo")
        let bar = Token(type: .identifier, lineNumber: 2, lexeme: "bar")
        XCTAssertNotEqual(JCNode(token: foo), JCNode(token: bar))
    }
}
