//
//  ID.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 12/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

public class ID_Output: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true
    
    public let stall: UInt
    public let ctl_EX: UInt
    public let a: UInt16
    public let b: UInt16
    public let ins: UInt
    public let associatedPC: UInt16?
    
    public override var description: String {
        "stall: \(stall), ctl_EX: \(String(format: "%x", ctl_EX)), a: \(String(format: "%04x", a)), b: \(String(format: "%04x", b)), ins: \(String(format: "%04x", ins))"
    }
    
    public required init(stall: UInt,
                         ctl_EX: UInt,
                         a: UInt16,
                         b: UInt16,
                         ins: UInt,
                         associatedPC: UInt16? = nil) {
        self.stall = stall
        self.ctl_EX = ctl_EX
        self.a = a
        self.b = b
        self.ins = ins
        self.associatedPC = associatedPC
    }
    
    public required init?(coder: NSCoder) {
        guard let stall = coder.decodeObject(forKey: "stall") as? UInt,
              let ctl_EX = coder.decodeObject(forKey: "ctl_EX") as? UInt,
              let a = coder.decodeObject(forKey: "a") as? UInt16,
              let b = coder.decodeObject(forKey: "b") as? UInt16,
              let ins = coder.decodeObject(forKey: "ins") as? UInt,
              let associatedPC = coder.decodeObject(forKey: "associatedPC") as? UInt16? else {
            return nil
        }
        self.stall = stall
        self.ctl_EX = ctl_EX
        self.a = a
        self.b = b
        self.ins = ins
        self.associatedPC = associatedPC
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(stall, forKey: "stall")
        coder.encode(ctl_EX, forKey: "ctl_EX")
        coder.encode(a, forKey: "a")
        coder.encode(b, forKey: "b")
        coder.encode(ins, forKey: "ins")
        coder.encode(associatedPC, forKey: "associatedPC")
    }
    
    public static func ==(lhs: ID_Output, rhs: ID_Output) -> Bool {
        lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard let rhs = rhs as? ID_Output else {
            return false
        }
        guard stall == rhs.stall,
              ctl_EX == rhs.ctl_EX,
              a == rhs.a,
              b == rhs.b,
              ins == rhs.ins,
              associatedPC == rhs.associatedPC else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(stall)
        hasher.combine(ctl_EX)
        hasher.combine(a)
        hasher.combine(b)
        hasher.combine(ins)
        hasher.combine(associatedPC)
        return hasher.finalize()
    }
}

