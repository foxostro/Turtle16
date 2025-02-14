//
//  LabelDeclarationTests.swift
//  TurtleCoreTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore

final class LabelDeclarationTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(LabelDeclaration(identifier: "label"),
                          CommentNode(string: ""))
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        XCTAssertNotEqual(LabelDeclaration(identifier: "foo"),
                          LabelDeclaration(identifier: "bar"))
    }
    
    func testEquality() {
        XCTAssertEqual(LabelDeclaration(identifier: "foo"),
                       LabelDeclaration(identifier: "foo"))
    }
    
    func testHash() {
        XCTAssertEqual(LabelDeclaration(identifier: "foo").hashValue,
                       LabelDeclaration(identifier: "foo").hashValue)
    }
}
