//
//  PipelineStageFetch.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class PipelineStageFetch: NSObject {
    public let programCounter:ProgramCounter
    public let instructionROM:InstructionROM
    public var instructionRegister = Instruction()
    public var isResetting = false
    public var logger:Logger?
    
    public init(withProgramCounter programCounter:ProgramCounter, withInstructionROM instructionROM:InstructionROM) {
        self.programCounter = programCounter
        self.instructionROM = instructionROM
    }
    
    public func fetch() -> Instruction {
        let oldInstruction = instructionRegister
        let pc = programCounter.contents
        let newInstruction = instructionROM.load(address: Int(pc))
        if (!isResetting) {
            logger?.append("Fetched new instruction from memory: %@", newInstruction)
        }
        
        instructionRegister = newInstruction
        programCounter.increment()
        
        return oldInstruction;
    }
}
