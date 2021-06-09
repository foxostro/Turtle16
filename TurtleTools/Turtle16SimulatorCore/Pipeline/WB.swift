//
//  WB.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 12/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

// Models the WB (write back) stage of the Turtle16 pipeline.
// Please refer to WB.sch for details.
// Classes in the simulator intentionally model specific pieces of hardware,
// following naming conventions and organization that matches the schematics.
public class WB: NSObject {
    public var associatedPC: UInt16? = nil
    
    public struct Input {
        public let y: UInt16
        public let storeOp: UInt16
        public let ctl: UInt
        public let associatedPC: UInt16?
        
        public init(ctl: UInt) {
            self.y = 0
            self.storeOp = 0
            self.ctl = ctl
            self.associatedPC = nil
        }
        
        public init(y: UInt16, storeOp: UInt16, ctl: UInt, associatedPC: UInt16? = nil) {
            self.y = y
            self.storeOp = storeOp
            self.ctl = ctl
            self.associatedPC = associatedPC
        }
    }
    
    public struct Output {
        public let c: UInt16
        public let wrl: UInt
        public let wrh: UInt
        public let wben: UInt
        
        public init(c: UInt16, wrl: UInt, wrh: UInt, wben: UInt) {
            self.c = c
            self.wrl = wrl
            self.wrh = wrh
            self.wben = wben
        }
        
        public var description: String {
            return "c: \(String(format: "%04x", c)), wrl: \(wrl), wrh: \(wrh), wben: \(wben)"
        }
    }
    
    public func step(input: Input) -> Output {
        let writeBackSrc = UInt((input.ctl >> 17) & 1)
        let c = (writeBackSrc == 0) ? input.y : input.storeOp
        let wrl: UInt = UInt((input.ctl >> 18) & 1)
        let wrh: UInt = UInt((input.ctl >> 19) & 1)
        let wben: UInt = UInt((input.ctl >> 20) & 1)
        associatedPC = input.associatedPC
        return Output(c: c, wrl: wrl, wrh: wrh, wben: wben)
    }
}
