//
//  JMPNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 10/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class JMPNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(JMPNode(), NOPNode())
    }
    
    func testEqualsJMPNode() {
        XCTAssertEqual(JMPNode(), JMPNode())
    }
}
