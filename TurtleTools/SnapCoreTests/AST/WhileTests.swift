//
//  WhileTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

final class WhileTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(While(condition: LiteralInt(1),
                                body: CommentNode(string: "")),
                          CommentNode(string: ""))
    }
    
    func testDoesNotEqualNodeWithDifferentCondition() {
        XCTAssertNotEqual(While(condition: LiteralInt(1),
                                body: CommentNode(string: "")),
                          While(condition: LiteralInt(2),
                          body: CommentNode(string: "")))
    }
    
    func testDoesNotEqualNodeWithDifferentBody() {
        XCTAssertNotEqual(While(condition: LiteralInt(1),
                                body: LiteralInt(1)),
                          While(condition: LiteralInt(1),
                                body: CommentNode(string: "")))
    }
    
    func testSame() {
        XCTAssertEqual(While(condition: LiteralInt(1),
                             body: LiteralInt(1)),
                       While(condition: LiteralInt(1),
                             body: LiteralInt(1)))
    }
    
    func testHash() {
        XCTAssertEqual(While(condition: LiteralInt(1),
                             body: LiteralInt(1)).hashValue,
                       While(condition: LiteralInt(1),
                             body: LiteralInt(1)).hashValue)
    }
    
    func testGetters() {
        let stmt = While(condition: LiteralInt(1),
                         body: LiteralInt(2))
        XCTAssertEqual(stmt.condition, LiteralInt(1))
        XCTAssertEqual(stmt.body, LiteralInt(2))
    }
}
