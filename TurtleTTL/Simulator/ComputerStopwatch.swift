//
//  ComputerStopwatch.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/16/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public final class ComputerStopwatch: NSObject {
    fileprivate var internalVumberOfInstructionRetired = 0
    public private(set) var numberOfInstructionRetired: Int {
        get {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            return internalVumberOfInstructionRetired
        }
        set(value) {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            internalVumberOfInstructionRetired = value
        }
    }
    var beginningOfPeriod: CFAbsoluteTime = 0
    let updateInterval = 1.0
    
    public func retireInstructions(count: Int) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        numberOfInstructionRetired += count
    }
    
    public func measure() -> Double {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        let currentTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = currentTime - beginningOfPeriod
        let ips = Double(numberOfInstructionRetired) / elapsedTime
        numberOfInstructionRetired = 0
        beginningOfPeriod = currentTime
        return ips
    }
}
