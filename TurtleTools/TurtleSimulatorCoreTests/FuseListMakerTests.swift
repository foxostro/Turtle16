//
//  FuseListMakerTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 4/6/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleSimulatorCore

final class FuseListMakerTests: XCTestCase {
    func testEmptyFuseList() throws {
        let maker = FuseListMaker()
        XCTAssertEqual(maker.fuseList, [])
        XCTAssertEqual(maker.numberOfFuses, 0)
    }
    
    func testSetNumberOfFuses_MakeLarger() throws {
        let maker = FuseListMaker()
        maker.numberOfFuses = 100
        XCTAssertEqual(maker.fuseList, Array<UInt>(repeating: 0, count: 100))
        XCTAssertEqual(maker.numberOfFuses, 100)
    }
    
    func testSetNumberOfFuses_MakeSmaller() throws {
        let maker = FuseListMaker()
        maker.numberOfFuses = 100
        maker.numberOfFuses = 1
        XCTAssertEqual(maker.fuseList, Array<UInt>(repeating: 0, count: 1))
        XCTAssertEqual(maker.numberOfFuses, 1)
    }
    
    func testSetDefaultFuseState() throws {
        let maker = FuseListMaker()
        maker.defaultFuseState = 1
        maker.numberOfFuses = 100
        XCTAssertEqual(maker.fuseList, Array<UInt>(repeating: 1, count: 100))
        XCTAssertEqual(maker.numberOfFuses, 100)
    }
    
    func testSetFusesAtIndexZeroWithEmptyList() throws {
        let maker = FuseListMaker()
        maker.set(begin: 0, array: [])
        XCTAssertEqual(maker.fuseList, [])
    }
    
    func testSetFusesWithFuseList() throws {
        let maker = FuseListMaker()
        maker.numberOfFuses = 10
        maker.set(begin: 7, array: [1, 1, 1])
        XCTAssertEqual(maker.fuseList, [0, 0, 0, 0, 0, 0, 0, 1, 1, 1])
    }
    
    func testSetFusesWithBitmap() throws {
        let maker = FuseListMaker()
        maker.numberOfFuses = 10
        maker.set(begin: 7, bitmap: "111")
        XCTAssertEqual(maker.fuseList, [0, 0, 0, 0, 0, 0, 0, 1, 1, 1])
    }
}
