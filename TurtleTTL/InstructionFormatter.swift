//
//  InstructionFormatter.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class InstructionFormatter: NSObject {
    let microcodeGenerator: MicrocodeGenerator
    
    public override convenience init() {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        self.init(microcodeGenerator: microcodeGenerator)
    }
    
    public init(microcodeGenerator: MicrocodeGenerator) {
        self.microcodeGenerator = microcodeGenerator
    }
    
    public func format(instruction: Instruction) -> String {
        let maybeMnemonic = microcodeGenerator.getMnemonic(withOpcode: Int(instruction.opcode))
        guard let mnemonic = maybeMnemonic else { return "UNKNOWN" }
        if mnemonic.hasPrefix("ALU") {
            switch instruction.immediate {
            case 0b0110:
                return "CMP"
            case 0b1001:
                return "ADD" + mnemonic.dropFirst(3)
            default:
                return mnemonic
            }
        }
        else if mnemonic == "MOV A, C" {
            return "LI A, \(instruction.immediate)"
        }
        else if mnemonic == "MOV B, C" {
            return "LI B, \(instruction.immediate)"
        }
        else if mnemonic == "MOV D, C" {
            return "LI D, \(instruction.immediate)"
        }
        else if mnemonic == "MOV X, C" {
            return "LI X, \(instruction.immediate)"
        }
        else if mnemonic == "MOV Y, C" {
            return "LI Y, \(instruction.immediate)"
        }
        else if mnemonic == "MOV U, C" {
            return "LI U, \(instruction.immediate)"
        }
        else if mnemonic == "MOV V, C" {
            return "LI V, \(instruction.immediate)"
        }
        
        return mnemonic
    }
    
    public func makeInstructionWithDisassembly(instruction: Instruction) -> Instruction {
        return Instruction(opcode: instruction.opcode,
                           immediate: instruction.immediate,
                           disassembly: format(instruction: instruction))
    }
}
