//
//  HLTNodeTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class HLTNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(HLTNode(), NOPNode())
    }
    
    func testEqualsHLTNode() {
        XCTAssertEqual(HLTNode(), HLTNode())
    }
}
