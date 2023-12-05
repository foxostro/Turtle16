//
//  ProductTermFuseMapTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 4/5/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleSimulatorCore

class ProductTermFuseMapTests: XCTestCase {
    func testSelectNoFusesSet() throws {
        let map = ProductTermFuseMap(fuseListBitmap: 0b11111111111111111111111111111111111111111111)
        let productTerm = map.evaluate(Array<UInt>(repeating: 0, count: 24))
        XCTAssertEqual(productTerm, Array<UInt>(repeating:1, count: 44))
    }
    
    func testSelectOneTerm_TrueInput() throws {
        let map = ProductTermFuseMap(fuseListBitmap: 0b01111111111111111111111111111111111111111111)
        let productTerm = map.evaluate(Array<UInt>(repeating: 0, count: 24))
        XCTAssertEqual(productTerm, [0, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1])
    }
    
    func testSelectOneTerm_InvInput() throws {
        let map = ProductTermFuseMap(fuseListBitmap: 0b10111111111111111111111111111111111111111111)
        let productTerm = map.evaluate([0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
        XCTAssertEqual(productTerm, [1, 0, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1])
    }
    
    func testSelectTwoTerms() throws {
        let map = ProductTermFuseMap(fuseListBitmap: 0b01110111111111111111111111111111111111111111)
        let productTerm = map.evaluate([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
        XCTAssertEqual(productTerm, [0, 1, 1, 1,
                                     0, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1])
    }
    
    func testSelectUpperTerms() throws {
        let map = ProductTermFuseMap(fuseListBitmap: 0b01111011110111101111111111111111111111111111)
        let productTerm = map.evaluate([0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0])
        XCTAssertEqual(productTerm, [0, 1, 1, 1,
                                     1, 0, 1, 1,
                                     1, 1, 0, 1,
                                     1, 1, 1, 0,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1,
                                     1, 1, 1, 1])
    }
}
