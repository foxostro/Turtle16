//
//  TopLevelTests.swift
//  TurtleCoreTests
//
//  Created by Andrew Fox on 6/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore

class TopLevelTests: NSObject {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(TopLevel(children: []),
                          CommentNode(string: ""))
    }
    
    func testDoesNotEqualNodeWithDifferentChildren() {
        XCTAssertNotEqual(TopLevel(children: []),
                          TopLevel(children: [CommentNode(string: "")]))
    }
    
    func testSame() {
        XCTAssertEqual(TopLevel(children: [CommentNode(string: "")]),
                       TopLevel(children: [CommentNode(string: "")]))
    }
    
    func testHash() {
        XCTAssertEqual(TopLevel(children: [CommentNode(string: "")]).hash,
                       TopLevel(children: [CommentNode(string: "")]).hash)
    }
}
