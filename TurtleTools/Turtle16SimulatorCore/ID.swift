//
//  ID.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 12/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

public extension UInt {
    fileprivate func asBinaryString() -> String {
        var result = String(self, radix: 2)
        if result.count < 8 {
            result = String(repeatElement("0", count: 8 - result.count)) + result
        }
        return "0b" + result
    }
}

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
        public let ovf: UInt
        public let z: UInt
        public let carry: UInt
        public let rst: UInt
        
        public init(ins: UInt16) {
            self.ins = ins
            self.ovf = 0
            self.z = 0
            self.carry = 0
            self.rst = 1
        }
        
        public init(ins: UInt16, rst: UInt) {
            self.ins = ins
            self.ovf = 0
            self.z = 0
            self.carry = 0
            self.rst = rst
        }
        
        public init(ins: UInt16, j: UInt) {
            self.ins = ins
            self.ovf = 0
            self.z = 0
            self.carry = 0
            self.rst = 1
        }
        
        public init(ins: UInt16, selC_EX: UInt, ctl_EX: UInt) {
            self.ins = ins
            self.ovf = 0
            self.z = 0
            self.carry = 0
            self.rst = 1
        }
        
        public init(ins: UInt16, ctl_EX: UInt) {
            self.ins = ins
            self.ovf = 0
            self.z = 0
            self.carry = 0
            self.rst = 1
        }
        
        public init(ins: UInt16, selC_MEM: UInt, ctl_MEM: UInt) {
            self.ins = ins
            self.ovf = 0
            self.z = 0
            self.carry = 0
            self.rst = 1
        }
        
        public init(ins: UInt16,
                    ovf: UInt,
                    z: UInt,
                    carry: UInt,
                    rst: UInt) {
            self.ins = ins
            self.ovf = ovf
            self.z = z
            self.carry = carry
            self.rst = rst
        }
    }
    
    public struct Output {
        public let ctl_EX: UInt
        public let a: UInt16
        public let b: UInt16
        public let ins: UInt
        
        public init(ctl_EX: UInt,
                    a: UInt16,
                    b: UInt16,
                    ins: UInt) {
            self.ctl_EX = ctl_EX
            self.a = a
            self.b = b
            self.ins = ins
        }
    }
    
    public var registerFile = Array<UInt16>(repeating: 0, count: 8)
    public var opcodeDecodeROM = Array<UInt>(repeating: 0, count: 512)
    
    public func step(input: Input) -> Output {
        let ctl_EX: UInt = decodeOpcode(input: input)
        let a = readRegisterA(input: input)
        let b = readRegisterB(input: input)
        let ins = UInt(input.ins & 0x07ff)
        return Output(ctl_EX: ctl_EX,
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
        let ctl_EX = ~ctl_ID & UInt((1<<21)-1) // only the lower 21 bits are present on real hardware
        return ctl_EX
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
