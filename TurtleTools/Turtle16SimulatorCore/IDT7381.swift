//
//  IDT7381.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 12/23/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

// Models the IDT7381 sixteen-bit ALU IC in the Turtle16 computer.
// Classes in the simulator intentionally model specific pieces of hardware,
// following naming conventions and organization that matches the schematics.
public class IDT7381: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true
    
    public struct Input {
        public let a: UInt16
        public let b: UInt16
        public let c0: UInt
        public let i0: UInt
        public let i1: UInt
        public let i2: UInt
        public let rs0: UInt
        public let rs1: UInt
        public let ena: UInt
        public let enb: UInt
        public let enf: UInt
        public let ftab: UInt
        public let ftf: UInt
        public let oe: UInt
        
        public init(a: UInt16,
                    b: UInt16,
                    c0: UInt,
                    i0: UInt,
                    i1: UInt,
                    i2: UInt,
                    rs0: UInt,
                    rs1: UInt,
                    ena: UInt,
                    enb: UInt,
                    enf: UInt,
                    ftab: UInt,
                    ftf: UInt,
                    oe: UInt) {
            self.a = a
            self.b = b
            self.c0 = c0
            self.i0 = i0
            self.i1 = i1
            self.i2 = i2
            self.rs0 = rs0
            self.rs1 = rs1
            self.ena = ena
            self.enb = enb
            self.enf = enf
            self.ftab = ftab
            self.ftf = ftf
            self.oe = oe
        }
    }
    
    public struct Output {
        public let f: UInt16?
        public let c16: UInt
        public let z: UInt
        public let ovf: UInt
    }
    
    public var a: UInt16 = 0
    public var b: UInt16 = 0
    public var f: UInt16 = 0
    
    public required override init() {
        a = 0
        b = 0
        f = 0
    }
    
    public required init?(coder: NSCoder) {
        guard let a = coder.decodeObject(forKey: "a") as? UInt16,
              let b = coder.decodeObject(forKey: "b") as? UInt16,
              let f = coder.decodeObject(forKey: "f") as? UInt16 else {
            return nil
        }
        self.a = a
        self.b = b
        self.f = f
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(a, forKey: "a")
        coder.encode(b, forKey: "b")
        coder.encode(f, forKey: "f")
    }
    
    public static func decode(from data: Data) throws -> IDT7381 {
        var decodedObject: IDT7381? = nil
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
    
    public func step(input: Input) -> Output {
        if input.ena == 0 {
            a = input.a
        }
        
        if input.enb == 0 {
            b = input.b
        }
        
        let portF: UInt16?
        if input.oe == 0 {
            portF = fmux(input: input)
        } else {
            portF = nil
        }
        
        let c16 = computeC16(input: input)
        let z = computeZ(input: input)
        let ovf = computeOVF(input: input)
        
        if input.enf == 0 {
            f = computeResult(input: input)
        }
        
        return Output(f: portF, c16: c16, z: z, ovf: ovf)
    }
    
    public func fmux(input: Input) -> UInt16 {
        if input.ftf == 0 {
            return f
        }
        return computeResult(input: input)
    }
    
    public func computeResult(input: Input) -> UInt16 {
        let result: UInt16
        let r = rmux(input: input)
        let s = smux(input: input)
        switch (input.i2, input.i1, input.i0) {
        case (0, 0, 0):
            result = 0x0000
        case (0, 0, 1):
            result = ~r &+ s &+ UInt16(input.c0)
        case (0, 1, 0):
            result = r &+ ~s &+ UInt16(input.c0)
        case (0, 1, 1):
            result = r &+ s &+ UInt16(input.c0)
        case (1, 0, 0):
            result = r ^ s
        case (1, 0, 1):
            result = r | s
        case (1, 1, 0):
            result = r & s
        case (1, 1, 1):
            result = 0xffff
        default:
            assert(false) // unreachable
            abort()
        }
        return result
    }
    
    public func computeC16(input: Input) -> UInt {
        let result64: UInt64
        let result16: UInt16
        let r = rmux(input: input)
        let s = smux(input: input)
        let c16: UInt
        switch (input.i2, input.i1, input.i0) {
        case (0, 0, 1):
            result16 = ~r &+ s &+ UInt16(input.c0)
            result64 = UInt64(~r) + UInt64(s) + UInt64(input.c0)
            c16 = (result64 > result16) ? 1 : 0
        case (0, 1, 0):
            result16 = r &+ ~s &+ UInt16(input.c0)
            result64 = UInt64(r) + UInt64(~s) + UInt64(input.c0)
            c16 = (result64 > result16) ? 1 : 0
        case (0, 1, 1):
            result16 = r &+ s &+ UInt16(input.c0)
            result64 = UInt64(r) + UInt64(s) + UInt64(input.c0)
            c16 = (result64 > result16) ? 1 : 0
        default:
            c16 = 0
        }
        return c16
    }
    
    public func computeZ(input: Input) -> UInt {
        return (computeResult(input: input) == 0) ? 1 : 0
    }
    
    public func computeOVF(input: Input) -> UInt {
        let r0 = rmux(input: input)
        let s0 = smux(input: input)
        
        let r1: UInt16
        let s1: UInt16
        
        switch (input.i2, input.i1, input.i0) {
        case (0, 0, 1):
            r1 = ~r0
            s1 = s0
            
        case (0, 1, 0):
            r1 = r0
            s1 = ~s0
            
        case (0, 1, 1):
            r1 = r0
            s1 = s0
            
        default:
            r1 = 0
            s1 = 0
        }
        
        let result = r1 &+ s1 &+ UInt16(input.c0)
        
        // If the two operands have the same sign and the sum has a different
        // sign then overflow has occurred. Otherwise, there is no overflow.
        let ovf: UInt
        if (r1 & 0x8000) == (s1 & 0x8000) {
            ovf = ((r1 & 0x8000) != (result & 0x8000)) ? 1 : 0
        }
        else {
            ovf = 0
        }
        
        return ovf
    }
    
    public func rmux(input: Input) -> UInt16 {
        switch (input.rs1, input.rs0) {
        case (0, 0):
            return amux(input: input)
        case (0, 1):
            return amux(input: input)
        case (1, 0):
            return 0
        case (1, 1):
            return amux(input: input)
        default:
            assert(false) // unreachable
            abort()
        }
    }
    
    public func smux(input: Input) -> UInt16 {
        switch (input.rs1, input.rs0) {
        case (0, 0):
            return f
        case (0, 1):
            return 0
        case (1, 0):
            return bmux(input: input)
        case (1, 1):
            return bmux(input: input)
        default:
            assert(false) // unreachable
            abort()
        }
    }
    
    public func amux(input: Input) -> UInt16 {
        if input.ftab == 0 {
            return a
        }
        return input.a
    }
    
    public func bmux(input: Input) -> UInt16 {
        if input.ftab == 0 {
            return b
        }
        return input.b
    }
    
    public static func ==(lhs: IDT7381, rhs: IDT7381) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard let rhs = rhs as? IDT7381 else {
            return false
        }
        guard a == rhs.a,
              b == rhs.b,
              f == rhs.f else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(a)
        hasher.combine(b)
        hasher.combine(f)
        return hasher.finalize()
    }
}
