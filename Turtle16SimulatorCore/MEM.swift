//
//  MEM.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 12/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

// Models the MEM (memory) stage of the Turtle16 pipeline.
// Please refer to MEM.sch for details.
// Classes in the simulator intentionally model specific pieces of hardware,
// following naming conventions and organization that matches the schematics.
public class MEM: NSObject {
    public struct Input {
        public let rdy: UInt
        public let y: UInt16
        public let storeOp: UInt16
        public let selC: UInt
        public let ctl: UInt32
        
        public init(rdy: UInt, y: UInt16, storeOp: UInt16, selC: UInt, ctl: UInt32) {
            self.rdy = rdy
            self.y = y
            self.storeOp = storeOp
            self.selC = selC
            self.ctl = ctl
        }
    }
    
    public struct Output {
        public let y: UInt16
        public let storeOp: UInt16
        public let selC: UInt
        public let ctl: UInt32
    }
    
    public var load: (UInt16) -> UInt16 = {(addr: UInt16) in
        return 0 // do nothing
    }
    
    public var store: (UInt16, UInt16) -> Void = {(value: UInt16, addr: UInt16) in
        // do nothing
    }
    
    public func step(input: Input) -> Output {
        var storeOp: UInt16 = 0
        if input.rdy == 0 {
            let isLoad = UInt((input.ctl >> 14) & 1) == 0
            let isStore = UInt((input.ctl >> 15) & 1) == 0
            let isAssertingStoreOp = UInt((input.ctl >> 16) & 1) == 0
            if isAssertingStoreOp {
                storeOp = input.storeOp
            }
            if isStore {
                store(storeOp, input.y)
            }
            if isLoad {
                assert(!isAssertingStoreOp)
                storeOp = load(input.y)
            }
        }
        return Output(y: input.y, storeOp: storeOp, selC: input.selC, ctl: input.ctl)
    }
}
