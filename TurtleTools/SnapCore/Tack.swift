//
//  Tack.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/19/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

// Program are compiled to an intermediate language called Tack
public enum TackInstruction: Equatable, Hashable {
    public typealias Label = String
    public typealias Count = Int
    public typealias Offset = Int
    public typealias Imm = Int
    
    public enum Register: Equatable, Hashable {
        case sp, fp, ra, vr(Int)
        
        public var description: String {
            switch self {
            case .sp:
                return "sp"
            case .fp:
                return "fp"
            case .ra:
                return "ra"
            case .vr(let i):
                return "vr\(i)"
            }
        }
    }
    
    case hlt
    case call(Label)
    case callptr(Register)
    case enter(Count)
    case leave
    case ret
    case jmp(Label)
    case not(Register, Register)
    case la(Register, Label)
    case bz(Register, Label)
    case bnz(Register, Label)
    case load(Register, Register, Offset)
    case store(Register, Register, Offset)
    case ststr(Register, Label)
    case memcpy(Register, Register, Count)
    case alloca(Register, Count)
    case free(Count)
    case andi16(Register, Register, Imm)
    case addi16(Register, Register, Imm)
    case subi16(Register, Register, Imm)
    case muli16(Register, Register, Imm)
    case li16(Register, Int)
    case liu16(Register, Int)
    case and16(Register, Register, Register)
    case or16(Register, Register, Register)
    case xor16(Register, Register, Register)
    case neg16(Register, Register)
    case add16(Register, Register, Register)
    case sub16(Register, Register, Register)
    case mul16(Register, Register, Register)
    case div16(Register, Register, Register)
    case mod16(Register, Register, Register)
    case lsl16(Register, Register, Register)
    case lsr16(Register, Register, Register)
    case eq16(Register, Register, Register)
    case ne16(Register, Register, Register)
    case lt16(Register, Register, Register)
    case ge16(Register, Register, Register)
    case le16(Register, Register, Register)
    case gt16(Register, Register, Register)
    case ltu16(Register, Register, Register)
    case geu16(Register, Register, Register)
    case leu16(Register, Register, Register)
    case gtu16(Register, Register, Register)
    case li8(Register, Int)
    case liu8(Register, Int)
    case and8(Register, Register, Register)
    case or8(Register, Register, Register)
    case xor8(Register, Register, Register)
    case neg8(Register, Register)
    case add8(Register, Register, Register)
    case sub8(Register, Register, Register)
    case mul8(Register, Register, Register)
    case div8(Register, Register, Register)
    case mod8(Register, Register, Register)
    case lsl8(Register, Register, Register)
    case lsr8(Register, Register, Register)
    case eq8(Register, Register, Register)
    case ne8(Register, Register, Register)
    case lt8(Register, Register, Register)
    case ge8(Register, Register, Register)
    case le8(Register, Register, Register)
    case gt8(Register, Register, Register)
    case ltu8(Register, Register, Register)
    case geu8(Register, Register, Register)
    case leu8(Register, Register, Register)
    case gtu8(Register, Register, Register)
    case sxt8(Register, Register)
    
