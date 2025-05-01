//
//  Tack.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/19/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

/// Program are compiled to an intermediate language called Tack
public enum TackInstruction: Hashable, CustomStringConvertible {
    public typealias Label = String
    public typealias Count = Int
    public typealias Offset = Int
    public typealias Imm = Int

    public enum RegisterType: Hashable, CustomStringConvertible {
        case p, w, b, o

        public var description: String {
            switch self {
            case .p: "p"
            case .w: "w"
            case .b: "b"
            case .o: "o"
            }
        }
    }

    public enum Register: Hashable, CustomStringConvertible {
        case p(RegisterPointer), w(Register16), b(Register8), o(RegisterBoolean)

        public static let sp: Register = .p(.sp)
        public static let fp: Register = .p(.fp)
        public static let ra: Register = .p(.ra)

        public var type: RegisterType {
            switch self {
            case .p: .p
            case .w: .w
            case .b: .b
            case .o: .o
            }
        }

        public var unwrapPointer: RegisterPointer? {
            switch self {
            case .p(let p): p
            default: nil
            }
        }

        public var unwrap16: Register16? {
            switch self {
            case .w(let w): w
            default: nil
            }
        }

        public var unwrap8: Register8? {
            switch self {
            case .b(let b): b
            default: nil
            }
        }

        public var unwrapBool: RegisterBoolean? {
            switch self {
            case .o(let o): o
            default: nil
            }
        }

        public var description: String {
            switch self {
            case .p(let register): "\(register)"
            case .w(let register): "\(register)"
            case .b(let register): "\(register)"
            case .o(let register): "\(register)"
            }
        }
    }

    public enum RegisterPointer: Hashable, CustomStringConvertible {
        case sp, fp, ra, p(Int)

        public var description: String {
            switch self {
            case .sp: "sp"
            case .fp: "fp"
            case .ra: "ra"
            case .p(let i): "p\(i)"
            }
        }
    }

    public enum Register16: Hashable, CustomStringConvertible {
        case w(Int)

        public var description: String {
            switch self {
            case .w(let i): "w\(i)"
            }
        }
    }

    public enum RegisterBoolean: Hashable, CustomStringConvertible {
        case o(Int)

        public var description: String {
            switch self {
            case .o(let i): "o\(i)"
            }
        }
    }

    public enum Register8: Hashable, CustomStringConvertible {
        case b(Int)

