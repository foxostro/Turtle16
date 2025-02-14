//
//  TokenEOFTests.swift
//  TurtleCoreTests
//
//  Created by Andrew Fox on 9/3/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore

final class TokenEOFTests: XCTestCase {
    func testTokenDescription() {
        XCTAssertEqual(TokenEOF().description, "<TokenEOF: sourceAnchor=nil, lexeme=\"\">")
    }
}
