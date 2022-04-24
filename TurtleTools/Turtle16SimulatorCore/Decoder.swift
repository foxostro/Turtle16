//
//  Decoder.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/23/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

public protocol Decoder: NSObject, NSSecureCoding {
    func decode(_ address: Int) -> UInt
    func decode(ovf: UInt, z: UInt, carry: UInt, opcode: UInt) -> UInt
}

public class OpcodeDecoderROM : NSObject, Decoder {
    public static var supportsSecureCoding = true
    public var opcodeDecodeROM: [UInt]
    public let kDecoderTableSize = 512
    
    public required init(_ original: Decoder? = nil) {
        opcodeDecodeROM = Array<UInt>(repeating: 0, count: kDecoderTableSize)
        if let original = original {
            for i in 0..<kDecoderTableSize {
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
        assert(address >= 0 && address < kDecoderTableSize)
        let control = opcodeDecodeROM[Int(address)]
        return control
    }
}

public class LogicalDecoder : NSObject, Decoder {
    public static var supportsSecureCoding = true
    public let kDecoderTableSize = 256
    
    public required override init() {
    }
    
    public required init?(coder: NSCoder) {
    }
    
    public func encode(with coder: NSCoder) {
    }
    
    public static func ==(lhs: LogicalDecoder, rhs: LogicalDecoder) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard let _ = rhs as? LogicalDecoder else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        let hasher = Hasher()
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
    
    public func decode(_ address_: Int) -> UInt {
        assert(address_ >= 0 && address_ < kDecoderTableSize)
        let address = UInt(address_)
        
        let h = 0 != (address & 1)
        let g = 0 != ((address >> 1) & 1)
        let f = 0 != ((address >> 2) & 1)
        let e = 0 != ((address >> 3) & 1)
        let d = 0 != ((address >> 4) & 1)
        let c = 0 != ((address >> 5) & 1)
        let b = 0 != ((address >> 6) & 1)
        let a = 0 != ((address >> 7) & 1)
        
        let hlt = d || e || f || g || !h
        let selStoreOpA = e || d || (f && h) || (g && !h) || (!f && !g)
        let selStoreOpB = !g || e || (f && h) || (d && !f) || (!d && !h)
        let selRightOpA = (!e && !f && !h) || (!d && e && f) || (!e && !g) || (d && !e) || (d && !f) || (f && !g)
        let selRightOpB = (d && !e && g && h) || (!d && !e && !g) || (f && !g && !h) || (d && e && !f) || (d && e && !g) || (!d && !e && !f && h)
        let fi = (!d && !e && !f) || (f && !g && !h) || (d && !e && f) || (d && e && !f) || (d && f && !g) || (!d && !e && !g) || (!e && !f && g && h)
        let c0 = (a && d && !f && g && h) || (!a && d && e && !f && g && !h) || (b && d && e && !g && h) || (b && d && !f && g && h) || (!b && e && !f && !g && !h) || (c && d && e && f && g && !h) || (!c && d && e && f && !g) || (!c && d && f && g && h) || (d && !e && g && h) || (!d && e && f && h) || (!d && !e && f && !h) || (!d && !e && !g) || (!d && !f && !g && !h)
        let i0 = (d && e && !f) || (d && e && !g) || (d && f && !h) || (!d && !e && !f) || (e && g && !h) || (!e && h) || (f && !g && !h)
        let i1 = (d && e) || (d && g && h) || (!d && !e) || (!d && !g && h) || (f && g) || (f && h) || (!f && !g && !h)
        let i2 = (a && d && !f && g && h) || (!a && b && d && !f && g) || (!a && d && !f && g && !h) || (b && d && e && !g && h) || (!b && d && !f && !g && !h) || (!c && d && e && f && !g) || (d && !e && !f) || (d && !e && g && h) || ( !d && e && !f && g) || (!d && e && !f && h) || (!d && !e && !g) || (!e && !g && !h)
        let rs0 = (a && g && h) || (!a && g && !h) || (b && h) || (!b && !f && !g && !h) || (!c && e && f) || !d || (!e && !f) || (!e && h) || (f && g)
        let rs1 = d || !e || !f || g || h
        let j = (a && g && h) || (!a && e && g && !h) || (b && e && h) || (!b && !f && !g && !h) || (!c && e && f) || !d || (e && f && g) || (!e && !f) || (!e && g && h)
        let jabs = !d || e || !f || (g && h) || (!g && !h)
        let memLoad = d || e || f || !g || h
        let memStore = d || e || f || !g || !h
        let assertStoreOp = (d && !g) || (d && h) || (!d && f && g) || e || (!f && !g) || (!f && !h)
        let writeBackSrcFlag = (d && e && !f) || (d && !e && g && h) || (d && f && !g) || (!d && !e && !f) || (!e && f && !h) || (f && !g && h)
        let wrl = (d && e && !f) || (d && !e && g && h) || (d && f && !g) || (!d && !e && f && g && !h) || (!d && !e && !f && !g) || (!e && !f && g && h) || (f && !g && h)
        let wrh = (d && e && !f) || (d && !e && g && h) || (d && f && !g) || (!d && !e && f && g && !h) || (!d && !e && !f && !g) || (e && f && !g && h) || (!e && !f && g && h)
        let wben = (d && e && !f) || (d && !e && g && h) || (d && f && !g) || (!d && !e && f && g && !h) || (!d && !e && !f && !g) || (e && f && !g && h) || (!e && !f && g && h)
        let leftOperandIsUnused = (d && e && !f) || (d && e && !g) || (d && !e && g && h) || (!d && !e && !g) || (!e && f && !g && !h)
        let rightOperandIsUnused = (d && !e) || (d && !f) || (d && !g) || (!d && e && f) || (!e && !g)
        
        var control: UInt = 0
        control |= (hlt ? 1 : 0) << DecoderGenerator.HLT
        control |= (selStoreOpA ? 1 : 0) << DecoderGenerator.SelStoreOpA
        control |= (selStoreOpB ? 1 : 0) << DecoderGenerator.SelStoreOpB
        control |= (selRightOpA ? 1 : 0) << DecoderGenerator.SelRightOpA
        control |= (selRightOpB ? 1 : 0) << DecoderGenerator.SelRightOpB
        control |= (fi ? 1 : 0) << DecoderGenerator.FI
        control |= (c0 ? 1 : 0) << DecoderGenerator.C0
        control |= (i0 ? 1 : 0) << DecoderGenerator.I0
        control |= (i1 ? 1 : 0) << DecoderGenerator.I1
        control |= (i2 ? 1 : 0) << DecoderGenerator.I2
        control |= (rs0 ? 1 : 0) << DecoderGenerator.RS0
        control |= (rs1 ? 1 : 0) << DecoderGenerator.RS1
        control |= (j ? 1 : 0) << DecoderGenerator.J
        control |= (jabs ? 1 : 0) << DecoderGenerator.JABS
        control |= (memLoad ? 1 : 0) << DecoderGenerator.MemLoad
        control |= (memStore ? 1 : 0) << DecoderGenerator.MemStore
        control |= (assertStoreOp ? 1 : 0) << DecoderGenerator.AssertStoreOp
        control |= (writeBackSrcFlag ? 1 : 0) << DecoderGenerator.WriteBackSrcFlag
        control |= (wrl ? 1 : 0) << DecoderGenerator.WRL
        control |= (wrh ? 1 : 0) << DecoderGenerator.WRH
        control |= (wben ? 1 : 0) << DecoderGenerator.WBEN
        control |= (leftOperandIsUnused ? 1 : 0) << DecoderGenerator.LeftOperandIsUnused
        control |= (rightOperandIsUnused ? 1 : 0) << DecoderGenerator.RightOperandIsUnused
        
        return control
    }
}
