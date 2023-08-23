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
    
    public enum RegisterType: Equatable, Hashable {
        case w, b
        
        public var description: String {
            switch self {
            case .w: return "w"
            case .b: return "b"
            }
        }
    }
    
    public enum Register: Equatable, Hashable {
        case w(Register16), b(Register8)
        
        public static let sp: Register = .w(.sp)
        public static let fp: Register = .w(.fp)
        public static let ra: Register = .w(.ra)
        
        public var type: RegisterType {
            switch self {
            case .w: return .w
            case .b: return .b
            }
        }
        
        public var unwrap16: Register16? {
            switch self {
            case .w(let w): return w
            default:        return nil
            }
        }
        
        public var unwrap8: Register8? {
            switch self {
            case .b(let b): return b
            default:        return nil
            }
        }

        public var description: String {
            switch self {
            case .w(let r): return r.description
            case .b(let r): return r.description
            }
        }
    }
    
    public enum RegisterValue: Equatable, Hashable {
        case w(UInt16), b(UInt8)
        
        public var description: String {
            switch self {
            case .w(let v): return "\(v)"
            case .b(let v): return "\(v)"
            }
        }
    }
    
    public enum Register16: Equatable, Hashable {
        case sp, fp, ra, w(Int)
        
        public var description: String {
            switch self {
            case .sp:
                return "sp"
            case .fp:
                return "fp"
            case .ra:
                return "ra"
            case .w(let i):
                return "w\(i)"
            }
        }
    }
    
    public typealias RegisterPointer = Register16 // TODO: RegisterPointer should be a distinct type from Register16
    public typealias RegisterBoolean = Register16 // TODO: RegisterBoolean should be a distinct type from Register16
    
    public enum Register8: Equatable, Hashable {
        case b(Int)
        
        public var description: String {
            switch self {
            case .b(let i): return "b\(i)"
            }
        }
    }
    
    case nop
    case hlt
    case call(Label)
    case callptr(RegisterPointer)
    case enter(Count)
    case leave
    case ret
    case jmp(Label)
    case la(RegisterPointer, Label)
    case ststr(RegisterPointer, String)
    case memcpy(RegisterPointer, RegisterPointer, Count)
    case alloca(RegisterPointer, Count)
    case free(Count)
    case inlineAssembly(String)
    case syscall(Register16, RegisterPointer) // first register is the syscall number, second is a pointer to the arguments structure
    
    case bz(RegisterBoolean, Label)
    case bnz(RegisterBoolean, Label)
    
    case load16(Register16, RegisterPointer, Offset)
    case store16(Register16, RegisterPointer, Offset)
    case andi16(Register16, Register16, Imm)
    case addi16(Register16, Register16, Imm)
    case subi16(Register16, Register16, Imm)
    case muli16(Register16, Register16, Imm)
    case li16(Register16, Int)
    case liu16(Register16, Int)
    case and16(Register16, Register16, Register16)
    case or16(Register16, Register16, Register16)
    case xor16(Register16, Register16, Register16)
    case neg16(Register16, Register16)
    case not16(Register16, Register16)
    case add16(Register16, Register16, Register16)
    case sub16(Register16, Register16, Register16)
    case mul16(Register16, Register16, Register16)
    case div16(Register16, Register16, Register16)
    case mod16(Register16, Register16, Register16)
    case lsl16(Register16, Register16, Register16)
    case lsr16(Register16, Register16, Register16)
    case eq16(RegisterBoolean, Register16, Register16)
    case ne16(RegisterBoolean, Register16, Register16)
    case lt16(RegisterBoolean, Register16, Register16)
    case ge16(RegisterBoolean, Register16, Register16)
    case le16(RegisterBoolean, Register16, Register16)
    case gt16(RegisterBoolean, Register16, Register16)
    case ltu16(RegisterBoolean, Register16, Register16)
    case geu16(RegisterBoolean, Register16, Register16)
    case leu16(RegisterBoolean, Register16, Register16)
    case gtu16(RegisterBoolean, Register16, Register16)
    
    case load8(Register8, RegisterPointer, Offset)
    case store8(Register8, RegisterPointer, Offset)
    case li8(Register8, Int)
    case liu8(Register8, Int)
    case and8(Register8, Register8, Register8)
    case or8(Register8, Register8, Register8)
    case xor8(Register8, Register8, Register8)
    case neg8(Register8, Register8)
    case not8(Register8, Register8)
    case add8(Register8, Register8, Register8)
    case sub8(Register8, Register8, Register8)
    case mul8(Register8, Register8, Register8)
    case div8(Register8, Register8, Register8)
    case mod8(Register8, Register8, Register8)
    case lsl8(Register8, Register8, Register8)
    case lsr8(Register8, Register8, Register8)
    case eq8(RegisterBoolean, Register8, Register8)
    case ne8(RegisterBoolean, Register8, Register8)
    case lt8(RegisterBoolean, Register8, Register8)
    case ge8(RegisterBoolean, Register8, Register8)
    case le8(RegisterBoolean, Register8, Register8)
    case gt8(RegisterBoolean, Register8, Register8)
    case ltu8(RegisterBoolean, Register8, Register8)
    case geu8(RegisterBoolean, Register8, Register8)
    case leu8(RegisterBoolean, Register8, Register8)
    case gtu8(RegisterBoolean, Register8, Register8)
    
    case movsbw(Register8, Register16) // Move a signed sixteen-bit register to a signed eight-bit register
    case movswb(Register16, Register8) // Move an eight-bit register to a sixteen-bit register, sign-extending to fill the upper bits.
    case movzwb(Register16, Register8) // Move an eight-bit register to a sixteen-bit register, zero-extending to fill the upper bits.
    case movzbw(Register8, Register16) // Move an unsigned sixteen-bit register to an unsigned eight-bit register
    
    public var description: String {
        switch self {
        case .nop: return "NOP"
        case .hlt: return "HLT"
        case .call(let target): return "CALL \(target)"
        case .callptr(let register): return "CALLPTR \(register.description)"
        case .enter(let count): return "ENTER \(count)"
        case .leave: return "LEAVE"
        case .ret: return "RET"
        case .jmp(let target): return "JMP \(target)"
        case .la(let dst, let label): return "LA \(dst.description), \(label)"
        case .ststr(let dst, let str): return "STSTR \(dst.description), \"\(str)\""
        case .memcpy(let dst, let src, let count): return "MEMCPY \(dst.description), \(src.description), \(count)"
        case .alloca(let dst, let count): return "ALLOCA \(dst.description), \(count)"
        case .free(let count): return "FREE \(count)"
        case .inlineAssembly(let asm): return "ASM \(makeInlineAssemblyDescription(asm))"
        case .syscall(let n, let ptr): return "SYSCALL \(n.description), \(ptr.description)"
        
        case .bz(let test, let target): return "BZ \(test) \(target)"
        case .bnz(let test, let target): return "BNZ \(test) \(target)"
            
        case .load16(let dst, let addr, let offset): return "LOAD16 \(dst.description), \(addr.description), \(offset)"
        case .store16(let src, let addr, let offset): return "STORE16 \(src.description), \(addr.description), \(offset)"
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
        case .not16(let dst, let src): return "NOT16 \(dst.description), \(src.description)"
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
        
        case .load8(let dst, let addr, let offset): return "LOAD8 \(dst.description), \(addr.description), \(offset)"
        case .store8(let src, let addr, let offset): return "STORE8 \(src.description), \(addr.description), \(offset)"
        case .li8(let dst, let imm): return "LI8 \(dst.description), \(imm)"
        case .liu8(let dst, let imm): return "LIU8 \(dst.description), \(imm)"
        case .and8(let c, let a, let b): return "AND8 \(c.description), \(a.description), \(b.description)"
        case .or8(let c, let a, let b): return "OR8 \(c.description), \(a.description), \(b.description)"
        case .xor8(let c, let a, let b): return "XOR8 \(c.description), \(a.description), \(b.description)"
        case .neg8(let c, let a): return "NEG8 \(c.description), \(a.description)"
        case .not8(let dst, let src): return "NOT8 \(dst.description), \(src.description)"
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
        case .movsbw(let dst, let src): return "MOVSBW \(dst.description), \(src.description)"
        case .movswb(let dst, let src): return "MOVSWB \(dst.description), \(src.description)"
        case .movzwb(let dst, let src): return "MOVZWB \(dst.description), \(src.description)"
        case .movzbw(let dst, let src): return "MOVZBW \(dst.description), \(src.description)"
        }
    }
    
    private func makeInlineAssemblyDescription(_ asm: String) -> String {
        if asm == "" {
            return "\"\""
        }
        
        let lines = asm.split(separator: "\n")
        if lines.count == 1 {
            return "\"\(lines.first!)\""
        }
        else {
            let formatted = lines.map{"\t\($0)"}.joined(separator: "\n")
            return "\"\"\"\n\(formatted)\t\"\"\""
        }
    }
}

