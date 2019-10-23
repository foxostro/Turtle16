//
//  LXYWithAddressNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 10/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest

import TurtleTTL

class LXYWithAddressNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(LXYWithAddressNode(address: 0), NOPNode())
    }
    
    func testDoesNotEqualLXYWithDifferentAddress() {
        XCTAssertNotEqual(LXYWithAddressNode(address: 0),
                          LXYWithAddressNode(address: 1))
    }
}
