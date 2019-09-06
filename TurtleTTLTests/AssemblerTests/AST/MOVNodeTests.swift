//
//  MOVNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class MOVNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(MOVNode(destination: .A, source: .A), NOPNode())
    }
    
    func testDoesNotEqualNodeWithDifferentDestination() {
        XCTAssertNotEqual(MOVNode(destination: .A, source: .A),
                          MOVNode(destination: .B, source: .A))
    }
    
    func testDoesNotEqualNodeWithDifferentSource() {
        XCTAssertNotEqual(MOVNode(destination: .A, source: .A),
                          MOVNode(destination: .A, source: .B))
    }
}
