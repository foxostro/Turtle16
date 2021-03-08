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
        public let y: UInt16
        public let jabs: UInt
        public let j: UInt
        public let rst: UInt
        
        public init(y: UInt16, jabs: UInt, j: UInt, rst: UInt) {
            self.y = y
            self.jabs = jabs
            self.j = j
            self.rst = rst
        }
    }
    
    public struct Output {
        public let ins: UInt16
        public let pc: UInt16
        
        public init(ins: UInt16, pc: UInt16) {
            self.ins = ins
            self.pc = pc
        }
    }
    
    public var alu = IDT7831()
    public var prevOutput: UInt16 = 0
    
    public var load: (UInt16) -> UInt16 = {(addr: UInt16) in
        return 0xffff // bogus
    }
    
    public func step(input: Input) -> Output {
        let aluOutput = alu.step(input: driveALU(input: input))
        let pc = aluOutput.f!
        let ins = load(pc)
        prevOutput = pc
        return Output(ins: ins, pc: pc)
    }
    
    public func driveALU(input: Input) -> IDT7831.Input {
        // The ALU control logic is written in this awkward way so that there is
        // a close correspondence between this simulator code and the HDL used
        // for U73, an ATF22V10.
        let c0: UInt = input.j & 1
        let i2: UInt = 0
        let i1: UInt = input.rst & 1
        let i0: UInt = input.rst & 1
        let rs1: UInt = ~input.j & 1
        let rs0: UInt = input.jabs & 1
        
        let aluInput = IDT7831.Input(a: prevOutput,
                                     b: input.y,
                                     c0: c0,
                                     i0: i0,
                                     i1: i1,
                                     i2: i2,
                                     rs0: rs0,
                                     rs1: rs1,
                                     ena: 0,
                                     enb: 0,
                                     enf: 1,
                                     ftab: 0,
                                     ftf: 1,
                                     oe: 0)
        return aluInput
    }
}
