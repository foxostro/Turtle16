//
//  PipelineStageDecode.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class PipelineStageDecode: NSObject {
    public let instructionDecoder:InstructionDecoder
    public let flags:Flags
    public var isResetting = false
    private var temp = ControlTuple()
    public var logger:Logger?
    
    public init(withDecoder instructionDecoder:InstructionDecoder, flags:Flags) {
        self.instructionDecoder = instructionDecoder
        self.flags = flags
    }
    
    public func decode(withInstruction instruction:Instruction) -> ControlTuple {
        let oldTemp = temp
        temp = ControlTuple()
        temp.controlWord.contents = instructionDecoder.load(opcode: Int(instruction.opcode),
                                                            carryFlag: flags.carryFlag,
                                                            equalFlag: flags.equalFlag)
        temp.immediate = instruction.immediate
        
        if (!isResetting) {
            logger?.append("Decoded instruction %@ to control word %@",
                        instruction, temp.controlWord)
        }
        
        return oldTemp
    }
}
