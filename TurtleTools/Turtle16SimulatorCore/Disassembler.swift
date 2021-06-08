//
//  Disassembler.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 6/6/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

public class Disassembler: NSObject {
    public typealias Register = AssemblerSingleInstructionCodeGenerator.Register
    
    let mnemonics = [
        DecoderGenerator.opcodeNop : "NOP",
        DecoderGenerator.opcodeHlt : "HLT",
        DecoderGenerator.opcodeLoad : "LOAD",
        DecoderGenerator.opcodeStore : "STORE",
        DecoderGenerator.opcodeLi : "LI",
        DecoderGenerator.opcodeLui : "LUI",
        DecoderGenerator.opcodeCmp : "CMP",
        DecoderGenerator.opcodeAdd : "ADD",
        DecoderGenerator.opcodeSub : "SUB",
        DecoderGenerator.opcodeAnd : "AND",
        DecoderGenerator.opcodeOr : "OR",
        DecoderGenerator.opcodeXor : "XOR",
        DecoderGenerator.opcodeNot : "NOT",
        DecoderGenerator.opcodeCmpi : "CMPI",
        DecoderGenerator.opcodeAddi : "ADDI",
        DecoderGenerator.opcodeSubi : "SUBI",
        DecoderGenerator.opcodeAndi : "ANDI",
        DecoderGenerator.opcodeOri : "ORI",
        DecoderGenerator.opcodeXori : "XORI",
        DecoderGenerator.opcodeJmp : "JMP",
        DecoderGenerator.opcodeJr : "JR",
        DecoderGenerator.opcodeJalr : "JALR",
        DecoderGenerator.opcodeBeq : "BEQ",
        DecoderGenerator.opcodeBne : "BNE",
        DecoderGenerator.opcodeBlt : "BLT",
        DecoderGenerator.opcodeBge : "BGE",
        DecoderGenerator.opcodeBltu : "BLTU",
        DecoderGenerator.opcodeBgeu : "BGEU",
        DecoderGenerator.opcodeAdc : "ADC",
        DecoderGenerator.opcodeSbc : "SBC"
    ]
    
    let formatX: Set<Int> = [
        DecoderGenerator.opcodeNop,
        DecoderGenerator.opcodeHlt
    ]
    
    let formatRRI: Set<Int> = [
        DecoderGenerator.opcodeLoad,
        DecoderGenerator.opcodeAddi,
        DecoderGenerator.opcodeSubi,
        DecoderGenerator.opcodeAndi,
        DecoderGenerator.opcodeOri,
        DecoderGenerator.opcodeXori,
        DecoderGenerator.opcodeJalr
    ]
    
    let formatIRR: Set<Int> = [
        DecoderGenerator.opcodeStore
    ]
    
    let formatRII: Set<Int> = [
        DecoderGenerator.opcodeLi,
        DecoderGenerator.opcodeLui
    ]
    
    let formatRRR: Set<Int> = [
        DecoderGenerator.opcodeAdd,
        DecoderGenerator.opcodeSub,
        DecoderGenerator.opcodeAnd,
        DecoderGenerator.opcodeOr,
        DecoderGenerator.opcodeXor,
        DecoderGenerator.opcodeAdc,
        DecoderGenerator.opcodeSbc
    ]
    
    let formatIII: Set<Int> = [
        DecoderGenerator.opcodeJmp,
        DecoderGenerator.opcodeBeq,
        DecoderGenerator.opcodeBne,
        DecoderGenerator.opcodeBlt,
        DecoderGenerator.opcodeBge,
        DecoderGenerator.opcodeBltu,
        DecoderGenerator.opcodeBgeu
    ]
    
    let formatXRI: Set<Int> = [
        DecoderGenerator.opcodeCmpi,
        DecoderGenerator.opcodeJr
    ]
    
    let formatXRR: Set<Int> = [
        DecoderGenerator.opcodeCmp
    ]
    
