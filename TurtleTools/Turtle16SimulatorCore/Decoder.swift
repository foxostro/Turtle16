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

//public class LogicalDecoder : NSObject, Decoder {
//    public static var supportsSecureCoding = true
//    public let kDecoderTableSize = 512
//    
//    public required override init() {
//    }
//    
//    public required init?(coder: NSCoder) {
//    }
//    
//    public func encode(with coder: NSCoder) {
//    }
//    
//    public static func ==(lhs: LogicalDecoder, rhs: LogicalDecoder) -> Bool {
//        return lhs.isEqual(rhs)
//    }
//    
//    public override func isEqual(_ rhs: Any?) -> Bool {
//        guard rhs != nil else {
//            return false
//        }
//        guard let _ = rhs as? LogicalDecoder else {
//            return false
//        }
//        return true
//    }
//    
//    public override var hash: Int {
//        let hasher = Hasher()
//        return hasher.finalize()
//    }
//    
//    public func decode(ovf: UInt, z: UInt, carry: UInt, opcode: UInt) -> UInt {
//        assert(ovf <= 1)
//        assert(z <= 1)
//        assert(carry <= 1)
//        assert(opcode <= 31)
//        let address = (ovf << 7)
//                    | (z << 6)
//                    | (carry << 5)
//                    | opcode
//        let control = decode(Int(address))
//        return control
//    }
//    
//    public func decode(_ address: Int) -> UInt {
//        assert(address >= 0 && address < kDecoderTableSize)
//        let control: UInt = 0
//        return control
//    }
//}
