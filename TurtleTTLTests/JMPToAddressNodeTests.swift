//
//  JMPToAddressNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class JMPToAddressNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(JMPToAddressNode(address: 0), NOPNode())
    }
    
    func testDoesNotEqualJMPWithDifferentAddress() {
        XCTAssertNotEqual(JMPToAddressNode(address: 0),
                          JMPToAddressNode(address: 1))
    }
}
