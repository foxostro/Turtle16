//
//  AssemblerCommandLineDriverTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/1/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class AssemblerCommandLineDriverTests: XCTestCase {
    func testParseArgumentsFailsWithNoArguments() {
        let driver = AssemblerCommandLineDriver(withArguments: [])
        XCTAssertThrowsError(try driver.parseArguments())
    }
    
    func testParseArgumentsFailsWithOneArgument() {
        let driver = AssemblerCommandLineDriver(withArguments: [""])
        XCTAssertThrowsError(try driver.parseArguments())
    }
    
    func testParseArgumentsFailsWithTwoArguments() {
        let driver = AssemblerCommandLineDriver(withArguments: ["", ""])
        XCTAssertThrowsError(try driver.parseArguments())
    }
    
    func testParseArgumentsFailsWithThreeEmptyArguments() {
        let driver = AssemblerCommandLineDriver(withArguments: ["", "", ""])
        XCTAssertThrowsError(try driver.parseArguments())
    }
    
    func testParseArgumentsFailsWhenInputFileIsMissing() {
        let fileNameIn = FileManager.default.temporaryDirectory.appendingPathComponent(NSUUID().uuidString).path
        let fileNameOut = FileManager.default.temporaryDirectory.appendingPathComponent(NSUUID().uuidString + ".program").path
        let driver = AssemblerCommandLineDriver(withArguments: ["", fileNameIn, fileNameOut])
        XCTAssertThrowsError(try driver.parseArguments())
        XCTAssertEqual(fileNameIn, driver.inputFileName?.path)
    }
    
    func testParseArgumentsSucceedsWhenFilenamesAreValidAndPresent() {
        let fileNameIn = FileManager.default.temporaryDirectory.appendingPathComponent(NSUUID().uuidString).path
        FileManager.default.createFile(atPath: fileNameIn, contents: Data(), attributes: nil)
        defer {
            try? FileManager.default.removeItem(atPath: fileNameIn)
        }
        let fileNameOut = FileManager.default.temporaryDirectory.appendingPathComponent(NSUUID().uuidString + ".program").path
        let driver = AssemblerCommandLineDriver(withArguments: ["", fileNameIn, fileNameOut])
        try! driver.parseArguments()
        XCTAssertEqual(fileNameIn, driver.inputFileName?.path)
        XCTAssertEqual(fileNameOut, driver.outputFileName?.path)
    }
}
