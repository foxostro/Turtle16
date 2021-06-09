//
//  IF.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 12/23/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

// Models the IF (instruction fetch) stage of the Turtle16 pipeline.
// Please refer to IF.sch for details.
// Classes in the simulator intentionally model specific pieces of hardware,
// following naming conventions and organization that matches the schematics.
public class IF: NSObject {
    public struct Input {
        public let stall: UInt
        public let y: UInt16
        public let jabs: UInt
        public let j: UInt
        public let rst: UInt
        
        public init(stall: UInt, y: UInt16, jabs: UInt, j: UInt, rst: UInt) {
            self.stall = stall
            self.y = y
            self.jabs = jabs
            self.j = j
            self.rst = rst
        }
    }
    
    public struct Output {
        public let ins: UInt16
        public let pc: UInt16
        public let associatedPC: UInt16?
        
        public init(ins: UInt16, pc: UInt16, associatedPC: UInt16? = nil) {
            self.ins = ins
            self.pc = pc
            self.associatedPC = associatedPC
        }
        
        public var description: String {
            let strIns = String(format: "%04x", ins)
            let strPC = String(format: "%04x", pc)
            return "ins: \(strIns), pc: \(strPC)"
        }
    }
    
    public var alu = IDT7831()
    public var prevPC: UInt16 = 0
    public var prevIns: UInt16 = 0
    public var prevAssociatedPC: UInt16? = nil
    public var associatedPC: UInt16? = nil
    
    public var load: (UInt16) -> UInt16 = {(addr: UInt16) in
        return 0xffff // bogus
    }
    
    public func step(input: Input) -> Output {
        // The ALU's F register updates on the clock so the IF stage takes two
        // clock cycles to complete.
        let aluOutput = alu.step(input: driveALU(input: input))
        let pc = (input.stall==0) ? aluOutput.f! : prevPC
        let nextIns = (input.j==0) ? 0 : load(prevPC)
        let ins = (input.stall==0) ? nextIns : prevIns
        
        if input.j == 0 {
            associatedPC = nil
        }
        else if input.stall == 1 {
            associatedPC = prevAssociatedPC
        }
        else {
            associatedPC = prevPC
        }
        
        prevPC = pc
        prevIns = ins
        prevAssociatedPC = associatedPC
        return Output(ins: ins, pc: pc, associatedPC: associatedPC)
    }
    
    public func driveALU(input: Input) -> IDT7831.Input {
        let aluInput = IDT7831.Input(a: prevPC,
                                     b: input.y,
                                     c0: input.j & 1,
                                     i0: input.rst & 1,
                                     i1: input.rst & 1,
                                     i2: 0,
                                     rs0: input.jabs & 1,
                                     rs1: ~input.j & 1,
                                     ena: 0,
                                     enb: 0,
                                     enf: input.stall & 1,
                                     ftab: 0,
                                     ftf: 1,
                                     oe: 0)
        return aluInput
    }
}
