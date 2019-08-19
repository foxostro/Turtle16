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
}
