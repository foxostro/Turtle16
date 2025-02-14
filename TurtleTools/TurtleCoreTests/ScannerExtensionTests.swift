//
//  ScannerExtensionTests.swift
//  TurtleCoreTests
//
//  Created by Andrew Fox on 5/16/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore

final class ScannerExtensionTests: XCTestCase {
    func testFailToScanBinaryIntFromEmptyString() {
        let scanner = Scanner(string: "")
        var number = -1
        XCTAssertFalse(scanner.scanBinaryInt(&number))
    }
    
    func testFailToScanInvalidCharacter() {
        let scanner = Scanner(string: "@")
        var number = -1
        XCTAssertFalse(scanner.scanBinaryInt(&number))
    }
    
    func testScanAOne() {
        let scanner = Scanner(string: "1")
        var number = -1
        XCTAssertTrue(scanner.scanBinaryInt(&number))
        XCTAssertEqual(number, 1)
    }
    
    func testScanAZero() {
        let scanner = Scanner(string: "0")
        var number = -1
        XCTAssertTrue(scanner.scanBinaryInt(&number))
        XCTAssertEqual(number, 0)
    }
    
    func testScanWith0bPrefix() {
        let scanner = Scanner(string: "0b0")
        var number = -1
        XCTAssertTrue(scanner.scanBinaryInt(&number))
        XCTAssertEqual(number, 0)
    }
    
    func testScanMultipleDigits() {
        let scanner = Scanner(string: "0b100")
        var number = -1
        XCTAssertTrue(scanner.scanBinaryInt(&number))
        XCTAssertEqual(number, 4)
    }
    
    func testScanOverflow() {
        let scanner = Scanner(string: "0b10000000000000000000000000000000000000000000000000000000000000000")
        var number = -1
        XCTAssertTrue(scanner.scanBinaryInt(&number))
        XCTAssertEqual(number, Int.max)
    }
}
