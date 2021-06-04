//
//  ID.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 12/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

// Models the ID (instruction decode) stage of the Turtle16 pipeline.
// Please refer to ID.sch for details.
// Classes in the simulator intentionally model specific pieces of hardware,
// following naming conventions and organization that matches the schematics.
public class ID: NSObject {
    public static let nopControlWord: UInt = 0b111111111111111111111
    
    public struct WriteBackInput {
        public let c: UInt16
        public let wrh: UInt
        public let wrl: UInt
        public let wben: UInt
        public let selC_WB: UInt
        
        public init(c: UInt16,
                    wrh: UInt,
                    wrl: UInt,
                    wben: UInt,
                    selC_WB: UInt) {
            self.c = c
            self.wrh = wrh
            self.wrl = wrl
            self.wben = wben
            self.selC_WB = selC_WB
        }
    }
    
    public func writeBack(input: WriteBackInput) {
        assert(input.selC_WB < 8)
        if input.wben == 0 {
            let old = registerFile[Int(input.selC_WB)]
            let upper = (input.wrh == 0) ? (input.c & 0xff00) : (old & 0xff00)
            let lower = (input.wrl == 0) ? (input.c & 0x00ff) : (old & 0x00ff)
            let val = upper | lower
            registerFile[Int(input.selC_WB)] = val
        }
    }
    
    public struct Input {
        public let ins: UInt16
        public let y_EX: UInt16
        public let y_MEM: UInt16
        public let ins_EX: UInt
        public let ctl_EX: UInt
        public let selC_MEM: UInt
        public let ctl_MEM: UInt
        public let j: UInt
        public let ovf: UInt
        public let z: UInt
        public let carry: UInt
        public let rst: UInt
        
        public init(ins: UInt16) {
            self.ins = ins
            self.y_EX = 0
            self.y_MEM = 0
            self.ins_EX = 0
            self.ctl_EX = ID.nopControlWord
            self.selC_MEM = 0
            self.ctl_MEM = ID.nopControlWord
            self.j = 1
            self.ovf = 0
            self.z = 0
            self.carry = 0
            self.rst = 1
        }
        
        public init(ins: UInt16, rst: UInt) {
            self.ins = ins
            self.y_EX = 0
            self.y_MEM = 0
            self.ins_EX = 0
            self.ctl_EX = ID.nopControlWord
            self.selC_MEM = 0
            self.ctl_MEM = ID.nopControlWord
            self.j = 1
            self.ovf = 0
            self.z = 0
            self.carry = 0
            self.rst = rst
        }
        
        public init(ins: UInt16, j: UInt) {
            self.ins = ins
            self.y_EX = 0
            self.y_MEM = 0
            self.ins_EX = 0
            self.ctl_EX = ID.nopControlWord
            self.selC_MEM = 0
            self.ctl_MEM = ID.nopControlWord
            self.j = j
            self.ovf = 0
            self.z = 0
            self.carry = 0
            self.rst = 1
        }
        
        public init(ins: UInt16, ctl_EX: UInt) {
            self.ins = ins
            self.y_EX = 0
            self.y_MEM = 0
            self.ins_EX = 0
            self.ctl_EX = ctl_EX
            self.selC_MEM = 0
            self.ctl_MEM = ID.nopControlWord
            self.j = 1
            self.ovf = 0
            self.z = 0
            self.carry = 0
            self.rst = 1
        }
        
        public init(ins: UInt16, ins_EX: UInt, ctl_EX: UInt, y_EX: UInt16) {
            self.ins = ins
            self.y_EX = y_EX
            self.y_MEM = 0
            self.ins_EX = ins_EX
            self.ctl_EX = ctl_EX
            self.selC_MEM = 0
            self.ctl_MEM = ID.nopControlWord
            self.j = 1
            self.ovf = 0
            self.z = 0
            self.carry = 0
            self.rst = 1
        }
        
        public init(ins: UInt16, selC_MEM: UInt, ctl_MEM: UInt, y_MEM: UInt16) {
            self.ins = ins
            self.y_EX = 0
            self.y_MEM = y_MEM
            self.ins_EX = 0
            self.ctl_EX = ID.nopControlWord
            self.selC_MEM = selC_MEM
            self.ctl_MEM = ctl_MEM
            self.j = 1
            self.ovf = 0
            self.z = 0
            self.carry = 0
            self.rst = 1
        }
        
        public init(ins: UInt16, selC_MEM: UInt, ctl_MEM: UInt) {
            self.ins = ins
            self.y_EX = 0
            self.y_MEM = 0
            self.ins_EX = 0
            self.ctl_EX = ID.nopControlWord
            self.selC_MEM = selC_MEM
            self.ctl_MEM = ctl_MEM
            self.j = 1
            self.ovf = 0
            self.z = 0
            self.carry = 0
            self.rst = 1
        }
        
