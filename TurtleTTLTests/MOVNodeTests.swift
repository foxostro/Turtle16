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
        XCTAssertNotEqual(MOVNode(destination: "", source: ""), NOPNode())
    }
    
    func testDoesNotEqualNodeWithDifferentDestination() {
        XCTAssertNotEqual(MOVNode(destination: "a", source: ""),
                          MOVNode(destination: "b", source: ""))
    }
    
    func testDoesNotEqualNodeWithDifferentSource() {
        XCTAssertNotEqual(MOVNode(destination: "", source: "a"),
                          MOVNode(destination: "", source: "b"))
    }
}
