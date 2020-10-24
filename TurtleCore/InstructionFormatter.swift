//
//  InstructionFormatter.swift
//  TurtleCore
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class InstructionFormatter: NSObject {
    static let sharedMicrocodeGenerator = MicrocodeGenerator.makeMicrocodeGenerator()
    let microcodeGenerator: MicrocodeGenerator
    
    public override convenience init() {
        self.init(microcodeGenerator: InstructionFormatter.sharedMicrocodeGenerator)
    }
    
    public init(microcodeGenerator: MicrocodeGenerator) {
        self.microcodeGenerator = microcodeGenerator
    }
    
    public func format(instruction: Instruction) -> String {
        let maybeMnemonic = microcodeGenerator.getMnemonic(opcode: Int(instruction.opcode))
        guard let mnemonic = maybeMnemonic else { return "UNKNOWN" }
        if mnemonic.hasPrefix("ALUwoC") {
            switch instruction.immediate {
            case 0b0110:
                return "CMP"
            case 0b1001:
                return "ADD" + mnemonic.dropFirst(6)
            default:
                return mnemonic
            }
        }
        else if mnemonic == "MOV A, C" {
            return "LI A, \(String(format: "0x%02x", instruction.immediate))"
        }
        else if mnemonic == "MOV B, C" {
            return "LI B, \(String(format: "0x%02x", instruction.immediate))"
        }
        else if mnemonic == "MOV D, C" {
            return "LI D, \(String(format: "0x%02x", instruction.immediate))"
        }
        else if mnemonic == "MOV X, C" {
            return "LI X, \(String(format: "0x%02x", instruction.immediate))"
        }
        else if mnemonic == "MOV Y, C" {
            return "LI Y, \(String(format: "0x%02x", instruction.immediate))"
        }
        else if mnemonic == "MOV U, C" {
            return "LI U, \(String(format: "0x%02x", instruction.immediate))"
        }
        else if mnemonic == "MOV V, C" {
            return "LI V, \(String(format: "0x%02x", instruction.immediate))"
        }
        else if mnemonic == "MOV M, C" {
            return "LI M, \(String(format: "0x%02x", instruction.immediate))"
        }
        else if mnemonic == "MOV P, C" {
            return "LI P, \(String(format: "0x%02x", instruction.immediate))"
        }
        else if mnemonic == "MOV UV, C" {
            return "LI UV, \(String(format: "0x%02x", instruction.immediate))"
        }
        
        return mnemonic
    }
    
    public func makeInstructionWithDisassembly(instruction: Instruction) -> Instruction {
        return Instruction(opcode: instruction.opcode,
                           immediate: instruction.immediate,
                           disassembly: format(instruction: instruction))
    }
    
    public static func makeInstructionsWithDisassembly(instructions: [Instruction]) -> [Instruction] {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let formatter = InstructionFormatter(microcodeGenerator: microcodeGenerator)
        return instructions.map {
            formatter.makeInstructionWithDisassembly(instruction: $0)
        }
    }
}