        public init(ins: UInt16,
                    y_EX: UInt16,
                    y_MEM: UInt16,
                    ins_EX: UInt,
                    ctl_EX: UInt,
                    selC_MEM: UInt,
                    ctl_MEM: UInt,
                    j: UInt,
                    ovf: UInt,
                    z: UInt,
                    carry: UInt,
                    rst: UInt) {
            self.ins = ins
            self.y_EX = y_EX
            self.y_MEM = y_MEM
            self.ins_EX = ins_EX
            self.ctl_EX = ctl_EX
            self.selC_MEM = selC_MEM
            self.ctl_MEM = ctl_MEM
            self.j = j
            self.ovf = ovf
            self.z = z
            self.carry = carry
            self.rst = rst
        }
    }
    
    public struct Output {
        public let stall: UInt
        public let ctl_EX: UInt
        public let a: UInt16
        public let b: UInt16
        public let ins: UInt
        
        public init(stall: UInt,
                    ctl_EX: UInt,
                    a: UInt16,
                    b: UInt16,
                    ins: UInt) {
            self.stall = stall
            self.ctl_EX = ctl_EX
            self.a = a
            self.b = b
            self.ins = ins
        }
    }
    
    public var registerFile = Array<UInt16>(repeating: 0, count: 8)
    public var opcodeDecodeROM = Array<UInt>(repeating: 0, count: 512)
    let hazardControlUnit: HazardControl = HazardControlMockup()
    
    public func step(input: Input) -> Output {
        let hazardControlSignals = hazardControlUnit.step(input: input)
        let ctl_EX: UInt = ((hazardControlSignals.flush & 1)==1) ? ID.nopControlWord : decodeOpcode(input: input)
        let a = forwardA(input, hazardControlSignals)
        let b = forwardB(input, hazardControlSignals)
        let ins = UInt(input.ins & 0x07ff)
        return Output(stall: hazardControlSignals.stall & 1,
                      ctl_EX: ctl_EX,
                      a: a,
                      b: b,
                      ins: ins)
    }
    
    public func decodeOpcode(input: Input) -> UInt {
        let address = UInt(input.rst << 8)
                    | UInt(input.carry << 7)
                    | UInt(input.z << 6)
                    | UInt(input.ovf << 5)
                    | UInt((input.ins >> 11) & 31)
        let ctl_ID = opcodeDecodeROM[Int(address)]
        let ctl_EX = ctl_ID & UInt((1<<21)-1) // only the lower 21 bits are present on real hardware
        return ctl_EX
    }
    
    fileprivate func forwardA(_ input: ID.Input, _ hzd: HazardControl.Output) -> UInt16 {
        if hzd.fwd_a == 0 && hzd.fwd_ex_to_a != 0 && hzd.fwd_mem_to_a != 0 {
            return readRegisterA(input: input)
        }
        if hzd.fwd_a != 0 && hzd.fwd_ex_to_a == 0 && hzd.fwd_mem_to_a != 0 {
            return input.y_EX
        }
        if hzd.fwd_a != 0 && hzd.fwd_ex_to_a != 0 && hzd.fwd_mem_to_a == 0 {
            return input.y_MEM
        }
        fatalError("illegal hazard resolution")
    }
    
    fileprivate func forwardB(_ input: ID.Input, _ hzd: HazardControl.Output) -> UInt16 {
        if hzd.fwd_b == 0 && hzd.fwd_ex_to_b != 0 && hzd.fwd_mem_to_b != 0 {
            return readRegisterB(input: input)
        }
        if hzd.fwd_b != 0 && hzd.fwd_ex_to_b == 0 && hzd.fwd_mem_to_b != 0 {
            return input.y_EX
        }
        if hzd.fwd_b != 0 && hzd.fwd_ex_to_b != 0 && hzd.fwd_mem_to_b == 0 {
            return input.y_MEM
        }
        fatalError("illegal hazard resolution")
    }
    
    public func readRegisterA(input: Input) -> UInt16 {
        return registerFile[Int(splitOutSelA(input: input))]
    }
    
    public func readRegisterB(input: Input) -> UInt16 {
        return registerFile[Int(splitOutSelB(input: input))]
    }
    
    public func splitOutSelA(input: Input) -> UInt {
        return UInt((input.ins >> 5) & 0b111)
    }
    
    public func splitOutSelB(input: Input) -> UInt {
        return UInt((input.ins >> 2) & 0b111)
    }
}
