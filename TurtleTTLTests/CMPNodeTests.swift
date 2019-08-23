//
//  CMPNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class CMPNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(CMPNode(), NOPNode())
    }
    
    func testEqualsCMPNode() {
        XCTAssertEqual(CMPNode(), CMPNode())
    }
}
