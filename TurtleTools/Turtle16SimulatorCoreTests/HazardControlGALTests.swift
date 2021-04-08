//
//  HazardControlGALTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 4/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class HazardControlGALTests: HazardControlMockupTests {
    public override func makeHazardControl() -> HazardControl {
        return HazardControlGAL()
    }
}
