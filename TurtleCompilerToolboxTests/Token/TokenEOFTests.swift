//
//  TokenEOFTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 9/3/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class TokenEOFTests: XCTestCase {
    func testTokenDescription() {
        XCTAssertEqual(TokenEOF(sourceAnchor: nil).description, "<TokenEOF: sourceAnchor=nil>")
    }
}
