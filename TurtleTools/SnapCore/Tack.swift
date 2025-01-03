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
        case p, w, b, o
        
        public var description: String {
            switch self {
            case .p: return "p"
            case .w: return "w"
            case .b: return "b"
            case .o: return "o"
            }
        }
    }
    
    public enum Register: Equatable, Hashable {
        case p(RegisterPointer), w(Register16), b(Register8), o(RegisterBoolean)
        
        public static let sp: Register = .p(.sp)
        public static let fp: Register = .p(.fp)
        public static let ra: Register = .p(.ra)
        
        public var type: RegisterType {
            switch self {
            case .p: return .p
            case .w: return .w
            case .b: return .b
            case .o: return .o
            }
        }
        
        public var unwrapPointer: RegisterPointer? {
            switch self {
            case .p(let p): return p
            default:        return nil
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
        
        public var unwrapBool: RegisterBoolean? {
            switch self {
            case .o(let o): return o
            default:        return nil
            }
        }

        public var description: String {
            switch self {
            case .p(let register): return register.description
            case .w(let register): return register.description
            case .b(let register): return register.description
            case .o(let register): return register.description
            }
        }
    }
    
    public enum RegisterPointer: Equatable, Hashable {
        case sp, fp, ra, p(Int)
        
        public var description: String {
            switch self {
            case .sp:
                return "sp"
            case .fp:
                return "fp"
            case .ra:
                return "ra"
            case .p(let i):
                return "p\(i)"
            }
        }
    }
    
    public enum Register16: Equatable, Hashable {
        case w(Int)
        
        public var description: String {
            switch self {
            case .w(let i):
                return "w\(i)"
            }
        }
    }
    
    public enum RegisterBoolean: Equatable, Hashable {
        case o(Int)
        
        public var description: String {
            switch self {
            case .o(let i):
                return "o\(i)"
            }
        }
    }
    
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
    case syscall(RegisterPointer, RegisterPointer) // first register is the address in memory where the syscall number is stored, second is a pointer to the arguments structure
    
    case bz(RegisterBoolean, Label)
    case bnz(RegisterBoolean, Label)
    case not(RegisterBoolean, RegisterBoolean)
    case eqo(RegisterBoolean, RegisterBoolean, RegisterBoolean)
    case neo(RegisterBoolean, RegisterBoolean, RegisterBoolean)
    case lio(RegisterBoolean, Bool)
    case lo(RegisterBoolean, RegisterPointer, Offset)
    case so(RegisterBoolean, RegisterPointer, Offset)
    
    case eqp(RegisterBoolean, RegisterPointer, RegisterPointer)
    case nep(RegisterBoolean, RegisterPointer, RegisterPointer)
    case lip(RegisterPointer, Int)
    case addip(RegisterPointer, RegisterPointer, Imm)
    case subip(RegisterPointer, RegisterPointer, Imm)
    case addpw(RegisterPointer, RegisterPointer, Register16)
    case lp(RegisterPointer, RegisterPointer, Offset)
    case sp(RegisterPointer, RegisterPointer, Offset)
    
    case lw(Register16, RegisterPointer, Offset)
    case sw(Register16, RegisterPointer, Offset)
    case bzw(Register16, Label)
    case andiw(Register16, Register16, Imm) // TODO: consider changing imm instruction mnemonic to andwi because the w operand is to the left of the i operand. This applies generally to many other Tack instructions too.
    case addiw(Register16, Register16, Imm)
    case subiw(Register16, Register16, Imm)
    case muliw(Register16, Register16, Imm)
    case liw(Register16, Int)
    case liuw(Register16, Int)
    case andw(Register16, Register16, Register16)
    case orw(Register16, Register16, Register16)
    case xorw(Register16, Register16, Register16)
    case negw(Register16, Register16)
    case addw(Register16, Register16, Register16)
    case subw(Register16, Register16, Register16)
    case mulw(Register16, Register16, Register16)
    case divw(Register16, Register16, Register16)
    case divuw(Register16, Register16, Register16)
    case modw(Register16, Register16, Register16)
    case lslw(Register16, Register16, Register16)
    case lsrw(Register16, Register16, Register16)
    case eqw(RegisterBoolean, Register16, Register16)
    case new(RegisterBoolean, Register16, Register16)
    case ltw(RegisterBoolean, Register16, Register16)
    case gew(RegisterBoolean, Register16, Register16)
    case lew(RegisterBoolean, Register16, Register16)
    case gtw(RegisterBoolean, Register16, Register16)
    case ltuw(RegisterBoolean, Register16, Register16)
    case geuw(RegisterBoolean, Register16, Register16)
    case leuw(RegisterBoolean, Register16, Register16)
    case gtuw(RegisterBoolean, Register16, Register16)
    
    case lb(Register8, RegisterPointer, Offset)
    case sb(Register8, RegisterPointer, Offset)
    case lib(Register8, Int)
    case liub(Register8, Int)
    case andb(Register8, Register8, Register8)
    case orb(Register8, Register8, Register8)
    case xorb(Register8, Register8, Register8)
    case negb(Register8, Register8)
    case addb(Register8, Register8, Register8)
    case subb(Register8, Register8, Register8)
    case mulb(Register8, Register8, Register8)
    case divb(Register8, Register8, Register8)
    case divub(Register8, Register8, Register8)
    case modb(Register8, Register8, Register8)
    case lslb(Register8, Register8, Register8)
    case lsrb(Register8, Register8, Register8)
    case eqb(RegisterBoolean, Register8, Register8)
    case neb(RegisterBoolean, Register8, Register8)
    case ltb(RegisterBoolean, Register8, Register8)
    case geb(RegisterBoolean, Register8, Register8)
    case leb(RegisterBoolean, Register8, Register8)
    case gtb(RegisterBoolean, Register8, Register8)
    case ltub(RegisterBoolean, Register8, Register8)
    case geub(RegisterBoolean, Register8, Register8)
    case leub(RegisterBoolean, Register8, Register8)
    case gtub(RegisterBoolean, Register8, Register8)
    
    case movsbw(Register8, Register16) // Move a signed sixteen-bit register to a signed eight-bit register
    case movswb(Register16, Register8) // Move an eight-bit register to a sixteen-bit register, sign-extending to fill the upper bits.
    case movzwb(Register16, Register8) // Move an eight-bit register to a sixteen-bit register, zero-extending to fill the upper bits.
    case movzbw(Register8, Register16) // Move an unsigned sixteen-bit register to an unsigned eight-bit register
    case bitcast(Register, Register) // Reinterpret the bit pattern of the source register as a new value in a desitnation register of a different type, with architecture-specific results.
    
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
        case .not(let dst, let src): return "NOT \(dst.description), \(src.description)"
        case .eqo(let c, let a, let b): return "EQO \(c.description), \(a.description), \(b.description)"
        case .neo(let c, let a, let b): return "NEO \(c.description), \(a.description), \(b.description)"
        case .lio(let dst, let imm): return "LIO \(dst.description), \(imm)"
        case .lo(let dst, let addr, let offset): return "LO \(dst.description), \(addr.description), \(offset)"
        case .so(let src, let addr, let offset): return "SO \(src.description), \(addr.description), \(offset)"
            
        case .eqp(let c, let a, let b): return "EQP \(c.description), \(a.description), \(b.description)"
        case .nep(let c, let a, let b): return "NEP \(c.description), \(a.description), \(b.description)"
        case .lip(let dst, let imm): return "LIP \(dst.description), \(imm)"
        case .addip(let c, let a, let b): return "ADDIP \(c.description), \(a.description), \(b.description)"
        case .subip(let c, let a, let b): return "SUBIP \(c.description), \(a.description), \(b.description)"
        case .addpw(let c, let a, let b): return "ADDPW \(c.description), \(a.description), \(b.description)"
        case .lp(let dst, let addr, let offset): return "LP \(dst.description), \(addr.description), \(offset)"
        case .sp(let src, let addr, let offset): return "SP \(src.description), \(addr.description), \(offset)"
        
        case .lw(let dst, let addr, let offset): return "LW \(dst.description), \(addr.description), \(offset)"
        case .sw(let src, let addr, let offset): return "SW \(src.description), \(addr.description), \(offset)"
        case .bzw(let test, let target): return "BZW \(test) \(target)"
        case .andiw(let c, let a, let b): return "ANDIW \(c.description), \(a.description), \(b.description)"
        case .addiw(let c, let a, let b): return "ADDIW \(c.description), \(a.description), \(b.description)"
        case .subiw(let c, let a, let b): return "SUBIW \(c.description), \(a.description), \(b.description)"
        case .muliw(let c, let a, let b): return "MULIIW \(c.description), \(a.description), \(b.description)"
        case .liw(let dst, let imm): return "LIW \(dst.description), \(imm)"
        case .liuw(let dst, let imm): return "LIUW \(dst.description), \(imm)"
        case .andw(let c, let a, let b): return "ANDW \(c.description), \(a.description), \(b.description)"
        case .orw(let c, let a, let b): return "ORW \(c.description), \(a.description), \(b.description)"
        case .xorw(let c, let a, let b): return "XORW \(c.description), \(a.description), \(b.description)"
        case .negw(let c, let a): return "NEGW \(c.description), \(a.description)"
        case .addw(let c, let a, let b): return "ADDW \(c.description), \(a.description), \(b.description)"
        case .subw(let c, let a, let b): return "SUBW \(c.description), \(a.description), \(b.description)"
        case .mulw(let c, let a, let b): return "MULW \(c.description), \(a.description), \(b.description)"
        case .divw(let c, let a, let b): return "DIVW \(c.description), \(a.description), \(b.description)"
        case .divuw(let c, let a, let b): return "DIVUW \(c.description), \(a.description), \(b.description)"
        case .modw(let c, let a, let b): return "MODW \(c.description), \(a.description), \(b.description)"
        case .lslw(let c, let a, let b): return "LSLW \(c.description), \(a.description), \(b.description)"
        case .lsrw(let c, let a, let b): return "LSRW \(c.description), \(a.description), \(b.description)"
        case .eqw(let c, let a, let b): return "EQW \(c.description), \(a.description), \(b.description)"
        case .new(let c, let a, let b): return "NEW \(c.description), \(a.description), \(b.description)"
        case .ltw(let c, let a, let b): return "LTW \(c.description), \(a.description), \(b.description)"
        case .gew(let c, let a, let b): return "GEW \(c.description), \(a.description), \(b.description)"
        case .lew(let c, let a, let b): return "LEW \(c.description), \(a.description), \(b.description)"
        case .gtw(let c, let a, let b): return "GTW \(c.description), \(a.description), \(b.description)"
        case .ltuw(let c, let a, let b): return "LTUW \(c.description), \(a.description), \(b.description)"
        case .geuw(let c, let a, let b): return "GEUW \(c.description), \(a.description), \(b.description)"
        case .leuw(let c, let a, let b): return "LEUW \(c.description), \(a.description), \(b.description)"
        case .gtuw(let c, let a, let b): return "GTUW \(c.description), \(a.description), \(b.description)"
        
        case .lb(let dst, let addr, let offset): return "LB \(dst.description), \(addr.description), \(offset)"
        case .sb(let src, let addr, let offset): return "SB \(src.description), \(addr.description), \(offset)"
        case .lib(let dst, let imm): return "LIB \(dst.description), \(imm)"
        case .liub(let dst, let imm): return "LIUB \(dst.description), \(imm)"
        case .andb(let c, let a, let b): return "ANDB \(c.description), \(a.description), \(b.description)"
        case .orb(let c, let a, let b): return "ORB \(c.description), \(a.description), \(b.description)"
        case .xorb(let c, let a, let b): return "XORB \(c.description), \(a.description), \(b.description)"
        case .negb(let c, let a): return "NEGB \(c.description), \(a.description)"
        case .addb(let c, let a, let b): return "ADDB \(c.description), \(a.description), \(b.description)"
        case .subb(let c, let a, let b): return "SUBB \(c.description), \(a.description), \(b.description)"
        case .mulb(let c, let a, let b): return "MULB \(c.description), \(a.description), \(b.description)"
        case .divb(let c, let a, let b): return "DIVB \(c.description), \(a.description), \(b.description)"
        case .divub(let c, let a, let b): return "DIVU \(c.description), \(a.description), \(b.description)"
        case .modb(let c, let a, let b): return "MODB \(c.description), \(a.description), \(b.description)"
        case .lslb(let c, let a, let b): return "LSLB \(c.description), \(a.description), \(b.description)"
        case .lsrb(let c, let a, let b): return "LSRB \(c.description), \(a.description), \(b.description)"
        case .eqb(let c, let a, let b): return "EQB \(c.description), \(a.description), \(b.description)"
        case .neb(let c, let a, let b): return "NEB \(c.description), \(a.description), \(b.description)"
        case .ltb(let c, let a, let b): return "LTB \(c.description), \(a.description), \(b.description)"
        case .geb(let c, let a, let b): return "GEB \(c.description), \(a.description), \(b.description)"
        case .leb(let c, let a, let b): return "LEB \(c.description), \(a.description), \(b.description)"
        case .gtb(let c, let a, let b): return "GTB \(c.description), \(a.description), \(b.description)"
        case .ltub(let c, let a, let b): return "LTUB \(c.description), \(a.description), \(b.description)"
        case .geub(let c, let a, let b): return "GEUB \(c.description), \(a.description), \(b.description)"
        case .leub(let c, let a, let b): return "LEUB \(c.description), \(a.description), \(b.description)"
        case .gtub(let c, let a, let b): return "GTUB \(c.description), \(a.description), \(b.description)"
        case .movsbw(let dst, let src): return "MOVSBW \(dst.description), \(src.description)"
        case .movswb(let dst, let src): return "MOVSWB \(dst.description), \(src.description)"
        case .movzwb(let dst, let src): return "MOVZWB \(dst.description), \(src.description)"
        case .movzbw(let dst, let src): return "MOVZBW \(dst.description), \(src.description)"
        case .bitcast(let dst, let src): return "BITCAST \(dst.description), \(src.description)"
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
                symbols: SymbolTable?,
                id: ID = ID()) {
        self.instruction = instruction
        self.symbols = symbols
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public func withSymbols(_ symbols: SymbolTable?) -> TackInstructionNode {
        TackInstructionNode(
            instruction: instruction,
            sourceAnchor: sourceAnchor,
            symbols: symbols,
            id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> TackInstructionNode {
        TackInstructionNode(instruction: instruction,
                            sourceAnchor: sourceAnchor,
                            symbols: symbols,
                            id: id)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? TackInstructionNode else { return false }
        guard instruction == rhs.instruction else { return false }
        
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
        case .bool:
            return .o
            
        case .void:
            return .w
            
        case .pointer, .constPointer:
            return .p
            
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
