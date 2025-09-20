//
//  InstructionDecoder.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 4/23/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//
import Foundation

public protocol InstructionDecoder: NSObject, NSSecureCoding {
    var count: Int { get }
    func decode(_ address: Int) -> UInt
    func decode(n: UInt, c: UInt, z: UInt, v: UInt, opcode: UInt) -> UInt
}

public class OpcodeDecoderROM: NSObject, InstructionDecoder {
    public let count: Int = 512
    public static var supportsSecureCoding = true
    public var opcodeDecodeROM: [UInt]

    public required init(_ original: InstructionDecoder? = nil) {
        opcodeDecodeROM = [UInt](repeating: 0, count: count)
        if let original {
            for i in 0..<count {
                opcodeDecodeROM[i] = original.decode(i)
            }
        }
    }

    public required init?(coder: NSCoder) {
        guard let opcodeDecodeROM = coder.decodeObject(forKey: "opcodeDecodeROM") as? [UInt] else {
            return nil
        }
        self.opcodeDecodeROM = opcodeDecodeROM
    }

    public func encode(with coder: NSCoder) {
        coder.encode(opcodeDecodeROM, forKey: "opcodeDecodeROM")
    }

    public static func == (lhs: OpcodeDecoderROM, rhs: OpcodeDecoderROM) -> Bool {
        lhs.isEqual(rhs)
    }

    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard let rhs = rhs as? OpcodeDecoderROM else {
            return false
        }
        guard opcodeDecodeROM == rhs.opcodeDecodeROM else {
            return false
        }
        return true
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(opcodeDecodeROM)
        return hasher.finalize()
    }

    public func decode(n: UInt, c: UInt, z: UInt, v: UInt, opcode: UInt) -> UInt {
        assert(n <= 1)
        assert(c <= 1)
        assert(z <= 1)
        assert(v <= 1)
        assert(opcode <= 31)
        let address = (n << 8)
            | (v << 7)
            | (z << 6)
            | (c << 5)
            | opcode
        let control = decode(Int(address))
        return control
    }

    public func decode(_ address: Int) -> UInt {
        assert(address >= 0 && address < count)
        let control = opcodeDecodeROM[Int(address)]
        return control
    }
}

public class ProgrammableLogicDecoder: NSObject, InstructionDecoder {
    public static var supportsSecureCoding = true
    public let count: Int = 512

    let gal1: ATF22V10
    let gal2: ATF22V10
    let gal3: ATF22V10

    public override required init() {
        gal1 = ProgrammableLogicDecoder.makeGAL("InstructionDecoder1")
        gal2 = ProgrammableLogicDecoder.makeGAL("InstructionDecoder2")
        gal3 = ProgrammableLogicDecoder.makeGAL("InstructionDecoder3")
    }

    public required convenience init?(coder _: NSCoder) {
        self.init()
    }

    public func encode(with _: NSCoder) {}

    public static func == (lhs: ProgrammableLogicDecoder, rhs: ProgrammableLogicDecoder) -> Bool {
        lhs.isEqual(rhs)
    }

    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard rhs as? ProgrammableLogicDecoder != nil else {
            return false
        }
        return true
    }

    public override var hash: Int {
        let hasher = Hasher()
        return hasher.finalize()
    }

    static func makeGAL(_ name: String) -> ATF22V10 {
        let path = Bundle(for: ProgrammableLogicDecoder.self).path(
            forResource: name,
            ofType: "jed"
        )!
        let jedecText = try! String(contentsOfFile: path)
        let fuseListMaker = FuseListMaker()
        let parser = JEDECFuseFileParser(fuseListMaker)
        parser.parse(jedecText)
        let fuseList = fuseListMaker.fuseList
        let gal = ATF22V10(fuseList: fuseList)
        return gal
    }

    public func decode(n: UInt, c: UInt, z: UInt, v: UInt, opcode: UInt) -> UInt {
        assert(n <= 1)
        assert(c <= 1)
        assert(z <= 1)
        assert(v <= 1)
        assert(opcode <= 31)
        let address = (n << 8)
            | (v << 7)
            | (z << 6)
            | (c << 5)
            | opcode
        let control = decode(Int(address))
        return control
    }

    public func decode(_ address_: Int) -> UInt {
        assert(address_ >= 0 && address_ < count)
        let address = UInt(address_)

        let inputs = [
            0, // ignored
            (address >> 8) & 1, // pin 1
            (address >> 7) & 1, // pin 2
            (address >> 6) & 1, // pin 3
            (address >> 5) & 1, // pin 4
            (address >> 4) & 1, // pin 5
            (address >> 3) & 1, // pin 6
            (address >> 2) & 1, // pin 7
            (address >> 1) & 1, // pin 8
            (address >> 0) & 1, // pin 9
            0,
            0,
            0,
            0,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil
        ]

        let out1 = gal1.step(inputs: inputs)
        let out2 = gal2.step(inputs: inputs)
        let out3 = gal3.step(inputs: inputs)

        let hlt = out1[0]!
        let selStoreOpA = out1[1]!
        let selStoreOpB = out1[2]!
        let selRightOpA = out1[3]!
        let selRightOpB = out1[4]!
        let i2 = out1[5]!
        let c0 = out1[6]!
        let fi = out1[7]!
        let i1 = out1[8]!
        let i0 = out1[9]!
        let rs1 = out2[0]!
        let memLoad = out2[1]!
        let j = out2[2]!
        let jabs = out2[3]!
        let rs0 = out2[4]!
        let memStore = out2[5]!
        let assertStoreOp = out2[6]!
        let writeBackSrcFlag = out2[7]!
        let wrl = out2[8]!
        let wrh = out2[9]!
        let wben = out3[0]!
        let leftOperandIsUnused = out3[1]!
        let rightOperandIsUnused = out3[2]!

        var control: UInt = 0
        control |= hlt << DecoderGenerator.HLT
        control |= selStoreOpA << DecoderGenerator.SelStoreOpA
        control |= selStoreOpB << DecoderGenerator.SelStoreOpB
        control |= selRightOpA << DecoderGenerator.SelRightOpA
        control |= selRightOpB << DecoderGenerator.SelRightOpB
        control |= fi << DecoderGenerator.FI
        control |= c0 << DecoderGenerator.C0
        control |= i0 << DecoderGenerator.I0
        control |= i1 << DecoderGenerator.I1
        control |= i2 << DecoderGenerator.I2
        control |= rs0 << DecoderGenerator.RS0
        control |= rs1 << DecoderGenerator.RS1
        control |= j << DecoderGenerator.J
        control |= jabs << DecoderGenerator.JABS
        control |= memLoad << DecoderGenerator.MemLoad
        control |= memStore << DecoderGenerator.MemStore
        control |= assertStoreOp << DecoderGenerator.AssertStoreOp
        control |= writeBackSrcFlag << DecoderGenerator.WriteBackSrcFlag
        control |= wrl << DecoderGenerator.WRL
        control |= wrh << DecoderGenerator.WRH
        control |= wben << DecoderGenerator.WBEN
        control |= leftOperandIsUnused << DecoderGenerator.LeftOperandIsUnused
        control |= rightOperandIsUnused << DecoderGenerator.RightOperandIsUnused

        return control
    }
}
