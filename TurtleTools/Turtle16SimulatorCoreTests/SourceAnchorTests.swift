//
//  SourceAnchorTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class SourceAnchorTests: XCTestCase {
    func testNotEqual() throws {
        let lineMapper = SourceLineRangeMapper(text: "test")
        let a1 = lineMapper.anchor(0, 4)
        let a2 = lineMapper.anchor(1, 4)
        XCTAssertNotEqual(a1, a2)
    }
    
    func testEqual() throws {
        let lineMapper = SourceLineRangeMapper(text: "test")
        let a1 = lineMapper.anchor(0, 4)
        let a2 = lineMapper.anchor(0, 4)
        XCTAssertEqual(a1, a2)
    }
    
    func testText() throws {
        let lineMapper = SourceLineRangeMapper(text: "test")
        let a = lineMapper.anchor(0, 4)
        XCTAssertEqual(a.text, "test")
    }
    
    func testLineNumbers() throws {
        let lineMapper = SourceLineRangeMapper(text: "test")
        let a = lineMapper.anchor(0, 4)
        XCTAssertEqual(a.lineNumbers, 0..<1)
    }
    
    func testUnion() throws {
        let lineMapper = SourceLineRangeMapper(text: "test")
        let a1 = lineMapper.anchor(0, 1)
        let a2 = lineMapper.anchor(1, 4)
        let a3 = lineMapper.anchor(0, 4)
        XCTAssertEqual(a1.union(a2), a3)
    }
}
