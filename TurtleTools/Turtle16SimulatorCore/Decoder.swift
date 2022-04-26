//
//  Decoder.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/23/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

public protocol Decoder: NSObject, NSSecureCoding {
    var count: Int { get }
    func decode(_ address: Int) -> UInt
    func decode(ovf: UInt, z: UInt, carry: UInt, opcode: UInt) -> UInt
}

public class OpcodeDecoderROM : NSObject, Decoder {
    public let count: Int = 256
    public static var supportsSecureCoding = true
    public var opcodeDecodeROM: [UInt]
    
    public required init(_ original: Decoder? = nil) {
        opcodeDecodeROM = Array<UInt>(repeating: 0, count: count)
        if let original = original {
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
    
    public static func ==(lhs: OpcodeDecoderROM, rhs: OpcodeDecoderROM) -> Bool {
        return lhs.isEqual(rhs)
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
    
    public func decode(ovf: UInt, z: UInt, carry: UInt, opcode: UInt) -> UInt {
        assert(ovf <= 1)
        assert(z <= 1)
        assert(carry <= 1)
        assert(opcode <= 31)
        let address = (ovf << 7)
                    | (z << 6)
                    | (carry << 5)
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

public class ProgrammableLogicDecoder : NSObject, Decoder {
    public static var supportsSecureCoding = true
    public let count: Int = 256
    
    let gal1: ATF22V10
    let gal2: ATF22V10
    let gal3: ATF22V10
    
    public required override init() {
        gal1 = ProgrammableLogicDecoder.makeGAL("InstructionDecoder1")
        gal2 = ProgrammableLogicDecoder.makeGAL("InstructionDecoder2")
        gal3 = ProgrammableLogicDecoder.makeGAL("InstructionDecoder3")
    }
    
    public required convenience init?(coder: NSCoder) {
        self.init()
    }
    
    public func encode(with coder: NSCoder) {
    }
    
    public static func ==(lhs: ProgrammableLogicDecoder, rhs: ProgrammableLogicDecoder) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard let _ = rhs as? ProgrammableLogicDecoder else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        let hasher = Hasher()
        return hasher.finalize()
    }
    
    static func makeGAL(_ name: String) -> ATF22V10 {
        let path = Bundle(for: ProgrammableLogicDecoder.self).path(forResource: name, ofType: "jed")!
        let jedecText = try! String(contentsOfFile: path)
        let fuseListMaker = FuseListMaker()
        let parser = JEDECFuseFileParser(fuseListMaker)
        parser.parse(jedecText)
        let fuseList = fuseListMaker.fuseList
        let gal = ATF22V10(fuseList: fuseList)
        return gal
    }
    
    public func decode(ovf: UInt, z: UInt, carry: UInt, opcode: UInt) -> UInt {
        assert(ovf <= 1)
        assert(z <= 1)
        assert(carry <= 1)
        assert(opcode <= 31)
        let address = (ovf << 7)
                    | (z << 6)
                    | (carry << 5)
                    | opcode
        let control = decode(Int(address))
        return control
    }
    
    public func decode(_ address_: Int) -> UInt {
        assert(address_ >= 0 && address_ < count)
        let address = UInt(address_)
        
        let inputs = [
            0,
            ((address >> 7) & 1),
            ((address >> 6) & 1),
            ((address >> 5) & 1),
            ((address >> 4) & 1),
            ((address >> 3) & 1),
            ((address >> 2) & 1),
            ((address >> 1) & 1),
            (address & 1),
            0,
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
        let fi = out1[5]!
        let c0 = out1[6]!
        let i2 = out1[7]!
        let i1 = out1[8]!
        let i0 = out1[9]!
        let rs1 = out2[0]!
        let rs0 = out2[1]!
        let j = out2[2]!
        let jabs = out2[3]!
        let memLoad = out2[4]!
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
