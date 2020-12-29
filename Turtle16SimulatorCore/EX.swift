//
//  EX.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 12/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

// Models the EX (execute) stage of the Turtle16 pipeline.
// Please refer to EX.sch for details.
// Classes in the simulator intentionally model specific pieces of hardware,
// following naming conventions and organization that matches the schematics.
public class EX: NSObject {
    public struct Input {
        public let pc: UInt16
        public let ctl: UInt
        public let a: UInt16
        public let b: UInt16
        public let ins: UInt
        
        public init(ins: UInt) {
            self.pc = 0
            self.ctl = 0
            self.a = 0
            self.b = 0
            self.ins = ins
        }
        
        public init(ins: UInt, b: UInt16, ctl: UInt) {
            self.pc = 0
            self.ctl = ctl
            self.a = 0
            self.b = b
            self.ins = ins
        }
        
        public init(ins: UInt, b: UInt16, pc: UInt16, ctl: UInt) {
            self.pc = pc
            self.ctl = ctl
            self.a = 0
            self.b = b
            self.ins = ins
        }
        
        public init(ctl: UInt) {
            self.pc = 0
            self.ctl = ctl
            self.a = 0
            self.b = 0
            self.ins = 0
        }
        
        public init(a: UInt16, b: UInt16, ctl: UInt) {
            self.pc = 0
            self.ctl = ctl
            self.a = a
            self.b = b
            self.ins = 0
        }
    }
    
    public struct Output {
        public let carry: UInt
        public let z: UInt
        public let ovf: UInt
        public let j: UInt
        public let jabs: UInt
        public let y: UInt16
        public let hlt: UInt
        public let storeOp: UInt16
        public let ctl: UInt
        public let selC: UInt
    }
    
    public func step(input: Input) -> Output {
        let c0 = (input.ctl >> 6) & 1
        let i0 = (input.ctl >> 7) & 1
        let i1 = (input.ctl >> 8) & 1
        let i2 = (input.ctl >> 9) & 1
        let rs0 = (input.ctl >> 10) & 1
        let rs1 = (input.ctl >> 11) & 1
        let j = (input.ctl >> 12) & 1
        let jabs = (input.ctl >> 13) & 1
        let hlt = input.ctl & 1
        let right = selectRightOperand(input: input)
        let alu = IDT7831()
        let aluOutput = alu.step(input: IDT7831.Input(a: input.a,
                                                      b: right,
                                                      c0: c0,
                                                      i0: i0,
                                                      i1: i1,
                                                      i2: i2,
                                                      rs0: rs0,
                                                      rs1: rs1,
                                                      ena: 0,
                                                      enb: 0,
                                                      enf: 0,
                                                      ftab: 1,
                                                      ftf: 1,
                                                      oe: 0))
        return Output(carry: aluOutput.c16,
                      z: aluOutput.z,
                      ovf: aluOutput.ovf,
                      j: j,
                      jabs: jabs,
                      y: aluOutput.f!,
                      hlt: hlt,
                      storeOp: 0,
                      ctl: input.ctl,
                      selC: splitOutSelC(input: input))
    }
    
    public func splitOutSelC(input: Input) -> UInt {
        return (input.ins >> 8) & 0b111
    }
    
    public func selectRightOperand(input: Input) -> UInt16 {
        let sel = (input.ctl >> 3) & 3
        switch sel {
        case 0b00:
            return input.b
        case 0b01:
            var val = UInt16(input.ins & 31)
            if (val & (1<<4)) != 0 {
                val = val | 0b1111111111100000
            }
            return val
        case 0b10:
            var val = UInt16(((input.ins >> 6) & 0b11100) | (input.ins & 0b11))
            if (val & (1<<4)) != 0 {
                val = val | 0b1111111111100000
            }
            return val
        case 0b11:
            var val = UInt16(input.ins & 2047)
            if (val & (1<<10)) != 0 {
                val = val | 0b1111111111100000
            }
            return val
        default:
            assert(false) // unreachable
            abort()
        }
    }
    
    public func selectStoreOperand(input: Input) -> UInt16 {
        let sel = (input.ctl >> 1) & 3
        switch sel {
        case 0b00:
            return input.b
        case 0b01:
            var val = UInt16(UInt(input.b & 0xff) << 8) & 0xffff
            if (val & (1<<7)) != 0 {
                val = val | 0b1111111100000000
            }
            return val
        case 0b10:
            return input.pc
        case 0b11:
            var val = UInt16(input.ins & 255)
            if (val & (1<<7)) != 0 {
                val = val | 0b1111111100000000
            }
            return val
        default:
            assert(false) // unreachable
            abort()
        }
    }
}
