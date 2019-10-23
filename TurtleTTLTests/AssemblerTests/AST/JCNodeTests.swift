//
//  JCNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 10/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class JCNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(JCNode(), NOPNode())
    }
    
    func testEqualsJCNode() {
        XCTAssertEqual(JCNode(), JCNode())
    }
}
