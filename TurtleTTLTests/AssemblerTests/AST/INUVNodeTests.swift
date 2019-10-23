//
//  INUVNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 10/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class INUVNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(INUVNode(), NOPNode())
    }
    
    func testEqualsINUVNode() {
        XCTAssertEqual(INUVNode(), INUVNode())
    }
}
