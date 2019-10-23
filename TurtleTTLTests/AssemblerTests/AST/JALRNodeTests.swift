//
//  JALRNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 10/21/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

public class JALRNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(JALRNode(), NOPNode())
    }
    
    func testEqualsJALRNode() {
        XCTAssertEqual(JALRNode(), JALRNode())
    }
}
