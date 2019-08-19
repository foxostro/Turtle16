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
    func testInitWithNoArguments() {
        let driver = AssemblerCommandLineDriver(withArguments: [])
        driver.stdout = String()
        driver.stderr = String()
        driver.run()
        XCTAssertEqual(driver.status, 1)
        XCTAssertNotEqual(driver.stderr as! String, "")
        XCTAssertTrue((driver.stderr as! String).contains("Error"))
    }
    
    func testInitWithOneArgument() {
        let driver = AssemblerCommandLineDriver(withArguments: [""])
        driver.stdout = String()
        driver.stderr = String()
        driver.run()
        XCTAssertEqual(driver.status, 1)
        XCTAssertNotEqual(driver.stderr as! String, "")
        XCTAssertTrue((driver.stderr as! String).contains("Error"))
    }
    
    func testInitWithTwoArguments() {
        let driver = AssemblerCommandLineDriver(withArguments: ["", ""])
        driver.stdout = String()
        driver.stderr = String()
        driver.run()
        XCTAssertEqual(driver.status, 1)
        XCTAssertNotEqual(driver.stderr as! String, "")
        XCTAssertTrue((driver.stderr as! String).contains("Error"))
    }
    
    func testInitWithThreeArguments() {
        let driver = AssemblerCommandLineDriver(withArguments: ["", "", ""])
        driver.stdout = String()
        driver.stderr = String()
        driver.run()
        XCTAssertEqual(driver.status, 0)
        XCTAssertEqual(driver.stderr as! String, "")
    }
}
