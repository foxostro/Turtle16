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
        driver.run()
        XCTAssertEqual(driver.status, 1)
    }
}
