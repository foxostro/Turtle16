//
//  Disassembler.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 6/6/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//
import Foundation

public final class Disassembler {
    public var shouldUseConventionalRegisterNames = false
    public typealias Register = AssemblerSingleInstructionCodeGenerator.Register

    let mnemonics = [
        DecoderGenerator.opcodeNop: "NOP",
        DecoderGenerator.opcodeHlt: "HLT",
        DecoderGenerator.opcodeLoad: "LOAD",
        DecoderGenerator.opcodeStore: "STORE",
        DecoderGenerator.opcodeLi: "LI",
        DecoderGenerator.opcodeLui: "LUI",
        DecoderGenerator.opcodeCmp: "CMP",
        DecoderGenerator.opcodeAdd: "ADD",
        DecoderGenerator.opcodeSub: "SUB",
        DecoderGenerator.opcodeAnd: "AND",
        DecoderGenerator.opcodeOr: "OR",
        DecoderGenerator.opcodeXor: "XOR",
        DecoderGenerator.opcodeNot: "NOT",
        DecoderGenerator.opcodeCmpi: "CMPI",
        DecoderGenerator.opcodeAddi: "ADDI",
        DecoderGenerator.opcodeSubi: "SUBI",
        DecoderGenerator.opcodeAndi: "ANDI",
        DecoderGenerator.opcodeOri: "ORI",
        DecoderGenerator.opcodeXori: "XORI",
        DecoderGenerator.opcodeJmp: "JMP",
        DecoderGenerator.opcodeJr: "JR",
        DecoderGenerator.opcodeJalr: "JALR",
        DecoderGenerator.opcodeBeq: "BEQ",
        DecoderGenerator.opcodeBne: "BNE",
        DecoderGenerator.opcodeBlt: "BLT",
        DecoderGenerator.opcodeBgt: "BGT",
        DecoderGenerator.opcodeBltu: "BLTU",
        DecoderGenerator.opcodeBgtu: "BGTU",
        DecoderGenerator.opcodeAdc: "ADC",
        DecoderGenerator.opcodeSbc: "SBC",
    ]

    let formatX: Set<Int> = [
        DecoderGenerator.opcodeNop,
        DecoderGenerator.opcodeHlt,
    ]

    let formatRRI: Set<Int> = [
        DecoderGenerator.opcodeLoad,
        DecoderGenerator.opcodeAddi,
        DecoderGenerator.opcodeSubi,
        DecoderGenerator.opcodeAndi,
        DecoderGenerator.opcodeOri,
        DecoderGenerator.opcodeXori,
        DecoderGenerator.opcodeJalr,
    ]

    let formatIRR: Set<Int> = [
        DecoderGenerator.opcodeStore
    ]

    let formatRII: Set<Int> = [
        DecoderGenerator.opcodeLi,
        DecoderGenerator.opcodeLui,
    ]

    let formatRRR: Set<Int> = [
        DecoderGenerator.opcodeAdd,
        DecoderGenerator.opcodeSub,
        DecoderGenerator.opcodeAnd,
        DecoderGenerator.opcodeOr,
        DecoderGenerator.opcodeXor,
        DecoderGenerator.opcodeAdc,
        DecoderGenerator.opcodeSbc,
    ]

    let formatIII: Set<Int> = [
        DecoderGenerator.opcodeJmp,
        DecoderGenerator.opcodeBeq,
        DecoderGenerator.opcodeBne,
        DecoderGenerator.opcodeBlt,
        DecoderGenerator.opcodeBgt,
        DecoderGenerator.opcodeBltu,
        DecoderGenerator.opcodeBgtu,
    ]

    let formatXRI: Set<Int> = [
        DecoderGenerator.opcodeCmpi,
        DecoderGenerator.opcodeJr,
    ]

    let formatXRR: Set<Int> = [
        DecoderGenerator.opcodeCmp
    ]

    let formatXRX: Set<Int> = [
        DecoderGenerator.opcodeNot
    ]

    public private(set) var labels: [Int: String] = [:]

    func labelForTarget(_ target: Int) -> String {
        guard let label = labels[target] else {
            let nextLabelIndex = (labels.keys.max() ?? -1) + 1
            let nextLabel = "L\(nextLabelIndex)"
            labels[target] = nextLabel
            return nextLabel
        }
        return label
    }

    public func disassembleOne(_ ins: UInt16) -> String? {
        disassembleOne(pc: nil, ins: ins)
    }

