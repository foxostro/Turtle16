//
//  IF.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 12/23/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

public class IF_Output: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true
    
    public let ins: UInt16
    public let pc: UInt16
    public let associatedPC: UInt16?
    
    public override var description: String {
        let strIns = String(format: "%04x", ins)
        let strPC = String(format: "%04x", pc)
        return "ins: \(strIns), pc: \(strPC)"
    }
    
    public required init(ins: UInt16, pc: UInt16, associatedPC: UInt16? = nil) {
        self.ins = ins
        self.pc = pc
        self.associatedPC = associatedPC
    }
    
    public required init?(coder: NSCoder) {
        guard let ins = coder.decodeObject(forKey: "ins") as? UInt16,
              let pc = coder.decodeObject(forKey: "pc") as? UInt16,
              let associatedPC = coder.decodeObject(forKey: "associatedPC") as? UInt16? else {
            return nil
        }
        self.ins = ins
        self.pc = pc
        self.associatedPC = associatedPC
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(ins, forKey: "ins")
        coder.encode(pc, forKey: "pc")
        coder.encode(associatedPC, forKey: "associatedPC")
    }
    
    public static func ==(lhs: IF_Output, rhs: IF_Output) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard let rhs = rhs as? IF_Output else {
            return false
        }
        guard ins == rhs.ins,
              pc == rhs.pc,
              associatedPC == rhs.associatedPC else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(ins)
        hasher.combine(pc)
        hasher.combine(associatedPC)
        return hasher.finalize()
    }
}

// Models the IF (instruction fetch) stage of the Turtle16 pipeline.
// Please refer to IF.sch for details.
// Classes in the simulator intentionally model specific pieces of hardware,
// following naming conventions and organization that matches the schematics.
public class IF: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true
    
    public struct Input: Equatable, Hashable {
        public let stall: UInt
        public let y: UInt16
        public let jabs: UInt
        public let j: UInt
        public let rst: UInt
        
        public init(stall: UInt, y: UInt16, jabs: UInt, j: UInt, rst: UInt) {
            self.stall = stall
            self.y = y
            self.jabs = jabs
            self.j = j
            self.rst = rst
        }
    }
    
    public var alu = IDT7381()
    public var prevPC: UInt16 = 0
    public var prevIns: UInt16 = 0
    public var prevAssociatedPC: UInt16? = nil
    public var associatedPC: UInt16? = nil
    
    public var load: (UInt16) -> UInt16 = {(addr: UInt16) in
        return 0xffff // bogus
    }
    
    public func step(input: Input) -> IF_Output {
        // The ALU's F register updates on the clock so the IF stage takes two
        // clock cycles to complete.
        let aluOutput = alu.step(input: driveALU(input: input))
        let pc = (input.stall==0) ? aluOutput.f! : prevPC
        let nextIns = (input.j==0) ? 0 : load(prevPC)
        let ins = (input.stall==0) ? nextIns : prevIns
        
        if input.j == 0 {
            associatedPC = nil
        }
        else if input.stall == 1 {
            associatedPC = prevAssociatedPC
        }
        else {
            associatedPC = prevPC
        }
        
        prevPC = pc
        prevIns = ins
        prevAssociatedPC = associatedPC
        return IF_Output(ins: ins, pc: pc, associatedPC: associatedPC)
    }
    
    public func driveALU(input: Input) -> IDT7381.Input {
        let aluInput = IDT7381.Input(a: prevPC,
                                     b: input.y,
                                     c0: input.j & 1,
                                     i0: input.rst & 1,
                                     i1: input.rst & 1,
                                     i2: 0,
                                     rs0: input.jabs & 1,
                                     rs1: ~input.j & 1,
                                     ena: 0,
                                     enb: 0,
                                     enf: input.stall & 1,
                                     ftab: 0,
                                     ftf: 1,
                                     oe: 0)
        return aluInput
    }
    
    public required override init() {
    }
    
    public required init?(coder: NSCoder) {
        guard let alu = coder.decodeObject(of: IDT7381.self, forKey: "alu"),
              let prevPC = coder.decodeObject(forKey: "prevPC") as? UInt16,
              let prevIns = coder.decodeObject(forKey: "prevIns") as? UInt16,
              let prevAssociatedPC = coder.decodeObject(forKey: "prevAssociatedPC") as? UInt16?,
              let associatedPC = coder.decodeObject(forKey: "associatedPC") as? UInt16? else {
            return nil
        }
        self.alu = alu
        self.prevPC = prevPC
        self.prevIns = prevIns
        self.prevAssociatedPC = prevAssociatedPC
        self.associatedPC = associatedPC
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(alu, forKey: "alu")
        coder.encode(prevPC, forKey: "prevPC")
        coder.encode(prevIns, forKey: "prevIns")
        coder.encode(prevAssociatedPC, forKey: "prevAssociatedPC")
        coder.encode(associatedPC, forKey: "associatedPC")
    }
    
    public static func decode(from data: Data) throws -> IF {
        var decodedObject: IF? = nil
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
    
    public static func ==(lhs: IF, rhs: IF) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard let rhs = rhs as? IF else {
            return false
        }
        guard alu == rhs.alu,
              prevPC == rhs.prevPC,
              prevIns == rhs.prevIns,
              prevAssociatedPC == rhs.prevAssociatedPC,
              associatedPC == rhs.associatedPC else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(alu)
        hasher.combine(prevPC)
        hasher.combine(prevIns)
        hasher.combine(prevAssociatedPC)
        hasher.combine(associatedPC)
        return hasher.finalize()
    }
}
