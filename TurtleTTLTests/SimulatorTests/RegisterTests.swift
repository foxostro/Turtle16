//
//  RegisterTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/17/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class RegisterTests: XCTestCase {
    func testInitWithEmptyString() {
        let r = Register(withStringValue: "")
        XCTAssertEqual(r, nil)
    }
    
    func testInitWithValidString() {
        let r = Register(withStringValue: "1")
        XCTAssertEqual(r?.value, 1)
    }
    
    func testInitWithStringNegative() {
        let r = Register(withStringValue: "-1")
        XCTAssertEqual(r, nil)
    }
    
    func testInitWithStringTooBig() {
        let r = Register(withStringValue: "256")
        XCTAssertEqual(r, nil)
    }
}
