//
//  DecoderGenerator.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 1/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

public extension UInt {
    func asBinaryString() -> String {
        var result = String(self, radix: 2)
        if result.count < 32 {
            result = String(repeatElement("0", count: 32 - result.count)) + result
        }
        return "0b" + result
    }
}

public class DecoderGenerator: NSObject {
    public static let HLT = 0
    public static let SelStoreOpA = 1
    public static let SelStoreOpB = 2
    public static let SelRightOpA = 3
    public static let SelRightOpB = 4
    public static let FI = 5
    public static let C0 = 6
    public static let I0 = 7
    public static let I1 = 8
    public static let I2 = 9
    public static let RS0 = 10
    public static let RS1 = 11
    public static let J = 12
    public static let JABS = 13
    public static let MemLoad = 14
    public static let MemStore = 15
    public static let AssertStoreOp = 16
    public static let WriteBackSrcFlag = 17
    public static let WRL = 18
    public static let WRH = 19
    public static let WBEN = 20
    
    public static let opcodeNop = 0
    public static let opcodeHlt = 1
    public static let opcodeLoad = 2
    public static let opcodeStore = 3
    public static let opcodeLi = 4
    public static let opcodeLui = 5
    public static let opcodeCmp = 6
    public static let opcodeAdd = 7
    public static let opcodeSub = 8
    public static let opcodeAnd = 9
    public static let opcodeOr = 10
    public static let opcodeXor = 11
    public static let opcodeNot = 12
    public static let opcodeCmpi = 13
    public static let opcodeAddi = 14
    public static let opcodeSubi = 15
    public static let opcodeAndi = 16
    public static let opcodeOri = 17
    public static let opcodeXori = 18
    public static let opcodeUnused19 = 19
    public static let opcodeJmp = 20
    public static let opcodeJr = 21
    public static let opcodeJalr = 22
    public static let opcodeUnused23 = 23
    public static let opcodeBeq = 24
    public static let opcodeBne = 25
    public static let opcodeBlt = 26
    public static let opcodeBge = 27
    public static let opcodeBltu = 28
    public static let opcodeBgeu = 29
    public static let opcodeAdc = 30
    public static let opcodeSbc = 31
    
    public struct SelStoreOpTag {
        let tag: UInt
    }
    public static func SelStoreOp(_ val: UInt) -> SelStoreOpTag {
        assert(val < 4)
        return SelStoreOpTag(tag: val & 3)
    }
    
    public enum SelRightOpEnum {
        case b, imm_4_0, imm_10_8_1_0, imm_10_0
        public func controlWord() -> UInt {
            switch self {
            case .b:            return 0b00
            case .imm_4_0:      return 0b01
            case .imm_10_8_1_0: return 0b10
            case .imm_10_0:     return 0b11
            }
        }
    }
    public struct SelRightOpTag {
        let tag: UInt
    }
    public static func SelRightOp(_ op: SelRightOpEnum) -> SelRightOpTag {
        let val = op.controlWord()
        assert(val < 4)
        return SelRightOpTag(tag: val & 3)
    }
    
    public enum ALUFunction {
        case add, sub, and, or, xor, not
        public func controlWord() -> UInt {
            switch self {
            case .add: return 0b011
            case .sub: return 0b010
            case .and: return 0b110
            case .or:  return 0b101
            case .xor: return 0b100
            case .not: return 0b001
            }
        }
    }
    public struct ALUControlTag {
        let i: UInt
        let c0: UInt
    }
    public static func ALUControl(fn: ALUFunction, c0: UInt) -> ALUControlTag {
        assert(c0 < 2)
        let i = fn.controlWord()
        assert(i < 8)
        return ALUControlTag(i: i & 7, c0: c0 & 1)
    }
    
    public enum WriteBackSrcEnum {
        case aluResult, storeOp
    }
    public struct WriteBackSrcTag {
        let tag: UInt
    }
    public static func WriteBackSrc(_ val: WriteBackSrcEnum) -> WriteBackSrcTag {
        let tag: UInt
        switch val {
        case .aluResult:
            tag = 0
        case .storeOp:
            tag = 1
        }
        return WriteBackSrcTag(tag: tag & 1)
    }
    
