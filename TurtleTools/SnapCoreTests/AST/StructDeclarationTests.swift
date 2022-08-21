//
//  StructDeclarationTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/6/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class StructDeclarationTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(StructDeclaration(identifier: Expression.Identifier("foo"), members: []),
                          CommentNode(string: ""))
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        XCTAssertNotEqual(StructDeclaration(identifier: Expression.Identifier("foo"),
                                            members: []),
                          StructDeclaration(identifier: Expression.Identifier("bar"),
                                            members: []))
    }
    
    func testDoesNotEqualNodeWithDifferentMembers() {
        XCTAssertNotEqual(StructDeclaration(identifier: Expression.Identifier("foo"),
                                            members: [StructDeclaration.Member(name: "bar", type: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u8))))]),
                          StructDeclaration(identifier: Expression.Identifier("foo"),
                                            members: [StructDeclaration.Member(name: "bar", type: Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))))]))
    }
    
    func testSame() {
        XCTAssertEqual(StructDeclaration(identifier: Expression.Identifier("foo"),
                                         members: []),
                       StructDeclaration(identifier: Expression.Identifier("foo"),
                                         members: []))
    }
    
    func testHash() {
        XCTAssertEqual(StructDeclaration(identifier: Expression.Identifier("foo"),
                                         members: []).hash,
                       StructDeclaration(identifier: Expression.Identifier("foo"),
                                         members: []).hash)
    }
}
