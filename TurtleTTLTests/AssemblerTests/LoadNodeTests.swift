//
//  LoadNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/23/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class LoadNodeTests: XCTestCase {
    let zero = TokenNumber(lineNumber: 1, lexeme: "0", literal: 0)
    let one = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
    
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(LoadNode(destination: .A, sourceAddress: zero), NOPNode())
    }
    
    func testEqualsLoadNode() {
        XCTAssertEqual(LoadNode(destination: .A, sourceAddress: zero),
                       LoadNode(destination: .A, sourceAddress: zero))
    }
    
    func testNotEqualToLoadNodeWithDifferentDestination() {
        XCTAssertNotEqual(LoadNode(destination: .A, sourceAddress: zero),
                          LoadNode(destination: .B, sourceAddress: zero))
    }
    
    func testNotEqualToLoadNodeWithDifferentSourceAddress() {
        XCTAssertNotEqual(LoadNode(destination: .A, sourceAddress: zero),
                          LoadNode(destination: .A, sourceAddress: one))
    }
}