// Allows a TackInstruction to be embedded in an Abstract Syntax Tree
public class TackInstructionNode: AbstractSyntaxTreeNode {
    public let instruction: TackInstruction
    public let symbols: SymbolTable?
    
    public convenience init(_ instruction: TackInstruction) {
        self.init(instruction: instruction,
                  sourceAnchor: nil,
                  symbols: nil)
    }
    
    public init(instruction: TackInstruction,
                sourceAnchor: SourceAnchor?,
                symbols: SymbolTable?) {
        self.instruction = instruction
        self.symbols = symbols
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public func withSymbols(_ symbols: SymbolTable?) -> TackInstructionNode {
        if (self.symbols != nil) || (self.symbols == symbols) {
            return self
        }
        return TackInstructionNode(
            instruction: instruction,
            sourceAnchor: sourceAnchor,
            symbols: symbols)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> TackInstructionNode {
        if (self.sourceAnchor != nil) || (self.sourceAnchor == sourceAnchor) {
            return self
        }
        return TackInstructionNode(
            instruction: instruction,
            sourceAnchor: sourceAnchor,
            symbols: symbols)
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
        
        // Symbol tables do not affect equality.
        
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(instruction)
        // Symbol tables do not affect the hash.
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let result = "\(indent)\(instruction.description)"
        return result
    }
}

// Representation of the program in the Tack intermediate language.
// This can be compiled to assembly code for some target, or it can be executed
// in the Tack virtual machine.
public struct TackProgram: Equatable {
    public let instructions: [TackInstruction]
    public let sourceAnchor: [SourceAnchor?]
    public let symbols: [SymbolTable?]
    public let subroutines: [String?]
    public let labels: [String : Int]
    public let ast: AbstractSyntaxTreeNode
    
    public init(instructions: [TackInstruction] = [],
                sourceAnchor: [SourceAnchor?]? = nil,
                symbols: [SymbolTable?]? = nil,
                subroutines: [String?]? = nil,
                labels: [String : Int] = [:],
                ast: AbstractSyntaxTreeNode = Seq()) {
        self.instructions = instructions
        self.labels = labels
        self.ast = ast
        
        if let sourceAnchor {
            assert(sourceAnchor.count == instructions.count)
            self.sourceAnchor = sourceAnchor
        }
        else {
            self.sourceAnchor = Array<SourceAnchor?>(repeating: nil, count: instructions.count)
        }
        
        if let symbols {
            assert(symbols.count == instructions.count)
            self.symbols = symbols
        }
        else {
            self.symbols = Array<SymbolTable?>(repeating: nil, count: instructions.count)
        }
        
        if let subroutines {
            assert(subroutines.count == instructions.count)
            self.subroutines = subroutines
        }
        else {
            self.subroutines = Array<String?>(repeating: nil, count: instructions.count)
        }
    }
    
    public var listing: String {
        var rowToLabel: [Int : String] = [:]
        for key in labels.keys {
            if let row = labels[key] {
                rowToLabel[row] = key
            }
        }
        var rows: [(Int, String?, String)] = []
        for i in 0..<instructions.count {
            let label = rowToLabel[i]
            let insDesc = instructions[i].description
            rows.append((i, label, insDesc))
        }
        var longestLabelLength = 0
        for (_, label, _) in rows {
            if let label {
                longestLabelLength = max(longestLabelLength, label.count+2)
            }
        }
        var lines: [String] = []
        for (addr, label, insDesc) in rows {
            let labelCol: String
            if let label {
                let formattedLabelPart = "\(label): "
                let pad = String(repeating: " ", count: longestLabelLength-formattedLabelPart.count)
                labelCol = pad + formattedLabelPart
            }
            else {
                labelCol = String(repeating: " ", count: longestLabelLength)
            }
            let addrCol = String(format: "%04x  ", addr)
            lines.append("\(addrCol)\(labelCol)\(insDesc)")
        }
        let result = lines.joined(separator: "\n")
        return result
    }
}

extension SymbolType {
    public var primitiveType: TackInstruction.RegisterType? {
        switch self {
        case .void, .bool:
            return .w
            
        case .pointer, .constPointer:
            return .w
            
        case .arithmeticType(.mutableInt(let intClass)),
             .arithmeticType(.immutableInt(let intClass)):
            switch intClass {
            case .u16, .i16: return .w
            case .u8, .i8:   return .b
            }
            
        case .arithmeticType(.compTimeInt(let v)):
            let intClass = IntClass.smallestClassContaining(value: v)
            switch intClass {
            case .u16, .i16: return .w
            case .u8, .i8:   return .b
            case .none:      return nil
            }
        
        default:
            return nil
        }
    }
}
