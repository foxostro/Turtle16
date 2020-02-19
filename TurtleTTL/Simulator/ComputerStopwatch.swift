//
//  ComputerStopwatch.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/16/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

final class ComputerStopwatch: NSObject {
    var numberOfInstructionRetired = 0
    var beginningOfPeriod: CFAbsoluteTime = 0
    let updateInterval = 1.0
    
    public func retireInstructions(count: Int) {
        numberOfInstructionRetired += count
    }
    
    public func tick(block: (Double)->Void) {
        let currentTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = currentTime - beginningOfPeriod
        if elapsedTime > updateInterval {
            let ips = Double(numberOfInstructionRetired) / elapsedTime
            block(ips)
            numberOfInstructionRetired = 0
            beginningOfPeriod = currentTime
        }
    }
}
