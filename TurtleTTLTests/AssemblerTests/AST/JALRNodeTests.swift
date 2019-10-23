//
//  JALRNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 10/21/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

public class JALRNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let label = TokenIdentifier(lineNumber: 1, lexeme: "label")
        XCTAssertNotEqual(JALRNode(token: label), NOPNode())
    }
    
    func testDoesNotEqualLabelWithDifferentIdentifier() {
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        let bar = TokenIdentifier(lineNumber: 2, lexeme: "bar")
        XCTAssertNotEqual(JALRNode(token: foo), JALRNode(token: bar))
    }
}
