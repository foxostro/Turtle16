//
//  AssemblerSingleInstructionCodeGenerator.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 5/17/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public final class AssemblerSingleInstructionCodeGenerator {
    public var sourceAnchor: SourceAnchor?
    public let kOpcodeShift = 11
    public let kOperandShiftC = 8
    public let kOperandShiftA = 5
    public let kOperandShiftB = 2

    public enum Register: Int {
        case r0, r1, r2, r3, r4, r5, r6, r7

        public var description: String {
            switch self {
            case .r0: "r0"
            case .r1: "r1"
            case .r2: "r2"
            case .r3: "r3"
            case .r4: "r4"
            case .r5: "r5"
            case .r6: "r6"
            case .r7: "r7"
            }
        }
    }

    public init() {}

    private func makeInstructionX(opcode: Int) -> UInt16 {
        try! makeInstructionIII(opcode: opcode, imm: 0)
    }

    private func makeInstructionRRR(
        opcode: Int,
        c: Register,
        a: Register,
        b: Register
    ) throws -> UInt16 {
        let partOpcode = UInt16((opcode & 0b11111) << kOpcodeShift)
        let partC = UInt16((c.rawValue & 0b111) << kOperandShiftC)
        let partA = UInt16((a.rawValue & 0b111) << kOperandShiftA)
        let partB = UInt16((b.rawValue & 0b111) << kOperandShiftB)
        return partOpcode | partC | partA | partB
    }

    private func makeInstructionRRI(
        opcode: Int,
        c: Register,
        a: Register,
        imm: Int
    ) throws -> UInt16 {
        if imm > 15 {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "offset exceeds positive limit of 15: `\(imm)'"
            )
        }
        if imm < -16 {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "offset exceeds negative limit of -16: `\(imm)'"
            )
        }
        let partOpcode = UInt16((opcode & 0b11111) << kOpcodeShift)
        let partC = UInt16((c.rawValue & 0b111) << kOperandShiftC)
        let partA = UInt16((a.rawValue & 0b111) << kOperandShiftA)
        let partImm = UInt16(imm & 0b11111)
        return partOpcode | partC | partA | partImm
    }

    private func makeInstructionRII(opcode: Int, c: Register, imm: Int) throws -> UInt16 {
        if imm > 255 {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "offset exceeds positive limit of 255: `\(imm)'"
            )
        }
        if imm < -128 {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "offset exceeds negative limit of -128: `\(imm)'"
            )
        }
        let partOpcode = UInt16((opcode & 0b11111) << kOpcodeShift)
        let partC = UInt16((c.rawValue & 0b111) << kOperandShiftC)
        let partImm = UInt16(imm & 0b11111111)
        return partOpcode | partC | partImm
    }

    private func makeInstructionIRR(
        opcode: Int,
        a: Register,
        b: Register,
        imm: Int
    ) throws -> UInt16 {
        if imm > 15 {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "offset exceeds positive limit of 15: `\(imm)'"
            )
        }
        if imm < -16 {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "offset exceeds negative limit of -16: `\(imm)'"
            )
        }
        let partOpcode = UInt16((opcode & 0b11111) << kOpcodeShift)
        let partImmHi = UInt16(((imm & 0b11100) >> 2) << kOperandShiftC)
        let partA = UInt16((a.rawValue & 0b111) << kOperandShiftA)
        let partB = UInt16((b.rawValue & 0b111) << kOperandShiftB)
        let partImmLo = UInt16(imm & 0b11)
        return partOpcode | partImmHi | partA | partB | partImmLo
    }

    private func makeInstructionIII(opcode: Int, imm: Int) throws -> UInt16 {
        if imm > 1023 {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "offset exceeds positive limit of 1023: `\(imm)'"
            )
        }
        if imm < -1024 {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "offset exceeds negative limit of -1024: `\(imm)'"
            )
        }
        let partOpcode = UInt16((opcode & 0b11111) << kOpcodeShift)
        let partImm = UInt16(imm & 0b111_11111111)
        return partOpcode | partImm
    }

    public func nop() -> UInt16 {
        makeInstructionX(opcode: DecoderGenerator.opcodeNop)
    }

    public func hlt() -> UInt16 {
        makeInstructionX(opcode: DecoderGenerator.opcodeHlt)
    }

    public func load(_ destination: Register, _ source: Register, _ offset: Int) throws -> UInt16 {
        try makeInstructionRRI(
            opcode: DecoderGenerator.opcodeLoad,
            c: destination,
            a: source,
            imm: offset
        )
    }

    public func store(_ val: Register, _ addr: Register, _ offset: Int) throws -> UInt16 {
        try makeInstructionIRR(opcode: DecoderGenerator.opcodeStore, a: addr, b: val, imm: offset)
    }

    public func li(_ destination: Register, _ value: Int) throws -> UInt16 {
        try makeInstructionRII(opcode: DecoderGenerator.opcodeLi, c: destination, imm: value)
    }

    public func lui(_ destination: Register, _ value: Int) throws -> UInt16 {
        try makeInstructionRII(opcode: DecoderGenerator.opcodeLui, c: destination, imm: value)
    }

    public func cmp(_ left: Register, _ right: Register) throws -> UInt16 {
        try makeInstructionRRR(opcode: DecoderGenerator.opcodeCmp, c: .r0, a: left, b: right)
    }

    public func add(_ dst: Register, _ left: Register, _ right: Register) throws -> UInt16 {
        try makeInstructionRRR(opcode: DecoderGenerator.opcodeAdd, c: dst, a: left, b: right)
    }

    public func sub(_ dst: Register, _ left: Register, _ right: Register) throws -> UInt16 {
        try makeInstructionRRR(opcode: DecoderGenerator.opcodeSub, c: dst, a: left, b: right)
    }

    public func and(_ dst: Register, _ left: Register, _ right: Register) throws -> UInt16 {
        try makeInstructionRRR(opcode: DecoderGenerator.opcodeAnd, c: dst, a: left, b: right)
    }

    public func or(_ dst: Register, _ left: Register, _ right: Register) throws -> UInt16 {
        try makeInstructionRRR(opcode: DecoderGenerator.opcodeOr, c: dst, a: left, b: right)
    }

    public func xor(_ dst: Register, _ left: Register, _ right: Register) throws -> UInt16 {
        try makeInstructionRRR(opcode: DecoderGenerator.opcodeXor, c: dst, a: left, b: right)
    }

    public func cmpi(_ left: Register, _ right: Int) throws -> UInt16 {
        try makeInstructionRRI(opcode: DecoderGenerator.opcodeCmpi, c: .r0, a: left, imm: right)
    }

    public func addi(_ dst: Register, _ left: Register, _ right: Int) throws -> UInt16 {
        try makeInstructionRRI(opcode: DecoderGenerator.opcodeAddi, c: dst, a: left, imm: right)
    }

    public func subi(_ dst: Register, _ left: Register, _ right: Int) throws -> UInt16 {
        try makeInstructionRRI(opcode: DecoderGenerator.opcodeSubi, c: dst, a: left, imm: right)
    }

    public func andi(_ dst: Register, _ left: Register, _ right: Int) throws -> UInt16 {
        try makeInstructionRRI(opcode: DecoderGenerator.opcodeAndi, c: dst, a: left, imm: right)
    }

    public func ori(_ dst: Register, _ left: Register, _ right: Int) throws -> UInt16 {
        try makeInstructionRRI(opcode: DecoderGenerator.opcodeOri, c: dst, a: left, imm: right)
    }

    public func xori(_ dst: Register, _ left: Register, _ right: Int) throws -> UInt16 {
        try makeInstructionRRI(opcode: DecoderGenerator.opcodeXori, c: dst, a: left, imm: right)
    }

    public func not(_ dst: Register, _ left: Register) throws -> UInt16 {
        try makeInstructionRRR(opcode: DecoderGenerator.opcodeNot, c: dst, a: left, b: .r0)
    }

    public func jmp(_ offset: Int) throws -> UInt16 {
        try makeInstructionIII(opcode: DecoderGenerator.opcodeJmp, imm: offset)
    }

    public func jr(_ destination: Register, _ offset: Int) throws -> UInt16 {
        try makeInstructionRRI(
            opcode: DecoderGenerator.opcodeJr,
            c: .r0,
            a: destination,
            imm: offset
        )
    }

    public func jalr(_ link: Register, _ destination: Register, _ offset: Int) throws -> UInt16 {
        try makeInstructionRRI(
            opcode: DecoderGenerator.opcodeJalr,
            c: link,
            a: destination,
            imm: offset
        )
    }

    public func beq(_ offset: Int) throws -> UInt16 {
        try makeInstructionIII(opcode: DecoderGenerator.opcodeBeq, imm: offset)
    }

    public func bne(_ offset: Int) throws -> UInt16 {
        try makeInstructionIII(opcode: DecoderGenerator.opcodeBne, imm: offset)
    }

    public func blt(_ offset: Int) throws -> UInt16 {
        try makeInstructionIII(opcode: DecoderGenerator.opcodeBlt, imm: offset)
    }

    public func bgt(_ offset: Int) throws -> UInt16 {
        try makeInstructionIII(opcode: DecoderGenerator.opcodeBgt, imm: offset)
    }

    public func bltu(_ offset: Int) throws -> UInt16 {
        try makeInstructionIII(opcode: DecoderGenerator.opcodeBltu, imm: offset)
    }

    public func bgtu(_ offset: Int) throws -> UInt16 {
        try makeInstructionIII(opcode: DecoderGenerator.opcodeBgtu, imm: offset)
    }

    public func adc(_ dst: Register, _ left: Register, _ right: Register) throws -> UInt16 {
        try makeInstructionRRR(opcode: DecoderGenerator.opcodeAdc, c: dst, a: left, b: right)
    }

    public func sbc(_ dst: Register, _ left: Register, _ right: Register) throws -> UInt16 {
        try makeInstructionRRR(opcode: DecoderGenerator.opcodeSbc, c: dst, a: left, b: right)
    }
}
