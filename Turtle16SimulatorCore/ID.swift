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
        public let selC_EX: UInt
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
            self.selC_EX = 0
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
            self.selC_EX = 0
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
            self.selC_EX = 0
            self.ctl_EX = ID.nopControlWord
            self.selC_MEM = 0
            self.ctl_MEM = ID.nopControlWord
            self.j = j
            self.ovf = 0
            self.z = 0
            self.carry = 0
            self.rst = 1
        }
        
        public init(ins: UInt16, selC_EX: UInt, ctl_EX: UInt) {
            self.ins = ins
            self.selC_EX = selC_EX
            self.ctl_EX = ctl_EX
            self.selC_MEM = 0
            self.ctl_MEM = ID.nopControlWord
            self.j = 1
            self.ovf = 0
            self.z = 0
            self.carry = 0
            self.rst = 1
        }
        
        public init(ins: UInt16, ctl_EX: UInt) {
            self.ins = ins
            self.selC_EX = 0
            self.ctl_EX = ctl_EX
            self.selC_MEM = 0
            self.ctl_MEM = ID.nopControlWord
            self.j = 1
            self.ovf = 0
            self.z = 0
            self.carry = 0
            self.rst = 1
        }
        
        public init(ins: UInt16, selC_MEM: UInt, ctl_MEM: UInt) {
            self.ins = ins
            self.selC_EX = 0
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
                    selC_EX: UInt,
                    ctl_EX: UInt,
                    selC_MEM: UInt,
                    ctl_MEM: UInt,
                    j: UInt,
                    ovf: UInt,
                    z: UInt,
                    carry: UInt,
                    rst: UInt) {
            self.ins = ins
            self.selC_EX = selC_EX
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
        public let stallPC: UInt
        public let stallIF: UInt
        public let ctl_EX: UInt
        public let a: UInt16
        public let b: UInt16
        public let ins: UInt
        
        public init(stallPC: UInt,
                    stallIF: UInt,
                    ctl_EX: UInt,
                    a: UInt16,
                    b: UInt16,
                    ins: UInt) {
            self.stallPC = stallPC
            self.stallIF = stallIF
            self.ctl_EX = ctl_EX
            self.a = a
            self.b = b
            self.ins = ins
        }
    }
    
    public var registerFile = Array<UInt16>(repeating: 0, count: 8)
    public var opcodeDecodeROM = Array<UInt>(repeating: 0, count: 512)
    
    public func step(input: Input) -> Output {
        let stall = generateStallSignals(input: input)
        let ctl_EX: UInt = ((stall.0 & 1)==0) ? ID.nopControlWord : decodeOpcode(input: input)
        let ins = UInt(input.ins & 0x07ff)
        let a = readRegisterA(input: input)
        let b = readRegisterB(input: input)
        return Output(stallPC: stall.1 & 1,
                      stallIF: stall.0 & 1,
                      ctl_EX: ctl_EX,
                      a: a,
                      b: b,
                      ins: ins)
    }
    
    public func generateStallSignals(input: Input) -> (UInt, UInt) {
        let selA: UInt = splitOutSelA(input: input)
        let selB: UInt = splitOutSelB(input: input)
        
        let selA0: UInt = selA & 1
        let selA1: UInt = (selA>>1) & 1
        let selA2: UInt = (selA>>2) & 1
        
        let selB0: UInt = selB & 1
        let selB1: UInt = (selB>>1) & 1
        let selB2: UInt = (selB>>2) & 1
        
        let selC_EX0: UInt = input.selC_EX & 1
        let selC_EX1: UInt = (input.selC_EX>>1) & 1
        let selC_EX2: UInt = (input.selC_EX>>2) & 1
        
        let selC_MEM0: UInt = input.selC_MEM & 1
        let selC_MEM1: UInt = (input.selC_MEM>>1) & 1
        let selC_MEM2: UInt = (input.selC_MEM>>2) & 1
        
        let ctl_EX5: UInt = (input.ctl_EX >> 5) & 1
        let ctl_EX20: UInt = (input.ctl_EX >> 20) & 1
        let ctl_MEM20: UInt = (input.ctl_MEM >> 20) & 1
        
        // U70, U71, and U72 form an array of XOR gates. We use these to compare
        // the selected destination register for the instruction in EX and MEM
        // with the selected source registers for the instruction in ID.
        let selC_EX_xor_selA0: UInt = selC_EX0 ^ selA0
        let selC_EX_xor_selA1: UInt = selC_EX1 ^ selA1
        let selC_EX_xor_selA2: UInt = selC_EX2 ^ selA2
        
        let selC_MEM_xor_selA0: UInt = selC_MEM0 ^ selA0
        let selC_MEM_xor_selA1: UInt = selC_MEM1 ^ selA1
        let selC_MEM_xor_selA2: UInt = selC_MEM2 ^ selA2
        
        let selC_EX_xor_selB0: UInt = selC_EX0 ^ selB0
        let selC_EX_xor_selB1: UInt = selC_EX1 ^ selB1
        let selC_EX_xor_selB2: UInt = selC_EX2 ^ selB2
        
        let selC_MEM_xor_selB0: UInt = selC_MEM0 ^ selB0
        let selC_MEM_xor_selB1: UInt = selC_MEM1 ^ selB1
        let selC_MEM_xor_selB2: UInt = selC_MEM2 ^ selB2
        
        // Determine whether the given opcode specifies an instruction that
        // depends on the ALU flags. This depends on the order of opcodes. The
        // last eight opcodes must be the ones which use the flags.
        // This is written in an awkward way so there is a close correspondence
        // between this code and the HDL used for U73, an ATF22V10.
        let opcode3: UInt = UInt(input.ins) >> 14
        let opcode4: UInt = UInt(input.ins) >> 15
        let areFlagsNeeded: UInt = opcode3 & opcode4
        
        let isRawHazardWithAInEX = ~selC_EX_xor_selA0 & ~selC_EX_xor_selA1 & ~selC_EX_xor_selA2 & ~ctl_EX20
        let isRawHazardWithAInMEM = ~selC_MEM_xor_selA0 & ~selC_MEM_xor_selA1 & ~selC_MEM_xor_selA2 & ~ctl_MEM20
        let isRawHazardWithBInEX = ~selC_EX_xor_selB0 & ~selC_EX_xor_selB1 & ~selC_EX_xor_selB2 & ~ctl_EX20
        let isRawHazardWithBInMEM = ~selC_MEM_xor_selB0 & ~selC_MEM_xor_selB1 & ~selC_MEM_xor_selB2 & ~ctl_MEM20
        let isFlagsHazard = areFlagsNeeded & ~ctl_EX5
        let stallIF: UInt = ~(isRawHazardWithAInEX | isRawHazardWithAInMEM | isRawHazardWithBInEX | isRawHazardWithBInMEM | isFlagsHazard | ~input.j)
        
        let stallPC: UInt = ~stallIF & input.j
        
        return (stallIF, stallPC)
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
