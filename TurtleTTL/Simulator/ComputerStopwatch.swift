//
//  ComputerStopwatch.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/16/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

class ComputerStopwatch: NSObject {
    var instructionRetired = 0
    var beginningOfPeriod = Date.distantPast
    
    public func reset() {
        instructionRetired = 0
        beginningOfPeriod = Date()
    }
    
    public func retireInstructions(_ numberOfInstructions: Int) {
        instructionRetired += numberOfInstructions
    }
    
    public func measure() -> Double {
        let elapsedTime = Date().timeIntervalSince(beginningOfPeriod)
        let ips = Double(instructionRetired) / elapsedTime
        reset()
        return ips
    }
}