    public var description: String {
        switch self {
        case .hlt: return "HLT"
        case .call(let target): return "CALL \(target)"
        case .callptr(let register): return "CALLPTR \(register.description)"
        case .enter(let count): return "ENTER \(count)"
        case .leave: return "LEAVE"
        case .ret: return "RET"
        case .jmp(let target): return "JMP \(target)"
        case .not(let dst, let src): return "NOT \(dst.description), \(src.description)"
        case .la(let dst, let label): return "LA \(dst.description), \(label)"
        case .bz(let test, let target): return "BZ \(test) \(target)"
        case .bnz(let test, let target): return "BNZ \(test) \(target)"
        case .load(let dst, let addr, let offset): return "LOAD \(dst.description), \(addr.description), \(offset)"
        case .store(let src, let addr, let offset): return "STORE \(src.description), \(addr.description), \(offset)"
        case .ststr(let dst, let str): return "STSTR \(dst.description), \"\(str)\""
        case .memcpy(let dst, let src, let count): return "MEMCPY \(dst.description), \(src.description), \(count)"
        case .alloca(let dst, let count): return "ALLOCA \(dst.description), \(count)"
        case .free(let count): return "FREE \(count)"
        case .andi16(let c, let a, let b): return "ANDI16 \(c.description), \(a.description), \(b.description)"
        case .addi16(let c, let a, let b): return "ADDI16 \(c.description), \(a.description), \(b.description)"
        case .subi16(let c, let a, let b): return "SUBI16 \(c.description), \(a.description), \(b.description)"
        case .muli16(let c, let a, let b): return "MULII16 \(c.description), \(a.description), \(b.description)"
        case .li16(let dst, let imm): return "LI16 \(dst.description), \(imm)"
        case .liu16(let dst, let imm): return "LIU16 \(dst.description), \(imm)"
        case .and16(let c, let a, let b): return "AND16 \(c.description), \(a.description), \(b.description)"
        case .or16(let c, let a, let b): return "OR16 \(c.description), \(a.description), \(b.description)"
        case .xor16(let c, let a, let b): return "XOR16 \(c.description), \(a.description), \(b.description)"
        case .neg16(let c, let a): return "NEG16 \(c.description), \(a.description)"
        case .add16(let c, let a, let b): return "ADD16 \(c.description), \(a.description), \(b.description)"
        case .sub16(let c, let a, let b): return "SUB16 \(c.description), \(a.description), \(b.description)"
        case .mul16(let c, let a, let b): return "MUL16 \(c.description), \(a.description), \(b.description)"
        case .div16(let c, let a, let b): return "DIV16 \(c.description), \(a.description), \(b.description)"
        case .mod16(let c, let a, let b): return "MOD16 \(c.description), \(a.description), \(b.description)"
        case .lsl16(let c, let a, let b): return "LSL16 \(c.description), \(a.description), \(b.description)"
        case .lsr16(let c, let a, let b): return "LSR16 \(c.description), \(a.description), \(b.description)"
        case .eq16(let c, let a, let b): return "EQ16 \(c.description), \(a.description), \(b.description)"
        case .ne16(let c, let a, let b): return "NE16 \(c.description), \(a.description), \(b.description)"
        case .lt16(let c, let a, let b): return "LT16 \(c.description), \(a.description), \(b.description)"
        case .ge16(let c, let a, let b): return "GE16 \(c.description), \(a.description), \(b.description)"
        case .le16(let c, let a, let b): return "LE16 \(c.description), \(a.description), \(b.description)"
        case .gt16(let c, let a, let b): return "GT16 \(c.description), \(a.description), \(b.description)"
        case .ltu16(let c, let a, let b): return "LTU16 \(c.description), \(a.description), \(b.description)"
        case .geu16(let c, let a, let b): return "GEU16 \(c.description), \(a.description), \(b.description)"
        case .leu16(let c, let a, let b): return "LEU16 \(c.description), \(a.description), \(b.description)"
        case .gtu16(let c, let a, let b): return "GTU16 \(c.description), \(a.description), \(b.description)"
        case .li8(let dst, let imm): return "LI8 \(dst.description), \(imm)"
        case .liu8(let dst, let imm): return "LIU8 \(dst.description), \(imm)"
        case .and8(let c, let a, let b): return "AND8 \(c.description), \(a.description), \(b.description)"
        case .or8(let c, let a, let b): return "OR8 \(c.description), \(a.description), \(b.description)"
        case .xor8(let c, let a, let b): return "XOR8 \(c.description), \(a.description), \(b.description)"
        case .neg8(let c, let a): return "NEG8 \(c.description), \(a.description)"
        case .add8(let c, let a, let b): return "ADD8 \(c.description), \(a.description), \(b.description)"
        case .sub8(let c, let a, let b): return "SUB8 \(c.description), \(a.description), \(b.description)"
        case .mul8(let c, let a, let b): return "MUL8 \(c.description), \(a.description), \(b.description)"
        case .div8(let c, let a, let b): return "DIV8 \(c.description), \(a.description), \(b.description)"
        case .mod8(let c, let a, let b): return "MOD8 \(c.description), \(a.description), \(b.description)"
        case .lsl8(let c, let a, let b): return "LSL8 \(c.description), \(a.description), \(b.description)"
        case .lsr8(let c, let a, let b): return "LSR8 \(c.description), \(a.description), \(b.description)"
        case .eq8(let c, let a, let b): return "EQ8 \(c.description), \(a.description), \(b.description)"
        case .ne8(let c, let a, let b): return "NE8 \(c.description), \(a.description), \(b.description)"
        case .lt8(let c, let a, let b): return "LT8 \(c.description), \(a.description), \(b.description)"
        case .ge8(let c, let a, let b): return "GE8 \(c.description), \(a.description), \(b.description)"
        case .le8(let c, let a, let b): return "LE8 \(c.description), \(a.description), \(b.description)"
        case .gt8(let c, let a, let b): return "GT8 \(c.description), \(a.description), \(b.description)"
        case .ltu8(let c, let a, let b): return "LTU8 \(c.description), \(a.description), \(b.description)"
        case .geu8(let c, let a, let b): return "GEU8 \(c.description), \(a.description), \(b.description)"
        case .leu8(let c, let a, let b): return "LEU8 \(c.description), \(a.description), \(b.description)"
        case .gtu8(let c, let a, let b): return "GTU8 \(c.description), \(a.description), \(b.description)"
        case .sxt8(let dst, let src): return "SXT8 \(dst.description), \(src.description)"
        }
    }
}

// A program in Tack consists of instrutions and some bits of required metadata.
public struct TackProgram {
    public let instructions: [TackInstruction]
    public let labels: [String: Int]
}

// Allows a TackInstruction to be embedded in an Abstract Syntax Tree
public class TackInstructionNode: AbstractSyntaxTreeNode {
    public let instruction: TackInstruction
    
    public convenience init(_ instruction: TackInstruction) {
        self.init(sourceAnchor: nil, instruction: instruction)
    }
    
    public init(sourceAnchor: SourceAnchor?, instruction: TackInstruction) {
        self.instruction = instruction
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> TackInstructionNode {
        if (self.sourceAnchor != nil) || (self.sourceAnchor == sourceAnchor) {
            return self
        }
        return TackInstructionNode(sourceAnchor: sourceAnchor,
                                   instruction: instruction)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard let rhs = rhs as? TackInstructionNode else {
            return false
        }
        guard instruction == rhs.instruction else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(instruction)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        return "\(indent)\(instruction.description)"
    }
}
