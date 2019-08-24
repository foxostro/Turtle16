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
    let zero = Token(type: .number, lineNumber: 1, lexeme: "0", literal: 0)
    let one = Token(type: .number, lineNumber: 1, lexeme: "1", literal: 1)
    
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(LoadNode(destination: "", sourceAddress: zero), NOPNode())
    }
    
    func testEqualsLoadNode() {
        XCTAssertEqual(LoadNode(destination: "", sourceAddress: zero),
                       LoadNode(destination: "", sourceAddress: zero))
    }
    
    func testNotEqualToLoadNodeWithDifferentDestination() {
        XCTAssertNotEqual(LoadNode(destination: "a", sourceAddress: zero),
                          LoadNode(destination: "b", sourceAddress: zero))
    }
    
    func testNotEqualToLoadNodeWithDifferentSourceAddress() {
        XCTAssertNotEqual(LoadNode(destination: "", sourceAddress: zero),
                          LoadNode(destination: "", sourceAddress: one))
    }
}
