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
        let immediate = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        XCTAssertNotEqual(LINode(destination: .A, immediate: immediate), NOPNode())
    }
    
    func testDoesNotEqualNodeWithDifferentDestination() {
        let immediate = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        XCTAssertNotEqual(LINode(destination: .A, immediate: immediate),
                          LINode(destination: .B, immediate: immediate))
    }
    
    func testDoesNotEqualNodeWithDifferentImmediate() {
        let a = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
        let b = TokenNumber(lineNumber: 1, lexeme: "1", literal: 2)
        XCTAssertNotEqual(LINode(destination: .A, immediate: a),
                          LINode(destination: .A, immediate: b))
    }
}
