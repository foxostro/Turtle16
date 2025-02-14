//
//  HazardControlGALTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 4/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleSimulatorCore

final class HazardControlGALTests: HazardControlMockupTests {
    public override func makeHazardControl() -> HazardControl {
        HazardControlGAL()
    }
}
