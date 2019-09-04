//
//  ADDNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class ADDNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(ADDNode(destination: .A), NOPNode())
    }
    
    func testDoesNotEqualNodeWithDifferentDestination() {
        XCTAssertNotEqual(ADDNode(destination: .A), ADDNode(destination: .B))
    }
}
