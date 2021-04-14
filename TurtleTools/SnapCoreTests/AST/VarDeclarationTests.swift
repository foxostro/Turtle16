//
//  VarDeclarationTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/19/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class VarDeclarationTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let foo = Expression.Identifier("foo")
        let one = Expression.LiteralInt(1)
        XCTAssertNotEqual(VarDeclaration(identifier: foo,
                                         explicitType: Expression.PrimitiveType(.u8),
                                         expression: one,
                                         storage: .staticStorage,
                                         isMutable: true),
                          AbstractSyntaxTreeNode())
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        let foo = Expression.Identifier("foo")
        let bar = Expression.Identifier("bar")
        let one = Expression.LiteralInt(1)
        XCTAssertNotEqual(VarDeclaration(identifier: foo,
                                         explicitType: Expression.PrimitiveType(.u8),
                                         expression: one,
                                         storage: .staticStorage,
                                         isMutable: true),
                          VarDeclaration(identifier: bar,
                                         explicitType: Expression.PrimitiveType(.u8),
                                         expression: one,
                                         storage: .staticStorage,
                                         isMutable: true))
    }
    
    func testDoesNotEqualNodeWithDifferentStorage() {
        let foo = Expression.Identifier("foo")
        let bar = Expression.Identifier("bar")
        let one = Expression.LiteralInt(1)
        XCTAssertNotEqual(VarDeclaration(identifier: foo,
                                         explicitType: Expression.PrimitiveType(.u8),
                                         expression: one,
                                         storage: .staticStorage,
                                         isMutable: true),
                          VarDeclaration(identifier: bar,
                                         explicitType: Expression.PrimitiveType(.u8),
                                         expression: one,
                                         storage: .stackStorage,
                                         isMutable: true))
    }
    
    func testDoesNotEqualNodeWithDifferentMutability() {
        let foo = Expression.Identifier("foo")
        let bar = Expression.Identifier("bar")
        let one = Expression.LiteralInt(1)
        XCTAssertNotEqual(VarDeclaration(identifier: foo,
                                         explicitType: Expression.PrimitiveType(.u8),
                                         expression: one,
                                         storage: .staticStorage,
                                         isMutable: true),
                          VarDeclaration(identifier: bar,
                                         explicitType: Expression.PrimitiveType(.u8),
                                         expression: one,
                                         storage: .staticStorage,
                                         isMutable: false))
    }
    
    func testDoesNotEqualNodeWithDifferentNumber() {
        let foo = Expression.Identifier("foo")
        let one = Expression.LiteralInt(1)
        let two = Expression.LiteralInt(2)
        XCTAssertNotEqual(VarDeclaration(identifier: foo,
                                         explicitType: Expression.PrimitiveType(.u8),
                                         expression: one,
                                         storage: .staticStorage,
                                         isMutable: true),
                          VarDeclaration(identifier: foo,
                                         explicitType: Expression.PrimitiveType(.u8),
                                         expression: two,
                                         storage: .staticStorage,
                                         isMutable: true))
    }
    
    func testDoesNotEqualNodeWithDifferentExplicitType() {
        let foo = Expression.Identifier("foo")
        XCTAssertNotEqual(VarDeclaration(identifier: foo,
                                         explicitType: Expression.PrimitiveType(.u8),
                                         expression: Expression.LiteralInt(1),
                                                   storage: .staticStorage, isMutable: true),
                          VarDeclaration(identifier: foo,
                                         explicitType: Expression.PrimitiveType(.u16),
                                         expression: Expression.LiteralInt(1),
                                         storage: .staticStorage, isMutable: true))
    }
    
    func testNodesActuallyAreTheSame() {
        let foo = Expression.Identifier("foo")
        XCTAssertEqual(VarDeclaration(identifier: foo,
                                      explicitType: Expression.PrimitiveType(.u8),
                                      expression: Expression.LiteralInt(1),
                                      storage: .staticStorage, isMutable: true),
                       VarDeclaration(identifier: foo,
                                      explicitType: Expression.PrimitiveType(.u8),
                                      expression: Expression.LiteralInt(1),
                                      storage: .staticStorage, isMutable: true))
    }
    
    func testHash() {
        let foo = Expression.Identifier("foo")
        XCTAssertNotEqual(VarDeclaration(identifier: foo,
                                         explicitType: Expression.PrimitiveType(.u8),
                                         expression: Expression.LiteralInt(1),
                                         storage: .staticStorage, isMutable: true).hashValue,
                          VarDeclaration(identifier: foo,
                                         explicitType: Expression.PrimitiveType(.u8),
                                         expression: Expression.LiteralInt(2),
                                         storage: .staticStorage, isMutable: true).hashValue)
    }
}
