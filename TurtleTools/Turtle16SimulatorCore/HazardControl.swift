//
//  HazardControl.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

// Simulates the CPU's hazard control unit to detect and resolve hazards.
//
// Implementing the Hazard Control unit in real hardware requires splitting
// it across two ATF22V10 ICs. We represent this split through the two
// stages of logic in this class.
public class HazardControl: NSObject {
    public struct Output {
        public let flush: UInt
        public let stall: UInt
        public let fwd_a: UInt
        public let fwd_ex_to_a: UInt
        public let fwd_mem_to_a: UInt
        public let fwd_b: UInt
        public let fwd_ex_to_b: UInt
        public let fwd_mem_to_b: UInt
    }
    
    public struct StageOneInput {
        let sel_a_matches_sel_c_ex: UInt
        let sel_b_matches_sel_c_ex: UInt
        let sel_a_matches_sel_c_mem: UInt
        let sel_b_matches_sel_c_mem: UInt
        let writeBackSrc_EX: UInt
        let writeBackSrc_MEM: UInt
        let wben_EX: UInt
        let wben_MEM: UInt
    }
    
    public struct StageOneOutput {
        let fwd_a: UInt
        let fwd_b: UInt
        let fwd_ex_to_a: UInt
        let fwd_ex_to_b: UInt
        let fwd_mem_to_a: UInt
        let fwd_mem_to_b: UInt
        let need_to_forward_storeOp_EX_to_a: UInt
        let need_to_forward_storeOp_MEM_to_a: UInt
        let need_to_forward_storeOp_EX_to_b: UInt
        let need_to_forward_storeOp_MEM_to_b: UInt
    }
    
    public struct StageTwoInput {
        let j: UInt
        let opcode3: UInt
        let opcode4: UInt
        let ctl_EX5: UInt
        let need_to_forward_storeOp_EX_to_a: UInt
        let need_to_forward_storeOp_MEM_to_a: UInt
        let need_to_forward_storeOp_EX_to_b: UInt
        let need_to_forward_storeOp_MEM_to_b: UInt
    }
    
    public struct StageTwoOutput {
        let flush: UInt
        let stall: UInt
    }
    
    public func generatedHazardControlSignalsStageOne(input: StageOneInput) -> StageOneOutput {
        abort() // implement in a subclass
    }
    
    public func generatedHazardControlSignalsStageTwo(input: StageTwoInput) -> StageTwoOutput {
        abort() // implement in a subclass
    }
    
    public func step(input: ID.Input) -> Output {
        // The hardware has an array of identity comparators to generate these
        // signals.
        let selA: UInt = UInt(input.ins >> 5) & 0b111
        let selB: UInt = UInt(input.ins >> 2) & 0b111
        let selC_EX: UInt = (input.ins_EX >> 8) & 0b111
        let selC_MEM: UInt = input.selC_MEM
        let sel_a_matches_sel_c_ex: UInt  = (selA == selC_EX)  ? 0 : 1
        let sel_b_matches_sel_c_ex: UInt  = (selB == selC_EX)  ? 0 : 1
        let sel_a_matches_sel_c_mem: UInt = (selA == selC_MEM) ? 0 : 1
        let sel_b_matches_sel_c_mem: UInt = (selB == selC_MEM) ? 0 : 1
        
        let stageOneInput = StageOneInput(sel_a_matches_sel_c_ex: sel_a_matches_sel_c_ex,
                                          sel_b_matches_sel_c_ex: sel_b_matches_sel_c_ex,
                                          sel_a_matches_sel_c_mem: sel_a_matches_sel_c_mem,
                                          sel_b_matches_sel_c_mem: sel_b_matches_sel_c_mem,
                                          writeBackSrc_EX: (input.ctl_EX >> 17) & 1,
                                          writeBackSrc_MEM: (input.ctl_MEM >> 17) & 1,
                                          wben_EX: (input.ctl_EX >> 20) & 1,
                                          wben_MEM: (input.ctl_MEM >> 20) & 1)
        let stageOneOutput = generatedHazardControlSignalsStageOne(input: stageOneInput)
        
        let stageTwoInput = StageTwoInput(j: input.j,
                                          opcode3: (UInt(input.ins) >> 14) & 1,
                                          opcode4: (UInt(input.ins) >> 15) & 1,
                                          ctl_EX5: (input.ctl_EX >> 5) & 1,
                                          need_to_forward_storeOp_EX_to_a: stageOneOutput.need_to_forward_storeOp_EX_to_a,
                                          need_to_forward_storeOp_MEM_to_a: stageOneOutput.need_to_forward_storeOp_MEM_to_a,
                                          need_to_forward_storeOp_EX_to_b: stageOneOutput.need_to_forward_storeOp_EX_to_b,
                                          need_to_forward_storeOp_MEM_to_b: stageOneOutput.need_to_forward_storeOp_MEM_to_b)
        let stageTwoOutput = generatedHazardControlSignalsStageTwo(input: stageTwoInput)
        
        return Output(flush: stageTwoOutput.flush,
                      stall: stageTwoOutput.stall,
                      fwd_a: stageOneOutput.fwd_a,
                      fwd_ex_to_a: stageOneOutput.fwd_ex_to_a,
                      fwd_mem_to_a: stageOneOutput.fwd_mem_to_a,
                      fwd_b: stageOneOutput.fwd_b,
                      fwd_ex_to_b: stageOneOutput.fwd_ex_to_b,
                      fwd_mem_to_b: stageOneOutput.fwd_mem_to_b)
    }
}
