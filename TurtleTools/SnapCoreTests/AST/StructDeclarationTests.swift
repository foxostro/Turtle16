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

final class StructDeclarationTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(StructDeclaration(identifier: Identifier("foo"), members: []),
                          CommentNode(string: ""))
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        XCTAssertNotEqual(StructDeclaration(identifier: Identifier("foo"),
                                            members: []),
                          StructDeclaration(identifier: Identifier("bar"),
                                            members: []))
    }
    
    func testDoesNotEqualNodeWithDifferentMembers() {
        XCTAssertNotEqual(StructDeclaration(identifier: Identifier("foo"),
                                            members: [StructDeclaration.Member(name: "bar", type: PrimitiveType(.u8))]),
                          StructDeclaration(identifier: Identifier("foo"),
                                            members: [StructDeclaration.Member(name: "bar", type: PrimitiveType(.u16))]))
    }
    
    func testSame() {
        XCTAssertEqual(StructDeclaration(identifier: Identifier("foo"),
                                         members: []),
                       StructDeclaration(identifier: Identifier("foo"),
                                         members: []))
    }
    
    func testHash() {
        XCTAssertEqual(StructDeclaration(identifier: Identifier("foo"),
                                         members: []).hashValue,
                       StructDeclaration(identifier: Identifier("foo"),
                                         members: []).hashValue)
    }
}
