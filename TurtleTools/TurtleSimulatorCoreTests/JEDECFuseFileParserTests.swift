//
//  JEDECFuseFileParserTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 4/6/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleSimulatorCore

final class JEDECFuseFileParserTests: XCTestCase {
    func testParserEmptyString() throws {
        let maker = FuseListMaker()
        let parser = JEDECFuseFileParser(maker)
        parser.parse("")
        XCTAssertEqual(maker.fuseList, [])
    }
    
    func testParserHeader() throws {
        let maker = FuseListMaker()
        let parser = JEDECFuseFileParser(maker)
        parser.parse("something*")
        XCTAssertEqual(maker.fuseList, [])
    }
    
    func testParserSetNumberOfFuses() throws {
        let maker = FuseListMaker()
        let parser = JEDECFuseFileParser(maker)
        parser.parse("*QF100")
        XCTAssertEqual(maker.numberOfFuses, 100)
    }
    
    func testParserSetFuses() throws {
        let maker = FuseListMaker()
        maker.numberOfFuses = 100
        let parser = JEDECFuseFileParser(maker)
        parser.parse("*L0000 1")
        XCTAssertEqual(maker.numberOfFuses, 100)
        XCTAssertEqual(maker.fuseList, [1] + Array<UInt>(repeating: 0, count: 99))
    }
    
    func testParserSetSeveralFuses() throws {
        let maker = FuseListMaker()
        maker.numberOfFuses = 100
        let parser = JEDECFuseFileParser(maker)
        parser.parse("*L0000 10101")
        XCTAssertEqual(maker.numberOfFuses, 100)
        XCTAssertEqual(maker.fuseList, [1, 0, 1, 0, 1] + Array<UInt>(repeating: 0, count: 95))
    }
}