// Models the ID (instruction decode) stage of the Turtle16 pipeline.
// Please refer to ID.sch for details.
// Classes in the simulator intentionally model specific pieces of hardware,
// following naming conventions and organization that matches the schematics.
public class ID: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true
    
    public static let nopControlWord: UInt = 0b111111111111111111111 // The signals output to ctl_EX on a NOP instruction. This is different than the signals on ctl_ID for the same.
    public static let nopControlWord_ID: UInt = 0b11111111111111111111111 // The signals on ctl_ID when executing a NOP instruction. This is differnet than ctl_EX.
    
    public struct WriteBackInput: Hashable {
        public let c: UInt16
        public let wrh: UInt
        public let wrl: UInt
        public let wben: UInt
        public let selC_WB: UInt
        
        public init(c: UInt16,
                    wrh: UInt,
                    wrl: UInt,
                    wben: UInt,
                    selC_WB: UInt) {
            self.c = c
            self.wrh = wrh
            self.wrl = wrl
            self.wben = wben
            self.selC_WB = selC_WB
        }
    }
    
    public func writeBack(input: WriteBackInput) {
        assert(input.selC_WB < 8)
        if input.wben == 0 {
            let old = registerFile[Int(input.selC_WB)]
            let upper = (input.wrh == 0) ? (input.c & 0xff00) : (old & 0xff00)
            let lower = (input.wrl == 0) ? (input.c & 0x00ff) : (old & 0x00ff)
            let val = upper | lower
            registerFile[Int(input.selC_WB)] = val
        }
    }
    
    public struct Input: Hashable {
        public let ins: UInt16
        public let y_EX: UInt16
        public let y_MEM: UInt16
        public let ins_EX: UInt
        public let ctl_EX: UInt
        public let selC_MEM: UInt
        public let ctl_MEM: UInt
        public let j: UInt
        public let n: UInt
        public let z: UInt
        public let c: UInt
        public let v: UInt
        public let associatedPC: UInt16?
        
        public init(ins: UInt16) {
            self.ins = ins
            self.y_EX = 0
            self.y_MEM = 0
            self.ins_EX = 0
            self.ctl_EX = ID.nopControlWord
            self.selC_MEM = 0
            self.ctl_MEM = ID.nopControlWord
            self.j = 1
            self.n = 0
            self.c = 0
            self.z = 0
            self.v = 0
            self.associatedPC = nil
        }
        
        public init(ins: UInt16, rst: UInt) {
            self.ins = ins
            self.y_EX = 0
            self.y_MEM = 0
            self.ins_EX = 0
            self.ctl_EX = ID.nopControlWord
            self.selC_MEM = 0
            self.ctl_MEM = ID.nopControlWord
            self.j = 1
            self.n = 0
            self.c = 0
            self.z = 0
            self.v = 0
            self.associatedPC = nil
        }
        
        public init(ins: UInt16, j: UInt) {
            self.ins = ins
            self.y_EX = 0
            self.y_MEM = 0
            self.ins_EX = 0
            self.ctl_EX = ID.nopControlWord
            self.selC_MEM = 0
            self.ctl_MEM = ID.nopControlWord
            self.j = j
            self.n = 0
            self.c = 0
            self.z = 0
            self.v = 0
            self.associatedPC = nil
        }
        
        public init(ins: UInt16, ctl_EX: UInt) {
            self.ins = ins
            self.y_EX = 0
            self.y_MEM = 0
            self.ins_EX = 0
            self.ctl_EX = ctl_EX
            self.selC_MEM = 0
            self.ctl_MEM = ID.nopControlWord
            self.j = 1
            self.n = 0
            self.c = 0
            self.z = 0
            self.v = 0
            self.associatedPC = nil
        }
        
        public init(ins: UInt16, ins_EX: UInt, ctl_EX: UInt, y_EX: UInt16) {
            self.ins = ins
            self.y_EX = y_EX
            self.y_MEM = 0
            self.ins_EX = ins_EX
            self.ctl_EX = ctl_EX
            self.selC_MEM = 0
            self.ctl_MEM = ID.nopControlWord
            self.j = 1
            self.n = 0
            self.c = 0
            self.z = 0
            self.v = 0
            self.associatedPC = nil
        }
        
        public init(ins: UInt16, selC_MEM: UInt, ctl_MEM: UInt, y_MEM: UInt16) {
            self.ins = ins
            self.y_EX = 0
            self.y_MEM = y_MEM
            self.ins_EX = 0
            self.ctl_EX = ID.nopControlWord
            self.selC_MEM = selC_MEM
            self.ctl_MEM = ctl_MEM
            self.j = 1
            self.n = 0
            self.c = 0
            self.z = 0
            self.v = 0
            self.associatedPC = nil
        }
        
        public init(ins: UInt16,
                    y_EX: UInt16,
                    y_MEM: UInt16,
                    ins_EX: UInt,
                    ctl_EX: UInt,
                    selC_MEM: UInt,
                    ctl_MEM: UInt,
                    j: UInt,
                    n: UInt,
                    c: UInt,
                    z: UInt,
                    v: UInt,
                    associatedPC: UInt16? = nil) {
            self.ins = ins
            self.y_EX = y_EX
            self.y_MEM = y_MEM
            self.ins_EX = ins_EX
            self.ctl_EX = ctl_EX
            self.selC_MEM = selC_MEM
            self.ctl_MEM = ctl_MEM
            self.j = j
            self.n = n
            self.c = c
            self.z = z
            self.v = v
            self.associatedPC = associatedPC
        }
    }
    
    public var registerFile: [UInt16]
    public var decoder: InstructionDecoder
    public var associatedPC: UInt16?
    let hazardControlUnit: HazardControl = HazardControlMockup()
    
    public required override init() {
        registerFile = Array<UInt16>(repeating: 0, count: 8)
        decoder = OpcodeDecoderROM()
        associatedPC = nil
    }
    
    public required init?(coder: NSCoder) {
        guard let registerFile = coder.decodeObject(forKey: "registerFile") as? [UInt16],
              let decoder = coder.decodeObject(forKey: "decoder") as? InstructionDecoder,
              let associatedPC = coder.decodeObject(forKey: "associatedPC") as? UInt16? else {
            return nil
        }
        self.registerFile = registerFile
        self.decoder = decoder
        self.associatedPC = associatedPC
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(registerFile, forKey: "registerFile")
        coder.encode(decoder, forKey: "decoder")
        coder.encode(associatedPC, forKey: "associatedPC")
    }
    
    public static func decode(from data: Data) throws -> ID {
        var decodedObject: ID? = nil
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        decodedObject = unarchiver.decodeObject(of: self, forKey: NSKeyedArchiveRootObjectKey)
        if let error = unarchiver.error {
            fatalError("Error occured while attempting to decode \(self) from data: \(error.localizedDescription)")
        }
        guard let decodedObject else {
            fatalError("Failed to decode \(self) from data.")
        }
        return decodedObject
    }
    
    public static func ==(lhs: ID, rhs: ID) -> Bool {
        lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard let rhs = rhs as? ID else {
            return false
        }
        guard registerFile == rhs.registerFile,
              decoder == rhs.decoder,
              associatedPC == rhs.associatedPC else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(registerFile)
        hasher.combine(decoder.hash)
        hasher.combine(associatedPC)
        return hasher.finalize()
    }
    
    public func step(input: Input) -> ID_Output {
        let ctl_ID: UInt = decodeOpcode(input: input)
        let hazardControlSignals = hazardControlUnit.step(input: input,
                                                          left_operand_is_unused: (ctl_ID >> 21) & 1,
                                                          right_operand_is_unused: (ctl_ID >> 22) & 1)
        let flush = (hazardControlSignals.flush & 1)==0 // FLUSH is an active-low signal
        associatedPC = flush ? nil : input.associatedPC
        let ctl_EX: UInt = flush ? ID.nopControlWord : (ctl_ID & UInt((1<<21)-1)) // only the lower 21 bits are present on real hardware
        let a = forwardA(input, hazardControlSignals)
        let b = forwardB(input, hazardControlSignals)
        let ins = UInt(input.ins & 0x07ff)
        return ID_Output(stall: hazardControlSignals.stall & 1,
                         ctl_EX: ctl_EX,
                         a: a,
                         b: b,
                         ins: ins,
                         associatedPC: associatedPC)
    }
    
    public func decodeOpcode(input: Input) -> UInt {
        let opcode = UInt((input.ins >> 11) & 31)
        let ctl_ID = decoder.decode(n: input.n, c: input.c, z: input.z, v: input.v, opcode: opcode)
        return ctl_ID
    }
    
    fileprivate func forwardA(_ input: ID.Input, _ hzd: HazardControl.Output) -> UInt16 {
        if hzd.fwd_a == 0 && hzd.fwd_ex_to_a != 0 && hzd.fwd_mem_to_a != 0 {
            return readRegisterA(input: input)
        }
        if hzd.fwd_a != 0 && hzd.fwd_ex_to_a == 0 && hzd.fwd_mem_to_a != 0 {
            return input.y_EX
        }
        if hzd.fwd_a != 0 && hzd.fwd_ex_to_a != 0 && hzd.fwd_mem_to_a == 0 {
            return input.y_MEM
        }
        fatalError("illegal hazard resolution")
    }
    
    fileprivate func forwardB(_ input: ID.Input, _ hzd: HazardControl.Output) -> UInt16 {
        if hzd.fwd_b == 0 && hzd.fwd_ex_to_b != 0 && hzd.fwd_mem_to_b != 0 {
            return readRegisterB(input: input)
        }
        if hzd.fwd_b != 0 && hzd.fwd_ex_to_b == 0 && hzd.fwd_mem_to_b != 0 {
            return input.y_EX
        }
        if hzd.fwd_b != 0 && hzd.fwd_ex_to_b != 0 && hzd.fwd_mem_to_b == 0 {
            return input.y_MEM
        }
        fatalError("illegal hazard resolution")
    }
    
    public func readRegisterA(input: Input) -> UInt16 {
        return registerFile[Int(splitOutSelA(input: input))]
    }
    
    public func readRegisterB(input: Input) -> UInt16 {
        return registerFile[Int(splitOutSelB(input: input))]
    }
    
    public func splitOutSelA(input: Input) -> UInt {
        return UInt((input.ins >> 5) & 0b111)
    }
    
    public func splitOutSelB(input: Input) -> UInt {
        return UInt((input.ins >> 2) & 0b111)
    }
}
