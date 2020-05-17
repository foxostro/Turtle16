//
//  TraceProfiler.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class TraceProfiler: NSObject {
    let threshold = 3
    public private(set) var hits: [UInt16:Int] = [:]
    
    public func reset() {
        hits = [:]
    }
    
    public func hit(pc: UInt16) -> Bool {
        if let currentCount = hits[pc] {
            let newCount = currentCount + 1
            hits[pc] = newCount
            return newCount == threshold
        } else {
            hits[pc] = 1
            return false
        }
    }
    
    public func isHot(pc: UInt16) -> Bool {
        if let currentCount = hits[pc] {
            return currentCount >= threshold
        } else {
            return false
        }
    }
}
