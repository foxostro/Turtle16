//
//  CompilerPassEraseConstTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/13/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassEraseConstTests: XCTestCase {
    func testNoOp() throws {
        let input = Block(
            children: [
                LiteralInt(0)
            ]
        )
        let actual = try input.eraseConst()
        let expected = input
        XCTAssertEqual(actual, expected)
    }

    func testEraseConstType() throws {
        let expected = Block(
            children: [
                PrimitiveType(.u16)
            ]
        )
        let input = Block(
            children: [
                ConstType(PrimitiveType(.u16))
            ]
        )
        let actual = try input.eraseConst()
        XCTAssertEqual(actual, expected)
    }

    /// Rewrite all `PrimitiveType` nodes to remove all const-ness.
    /// Note that `PrimitiveType` is perhaps poorly named. The class allows a
    /// type which is represented by a value of `SymbolType` to be placed in an
    /// expression. See also `SymbolType.lift`
    func testEraseConstFromPrimitiveType_constU16() throws {
        let expected = Block(
            children: [
                PrimitiveType(.u16)
            ]
        )
        let input = Block(
            children: [
                PrimitiveType(.constU16)
            ]
        )
        let actual = try input.eraseConst()
        XCTAssertEqual(actual, expected)
    }

    /// Ensure we can erase const from inner types contained within SymbolType
    func testEraseConstFromPrimitiveType_pointerToConst() throws {
        let expected = Block(
            children: [
                PrimitiveType(.pointer(.u16))
            ]
        )
        let input = Block(
            children: [
                PrimitiveType(.constPointer(.constU16))
            ]
        )
        let actual = try input.eraseConst()
        XCTAssertEqual(actual, expected)
    }

    /// Ensure we can erase const from inner types contained within SymbolType
    func testEraseConstFromPrimitiveType_struct() throws {
        let expected = Block(
            children: [
                PrimitiveType(
                    .structType(
                        StructTypeInfo(
                            name: "Foo",
                            fields: Env(
                                frameLookupMode: .set(Frame()),
                                tuples: [
                                    ("value", Symbol(type: .pointer(.u16), offset: 0))
                                ]
                            )
                        )
                    )
                )
            ]
        )
        let input = Block(
            children: [
                PrimitiveType(
                    .constStructType(
                        StructTypeInfo(
                            name: "Foo",
                            fields: Env(
                                frameLookupMode: .set(Frame()),
                                tuples: [
                                    ("value", Symbol(type: .constPointer(.constU16), offset: 0))
                                ]
                            )
                        )
                    )
                )
            ]
        )
        let actual = try input.eraseConst()
        XCTAssertEqual(actual, expected)
    }
}
