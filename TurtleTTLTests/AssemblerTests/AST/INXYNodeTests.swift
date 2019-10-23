//
//  INXYNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 10/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class INXYNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(INXYNode(), NOPNode())
    }
    
    func testEqualsINXYNode() {
        XCTAssertEqual(INXYNode(), INXYNode())
    }
}
