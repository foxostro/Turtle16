//
//  ProductTermFuseMapTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 4/5/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleSimulatorCore
import XCTest

final class ProductTermFuseMapTests: XCTestCase {
    func testSelectNoFusesSet() throws {
        let map = ProductTermFuseMap(
            fuseListBitmap: 0b1111_11111111_11111111_11111111_11111111_11111111
        )
        let productTerm = map.evaluate([UInt](repeating: 0, count: 24))
        XCTAssertEqual(productTerm, [UInt](repeating: 1, count: 44))
    }

    func testSelectOneTerm_TrueInput() throws {
        let map = ProductTermFuseMap(
            fuseListBitmap: 0b0111_11111111_11111111_11111111_11111111_11111111
        )
        let productTerm = map.evaluate([UInt](repeating: 0, count: 24))
        XCTAssertEqual(
            productTerm,
            [
                0, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
            ]
        )
    }

    func testSelectOneTerm_InvInput() throws {
        let map = ProductTermFuseMap(
            fuseListBitmap: 0b1011_11111111_11111111_11111111_11111111_11111111
        )
        let productTerm = map.evaluate([
            0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        ])
        XCTAssertEqual(
            productTerm,
            [
                1, 0, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
            ]
        )
    }

    func testSelectTwoTerms() throws {
        let map = ProductTermFuseMap(
            fuseListBitmap: 0b0111_01111111_11111111_11111111_11111111_11111111
        )
        let productTerm = map.evaluate([
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        ])
        XCTAssertEqual(
            productTerm,
            [
                0, 1, 1, 1,
                0, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
            ]
        )
    }

    func testSelectUpperTerms() throws {
        let map = ProductTermFuseMap(
            fuseListBitmap: 0b0111_10111101_11101111_11111111_11111111_11111111
        )
        let productTerm = map.evaluate([
            0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0,
        ])
        XCTAssertEqual(
            productTerm,
            [
                0, 1, 1, 1,
                1, 0, 1, 1,
                1, 1, 0, 1,
                1, 1, 1, 0,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 1, 1,
            ]
        )
    }
}
