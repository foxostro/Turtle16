//
//  LINodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class LINodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let immediate = Token(type: .number, lineNumber: 1, lexeme: "1", literal: 1)
        XCTAssertNotEqual(LINode(destination: "", immediate: immediate), NOPNode())
    }
    
    func testDoesNotEqualNodeWithDifferentDestination() {
        let immediate = Token(type: .number, lineNumber: 1, lexeme: "1", literal: 1)
        XCTAssertNotEqual(LINode(destination: "a", immediate: immediate),
                          LINode(destination: "b", immediate: immediate))
    }
    
    func testDoesNotEqualNodeWithDifferentImmediate() {
        let a = Token(type: .number, lineNumber: 1, lexeme: "1", literal: 1)
        let b = Token(type: .number, lineNumber: 1, lexeme: "1", literal: 2)
        XCTAssertNotEqual(LINode(destination: "", immediate: a),
                          LINode(destination: "", immediate: b))
    }
}
