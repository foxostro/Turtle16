//
//  VarDeclarationTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/19/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class VarDeclarationTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let foo = Identifier("foo")
        let one = LiteralInt(1)
        XCTAssertNotEqual(
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(.u8),
                expression: one,
                storage: .staticStorage,
                isMutable: true
            ),
            CommentNode(string: "")
        )
    }

    func testDoesNotEqualNodeWithDifferentIdentifier() {
        let foo = Identifier("foo")
        let bar = Identifier("bar")
        let one = LiteralInt(1)
        XCTAssertNotEqual(
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(.u8),
                expression: one,
                storage: .staticStorage,
                isMutable: true
            ),
            VarDeclaration(
                identifier: bar,
                explicitType: PrimitiveType(.u8),
                expression: one,
                storage: .staticStorage,
                isMutable: true
            )
        )
    }

    func testDoesNotEqualNodeWithDifferentStorage() {
        let foo = Identifier("foo")
        let bar = Identifier("bar")
        let one = LiteralInt(1)
        XCTAssertNotEqual(
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(.u8),
                expression: one,
                storage: .staticStorage,
                isMutable: true
            ),
            VarDeclaration(
                identifier: bar,
                explicitType: PrimitiveType(.u8),
                expression: one,
                storage: .automaticStorage,
                isMutable: true
            )
        )
    }

    func testDoesNotEqualNodeWithDifferentMutability() {
        let foo = Identifier("foo")
        let bar = Identifier("bar")
        let one = LiteralInt(1)
        XCTAssertNotEqual(
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(.u8),
                expression: one,
                storage: .staticStorage,
                isMutable: true
            ),
            VarDeclaration(
                identifier: bar,
                explicitType: PrimitiveType(.u8),
                expression: one,
                storage: .staticStorage,
                isMutable: false
            )
        )
    }

    func testDoesNotEqualNodeWithDifferentNumber() {
        let foo = Identifier("foo")
        let one = LiteralInt(1)
        let two = LiteralInt(2)
        XCTAssertNotEqual(
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(.u8),
                expression: one,
                storage: .staticStorage,
                isMutable: true
            ),
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(.u8),
                expression: two,
                storage: .staticStorage,
                isMutable: true
            )
        )
    }

    func testDoesNotEqualNodeWithDifferentExplicitType() {
        let foo = Identifier("foo")
        XCTAssertNotEqual(
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(.u8),
                expression: LiteralInt(1),
                storage: .staticStorage,
                isMutable: true
            ),
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(.u16),
                expression: LiteralInt(1),
                storage: .staticStorage,
                isMutable: true
            )
        )
    }

    func testNodesActuallyAreTheSame() {
        let foo = Identifier("foo")
        XCTAssertEqual(
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(.u8),
                expression: LiteralInt(1),
                storage: .staticStorage,
                isMutable: true
            ),
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(.u8),
                expression: LiteralInt(1),
                storage: .staticStorage,
                isMutable: true
            )
        )
    }

    func testHash() {
        let foo = Identifier("foo")
        XCTAssertNotEqual(
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(.u8),
                expression: LiteralInt(1),
                storage: .staticStorage,
                isMutable: true
            ).hashValue,
            VarDeclaration(
                identifier: foo,
                explicitType: PrimitiveType(.u8),
                expression: LiteralInt(2),
                storage: .staticStorage,
                isMutable: true
            ).hashValue
        )
    }
}
