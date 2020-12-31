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
    }
    
    public struct Output {
        public let stallPC: UInt
        public let stallIF: UInt
        public let ctl_EX: UInt
        public let a: UInt16
        public let b: UInt16
        public let ins: UInt
    }
    
    public var registerFile = Array<UInt16>(repeating: 0, count: 8)
    public var opcodeDecodeROM = Array<UInt>(repeating: 0, count: 512)
    
    public func step(input: Input) -> Output {
        var stallPC: UInt = 0
        var stallIF: UInt = 1
        var stallID: UInt = 1
        
        // Flush the pipeline on a jump.
        if input.j == 0 {
            stallPC = 0
            stallIF = 0
            stallID = 0
        }
        
        // Stall on RAW Hazard with the A port
        let selA = splitOutSelA(input: input)
        if (input.selC_EX == selA) && ((input.ctl_EX & (1<<20)) == 0) {
            stallPC = 1
            stallIF = 0
            stallID = 0
        }
        if (input.selC_MEM == selA) && ((input.ctl_MEM & (1<<20)) == 0) {
            stallPC = 1
            stallIF = 0
            stallID = 0
        }
        
        // Stall on RAW Hazard with the B port
        let selB = splitOutSelB(input: input)
        if (input.selC_EX == selB) && ((input.ctl_EX & (1<<20)) == 0) {
            stallPC = 1
            stallIF = 0
            stallID = 0
        }
        if (input.selC_MEM == selB) && ((input.ctl_MEM & (1<<20)) == 0) {
            stallPC = 1
            stallIF = 0
            stallID = 0
        }
        
        // Stall on a Flags Hazard
        let opcode = UInt((input.ins >> 11) & 31)
        let beq = 25
        let bne = 26
        let blt = 27
        let bge = 28
        let bltu = 29
        let bgeu = 30
        let areFlagsNeeded = (opcode == beq) || (opcode == bne) || (opcode == blt) || (opcode == bge) || (opcode == bltu) || (opcode == bgeu)
        if areFlagsNeeded && ((input.ctl_EX & (1<<5)) == 0) {
            stallPC = 1
            stallIF = 0
            stallID = 0
        }
        
        let ctl_EX: UInt = (stallID==0) ? ID.nopControlWord : decodeOpcode(input: input)
        let ins = UInt(input.ins & 0x07ff)
        let a = readRegisterA(input: input)
        let b = readRegisterB(input: input)
        return Output(stallPC: stallPC,
                      stallIF: stallIF,
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
