//
//  HazardControlGAL.swift
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
public class HazardControlGAL: HazardControl {
    public let stageOneGAL: ATF22V10
    public let stageTwoGAL: ATF22V10
    
    public override init() {
        self.stageOneGAL = HazardControlGAL.makeGAL("HazardControl1")
        self.stageTwoGAL = HazardControlGAL.makeGAL("HazardControl2")
    }
    
    public static func makeGAL(_ name: String) -> ATF22V10 {
        let path = Bundle(for: self).path(forResource: name, ofType: "jed")!
        let jedecText = try! String(contentsOfFile: path)
        let fuseListMaker = FuseListMaker()
        let parser = JEDECFuseFileParser(fuseListMaker)
        parser.parse(jedecText)
        let fuseList = fuseListMaker.fuseList
        let gal = ATF22V10(fuseList: fuseList)
        return gal
    }
    
    public override func generatedHazardControlSignalsStageOne(input: StageOneInput) -> StageOneOutput {
        let outputs = stageOneGAL.step(inputs: [
            0,
            0,
            input.writeBackSrc_EX,
            input.wben_EX,
            input.writeBackSrc_MEM,
            input.wben_MEM,
            input.sel_a_matches_sel_c_ex,
            input.sel_b_matches_sel_c_ex,
            input.sel_a_matches_sel_c_mem,
            input.sel_b_matches_sel_c_mem,
            0,
            0,
            0,
            0,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
        ])
        
        let fwd_mem_to_a: UInt = outputs[0]!
        let fwd_ex_to_a: UInt = outputs[1]!
        let fwd_a: UInt = outputs[2]!
        let fwd_b: UInt = outputs[3]!
        let fwd_ex_to_b: UInt = outputs[4]!
        let fwd_mem_to_b: UInt = outputs[5]!
        let need_to_forward_storeOp_EX_to_a: UInt = outputs[6]!
        let need_to_forward_storeOp_MEM_to_a: UInt = outputs[7]!
        let need_to_forward_storeOp_EX_to_b: UInt = outputs[8]!
        let need_to_forward_storeOp_MEM_to_b: UInt = outputs[9]!
        
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
        let outputs = stageTwoGAL.step(inputs: [
            0,
            0,
            input.opcode3,
            input.opcode4,
            input.ctl_EX5,
            input.j,
            input.need_to_forward_storeOp_EX_to_a,
            input.need_to_forward_storeOp_MEM_to_a,
            input.need_to_forward_storeOp_EX_to_b,
            input.need_to_forward_storeOp_MEM_to_b,
            0,
            0,
            0,
            0,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
        ])
        
        let stall: UInt = outputs[0]!
        let flush: UInt = outputs[1]!
        
        return StageTwoOutput(flush: flush & 1,
                              stall: stall & 1)
    }
}
