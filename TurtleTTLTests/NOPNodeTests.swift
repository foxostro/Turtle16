//
//  NOPNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class NOPNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(NOPNode(), CMPNode())
    }
    
    func testEqualsNOPNode() {
        XCTAssertEqual(NOPNode(), NOPNode())
    }
}
