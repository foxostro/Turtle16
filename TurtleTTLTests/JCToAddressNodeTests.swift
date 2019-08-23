//
//  JCToAddressNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class JCToAddressNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(JCToAddressNode(address: 0), NOPNode())
    }
    
    func testDoesNotEqualJCWithDifferentAddress() {
        XCTAssertNotEqual(JCToAddressNode(address: 0),
                          JCToAddressNode(address: 1))
    }
}