    public func registerName(_ index: Int) -> String {
        if shouldUseConventionalRegisterNames {
            switch index {
            case 5: "ra"
            case 6: "sp"
            case 7: "fp"
            default: "\(Register(rawValue: index)!)"
            }
        } else {
            "\(Register(rawValue: index)!)"
        }
    }

    public func disassembleOne(pc maybeProgramCounter: Int?, ins: UInt16) -> String? {
        let opcode: Int = Int((ins & 0b11111000_00000000) >> 11)
        let c = Int((ins & 0b00000111_00000000) >> 8)
        let regC = registerName(c)
        let a = Int((ins & 0b00000000_11100000) >> 5)
        let regA = registerName(a)
        let b = Int((ins & 0b00000000_00011100) >> 2)
        let regB = registerName(b)
        let imm5_0 = Int(ins & 0b00000000_00011111)
        let tcImm5_0: Int = (imm5_0 > 15) ? (((~0 >> 5) << 5) | imm5_0) : imm5_0
        let imm10_8_1_0 = Int(((ins & 0b00000111_00000000) >> 6) | (ins & 0b00000000_00000011))
        let tcImm10_8_1_0: Int = (imm10_8_1_0 > 15) ? (((~0 >> 5) << 5) | imm10_8_1_0) : imm10_8_1_0
        let imm7_0 = Int(ins & 0b00000000_11111111)
        let tcImm7_0: Int = (imm7_0 > 127) ? (((~0 >> 8) << 8) | imm7_0) : imm7_0
        let imm10_0 = Int(ins & 0b00000111_11111111)
        let tcImm10_0: Int = (imm10_0 > 1023) ? (((~0 >> 11) << 11) | imm10_0) : imm10_0

        guard let mnemonic = mnemonics[opcode] else {
            return nil
        }

        if formatX.contains(opcode) {
            return mnemonic
        } else if formatRRI.contains(opcode) {
            return "\(mnemonic) \(regC), \(regA), \(tcImm5_0)"
        } else if formatIRR.contains(opcode) {
            return "\(mnemonic) \(regB), \(regA), \(tcImm10_8_1_0)"
        } else if formatRII.contains(opcode) {
            guard opcode == DecoderGenerator.opcodeLui else {
                return "\(mnemonic) \(regC), \(tcImm7_0)"
            }
            return "\(mnemonic) \(regC), \(imm7_0)"
        } else if formatRRR.contains(opcode) {
            return "\(mnemonic) \(regC), \(regA), \(regB)"
        } else if formatIII.contains(opcode) {
            guard let pc = maybeProgramCounter else {
                return "\(mnemonic) \(tcImm10_0)"
            }
            let target = pc + tcImm10_0 + 2
            let label = labelForTarget(target)
            return "\(mnemonic) \(label)"
        } else if formatXRI.contains(opcode) {
            return "\(mnemonic) \(regA), \(tcImm5_0)"
        } else if formatXRR.contains(opcode) {
            return "\(mnemonic) \(regA), \(regB)"
        } else if formatXRX.contains(opcode) {
            return "\(mnemonic) \(regC), \(regA)"
        } else {
            fatalError("unimplemented")
        }
    }

    public struct Entry: Equatable {
        public let address: Int
        public let word: UInt16
        public let label: String?
        public let mnemonic: String?

        public init(address: Int, word: UInt16, label: String?, mnemonic: String?) {
            self.address = address
            self.word = word
            self.label = label
            self.mnemonic = mnemonic
        }
    }

    public func disassemble(_ program: [UInt16]) -> [Entry] {
        var result: [Entry] = []
        for pc in 0..<program.count {
            let ins = program[pc]
            let mnemonic = disassembleOne(pc: pc, ins: ins)
            let entry = Entry(address: pc, word: ins, label: nil, mnemonic: mnemonic)
            result.append(entry)
        }
        result = result.map {
            Entry(
                address: $0.address,
                word: $0.word,
                label: labels[$0.address],
                mnemonic: $0.mnemonic
            )
        }
        return result
    }

    public func disassembleToText(_ program: [UInt16]) -> String {
        disassemble(program).map { entry in
            var str = ""
            if let label = entry.label {
                str += label + ": "
            }
            if let mnemonic = entry.mnemonic {
                str += mnemonic
            }
            return str
        }.joined(separator: "\n")
    }

    public init() {}
}