    let formatXRX: Set<Int> = [
        DecoderGenerator.opcodeNot
    ]
    
    public private(set) var labels: [Int : String] = [:]
    
    func labelForTarget(_ target: Int) -> String {
        if let label = labels[target] {
            return label
        }
        else {
            let nextLabelIndex = (labels.keys.max() ?? -1) + 1
            let nextLabel = "L\(nextLabelIndex)"
            labels[target] = nextLabel
            return nextLabel
        }
    }
    
    public func disassembleOne(_ ins: UInt16) -> String? {
        return disassembleOne(pc: nil, ins: ins)
    }
    
    public func disassembleOne(pc maybeProgramCounter: Int?, ins: UInt16) -> String? {
        let opcode: Int = Int((ins & 0b1111100000000000) >> 11)
        let c = Int((ins & 0b0000011100000000) >> 8)
        let regC = Register(rawValue: c)!.description
        let a = Int((ins & 0b0000000011100000) >> 5)
        let regA = Register(rawValue: a)!.description
        let b = Int((ins & 0b0000000000011100) >> 2)
        let regB = Register(rawValue: b)!.description
        let imm5_0 = Int(ins & 0b0000000000011111)
        let tcImm5_0: Int = (imm5_0 > 15) ? (((~0 >> 5) << 5) | imm5_0) : imm5_0
        let imm10_8_1_0 = Int(((ins & 0b0000011100000000) >> 6) | (ins & 0b0000000000000011))
        let tcImm10_8_1_0: Int = (imm10_8_1_0 > 15) ? (((~0 >> 5) << 5) | imm10_8_1_0) : imm10_8_1_0
        let imm7_0 = Int(ins & 0b0000000011111111)
        let tcImm7_0: Int = (imm7_0 > 127) ? (((~0 >> 8) << 8) | imm7_0) : imm7_0
        let imm10_0 = Int(ins & 0b0000011111111111)
        let tcImm10_0: Int = (imm10_0 > 1023) ? (((~0 >> 11) << 11) | imm10_0) : imm10_0
        
        guard let mnemonic = mnemonics[opcode] else {
            return nil
        }
        
        if formatX.contains(opcode) {
            return mnemonic
        }
        else if formatRRI.contains(opcode) {
            return "\(mnemonic) \(regC), \(regA), \(tcImm5_0)"
        }
        else if formatIRR.contains(opcode) {
            return "\(mnemonic) \(regB), \(regA), \(tcImm10_8_1_0)"
        }
        else if formatRII.contains(opcode) {
            if opcode == DecoderGenerator.opcodeLui {
                return "\(mnemonic) \(regC), \(imm7_0)"
            }
            else {
                return "\(mnemonic) \(regC), \(tcImm7_0)"
            }
        }
        else if formatRRR.contains(opcode) {
            return "\(mnemonic) \(regC), \(regA), \(regB)"
        }
        else if formatIII.contains(opcode) {
            if let pc = maybeProgramCounter {
                let target = pc + tcImm10_0 + 2
                let label = labelForTarget(target)
                return "\(mnemonic) \(label)"
            }
            else {
                return "\(mnemonic) \(tcImm10_0)"
            }
        }
        else if formatXRI.contains(opcode) {
            return "\(mnemonic) \(regA), \(tcImm5_0)"
        }
        else if formatXRR.contains(opcode) {
            return "\(mnemonic) \(regA), \(regB)"
        }
        else if formatXRX.contains(opcode) {
            return "\(mnemonic) \(regC), \(regA)"
        }
        else {
            fatalError("unimplemented")
        }
    }
    
    public func disassemble(_ program: [UInt16]) -> [String] {
        var result: [String] = []
        for pc in 0..<program.count {
            let ins = program[pc]
            let oneLine = disassembleOne(pc: pc, ins: ins) ?? ""
            result.append(oneLine)
        }
        return result
    }
}
