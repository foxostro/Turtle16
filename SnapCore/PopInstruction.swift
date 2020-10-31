//
//  PopInstruction.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleCompilerToolbox

// An instruction in the "Pop" intermediate language.
// This is basically a thin veneer over the actual low-level machine code
// supported by the compiler. It supports labels as an explicit concept, and
// supports some macro instructions to paper over hardware annoyances like
// delay slots.
public enum PopInstruction: Equatable, Hashable {
    case fake // Placeholder instructions. Compiles down to nothing.
    case nop // The CPU executes one NOP instruction, doing nothing.
    case hlt // Halt the computer until reset
    case inuv // Increment the UV register pair
    case inxy // Increment the XY register pair
    case mov(RegisterName, RegisterName) // Copy a value from one bus device to another.
    case li(RegisterName, Int) // Loads an immediate value to the specified destination
    case add(RegisterName) // Result <-- A + B
    case sub(RegisterName) // Result <-- A - B
    case adc(RegisterName) // Result <-- A + B + Cf
    case sbc(RegisterName) // Result <-- A - B - Cf
    case dea(RegisterName) // Result <-- A - 1
    case dca(RegisterName) // Result <-- A - 1, if Cf is set
    case and(RegisterName) // Result <-- A & B
    case or(RegisterName) // Result <-- A | B
    case xor(RegisterName) // Result <-- A ^ B
    case lsl(RegisterName) // Result <-- A << B
    case neg(RegisterName) // Result <-- ~A
    case cmp // The ALU compares A and B and updates flags accordingly.
    case label(String) // declares a label
    case lixy(String) // Loads the sixteen-bit value of the label into XY
    case jalr(String) // unconditional jump-and-link to the specified label
    case explicitJalr // unconditional jump-and-link to the address in XY
    case jmp(String) // unconditional jump to the specified label
    case explicitJmp // unconditional jump to the address in XY
    case jc(String) // Jump if the carry flag is set
    case jnc(String) // Jump if the carry flag is not set
    case je(String) // Jump if the equal flag is set
    case jne(String) // Jump if the equal flag is not set
    case jg(String) // Jump if the flags indicate a Greater Than condition
    case jle(String) // Jump if the flags indicate a Less Than Or Equal To condition
    case jl(String) // Jump if the flags indicate a Less Than condition
    case jge(String) // Jump if the flags indicate a Greater Than Or Equal To condition
    case blt(RegisterName, RegisterName) // Copy a value between peripheral and data devices (or vice versa) and simultaneously increment both sets of address registers
    case blti(RegisterName, Int) // Copy the immediate value to either peripheral memory or RAM, and simultaneously increment UV.
    case copyLabel(Int, String) // (dst, label) -- copies the two-byte address of the given label to the destination address
    
    public var description: String {
        switch self {
        case .fake:
            return "fake"
        
        case .nop:
            return "NOP"
        
        case .hlt:
            return "HLT"
        
        case .inuv:
            return "INUV"
            
        case .inxy:
            return "INXY"
        
        case .mov(let dst, let src):
            return "MOV \(dst), \(src)"
            
        case .li(let dst, let value):
            return "LI \(dst), \(toHex2(value))"
            
        case .add(let dst):
            return "ADD \(dst)"
                 
        case .sub(let dst):
            return "SUB \(dst)"
            
        case .adc(let dst):
            return "ADC \(dst)"
            
        case .sbc(let dst):
            return "SBC \(dst)"
            
        case .dea(let dst):
            return "DEA \(dst)"
            
        case .dca(let dst):
            return "DCA \(dst)"
            
        case .and(let dst):
            return "AND \(dst)"
            
        case .or(let dst):
            return "OR \(dst)"
            
        case .xor(let dst):
            return "XOR \(dst)"
            
        case .lsl(let dst):
            return "LSL \(dst)"
            
        case .neg(let dst):
            return "NEG \(dst)"
            
        case .cmp:
            return "CMP"
            
        case .label(let name):
            return "LABEL \(name)"
            
        case .lixy(let name):
            return "LIXY \(name)"
            
        case .jalr(let name):
            return "JALR \(name)"
            
        case .explicitJalr:
            return "JALR"
            
        case .jmp(let name):
            return "JMP \(name)"
            
        case .explicitJmp:
            return "JMP"
            
        case .jc(let name):
            return "JC \(name)"
            
        case .jnc(let name):
            return "JNC \(name)"
            
        case .je(let name):
            return "JE \(name)"
            
        case .jne(let name):
            return "JNE \(name)"
            
        case .jg(let name):
            return "JG \(name)"
            
        case .jle(let name):
            return "JLE \(name)"
            
        case .jl(let name):
            return "JL \(name)"
            
        case .jge(let name):
            return "JGE \(name)"
            
        case .blt(let dst, let src):
            return "BLT \(dst), \(src)"
            
        case .blti(let dst, let value):
            return "BLTI \(dst), \(toHex2(value))"
            
        case .copyLabel(let dst, let name):
            return "COPY-LABEL \(toHex4(dst)), \(name)"
        }
    }
    
    fileprivate func toHex2(_ value: Int) -> String {
        return String(format: "0x%02x", value)
    }
    
    fileprivate func toHex4(_ value: Int) -> String {
        return String(format: "0x%04x", value)
    }
}
