//
//  StructDeclarationTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/6/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class StructDeclarationTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(StructDeclaration(identifier: Expression.Identifier("foo")),
                          AbstractSyntaxTreeNode())
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        XCTAssertNotEqual(StructDeclaration(identifier: Expression.Identifier("foo")),
                          StructDeclaration(identifier: Expression.Identifier("bar")))
    }
    
    func testSame() {
        XCTAssertEqual(StructDeclaration(identifier: Expression.Identifier("foo")),
                       StructDeclaration(identifier: Expression.Identifier("foo")))
    }
    
    func testHash() {
        XCTAssertEqual(StructDeclaration(identifier: Expression.Identifier("foo")).hash,
                       StructDeclaration(identifier: Expression.Identifier("foo")).hash)
    }
}
