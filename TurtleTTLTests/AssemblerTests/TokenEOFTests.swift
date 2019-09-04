//
//  TokenEOFTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 9/3/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class TokenEOFTests: XCTestCase {
    func testTokenDescription() {
        XCTAssertEqual(TokenEOF(lineNumber: 1).description, "<TokenEOF: lineNumber=1>")
    }
}
