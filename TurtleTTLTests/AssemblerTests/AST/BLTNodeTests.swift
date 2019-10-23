//
//  BLTNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 10/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class BLTNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(BLTNode(destination: .M, source: .M), NOPNode())
    }
    
    func testDoesNotEqualNodeWithDifferentDestination() {
        XCTAssertNotEqual(BLTNode(destination: .M, source: .M),
                          BLTNode(destination: .P, source: .M))
    }
    
    func testDoesNotEqualNodeWithDifferentSource() {
        XCTAssertNotEqual(BLTNode(destination: .M, source: .M),
                          BLTNode(destination: .M, source: .P))
    }
}
