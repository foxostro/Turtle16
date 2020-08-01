//
//  VarDeclarationTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/19/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class VarDeclarationTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let foo = Expression.Identifier(sourceAnchor: nil, identifier: "foo")
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        XCTAssertNotEqual(VarDeclaration(sourceAnchor: nil,
                                         identifier: foo,
                                         explicitType: .u8,
                                         expression: one,
                                         storage: .staticStorage,
                                         isMutable: true),
                          AbstractSyntaxTreeNode(sourceAnchor: nil))
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        let foo = Expression.Identifier(sourceAnchor: nil, identifier: "foo")
        let bar = Expression.Identifier(sourceAnchor: nil, identifier: "bar")
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        XCTAssertNotEqual(VarDeclaration(sourceAnchor: nil,
                                         identifier: foo,
                                         explicitType: .u8,
                                         expression: one,
                                         storage: .staticStorage,
                                         isMutable: true),
                          VarDeclaration(sourceAnchor: nil,
                                         identifier: bar,
                                         explicitType: .u8,
                                         expression: one,
                                         storage: .staticStorage,
                                         isMutable: true))
    }
    
    func testDoesNotEqualNodeWithDifferentStorage() {
        let foo = Expression.Identifier(sourceAnchor: nil, identifier: "foo")
        let bar = Expression.Identifier(sourceAnchor: nil, identifier: "bar")
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        XCTAssertNotEqual(VarDeclaration(sourceAnchor: nil,
                                         identifier: foo,
                                         explicitType: .u8,
                                         expression: one,
                                         storage: .staticStorage,
                                         isMutable: true),
                          VarDeclaration(sourceAnchor: nil,
                                         identifier: bar,
                                         explicitType: .u8,
                                         expression: one,
                                         storage: .stackStorage,
                                         isMutable: true))
    }
    
    func testDoesNotEqualNodeWithDifferentMutability() {
        let foo = Expression.Identifier(sourceAnchor: nil, identifier: "foo")
        let bar = Expression.Identifier(sourceAnchor: nil, identifier: "bar")
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        XCTAssertNotEqual(VarDeclaration(sourceAnchor: nil,
                                         identifier: foo,
                                         explicitType: .u8,
                                         expression: one,
                                         storage: .staticStorage,
                                         isMutable: true),
                          VarDeclaration(sourceAnchor: nil,
                                         identifier: bar,
                                         explicitType: .u8,
                                         expression: one,
                                         storage: .staticStorage,
                                         isMutable: false))
    }
    
    func testDoesNotEqualNodeWithDifferentNumber() {
        let foo = Expression.Identifier(sourceAnchor: nil, identifier: "foo")
        let one = Expression.LiteralWord(sourceAnchor: nil, value: 1)
        let two = Expression.LiteralWord(sourceAnchor: nil, value: 2)
        XCTAssertNotEqual(VarDeclaration(sourceAnchor: nil,
                                         identifier: foo,
                                         explicitType: .u8,
                                         expression: one,
                                         storage: .staticStorage,
                                         isMutable: true),
                          VarDeclaration(sourceAnchor: nil,
                                         identifier: foo,
                                         explicitType: .u8,
                                         expression: two,
                                         storage: .staticStorage,
                                         isMutable: true))
    }
    
    func testDoesNotEqualNodeWithDifferentExplicitType() {
        let foo = Expression.Identifier(sourceAnchor: nil, identifier: "foo")
        XCTAssertNotEqual(VarDeclaration(sourceAnchor: nil,
                                         identifier: foo,
                                         explicitType: .u8,
                                         expression: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                                   storage: .staticStorage, isMutable: true),
                          VarDeclaration(sourceAnchor: nil,
                                         identifier: foo,
                                         explicitType: .u16,
                                         expression: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                         storage: .staticStorage, isMutable: true))
    }
    
    func testNodesActuallyAreTheSame() {
        let foo = Expression.Identifier(sourceAnchor: nil, identifier: "foo")
        XCTAssertEqual(VarDeclaration(sourceAnchor: nil,
                                      identifier: foo,
                                      explicitType: .u8,
                                      expression: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                      storage: .staticStorage, isMutable: true),
                       VarDeclaration(sourceAnchor: nil,
                                      identifier: foo,
                                      explicitType: .u8,
                                      expression: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                      storage: .staticStorage, isMutable: true))
    }
    
    func testHash() {
        let foo = Expression.Identifier(sourceAnchor: nil, identifier: "foo")
        XCTAssertNotEqual(VarDeclaration(sourceAnchor: nil,
                                         identifier: foo,
                                         explicitType: .u8,
                                         expression: Expression.LiteralWord(sourceAnchor: nil, value: 1),
                                         storage: .staticStorage, isMutable: true).hashValue,
                          VarDeclaration(sourceAnchor: nil,
                                         identifier: foo,
                                         explicitType: .u8,
                                         expression: Expression.LiteralWord(sourceAnchor: nil, value: 2),
                                         storage: .staticStorage, isMutable: true).hashValue)
    }
}
