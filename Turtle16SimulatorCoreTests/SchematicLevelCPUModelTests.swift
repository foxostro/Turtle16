//
//  SchematicLevelCPUModelTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 12/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class SchematicLevelCPUModelTests: XCTestCase {
    func testExample() throws {
        let cpu = SchematicLevelCPUModel()
        cpu.step()
    }
}
