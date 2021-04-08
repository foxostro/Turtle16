//
//  HazardControlMockup.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

// Mock up the hazard control logic. This will be implemented in a GAL on real hardware.
public class HazardControlMockup: HazardControl {
    public override func generatedHazardControlSignalsStageOne(input: StageOneInput) -> StageOneOutput {
        // For `fwd_a', we really want an expression like the following:
        //   let fwd_a = ~((sel_a_matches_sel_c_ex | wben_EX | writeBackSrc_EX) & (sel_a_matches_sel_c_mem | wben_MEM | writeBackSrc_MEM))
        // However, the ATF22V10 (equivalent to the venerable GAL22V10) is very
        // particular about the way we program it. All equations must be defined
        // as a series of terms ANDed together, and that list of terms is ORed
        // together. There is support for taking the inverted value of the
        // output, or of any individual input.
        //
        // The Swift compiler demands that we split this expression
        // into separate subexpressions. We can't do this on the GAL.
        let a: UInt = (input.sel_a_matches_sel_c_ex & input.sel_a_matches_sel_c_mem) | (input.sel_a_matches_sel_c_ex & input.wben_MEM) | (input.sel_a_matches_sel_c_ex & input.writeBackSrc_MEM)
        let b: UInt = (input.wben_EX & input.sel_a_matches_sel_c_mem) | (input.wben_EX & input.wben_MEM) | (input.wben_EX & input.writeBackSrc_MEM)
        let c: UInt = (input.writeBackSrc_EX & input.sel_a_matches_sel_c_mem) | (input.writeBackSrc_EX & input.wben_MEM) | (input.writeBackSrc_EX & input.writeBackSrc_MEM)
        let fwd_a = ~(a | b | c)
        
        // For `fwd_b', we really want an expression like the following:
        //   let fwd_b = ~((sel_b_matches_sel_c_ex | wben_EX | writeBackSrc_EX) & (sel_b_matches_sel_c_mem | wben_MEM | writeBackSrc_MEM))
        // However, we can't write it that way for the same reasons as `fwd_a'.
        //
        // The Swift compiler demands that we split this expression
        // into separate subexpressions. We can't do this on the GAL.
        let d: UInt = (input.sel_b_matches_sel_c_ex & input.sel_b_matches_sel_c_mem) | (input.sel_b_matches_sel_c_ex & input.wben_MEM) | (input.sel_b_matches_sel_c_ex & input.writeBackSrc_MEM)
        let e: UInt = (input.wben_EX & input.sel_b_matches_sel_c_mem) | (input.wben_EX & input.wben_MEM) | (input.wben_EX & input.writeBackSrc_MEM)
        let f: UInt = (input.writeBackSrc_EX & input.sel_b_matches_sel_c_mem) | (input.writeBackSrc_EX & input.wben_MEM) | (input.writeBackSrc_EX & input.writeBackSrc_MEM)
        let fwd_b = ~(d | e | f)
        
        let fwd_ex_to_a: UInt = (input.sel_a_matches_sel_c_ex | input.wben_EX | input.writeBackSrc_EX)
        let fwd_ex_to_b: UInt = (input.sel_b_matches_sel_c_ex | input.wben_EX | input.writeBackSrc_EX)
        
        let fwd_mem_to_a: UInt = (input.sel_a_matches_sel_c_mem | input.wben_MEM | input.writeBackSrc_MEM)
        let fwd_mem_to_b: UInt = (input.sel_b_matches_sel_c_mem | input.wben_MEM | input.writeBackSrc_MEM)
        
        let need_to_forward_storeOp_EX_to_a: UInt = (input.sel_a_matches_sel_c_ex | input.wben_EX | ~input.writeBackSrc_EX)
        let need_to_forward_storeOp_MEM_to_a: UInt = (input.sel_a_matches_sel_c_mem | input.wben_MEM | ~input.writeBackSrc_MEM)
        let need_to_forward_storeOp_EX_to_b: UInt = (input.sel_b_matches_sel_c_ex | input.wben_EX | ~input.writeBackSrc_EX)
        let need_to_forward_storeOp_MEM_to_b: UInt = (input.sel_b_matches_sel_c_mem | input.wben_MEM | ~input.writeBackSrc_MEM)
        
        return StageOneOutput(fwd_a: fwd_a & 1,
                              fwd_b: fwd_b & 1,
                              fwd_ex_to_a: fwd_ex_to_a & 1,
                              fwd_ex_to_b: fwd_ex_to_b & 1,
                              fwd_mem_to_a: fwd_mem_to_a & 1,
                              fwd_mem_to_b: fwd_mem_to_b & 1,
                              need_to_forward_storeOp_EX_to_a: need_to_forward_storeOp_EX_to_a & 1,
                              need_to_forward_storeOp_MEM_to_a: need_to_forward_storeOp_MEM_to_a & 1,
                              need_to_forward_storeOp_EX_to_b: need_to_forward_storeOp_EX_to_b & 1,
                              need_to_forward_storeOp_MEM_to_b: need_to_forward_storeOp_MEM_to_b & 1)
    }
    
    public override func generatedHazardControlSignalsStageTwo(input: StageTwoInput) -> StageTwoOutput {
        // Determine whether the given opcode specifies an instruction that
        // depends on the ALU flags. This depends on the order of opcodes. The
        // last eight opcodes must be the ones which use the flags.
        // This is written in an awkward way so there is a close correspondence
        // between this code and the HDL used for U73, an ATF22V10.
        let isFlagsHazard: UInt = input.opcode3 & input.opcode4 & ~input.ctl_EX5
        
        let flush: UInt = ~(input.j & ~isFlagsHazard & input.need_to_forward_storeOp_EX_to_a & input.need_to_forward_storeOp_MEM_to_a & input.need_to_forward_storeOp_EX_to_b & input.need_to_forward_storeOp_MEM_to_b)
        let stall = ~(~isFlagsHazard & input.need_to_forward_storeOp_EX_to_a & input.need_to_forward_storeOp_MEM_to_a & input.need_to_forward_storeOp_EX_to_b & input.need_to_forward_storeOp_MEM_to_b)
        
        return StageTwoOutput(flush: flush & 1,
                              stall: stall & 1)
    }
}
