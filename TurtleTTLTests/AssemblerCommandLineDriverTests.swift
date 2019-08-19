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
    
    func testCompileProgramConsistingOfOneNOP() {
        let fileNameIn = FileManager.default.temporaryDirectory.appendingPathComponent(NSUUID().uuidString).path
        FileManager.default.createFile(atPath: fileNameIn,
                                       contents: "\n".data(using: .utf8),
                                       attributes: nil)
        defer {
            try? FileManager.default.removeItem(atPath: fileNameIn)
        }
        let urlOut = FileManager.default.temporaryDirectory.appendingPathComponent(NSUUID().uuidString + ".program")
        let upperDataUrl = urlOut.appendingPathComponent("Upper Instruction ROM.bin")
        let lowerDataUrl = urlOut.appendingPathComponent("Lower Instruction ROM.bin")
        let fileNameOut = urlOut.path
        defer {
            try? FileManager.default.removeItem(at: urlOut)
        }
        let driver = AssemblerCommandLineDriver(withArguments: ["", fileNameIn, fileNameOut])
        driver.run()
        XCTAssertEqual(driver.status, 0)
        
        XCTAssertEqual(fileNameIn, driver.inputFileName?.path)
        XCTAssertEqual(fileNameOut, driver.outputFileName?.path)
        var isDirectory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileNameOut, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
        
        isDirectory = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: upperDataUrl.path, isDirectory: &isDirectory))
        XCTAssertFalse(isDirectory.boolValue)
        let upperData = try! Data(contentsOf: upperDataUrl)
        
        isDirectory = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: lowerDataUrl.path, isDirectory: &isDirectory))
        XCTAssertFalse(isDirectory.boolValue)
        let lowerData = try! Data(contentsOf: lowerDataUrl)
        
        // Now unpack the first instruction. Is it the NOP that we expected?
        let instructionROM = InstructionROM(withUpperROM: Memory(withData: upperData),
                                            withLowerROM: Memory(withData: lowerData))
        let instruction = instructionROM.load(from: 0)
        XCTAssert(instruction == Instruction(opcode: 0, immediate: 0))
        XCTAssertEqual(instruction.value, 0)
    }
}
