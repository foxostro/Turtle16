//
//  ScannerExtensionsTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class ScannerExtensionsTests: XCTestCase {
    func testScanEmptyString() throws {
        let scanner = Scanner(string: "")
        var number = 0
        let result = scanner.scanBinaryInt(&number)
        XCTAssertFalse(result)
    }
    
    func testScanSomethingThatsNotABinaryNumber() throws {
        let scanner = Scanner(string: "54321")
        var number = 0
        let result = scanner.scanBinaryInt(&number)
        XCTAssertFalse(result)
    }
    
    func testScanBinaryNumber() throws {
        let scanner = Scanner(string: "1")
        var number = 0
        let result = scanner.scanBinaryInt(&number)
        XCTAssertTrue(result)
        XCTAssertEqual(number, 1)
    }
}