    public func generate() -> [UInt] {
        var controlWords = Array<UInt>(repeating: ID.nopControlWord, count: 512)
        makeControlWord(&controlWords, DecoderGenerator.opcodeNop, [])
        makeControlWord(&controlWords, DecoderGenerator.opcodeHlt, [
            DecoderGenerator.HLT
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeLoad, [
            DecoderGenerator.SelRightOp(.imm_4_0),
            DecoderGenerator.ALUControl(fn: .add, c0: 0),
            DecoderGenerator.MemLoad,
            DecoderGenerator.WriteBackSrc(.storeOp),
            DecoderGenerator.WRL,
            DecoderGenerator.WRH,
            DecoderGenerator.WBEN
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeStore, [
            DecoderGenerator.SelStoreOp(0b00),
            DecoderGenerator.SelRightOp(.imm_10_8_1_0),
            DecoderGenerator.ALUControl(fn: .add, c0: 0),
            DecoderGenerator.MemStore,
            DecoderGenerator.AssertStoreOp
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeLi, [
            DecoderGenerator.SelStoreOp(0b10),
            DecoderGenerator.AssertStoreOp,
            DecoderGenerator.WriteBackSrc(.storeOp),
            DecoderGenerator.WRL,
            DecoderGenerator.WRH,
            DecoderGenerator.WBEN
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeLui, [
            DecoderGenerator.SelStoreOp(0b11),
            DecoderGenerator.AssertStoreOp,
            DecoderGenerator.WriteBackSrc(.storeOp),
            DecoderGenerator.WRH,
            DecoderGenerator.WBEN
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeCmp, [
            DecoderGenerator.SelRightOp(.b),
            DecoderGenerator.ALUControl(fn: .sub, c0: 1),
            DecoderGenerator.FI,
            DecoderGenerator.I0,
            DecoderGenerator.I2
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeAdd, [
            DecoderGenerator.SelRightOp(.b),
            DecoderGenerator.ALUControl(fn: .add, c0: 0),
            DecoderGenerator.FI,
            DecoderGenerator.WriteBackSrc(.aluResult),
            DecoderGenerator.WRL,
            DecoderGenerator.WRH,
            DecoderGenerator.WBEN
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeSub, [
            DecoderGenerator.SelRightOp(.b),
            DecoderGenerator.ALUControl(fn: .sub, c0: 1),
            DecoderGenerator.FI,
            DecoderGenerator.WriteBackSrc(.aluResult),
            DecoderGenerator.WRL,
            DecoderGenerator.WRH,
            DecoderGenerator.WBEN
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeAnd, [
            DecoderGenerator.SelRightOp(.b),
            DecoderGenerator.ALUControl(fn: .and, c0: 0),
            DecoderGenerator.FI,
            DecoderGenerator.WriteBackSrc(.aluResult),
            DecoderGenerator.WRL,
            DecoderGenerator.WRH,
            DecoderGenerator.WBEN
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeOr, [
            DecoderGenerator.SelRightOp(.b),
            DecoderGenerator.ALUControl(fn: .or, c0: 0),
            DecoderGenerator.FI,
            DecoderGenerator.WriteBackSrc(.aluResult),
            DecoderGenerator.WRL,
            DecoderGenerator.WRH,
            DecoderGenerator.WBEN
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeXor, [
            DecoderGenerator.SelRightOp(.b),
            DecoderGenerator.ALUControl(fn: .xor, c0: 0),
            DecoderGenerator.FI,
            DecoderGenerator.WriteBackSrc(.aluResult),
            DecoderGenerator.WRL,
            DecoderGenerator.WRH,
            DecoderGenerator.WBEN
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeNot, [
            DecoderGenerator.ALUControl(fn: .not, c0: 0),
            DecoderGenerator.RS1,
            DecoderGenerator.WriteBackSrc(.aluResult),
            DecoderGenerator.WRL,
            DecoderGenerator.WRH,
            DecoderGenerator.WBEN
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeCmpi, [
            DecoderGenerator.SelRightOp(.imm_4_0),
            DecoderGenerator.ALUControl(fn: .sub, c0: 1),
            DecoderGenerator.FI
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeAddi, [
            DecoderGenerator.SelRightOp(.imm_4_0),
            DecoderGenerator.ALUControl(fn: .add, c0: 0),
            DecoderGenerator.FI,
            DecoderGenerator.WriteBackSrc(.aluResult),
            DecoderGenerator.WRL,
            DecoderGenerator.WRH,
            DecoderGenerator.WBEN
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeSubi, [
            DecoderGenerator.SelRightOp(.imm_4_0),
            DecoderGenerator.ALUControl(fn: .sub, c0: 1),
            DecoderGenerator.FI,
            DecoderGenerator.WriteBackSrc(.aluResult),
            DecoderGenerator.WRL,
            DecoderGenerator.WRH,
            DecoderGenerator.WBEN
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeAndi, [
            DecoderGenerator.SelRightOp(.imm_4_0),
            DecoderGenerator.ALUControl(fn: .and, c0: 0),
            DecoderGenerator.FI,
            DecoderGenerator.WriteBackSrc(.aluResult),
            DecoderGenerator.WRL,
            DecoderGenerator.WRH,
            DecoderGenerator.WBEN
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeOri, [
            DecoderGenerator.SelRightOp(.imm_4_0),
            DecoderGenerator.ALUControl(fn: .or, c0: 0),
            DecoderGenerator.FI,
            DecoderGenerator.WriteBackSrc(.aluResult),
            DecoderGenerator.WRL,
            DecoderGenerator.WRH,
            DecoderGenerator.WBEN
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeXori, [
            DecoderGenerator.SelRightOp(.imm_4_0),
            DecoderGenerator.ALUControl(fn: .xor, c0: 0),
            DecoderGenerator.FI,
            DecoderGenerator.WriteBackSrc(.aluResult),
            DecoderGenerator.WRL,
            DecoderGenerator.WRH,
            DecoderGenerator.WBEN
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeJmp, [
            DecoderGenerator.SelRightOp(.imm_10_0),
            DecoderGenerator.ALUControl(fn: .or, c0: 0),
            DecoderGenerator.RS0,
            DecoderGenerator.J
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeJr, [
            DecoderGenerator.SelRightOp(.imm_4_0),
            DecoderGenerator.ALUControl(fn: .add, c0: 0),
            DecoderGenerator.J,
            DecoderGenerator.JABS
        ])
        makeControlWord(&controlWords, DecoderGenerator.opcodeJalr, [
            DecoderGenerator.SelStoreOp(0b01),
            DecoderGenerator.SelRightOp(.imm_4_0),
            DecoderGenerator.ALUControl(fn: .add, c0: 0),
            DecoderGenerator.J,
            DecoderGenerator.JABS,
            DecoderGenerator.AssertStoreOp,
            DecoderGenerator.WRL,
            DecoderGenerator.WRH,
            DecoderGenerator.WBEN
        ])
        let signalsForRelativeJump: [Any] = [
            DecoderGenerator.SelRightOp(.imm_10_0),
            DecoderGenerator.ALUControl(fn: .add, c0: 0),
            DecoderGenerator.RS0,
            DecoderGenerator.J
        ]
        let bits = [UInt(0), UInt(1)]
        for carry in bits {
            for ovf in bits {
                for z in bits {
                    makeControlWord(&controlWords, index: makeIndex(rst: 1, carry: carry, z: 1, ovf: ovf, opcode: DecoderGenerator.opcodeBeq), signals: signalsForRelativeJump)
                    makeControlWord(&controlWords, index: makeIndex(rst: 1, carry: carry, z: 0, ovf: ovf, opcode: DecoderGenerator.opcodeBne), signals: signalsForRelativeJump)
                    makeControlWord(&controlWords, index: makeIndex(rst: 1, carry: carry, z: z, ovf: 1, opcode: DecoderGenerator.opcodeBlt), signals: signalsForRelativeJump)
                    makeControlWord(&controlWords, index: makeIndex(rst: 1, carry: carry, z: z, ovf: 0, opcode: DecoderGenerator.opcodeBge), signals: signalsForRelativeJump)
                    makeControlWord(&controlWords, index: makeIndex(rst: 1, carry: 1, z: z, ovf: ovf, opcode: DecoderGenerator.opcodeBltu), signals: signalsForRelativeJump)
                    makeControlWord(&controlWords, index: makeIndex(rst: 1, carry: 0, z: z, ovf: ovf, opcode: DecoderGenerator.opcodeBgeu), signals: signalsForRelativeJump)
                    
                    makeControlWord(&controlWords, index: makeIndex(rst: 1, carry: 0, z: z, ovf: ovf, opcode: DecoderGenerator.opcodeAdc), signals: [
                        DecoderGenerator.SelRightOp(.b),
                        DecoderGenerator.ALUControl(fn: .add, c0: 0),
                        DecoderGenerator.FI,
                        DecoderGenerator.WriteBackSrc(.aluResult),
                        DecoderGenerator.WRL,
                        DecoderGenerator.WRH,
                        DecoderGenerator.WBEN
                    ])
                    makeControlWord(&controlWords, index: makeIndex(rst: 1, carry: 1, z: z, ovf: ovf, opcode: DecoderGenerator.opcodeAdc), signals: [
                        DecoderGenerator.SelRightOp(.b),
                        DecoderGenerator.ALUControl(fn: .add, c0: 1),
                        DecoderGenerator.FI,
                        DecoderGenerator.WriteBackSrc(.aluResult),
                        DecoderGenerator.WRL,
                        DecoderGenerator.WRH,
                        DecoderGenerator.WBEN
                    ])
                    
                    makeControlWord(&controlWords, index: makeIndex(rst: 1, carry: 0, z: z, ovf: ovf, opcode: DecoderGenerator.opcodeSbc), signals: [
                        DecoderGenerator.SelRightOp(.b),
                        DecoderGenerator.ALUControl(fn: .sub, c0: 1),
                        DecoderGenerator.FI,
                        DecoderGenerator.WriteBackSrc(.aluResult),
                        DecoderGenerator.WRL,
                        DecoderGenerator.WRH,
                        DecoderGenerator.WBEN
                    ])
                    makeControlWord(&controlWords, index: makeIndex(rst: 1, carry: 1, z: z, ovf: ovf, opcode: DecoderGenerator.opcodeSbc), signals: [
                        DecoderGenerator.SelRightOp(.b),
                        DecoderGenerator.ALUControl(fn: .sub, c0: 0),
                        DecoderGenerator.FI,
                        DecoderGenerator.WriteBackSrc(.aluResult),
                        DecoderGenerator.WRL,
                        DecoderGenerator.WRH,
                        DecoderGenerator.WBEN
                    ])
                }
            }
        }
        
        return controlWords
    }
    
    public func makeControlWord(_ controlWords: inout [UInt], _ opcode: Int, _ signals: [Any]) {
        for index in indicesForAllConditions(opcode) {
            makeControlWord(&controlWords, index: index, signals: signals)
        }
    }
    
    public func makeControlWord(_ controlWords: inout [UInt], index: Int, signals: [Any]) {
        for signal_ in signals {
            let next: UInt
            let prev = controlWords[index]
            if let signal = signal_ as? Int {
                next = prev & ~(1 << signal)
            }
            else if let signal = signal_ as? SelStoreOpTag {
                next = (prev & ~(0b11 << DecoderGenerator.SelStoreOpA))
                     | (signal.tag << DecoderGenerator.SelStoreOpA)
            }
            else if let signal = signal_ as? SelRightOpTag {
                next = (prev & ~(0b11 << DecoderGenerator.SelRightOpA))
                     | (signal.tag << DecoderGenerator.SelRightOpA)
            }
            else if let signal = signal_ as? ALUControlTag {
                next = (prev
                            & ~(0b111 << DecoderGenerator.I0)
                            & ~(1 << DecoderGenerator.C0)
                        )
                        | (signal.i << DecoderGenerator.I0)
                        | (signal.c0 << DecoderGenerator.C0)
            }
            else if let signal = signal_ as? WriteBackSrcTag {
                next = (prev & ~(1 << DecoderGenerator.WriteBackSrcFlag))
                     | (signal.tag << DecoderGenerator.WriteBackSrcFlag)
            }
            else {
                assert(false)
                abort()
            }
            controlWords[index] = next
        }
    }
    
    public func makeIndex(rst: UInt,
                          carry: UInt,
                          z: UInt,
                          ovf: UInt,
                          opcode: Int) -> Int {
        assert(rst <= 1)
        assert(carry <= 1)
        assert(z <= 1)
        assert(ovf <= 1)
        assert(opcode >= 0)
        assert(opcode <= 31)
        let index = UInt(rst << 8)
                  | UInt(carry << 7)
                  | UInt(z << 6)
                  | UInt(ovf << 5)
                  | UInt(opcode)
        return Int(index)
    }
    
    public func indicesForReset() -> [Int] {
        var indices: [Int] = []
        let rst: UInt = 0
        for opcode in 0..<32 {
            for ovf in [0, 1] {
                for z in [0, 1] {
                    for carry in [0, 1] {
                        let index = makeIndex(rst: UInt(rst),
                                              carry: UInt(carry),
                                              z: UInt(z),
                                              ovf: UInt(ovf),
                                              opcode: opcode)
                        indices.append(Int(index))
                    }
                }
            }
        }
        return indices
    }
    
    public func indicesForAllConditions(_ opcode: Int) -> [Int] {
        var indices: [Int] = []
        let rst: UInt = 1
        for ovf in [0, 1] {
            for z in [0, 1] {
                for carry in [0, 1] {
                    let index = makeIndex(rst: UInt(rst),
                                          carry: UInt(carry),
                                          z: UInt(z),
                                          ovf: UInt(ovf),
                                          opcode: opcode)
                    indices.append(Int(index))
                }
            }
        }
        return indices
    }
}
