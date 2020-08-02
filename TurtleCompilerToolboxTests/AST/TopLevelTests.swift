//
//  TopLevelTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 6/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class TopLevelTests: NSObject {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(TopLevel(children: []),
                          AbstractSyntaxTreeNode())
    }
    
    func testDoesNotEqualNodeWithDifferentChildren() {
        XCTAssertNotEqual(TopLevel(children: []),
                          TopLevel(children: [AbstractSyntaxTreeNode()]))
    }
    
    func testSame() {
        XCTAssertEqual(TopLevel(children: [AbstractSyntaxTreeNode()]),
                       TopLevel(children: [AbstractSyntaxTreeNode()]))
    }
    
    func testHash() {
        XCTAssertEqual(TopLevel(children: [AbstractSyntaxTreeNode()]).hash,
                       TopLevel(children: [AbstractSyntaxTreeNode()]).hash)
    }
}
