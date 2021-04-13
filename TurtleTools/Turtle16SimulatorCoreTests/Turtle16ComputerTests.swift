//
//  Turtle16ComputerTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class Turtle16ComputerTests: XCTestCase {
    func testExample() throws {
        let cpu = SchematicLevelCPUModel()
        let _ = Turtle16Computer(cpu)
    }
}
