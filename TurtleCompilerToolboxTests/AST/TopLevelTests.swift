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
        XCTAssertNotEqual(TopLevel(sourceAnchor: nil, children: []),
                          AbstractSyntaxTreeNode(sourceAnchor: nil))
    }
    
    func testDoesNotEqualNodeWithDifferentChildren() {
        XCTAssertNotEqual(TopLevel(sourceAnchor: nil, children: []),
                          TopLevel(sourceAnchor: nil, children: [AbstractSyntaxTreeNode(sourceAnchor: nil)]))
    }
    
    func testSame() {
        XCTAssertEqual(TopLevel(sourceAnchor: nil, children: [AbstractSyntaxTreeNode(sourceAnchor: nil)]),
                       TopLevel(sourceAnchor: nil, children: [AbstractSyntaxTreeNode(sourceAnchor: nil)]))
    }
    
    func testHash() {
        XCTAssertEqual(TopLevel(sourceAnchor: nil, children: [AbstractSyntaxTreeNode(sourceAnchor: nil)]).hash,
                       TopLevel(sourceAnchor: nil, children: [AbstractSyntaxTreeNode(sourceAnchor: nil)]).hash)
    }
}