        public var description: String {
            switch self {
            case .b(let i): "b\(i)"
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

    /// Call the interpreter or runtime
    /// The first register is the address in memory where the syscall number is
    /// stored. The second register is a pointer to the arguments structure.
    case syscall(RegisterPointer, RegisterPointer)

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
    case andiw(Register16, Register16, Imm)  // TODO: consider changing imm instruction mnemonic to andwi because the w operand is to the left of the i operand. This applies generally to many other Tack instructions too.
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


    /// Move a signed sixteen-bit register to a signed eight-bit register
    case movsbw(Register8, Register16)

    /// Move an eight-bit register to a sixteen-bit register, sign-extending to
    /// fill the upper bits.
    case movswb(Register16, Register8)

    /// Move an eight-bit register to a sixteen-bit register, zero-extending to
    /// fill the upper bits.
    case movzwb(Register16, Register8)

    /// Move an unsigned sixteen-bit register to an unsigned eight-bit register
    case movzbw(Register8, Register16)

    /// Reinterpret the bit pattern of the source register as a new value in a
    /// destination register of a different type, with architecture-specific
    /// results.
    case bitcast(Register, Register)


    public var description: String {
        switch self {
        case .nop: "NOP"
        case .hlt: "HLT"
        case .call(let target): "CALL \(target)"
        case .callptr(let register): "CALLPTR \(register)"
        case .enter(let count): "ENTER \(count)"
        case .leave: "LEAVE"
        case .ret: "RET"
        case .jmp(let target): "JMP \(target)"
        case .la(let dst, let label): "LA \(dst), \(label)"
        case .ststr(let dst, let str): "STSTR \(dst), \"\(str)\""
        case .memcpy(let dst, let src, let count): "MEMCPY \(dst), \(src), \(count)"
        case .alloca(let dst, let count): "ALLOCA \(dst), \(count)"
        case .free(let count): "FREE \(count)"
        case .inlineAssembly(let asm): "ASM \(makeInlineAssemblyDescription(asm))"
        case .syscall(let n, let ptr): "SYSCALL \(n), \(ptr)"

        case .bz(let test, let target): "BZ \(test) \(target)"
        case .bnz(let test, let target): "BNZ \(test) \(target)"
        case .not(let dst, let src): "NOT \(dst), \(src)"
        case .eqo(let c, let a, let b): "EQO \(c), \(a), \(b)"
        case .neo(let c, let a, let b): "NEO \(c), \(a), \(b)"
        case .lio(let dst, let imm): "LIO \(dst), \(imm)"
        case .lo(let dst, let addr, let offset): "LO \(dst), \(addr), \(offset)"
        case .so(let src, let addr, let offset): "SO \(src), \(addr), \(offset)"

        case .eqp(let c, let a, let b): "EQP \(c), \(a), \(b)"
        case .nep(let c, let a, let b): "NEP \(c), \(a), \(b)"
        case .lip(let dst, let imm): "LIP \(dst), \(imm)"
        case .addip(let c, let a, let b): "ADDIP \(c), \(a), \(b)"
        case .subip(let c, let a, let b): "SUBIP \(c), \(a), \(b)"
        case .addpw(let c, let a, let b): "ADDPW \(c), \(a), \(b)"
        case .lp(let dst, let addr, let offset): "LP \(dst), \(addr), \(offset)"
        case .sp(let src, let addr, let offset): "SP \(src), \(addr), \(offset)"

        case .lw(let dst, let addr, let offset): "LW \(dst), \(addr), \(offset)"
        case .sw(let src, let addr, let offset): "SW \(src), \(addr), \(offset)"
        case .bzw(let test, let target): "BZW \(test) \(target)"
        case .andiw(let c, let a, let b): "ANDIW \(c), \(a), \(b)"
        case .addiw(let c, let a, let b): "ADDIW \(c), \(a), \(b)"
        case .subiw(let c, let a, let b): "SUBIW \(c), \(a), \(b)"
        case .muliw(let c, let a, let b): "MULIIW \(c), \(a), \(b)"
        case .liw(let dst, let imm): "LIW \(dst), \(imm)"
        case .liuw(let dst, let imm): "LIUW \(dst), \(imm)"
        case .andw(let c, let a, let b): "ANDW \(c), \(a), \(b)"
        case .orw(let c, let a, let b): "ORW \(c), \(a), \(b)"
        case .xorw(let c, let a, let b): "XORW \(c), \(a), \(b)"
        case .negw(let c, let a): "NEGW \(c), \(a)"
        case .addw(let c, let a, let b): "ADDW \(c), \(a), \(b)"
        case .subw(let c, let a, let b): "SUBW \(c), \(a), \(b)"
        case .mulw(let c, let a, let b): "MULW \(c), \(a), \(b)"
        case .divw(let c, let a, let b): "DIVW \(c), \(a), \(b)"
        case .divuw(let c, let a, let b): "DIVUW \(c), \(a), \(b)"
        case .modw(let c, let a, let b): "MODW \(c), \(a), \(b)"
        case .lslw(let c, let a, let b): "LSLW \(c), \(a), \(b)"
        case .lsrw(let c, let a, let b): "LSRW \(c), \(a), \(b)"
        case .eqw(let c, let a, let b): "EQW \(c), \(a), \(b)"
        case .new(let c, let a, let b): "NEW \(c), \(a), \(b)"
        case .ltw(let c, let a, let b): "LTW \(c), \(a), \(b)"
        case .gew(let c, let a, let b): "GEW \(c), \(a), \(b)"
        case .lew(let c, let a, let b): "LEW \(c), \(a), \(b)"
        case .gtw(let c, let a, let b): "GTW \(c), \(a), \(b)"
        case .ltuw(let c, let a, let b): "LTUW \(c), \(a), \(b)"
        case .geuw(let c, let a, let b): "GEUW \(c), \(a), \(b)"
        case .leuw(let c, let a, let b): "LEUW \(c), \(a), \(b)"
        case .gtuw(let c, let a, let b): "GTUW \(c), \(a), \(b)"

        case .lb(let dst, let addr, let offset): "LB \(dst), \(addr), \(offset)"
        case .sb(let src, let addr, let offset): "SB \(src), \(addr), \(offset)"
        case .lib(let dst, let imm): "LIB \(dst), \(imm)"
        case .liub(let dst, let imm): "LIUB \(dst), \(imm)"
        case .andb(let c, let a, let b): "ANDB \(c), \(a), \(b)"
        case .orb(let c, let a, let b): "ORB \(c), \(a), \(b)"
        case .xorb(let c, let a, let b): "XORB \(c), \(a), \(b)"
        case .negb(let c, let a): "NEGB \(c), \(a)"
        case .addb(let c, let a, let b): "ADDB \(c), \(a), \(b)"
        case .subb(let c, let a, let b): "SUBB \(c), \(a), \(b)"
        case .mulb(let c, let a, let b): "MULB \(c), \(a), \(b)"
        case .divb(let c, let a, let b): "DIVB \(c), \(a), \(b)"
        case .divub(let c, let a, let b): "DIVU \(c), \(a), \(b)"
        case .modb(let c, let a, let b): "MODB \(c), \(a), \(b)"
        case .lslb(let c, let a, let b): "LSLB \(c), \(a), \(b)"
        case .lsrb(let c, let a, let b): "LSRB \(c), \(a), \(b)"
        case .eqb(let c, let a, let b): "EQB \(c), \(a), \(b)"
        case .neb(let c, let a, let b): "NEB \(c), \(a), \(b)"
        case .ltb(let c, let a, let b): "LTB \(c), \(a), \(b)"
        case .geb(let c, let a, let b): "GEB \(c), \(a), \(b)"
        case .leb(let c, let a, let b): "LEB \(c), \(a), \(b)"
        case .gtb(let c, let a, let b): "GTB \(c), \(a), \(b)"
        case .ltub(let c, let a, let b): "LTUB \(c), \(a), \(b)"
        case .geub(let c, let a, let b): "GEUB \(c), \(a), \(b)"
        case .leub(let c, let a, let b): "LEUB \(c), \(a), \(b)"
        case .gtub(let c, let a, let b): "GTUB \(c), \(a), \(b)"

        case .movsbw(let dst, let src): "MOVSBW \(dst), \(src)"
        case .movswb(let dst, let src): "MOVSWB \(dst), \(src)"
        case .movzwb(let dst, let src): "MOVZWB \(dst), \(src)"
        case .movzbw(let dst, let src): "MOVZBW \(dst), \(src)"
        case .bitcast(let dst, let src): "BITCAST \(dst), \(src)"
        }
    }

    private func makeInlineAssemblyDescription(_ asm: String) -> String {
        if asm == "" {
            return "\"\""
        }

        let lines = asm.split(separator: "\n")
        guard lines.count == 1 else {
            let formatted = lines.map { "\t\($0)" }.joined(separator: "\n")
            return "\"\"\"\n\(formatted)\t\"\"\""
        }
        return "\"\(lines.first!)\""
    }
}

/// Allows a TackInstruction to be embedded in an Abstract Syntax Tree
public final class TackInstructionNode: AbstractSyntaxTreeNode {
    public let instruction: TackInstruction
    public let symbols: Env?

    public convenience init(_ instruction: TackInstruction) {
        self.init(
            instruction: instruction,
            sourceAnchor: nil,
            symbols: nil
        )
    }

    public init(
        instruction: TackInstruction,
        sourceAnchor: SourceAnchor?,
        symbols: Env?,
        id: ID = ID()
    ) {
        self.instruction = instruction
        self.symbols = symbols
        super.init(sourceAnchor: sourceAnchor, id: id)
    }

    public func withSymbols(_ symbols: Env?) -> TackInstructionNode {
        TackInstructionNode(
            instruction: instruction,
            sourceAnchor: sourceAnchor,
            symbols: symbols,
            id: id
        )
    }

    public func withInstruction(_ instruction: TackInstruction) -> TackInstructionNode {
        TackInstructionNode(
            instruction: instruction,
            sourceAnchor: sourceAnchor,
            symbols: symbols,
            id: id
        )
    }

    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> TackInstructionNode {
        TackInstructionNode(
            instruction: instruction,
            sourceAnchor: sourceAnchor,
            symbols: symbols,
            id: id
        )
    }

    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard instruction == rhs.instruction else { return false }

        // Symbol tables do not affect equality.

        return true
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(instruction)
        // Symbol tables do not affect the hash.
    }

    public override func makeIndentedDescription(
        depth: Int,
        wantsLeadingWhitespace: Bool = false
    ) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let result = "\(indent)\(instruction)"
        return result
    }
}

/// Representation of the program in the Tack intermediate language.
/// This can be compiled to assembly code for some target, or it can be executed
/// in the Tack virtual machine.
public struct TackProgram: Equatable {
    public let instructions: [TackInstruction]
    public let sourceAnchor: [SourceAnchor?]
    public let symbols: [Env?]
    public let subroutines: [String?]
    public let labels: [String: Int]
    public let ast: AbstractSyntaxTreeNode

