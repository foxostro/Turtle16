//
//  StoreNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/23/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class StoreNodeTests: XCTestCase {
    let zero = TokenNumber(lineNumber: 1, lexeme: "0", literal: 0)
    let one = TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)
    
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(StoreNode(destinationAddress: zero, source: ""), CMPNode())
    }
    
    func testEqualsStoreNode() {
        XCTAssertEqual(StoreNode(destinationAddress: zero, source: ""),
                       StoreNode(destinationAddress: zero, source: ""))
    }
    
    func testNotEqualToStoreNodeWithDifferentDestinationAddress() {
        XCTAssertNotEqual(StoreNode(destinationAddress: zero, source: ""),
                          StoreNode(destinationAddress: one, source: ""))
    }
    
    func testNotEqualToStoreNodeWithDifferentSource() {
        XCTAssertNotEqual(StoreNode(destinationAddress: zero, source: "A"),
                          StoreNode(destinationAddress: zero, source: "B"))
    }
}
