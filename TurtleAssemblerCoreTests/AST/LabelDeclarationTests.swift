//
//  LabelDeclarationTests.swift
//  TurtleAssemblerCoreTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox
import TurtleAssemblerCore

class LabelDeclarationTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(LabelDeclaration(sourceAnchor: nil, identifier: "label"),
                          AbstractSyntaxTreeNode(sourceAnchor: nil))
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        XCTAssertNotEqual(LabelDeclaration(sourceAnchor: nil, identifier: "foo"),
                          LabelDeclaration(sourceAnchor: nil, identifier: "bar"))
    }
    
    func testEquality() {
        XCTAssertEqual(LabelDeclaration(sourceAnchor: nil, identifier: "foo"),
                       LabelDeclaration(sourceAnchor: nil, identifier: "foo"))
    }
    
    func testHash() {
        XCTAssertEqual(LabelDeclaration(sourceAnchor: nil, identifier: "foo").hashValue,
                       LabelDeclaration(sourceAnchor: nil, identifier: "foo").hashValue)
    }
}
