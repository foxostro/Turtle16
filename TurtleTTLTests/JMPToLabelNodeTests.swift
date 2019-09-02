//
//  JMPToLabelNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class JMPToLabelNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let label = TokenIdentifier(lineNumber: 1, lexeme: "label")
        XCTAssertNotEqual(JMPToLabelNode(token: label), NOPNode())
    }
    
    func testDoesNotEqualLabelWithDifferentIdentifier() {
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        let bar = TokenIdentifier(lineNumber: 2, lexeme: "bar")
        XCTAssertNotEqual(JMPToLabelNode(token: foo), JMPToLabelNode(token: bar))
    }
}
