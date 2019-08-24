//
//  StoreImmediateNode.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/23/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class StoreImmediateNodeTests: XCTestCase {
    let zero = Token(type: .number, lineNumber: 1, lexeme: "0", literal: 0)
    let one = Token(type: .number, lineNumber: 1, lexeme: "1", literal: 1)
    
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(StoreImmediateNode(destinationAddress: zero, immediate: 0), CMPNode())
    }
    
    func testEqualsStoreImmediateNode() {
        XCTAssertEqual(StoreImmediateNode(destinationAddress: zero, immediate: 0),
                       StoreImmediateNode(destinationAddress: zero, immediate: 0))
    }
    
    func testNotEqualToStoreImmediateNodeWithDifferentImmediate() {
        XCTAssertNotEqual(StoreImmediateNode(destinationAddress: zero, immediate: 0),
                          StoreImmediateNode(destinationAddress: zero, immediate: 1))
    }
    
    func testNotEqualToStoreImmediateNodeWithDifferentDestinationAddress() {
        XCTAssertNotEqual(StoreImmediateNode(destinationAddress: zero, immediate: 0),
                          StoreImmediateNode(destinationAddress: one, immediate: 0))
    }
}
