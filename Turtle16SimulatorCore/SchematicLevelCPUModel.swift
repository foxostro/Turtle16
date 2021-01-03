//
//  SchematicLevelCPUModel.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 12/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

// Models the Turtle16 CPU. Please refer to MainBoard.sch for details.
// Classes in the simulator intentionally model specific pieces of hardware,
// following naming conventions and organization that matches the schematics.
public class SchematicLevelCPUModel: NSObject {
    public static let kNumberOfResetCycles: UInt = 100 // fake, but whatever
    
    public var resetCounter: UInt = kNumberOfResetCycles
    
    public var isResetting: Bool {
        resetCounter > 0
    }
    
    public var pc: UInt16 = 0
    
    public var instructions: [UInt16] = []
    
    public func setRegister(_ idx: Int, _ val: UInt16) {
        assert(idx >= 0 && idx <= 7)
        stageID.registerFile[idx] = val
    }
    
    public func getRegister(_ idx: Int) -> UInt16 {
        assert(idx >= 0 && idx <= 7)
        return stageID.registerFile[idx]
    }
    
    public var load: (UInt16) -> UInt16 = {(addr: UInt16) in
        return 0 // do nothing
    }
    
    public var store: (UInt16, UInt16) -> Void = {(value: UInt16, addr: UInt16) in
        // do nothing
    }

    public let stageIF = IF()
    public let stageID = ID()
    public let stageEX = EX()
    public let stageMEM = MEM()
    public let stageWB = WB()
    
    public var outputIF = IF.Output(ins: 0, pc: 0)
    public var outputID = ID.Output(stallPC: 0, stallIF: 0, ctl_EX: 0b111111111111111111111, a: 0, b: 0, ins: 0)
    public var outputEX = EX.Output(carry: 0, z: 0, ovf: 0, j: 1, jabs: 1, y: 0, hlt: 1, storeOp: 0, ctl: 0b111111111111111111111, selC: 0)
    public var outputMEM = MEM.Output(y: 0, storeOp: 0, selC: 0, ctl: 0b111111111111111111111)
    public var outputWB = WB.Output(c: 0, wrl: 1, wrh: 1, wben: 1)
    
    public override init() {
        super.init()
        stageIF.load = {[weak self] (addr: UInt16) in
            if addr < self!.instructions.count {
                return self!.instructions[Int(addr)]
            } else {
                return 0
            }
        }
        // TODO: need a better way to generate the decode ROM, of course
        stageID.opcodeDecodeROM[267] = 0b111100000000111111110
    }
    
    public func reset() {
        resetCounter = SchematicLevelCPUModel.kNumberOfResetCycles
        while isResetting {
            step()
        }
    }
    
    public func step() {
        let rst: UInt = isResetting ? 0 : 1
        
        // WB
        let inputWB = WB.Input(y: outputMEM.y,
                               storeOp: outputMEM.storeOp,
                               ctl: outputMEM.ctl)
        outputWB = stageWB.step(input: inputWB)
        
        let inputWriteBack = ID.WriteBackInput(c: outputWB.c,
                                               wrh: outputWB.wrh,
                                               wrl: outputWB.wrl,
                                               wben: outputWB.wben,
                                               selC_WB: outputMEM.selC)
        stageID.writeBack(input: inputWriteBack)
        
        // MEM
        let inputMEM = MEM.Input(rdy: 0,
                                 y: outputEX.y,
                                 storeOp: outputEX.storeOp,
                                 selC: outputEX.selC,
                                 ctl: outputEX.ctl)
        outputMEM = stageMEM.step(input: inputMEM)
        
        // EX
        let inputEX = EX.Input(pc: outputIF.pc,
                               ctl: outputID.ctl_EX,
                               a: outputID.a,
                               b: outputID.b,
                               ins: outputID.ins)
        outputEX = stageEX.step(input: inputEX)
        
        // ID
        let inputID = ID.Input(ins: outputIF.ins,
                               selC_MEM: outputMEM.selC,
                               ctl_MEM: outputMEM.ctl)
        outputID = stageID.step(input: inputID)
        
        // IF
        let inputIF = IF.Input(stallPC: outputID.stallPC,
                               stallIF: outputID.stallIF,
                               y: outputEX.y,
                               jabs: outputEX.jabs,
                               j: outputEX.j,
                               rst: rst)
        outputIF = stageIF.step(input: inputIF)
        pc = outputIF.pc
        
        if resetCounter > 0 {
            resetCounter = resetCounter - 1
        }
    }
}