    public init(
        instructions: [TackInstruction] = [],
        sourceAnchor: [SourceAnchor?]? = nil,
        symbols: [Env?]? = nil,
        subroutines: [String?]? = nil,
        labels: [String: Int] = [:],
        ast: AbstractSyntaxTreeNode = Seq()
    ) {
        self.instructions = instructions
        self.labels = labels
        self.ast = ast

        if let sourceAnchor {
            assert(sourceAnchor.count == instructions.count)
            self.sourceAnchor = sourceAnchor
        }
        else {
            self.sourceAnchor = [SourceAnchor?](repeating: nil, count: instructions.count)
        }

        if let symbols {
            assert(symbols.count == instructions.count)
            self.symbols = symbols
        }
        else {
            self.symbols = [Env?](repeating: nil, count: instructions.count)
        }

        if let subroutines {
            assert(subroutines.count == instructions.count)
            self.subroutines = subroutines
        }
        else {
            self.subroutines = [String?](repeating: nil, count: instructions.count)
        }
    }

    public var listing: String {
        var rowToLabel: [Int: String] = [:]
        for key in labels.keys {
            if let row = labels[key] {
                rowToLabel[row] = key
            }
        }
        var rows: [(Int, String?, String)] = []
        for i in 0..<instructions.count {
            let label = rowToLabel[i]
            let insDesc = "\(instructions[i])"
            rows.append((i, label, insDesc))
        }
        var longestLabelLength = 0
        for (_, label, _) in rows {
            if let label {
                longestLabelLength = max(longestLabelLength, label.count + 2)
            }
        }
        var lines: [String] = []
        for (addr, label, insDesc) in rows {
            let labelCol: String
            if let label {
                let formattedLabelPart = "\(label): "
                let pad = String(
                    repeating: " ",
                    count: longestLabelLength - formattedLabelPart.count
                )
                labelCol = pad + formattedLabelPart
            }
            else {
                labelCol = String(repeating: " ", count: longestLabelLength)
            }
            let addrCol = addr.hexadecimalString
            lines.append("\(addrCol)  \(labelCol)\(insDesc)")
        }
        let result = lines.joined(separator: "\n")
        return result
    }
}

extension SymbolType {
    public var primitiveType: TackInstruction.RegisterType? {
        switch self {
        case .booleanType:
            return .o

        case .void:
            return .w

        case .pointer, .constPointer:
            return .p

        case .arithmeticType(.mutableInt(let intClass)),
            .arithmeticType(.immutableInt(let intClass)):
            switch intClass {
            case .u16, .i16: return .w
            case .u8, .i8: return .b
            }

        case .arithmeticType(.compTimeInt(let v)):
            let intClass = IntClass.smallestClassContaining(value: v)
            switch intClass {
            case .u16, .i16: return .w
            case .u8, .i8: return .b
            case .none: return nil
            }

        default:
            return nil
        }
    }
}

extension Int {
    fileprivate var hexadecimalString: String {
        String(format: "%04x", self)
    }
}
