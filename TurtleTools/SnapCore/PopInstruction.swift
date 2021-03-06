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
    
    public var setOfRegistersOnWhichThisInstructionDepends: Set<RegisterName> {
        switch self {
        case .inuv:
            return [.U, .V]
            
        case .inxy:
            return [.X, .Y]
            
        case .mov(let dst, let src):
            var registers = Set<RegisterName>()
            if dst == .M || src == .M {
                registers.insert(.U)
                registers.insert(.V)
            }
            if dst == .P || src == .P {
                registers.insert(.X)
                registers.insert(.Y)
                registers.insert(.D)
            }
            if (src != .M) && (src != .P) {
                registers.insert(src)
            }
            return registers
            
        case .li(let dst, _):
            if dst == .M {
                return [.U, .V]
            }
            else if dst == .P {
                return [.X, .Y, .D]
            }
            else {
                return []
            }
            
        case .add(let dst), .sub(let dst), .adc(let dst), .sbc(let dst), .dea(let dst), .dca(let dst), .and(let dst), .or(let dst), .xor(let dst), .lsl(let dst), .neg(let dst):
            if dst == .M {
                return [.U, .V, .A, .B]
            }
            else if dst == .P {
                return [.X, .Y, .D, .A, .B]
            }
            else {
                return [.A, .B]
            }
            
        case .cmp:
            return [.A, .B]
        
        case .blt(_, let src):
            assert(src == .M || src == .P)
            return [.U, .V, .X, .Y, .D]
            
        case .blti(let dst, _):
            assert(dst == .M || dst == .P)
            if dst == .M {
                return [.U, .V]
            } else {
                return [.X, .Y, .D]
            }
            
        case .fake, .nop, .hlt, .label, .copyLabel, .lixy, .jalr, .jmp, .jc, .jnc, .je, .jne, .jg, .jle, .jl, .jge, .explicitJalr, .explicitJmp:
            // We cannot reason across basic block boundaries. So just say the
            // branch instructions modify no registers.
            return []
        }
    }
    
    public var setOfRegistersModifiedByThisInstruction: Set<RegisterName> {
        switch self {
        case .inuv:
            return [.U, .V]
            
        case .inxy, .lixy:
            return [.X, .Y]
            
        case .mov(let dst, _), .li(let dst, _), .add(let dst), .sub(let dst), .adc(let dst), .sbc(let dst), .dea(let dst), .dca(let dst), .and(let dst), .or(let dst), .xor(let dst), .lsl(let dst), .neg(let dst):
            if dst == .UV {
                return [.U, .V]
            } else if (dst != .M) && (dst != .P) {
                return [dst]
            } else {
                return []
            }
        
        case .blt(let dst, _):
            assert(dst == .M || dst == .P)
            return [.X, .Y, .U, .V]
            
        case .blti(let dst, _):
            if dst == .M {
                return [.U, .V]
            } else {
                assert(dst == .P)
                return [.X, .Y]
            }
            
        case .fake, .nop, .hlt, .cmp, .explicitJmp, .label, .copyLabel, .jmp, .jc, .jnc, .je, .jne, .jg, .jle, .jl, .jge, .explicitJalr, .jalr:
            // We cannot reason across basic block boundaries. So just say the
            // branch instructions modify no registers.
            return []
        }
    }
    
    public var doesInstructionModifyStateOtherThanRegisterValues: Bool {
        switch self {
        case .fake, .inuv, .inxy, .lixy:
            return false
            
        case .mov(let dst, let src):
            if dst == .M || dst == .P || src == .M || src == .P {
                return true
            } else {
                return false
            }
        
        case .blti(let dst, _), .li(let dst, _):
            if dst == .M || dst == .P {
                return true
            } else {
                return false
            }
            
        case .add, .sub, .adc, .sbc, .dea, .dca, .and, .or, .xor, .lsl, .neg:
            return true
            
        case .nop, .hlt, .cmp, .label, .jalr, .explicitJalr, .jmp, .explicitJmp, .jc, .jnc, .je, .jne, .jg, .jle, .jl, .jge, .blt, .copyLabel:
            return true
        }
    }
}
