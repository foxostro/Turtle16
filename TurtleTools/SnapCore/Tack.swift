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
            case let .p(p): p
            default: nil
            }
        }

        public var unwrap16: Register16? {
            switch self {
            case let .w(w): w
            default: nil
            }
        }

        public var unwrap8: Register8? {
            switch self {
            case let .b(b): b
            default: nil
            }
        }

        public var unwrapBool: RegisterBoolean? {
            switch self {
            case let .o(o): o
            default: nil
            }
        }

        public var description: String {
            switch self {
            case let .p(register): "\(register)"
            case let .w(register): "\(register)"
            case let .b(register): "\(register)"
            case let .o(register): "\(register)"
            }
        }
    }

    public enum RegisterPointer: Sendable, Hashable, CustomStringConvertible {
        case sp, fp, ra, p(Int)

        public var description: String {
            switch self {
            case .sp: "sp"
            case .fp: "fp"
            case .ra: "ra"
            case let .p(i): "p\(i)"
            }
        }
    }

    public enum Register16: Sendable, Hashable, CustomStringConvertible {
        case w(Int)

        public var description: String {
            switch self {
            case let .w(i): "w\(i)"
            }
        }
    }

    public enum RegisterBoolean: Sendable, Hashable, CustomStringConvertible {
        case o(Int)

        public var description: String {
            switch self {
            case let .o(i): "o\(i)"
            }
        }
    }

    public enum Register8: Sendable, Hashable, CustomStringConvertible {
        case b(Int)

        public var description: String {
            switch self {
            case let .b(i): "b\(i)"
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
    case andiw(
        Register16,
        Register16,
        Imm
    ) // TODO: consider changing imm instruction mnemonic to andwi because the w operand is to the left of the i operand. This applies generally to many other Tack instructions too.
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

    /// Move a pointer value from one register to another
    case movp(RegisterPointer, RegisterPointer)

    /// Move a sixteen-bit unsigned value from one register to another
    case movw(Register16, Register16)

    /// Move an eight-bit unsigned value from one register to another
    case movb(Register8, Register8)

    /// Move a boolean value from one register to another
    case movo(RegisterBoolean, RegisterBoolean)

    /// Reinterpret the bit pattern of the source register as a new value in a
    /// destination register of a different type, with architecture-specific
    /// results.
    case bitcast(Register, Register)

    public var description: String {
        switch self {
        case .nop: "NOP"
        case .hlt: "HLT"
        case let .call(target): "CALL \(target)"
        case let .callptr(register): "CALLPTR \(register)"
        case let .enter(count): "ENTER \(count)"
        case .leave: "LEAVE"
        case .ret: "RET"
        case let .jmp(target): "JMP \(target)"
        case let .la(dst, label): "LA \(dst), \(label)"
        case let .ststr(dst, str): "STSTR \(dst), \"\(str)\""
        case let .memcpy(dst, src, count): "MEMCPY \(dst), \(src), \(count)"
        case let .alloca(dst, count): "ALLOCA \(dst), \(count)"
        case let .free(count): "FREE \(count)"
        case let .inlineAssembly(asm): "ASM \(makeInlineAssemblyDescription(asm))"
        case let .syscall(n, ptr): "SYSCALL \(n), \(ptr)"
        case let .bz(test, target): "BZ \(test) \(target)"
        case let .bnz(test, target): "BNZ \(test) \(target)"
        case let .not(dst, src): "NOT \(dst), \(src)"
        case let .eqo(c, a, b): "EQO \(c), \(a), \(b)"
        case let .neo(c, a, b): "NEO \(c), \(a), \(b)"
        case let .lio(dst, imm): "LIO \(dst), \(imm)"
        case let .lo(dst, addr, offset): "LO \(dst), \(addr), \(offset)"
        case let .so(src, addr, offset): "SO \(src), \(addr), \(offset)"
        case let .eqp(c, a, b): "EQP \(c), \(a), \(b)"
        case let .nep(c, a, b): "NEP \(c), \(a), \(b)"
        case let .lip(dst, imm): "LIP \(dst), \(imm)"
        case let .addip(c, a, b): "ADDIP \(c), \(a), \(b)"
        case let .subip(c, a, b): "SUBIP \(c), \(a), \(b)"
        case let .addpw(c, a, b): "ADDPW \(c), \(a), \(b)"
        case let .lp(dst, addr, offset): "LP \(dst), \(addr), \(offset)"
        case let .sp(src, addr, offset): "SP \(src), \(addr), \(offset)"
        case let .lw(dst, addr, offset): "LW \(dst), \(addr), \(offset)"
        case let .sw(src, addr, offset): "SW \(src), \(addr), \(offset)"
        case let .bzw(test, target): "BZW \(test) \(target)"
        case let .andiw(c, a, b): "ANDIW \(c), \(a), \(b)"
        case let .addiw(c, a, b): "ADDIW \(c), \(a), \(b)"
        case let .subiw(c, a, b): "SUBIW \(c), \(a), \(b)"
        case let .muliw(c, a, b): "MULIIW \(c), \(a), \(b)"
        case let .liw(dst, imm): "LIW \(dst), \(imm)"
        case let .liuw(dst, imm): "LIUW \(dst), \(imm)"
        case let .andw(c, a, b): "ANDW \(c), \(a), \(b)"
        case let .orw(c, a, b): "ORW \(c), \(a), \(b)"
        case let .xorw(c, a, b): "XORW \(c), \(a), \(b)"
        case let .negw(c, a): "NEGW \(c), \(a)"
        case let .addw(c, a, b): "ADDW \(c), \(a), \(b)"
        case let .subw(c, a, b): "SUBW \(c), \(a), \(b)"
        case let .mulw(c, a, b): "MULW \(c), \(a), \(b)"
        case let .divw(c, a, b): "DIVW \(c), \(a), \(b)"
        case let .divuw(c, a, b): "DIVUW \(c), \(a), \(b)"
        case let .modw(c, a, b): "MODW \(c), \(a), \(b)"
        case let .lslw(c, a, b): "LSLW \(c), \(a), \(b)"
        case let .lsrw(c, a, b): "LSRW \(c), \(a), \(b)"
        case let .eqw(c, a, b): "EQW \(c), \(a), \(b)"
        case let .new(c, a, b): "NEW \(c), \(a), \(b)"
        case let .ltw(c, a, b): "LTW \(c), \(a), \(b)"
        case let .gew(c, a, b): "GEW \(c), \(a), \(b)"
        case let .lew(c, a, b): "LEW \(c), \(a), \(b)"
        case let .gtw(c, a, b): "GTW \(c), \(a), \(b)"
        case let .ltuw(c, a, b): "LTUW \(c), \(a), \(b)"
        case let .geuw(c, a, b): "GEUW \(c), \(a), \(b)"
        case let .leuw(c, a, b): "LEUW \(c), \(a), \(b)"
        case let .gtuw(c, a, b): "GTUW \(c), \(a), \(b)"
        case let .lb(dst, addr, offset): "LB \(dst), \(addr), \(offset)"
        case let .sb(src, addr, offset): "SB \(src), \(addr), \(offset)"
        case let .lib(dst, imm): "LIB \(dst), \(imm)"
        case let .liub(dst, imm): "LIUB \(dst), \(imm)"
        case let .andb(c, a, b): "ANDB \(c), \(a), \(b)"
        case let .orb(c, a, b): "ORB \(c), \(a), \(b)"
        case let .xorb(c, a, b): "XORB \(c), \(a), \(b)"
        case let .negb(c, a): "NEGB \(c), \(a)"
        case let .addb(c, a, b): "ADDB \(c), \(a), \(b)"
        case let .subb(c, a, b): "SUBB \(c), \(a), \(b)"
        case let .mulb(c, a, b): "MULB \(c), \(a), \(b)"
        case let .divb(c, a, b): "DIVB \(c), \(a), \(b)"
        case let .divub(c, a, b): "DIVU \(c), \(a), \(b)"
        case let .modb(c, a, b): "MODB \(c), \(a), \(b)"
        case let .lslb(c, a, b): "LSLB \(c), \(a), \(b)"
        case let .lsrb(c, a, b): "LSRB \(c), \(a), \(b)"
        case let .eqb(c, a, b): "EQB \(c), \(a), \(b)"
        case let .neb(c, a, b): "NEB \(c), \(a), \(b)"
        case let .ltb(c, a, b): "LTB \(c), \(a), \(b)"
        case let .geb(c, a, b): "GEB \(c), \(a), \(b)"
        case let .leb(c, a, b): "LEB \(c), \(a), \(b)"
        case let .gtb(c, a, b): "GTB \(c), \(a), \(b)"
        case let .ltub(c, a, b): "LTUB \(c), \(a), \(b)"
        case let .geub(c, a, b): "GEUB \(c), \(a), \(b)"
        case let .leub(c, a, b): "LEUB \(c), \(a), \(b)"
        case let .gtub(c, a, b): "GTUB \(c), \(a), \(b)"
        case let .movsbw(dst, src): "MOVSBW \(dst), \(src)"
        case let .movswb(dst, src): "MOVSWB \(dst), \(src)"
        case let .movzwb(dst, src): "MOVZWB \(dst), \(src)"
        case let .movzbw(dst, src): "MOVZBW \(dst), \(src)"
        case let .movp(dst, src): "MOVP \(dst), \(src)"
        case let .movw(dst, src): "MOVW \(dst), \(src)"
        case let .movb(dst, src): "MOVB \(dst), \(src)"
        case let .movo(dst, src): "MOVO \(dst), \(src)"
        case let .bitcast(dst, src): "BITCAST \(dst), \(src)"
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

public extension SymbolType {
    var primitiveType: TackInstruction.RegisterType? {
        switch self {
        case .booleanType:
            return .o

        case .void:
            return .w

        case .pointer,
             .constPointer:
            return .p

        case let .arithmeticType(.mutableInt(intClass)),
             let .arithmeticType(.immutableInt(intClass)):
            switch intClass {
            case .u16,
                 .i16: return .w
            case .u8,
                 .i8: return .b
            }

        case let .arithmeticType(.compTimeInt(v)):
            let intClass = IntClass.smallestClassContaining(value: v)
            switch intClass {
            case .u16,
                 .i16: return .w
            case .u8,
                 .i8: return .b
            case .none: return nil
            }

        default:
            return nil
        }
    }
}

private extension Int {
    var hexadecimalString: String {
        String(format: "%04x", self)
    }
}
