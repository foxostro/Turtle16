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
    
    public func step(input: Input) -> Output {
        let hazardControl = generateHazardControlSignals(input: input)
        let ctl_EX: UInt = ((hazardControl.flush & 1)==1) ? ID.nopControlWord : decodeOpcode(input: input)
        let a = forwardA(input, hazardControl)
        let b = forwardB(input, hazardControl)
        let ins = UInt(input.ins & 0x07ff)
        return Output(stall: hazardControl.stall & 1,
                      ctl_EX: ctl_EX,
                      a: a,
                      b: b,
                      ins: ins)
    }
    
    fileprivate struct HazardControlSignals {
        public let flush: UInt
        public let stall: UInt
        public let fwd_a: UInt
        public let fwd_ex_to_a: UInt
        public let fwd_mem_to_a: UInt
        public let fwd_b: UInt
        public let fwd_ex_to_b: UInt
        public let fwd_mem_to_b: UInt
    }
    
    fileprivate func generateHazardControlSignals(input: Input) -> HazardControlSignals {
        // The hazard control logic is written in this awkward way so that there
        // is a close correspondence between this simulator code and the HDL
        // used in U73, a ATF22V10, in the actual hardware.
        
        let selA = splitOutSelA(input: input)
        let selB = splitOutSelB(input: input)
        let selC_EX: UInt = (input.ins_EX >> 8) & 0b111
        let selC_MEM: UInt = input.selC_MEM
        let writeBackSrc_EX: UInt = (input.ctl_EX >> 17) & 1
        let writeBackSrc_MEM: UInt = (input.ctl_MEM >> 17) & 1
        let wben_EX: UInt = (input.ctl_EX >> 20) & 1
        let wben_MEM: UInt = (input.ctl_MEM >> 20) & 1
        let j: UInt = input.j & 1
        
        // The hardware has an array of identity comparators to generate these
        // signals.
        let sel_a_matches_sel_c_ex: UInt  = (selA == selC_EX)  ? 0 : 1
        let sel_b_matches_sel_c_ex: UInt  = (selB == selC_EX)  ? 0 : 1
        let sel_a_matches_sel_c_mem: UInt = (selA == selC_MEM) ? 0 : 1
        let sel_b_matches_sel_c_mem: UInt = (selB == selC_MEM) ? 0 : 1
        
        // For `fwd_a', we really want an expression like the following:
        //   let fwd_a = ~((sel_a_matches_sel_c_ex | wben_EX | writeBackSrc_EX) & (sel_a_matches_sel_c_mem | wben_MEM | writeBackSrc_MEM)) & 1
        // However, the ATF22V10 (equivalent to the venerable GAL22V10) is very
        // particular about the way we program it. All equations must be defined
        // as a series of terms ANDed together, and that list of terms is ORed
        // together. There is support for taking the inverted value of the
        // output, or of any individual input.
        //
        // The Swift compiler demands that we split this expression
        // into separate subexpressions. We can't do this on the GAL.
        let a: UInt = (sel_a_matches_sel_c_ex & sel_a_matches_sel_c_mem) | (sel_a_matches_sel_c_ex & wben_MEM) | (sel_a_matches_sel_c_ex & writeBackSrc_MEM)
        let b: UInt = (wben_EX & sel_a_matches_sel_c_mem) | (wben_EX & wben_MEM) | (wben_EX & writeBackSrc_MEM)
        let c: UInt = (writeBackSrc_EX & sel_a_matches_sel_c_mem) | (writeBackSrc_EX & wben_MEM) | (writeBackSrc_EX & writeBackSrc_MEM)
        let fwd_a = ~(a | b | c) & 1
        
        // For `fwd_b', we really want an expression like the following:
        //   let fwd_b = ~((sel_b_matches_sel_c_ex | wben_EX | writeBackSrc_EX) & (sel_b_matches_sel_c_mem | wben_MEM | writeBackSrc_MEM)) & 1
        // However, we can't write it that way for the same reasons as `fwd_a'.
        //
        // The Swift compiler demands that we split this expression
        // into separate subexpressions. We can't do this on the GAL.
        let d: UInt = (sel_b_matches_sel_c_ex & sel_b_matches_sel_c_mem) | (sel_b_matches_sel_c_ex & wben_MEM) | (sel_b_matches_sel_c_ex & writeBackSrc_MEM)
        let e: UInt = (wben_EX & sel_b_matches_sel_c_mem) | (wben_EX & wben_MEM) | (wben_EX & writeBackSrc_MEM)
        let f: UInt = (writeBackSrc_EX & sel_b_matches_sel_c_mem) | (writeBackSrc_EX & wben_MEM) | (writeBackSrc_EX & writeBackSrc_MEM)
        let fwd_b = ~(d | e | f) & 1
        
        let fwd_ex_to_a: UInt = (sel_a_matches_sel_c_ex | wben_EX | writeBackSrc_EX) & 1
        let fwd_ex_to_b: UInt = (sel_b_matches_sel_c_ex | wben_EX | writeBackSrc_EX) & 1
        
        let fwd_mem_to_a: UInt = (sel_a_matches_sel_c_mem | wben_MEM | writeBackSrc_MEM) & 1
        let fwd_mem_to_b: UInt = (sel_b_matches_sel_c_mem | wben_MEM | writeBackSrc_MEM) & 1
        
        // Determine whether the given opcode specifies an instruction that
        // depends on the ALU flags. This depends on the order of opcodes. The
        // last eight opcodes must be the ones which use the flags.
        // This is written in an awkward way so there is a close correspondence
        // between this code and the HDL used for U73, an ATF22V10.
        let opcode3: UInt = UInt(input.ins) >> 14
        let opcode4: UInt = UInt(input.ins) >> 15
        let areFlagsNeeded: UInt = opcode3 & opcode4
        let ctl_EX5: UInt = (input.ctl_EX >> 5) & 1
        let isFlagsHazard: UInt = (areFlagsNeeded & ~ctl_EX5) & 1
        
        // The Swift compiler demands that we split this expression
        // into separate subexpressions. We can't do this on the GAL.
        let need_to_forward_storeOp_EX_to_a: UInt = (sel_a_matches_sel_c_ex | wben_EX | ~writeBackSrc_EX) & 1
        let need_to_forward_storeOp_MEM_to_a: UInt = (sel_a_matches_sel_c_mem | wben_MEM | ~writeBackSrc_MEM) & 1
        let need_to_forward_storeOp_EX_to_b: UInt = (sel_b_matches_sel_c_ex | wben_EX | ~writeBackSrc_EX) & 1
        let need_to_forward_storeOp_MEM_to_b: UInt = (sel_b_matches_sel_c_mem | wben_MEM | ~writeBackSrc_MEM) & 1
        let flush: UInt = ~(j & ~isFlagsHazard & need_to_forward_storeOp_EX_to_a & need_to_forward_storeOp_MEM_to_a & need_to_forward_storeOp_EX_to_b & need_to_forward_storeOp_MEM_to_b) & 1
        
        let stall = ~(~isFlagsHazard & need_to_forward_storeOp_EX_to_a & need_to_forward_storeOp_MEM_to_a & need_to_forward_storeOp_EX_to_b & need_to_forward_storeOp_MEM_to_b) & 1
        
        return HazardControlSignals(flush: flush,
                                    stall: stall,
                                    fwd_a: fwd_a,
                                    fwd_ex_to_a: fwd_ex_to_a,
                                    fwd_mem_to_a: fwd_mem_to_a,
                                    fwd_b: fwd_b,
                                    fwd_ex_to_b: fwd_ex_to_b,
                                    fwd_mem_to_b: fwd_mem_to_b)
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
    
    fileprivate func forwardA(_ input: ID.Input, _ hazardControl: HazardControlSignals) -> UInt16 {
        if hazardControl.fwd_a == 0 && hazardControl.fwd_ex_to_a != 0 && hazardControl.fwd_mem_to_a != 0 {
            return readRegisterA(input: input)
        }
        if hazardControl.fwd_a != 0 && hazardControl.fwd_ex_to_a == 0 && hazardControl.fwd_mem_to_a != 0 {
            return input.y_EX
        }
        if hazardControl.fwd_a != 0 && hazardControl.fwd_ex_to_a != 0 && hazardControl.fwd_mem_to_a == 0 {
            return input.y_MEM
        }
        assert(false)
        return 0
    }
    
    fileprivate func forwardB(_ input: ID.Input, _ hazardControl: HazardControlSignals) -> UInt16 {
        if hazardControl.fwd_b == 0 && hazardControl.fwd_ex_to_b != 0 && hazardControl.fwd_mem_to_b != 0 {
            return readRegisterB(input: input)
        }
        if hazardControl.fwd_b != 0 && hazardControl.fwd_ex_to_b == 0 && hazardControl.fwd_mem_to_b != 0 {
            return input.y_EX
        }
        if hazardControl.fwd_b != 0 && hazardControl.fwd_ex_to_b != 0 && hazardControl.fwd_mem_to_b == 0 {
            return input.y_MEM
        }
        assert(false)
        return 0
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
