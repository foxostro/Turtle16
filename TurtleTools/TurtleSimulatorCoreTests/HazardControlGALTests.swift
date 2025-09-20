//
//  HazardControlGALTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 4/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleSimulatorCore
import XCTest

final class HazardControlGALTests: HazardControlMockupTests {
    override func makeHazardControl() -> HazardControl {
        HazardControlGAL()
    }
}
