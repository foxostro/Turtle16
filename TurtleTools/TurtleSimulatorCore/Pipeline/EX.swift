//
//  EX.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 12/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

public class EX_Output: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true

    public let n: UInt
    public let c: UInt
    public let z: UInt
    public let v: UInt
    public let j: UInt
    public let jabs: UInt
    public let y: UInt16
    public let hlt: UInt
    public let storeOp: UInt16
    public let ctl: UInt
    public let selC: UInt
    public let associatedPC: UInt16?

    public override var description: String {
        let n = (self.n == 0) ? "n" : "N"
        let c = (self.c == 0) ? "c" : "C"
        let z = (self.z == 0) ? "z" : "Z"
        let v = (self.v == 0) ? "v" : "V"
        let j = (self.j == 0) ? "J" : "j"
        let a = (self.jabs == 0) ? "A" : "a"
        let h = (self.hlt == 0) ? "H" : "h"
        return
            "\(n)\(c)\(z)\(v)\(j)\(a)\(h), y: \(String(format: "%04x", y)), storeOp: \(String(format: "%04x", storeOp)), ctl: \(String(format: "%x", ctl)), selC: \(selC)"
    }

    public required init(
        n: UInt,
        c: UInt,
        z: UInt,
        v: UInt,
        j: UInt,
        jabs: UInt,
        y: UInt16,
        hlt: UInt,
        storeOp: UInt16,
        ctl: UInt,
        selC: UInt,
        associatedPC: UInt16? = nil
    ) {
        self.n = n
        self.c = c
        self.z = z
        self.v = v
        self.j = j
        self.jabs = jabs
        self.y = y
        self.hlt = hlt
        self.storeOp = storeOp
        self.ctl = ctl
        self.selC = selC
        self.associatedPC = associatedPC
    }

    public required init?(coder: NSCoder) {
        guard let n = coder.decodeObject(forKey: "n") as? UInt,
            let c = coder.decodeObject(forKey: "c") as? UInt,
            let z = coder.decodeObject(forKey: "z") as? UInt,
            let v = coder.decodeObject(forKey: "v") as? UInt,
            let j = coder.decodeObject(forKey: "j") as? UInt,
            let jabs = coder.decodeObject(forKey: "jabs") as? UInt,
            let y = coder.decodeObject(forKey: "y") as? UInt16,
            let hlt = coder.decodeObject(forKey: "hlt") as? UInt,
            let storeOp = coder.decodeObject(forKey: "storeOp") as? UInt16,
            let ctl = coder.decodeObject(forKey: "ctl") as? UInt,
            let selC = coder.decodeObject(forKey: "selC") as? UInt,
            let associatedPC = coder.decodeObject(forKey: "associatedPC") as? UInt16?
        else {
            return nil
        }
        self.n = n
        self.c = c
        self.z = z
        self.v = v
        self.j = j
        self.jabs = jabs
        self.y = y
        self.hlt = hlt
        self.storeOp = storeOp
        self.ctl = ctl
        self.selC = selC
        self.associatedPC = associatedPC
    }

    public func encode(with coder: NSCoder) {
        coder.encode(n, forKey: "n")
        coder.encode(c, forKey: "c")
        coder.encode(z, forKey: "z")
        coder.encode(v, forKey: "v")
        coder.encode(j, forKey: "j")
        coder.encode(jabs, forKey: "jabs")
        coder.encode(y, forKey: "y")
        coder.encode(hlt, forKey: "hlt")
        coder.encode(storeOp, forKey: "storeOp")
        coder.encode(ctl, forKey: "ctl")
        coder.encode(selC, forKey: "selC")
        coder.encode(associatedPC, forKey: "associatedPC")
    }

    public static func == (lhs: EX_Output, rhs: EX_Output) -> Bool {
        lhs.isEqual(rhs)
    }

    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard let rhs = rhs as? EX_Output else {
            return false
        }
        guard n == rhs.n,
            c == rhs.c,
            z == rhs.z,
            v == rhs.v,
            j == rhs.j,
            jabs == rhs.jabs,
            y == rhs.y,
            hlt == rhs.hlt,
            storeOp == rhs.storeOp,
            ctl == rhs.ctl,
            selC == rhs.selC,
            associatedPC == rhs.associatedPC
        else {
            return false
        }
        return true
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(n)
        hasher.combine(c)
        hasher.combine(z)
        hasher.combine(v)
        hasher.combine(j)
        hasher.combine(jabs)
        hasher.combine(y)
        hasher.combine(hlt)
        hasher.combine(storeOp)
        hasher.combine(ctl)
        hasher.combine(selC)
        hasher.combine(associatedPC)
        return hasher.finalize()
    }
}

// Models the EX (execute) stage of the Turtle16 pipeline.
// Please refer to EX.sch for details.
// Classes in the simulator intentionally model specific pieces of hardware,
// following naming conventions and organization that matches the schematics.
public class EX: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true

    public var associatedPC: UInt16? = nil

    public struct Input: Hashable {
        public let pc: UInt16
        public let ctl: UInt
        public let a: UInt16
        public let b: UInt16
        public let ins: UInt
        public let associatedPC: UInt16?

        public init(ins: UInt) {
            self.pc = 0
            self.ctl = 0
            self.a = 0
            self.b = 0
            self.ins = ins
            self.associatedPC = nil
        }

        public init(ins: UInt, b: UInt16, ctl: UInt) {
            self.pc = 0
            self.ctl = ctl
            self.a = 0
            self.b = b
            self.ins = ins
            self.associatedPC = nil
        }

        public init(ins: UInt, b: UInt16, pc: UInt16, ctl: UInt) {
            self.pc = pc
            self.ctl = ctl
            self.a = 0
            self.b = b
            self.ins = ins
            self.associatedPC = nil
        }

        public init(ctl: UInt) {
            self.pc = 0
            self.ctl = ctl
            self.a = 0
            self.b = 0
            self.ins = 0
            self.associatedPC = nil
        }

        public init(a: UInt16, b: UInt16, ctl: UInt) {
            self.pc = 0
            self.ctl = ctl
            self.a = a
            self.b = b
            self.ins = 0
            self.associatedPC = nil
        }

        public init(
            pc: UInt16,
            ctl: UInt,
            a: UInt16,
            b: UInt16,
            ins: UInt,
            associatedPC: UInt16? = nil
        ) {
            self.pc = pc
            self.ctl = ctl
            self.a = a
            self.b = b
            self.ins = ins
            self.associatedPC = associatedPC
        }
    }

    public func step(input: Input) -> EX_Output {
        let c0 = (input.ctl >> 6) & 1
        let i0 = (input.ctl >> 7) & 1
        let i1 = (input.ctl >> 8) & 1
        let i2 = (input.ctl >> 9) & 1
        let rs0 = (input.ctl >> 10) & 1
        let rs1 = (input.ctl >> 11) & 1
        let j = (input.ctl >> 12) & 1
        let jabs = (input.ctl >> 13) & 1
        let hlt = input.ctl & 1
        let right = selectRightOperand(input: input)
        let alu = IDT7381()
        let aluOutput = alu.step(
            input: IDT7381.Input(
                a: input.a,
                b: right,
                c0: c0,
                i0: i0,
                i1: i1,
                i2: i2,
                rs0: rs0,
                rs1: rs1,
                ena: 0,
                enb: 0,
                enf: 0,
                ftab: 1,
                ftf: 1,
                oe: 0
            )
        )
        let storeOp = selectStoreOperand(input: input)
        associatedPC = input.associatedPC
        let y = aluOutput.f!
        let n = (UInt(y) >> 15) & 1
        return EX_Output(
            n: n,
            c: aluOutput.c16,
            z: aluOutput.z,
            v: aluOutput.ovf,
            j: j,
            jabs: jabs,
            y: y,
            hlt: hlt,
            storeOp: storeOp,
            ctl: input.ctl,
            selC: splitOutSelC(input: input),
            associatedPC: associatedPC
        )
    }

    public func splitOutSelC(input: Input) -> UInt {
        (input.ins >> 8) & 0b111
    }

    public func selectRightOperand(input: Input) -> UInt16 {
        let sel = (input.ctl >> 3) & 3
        switch sel {
        case 0b00:
            return input.b
        case 0b01:
            var val = UInt16(input.ins & 31)
            if (val & (1 << 4)) != 0 {
                val = val | 0b11111111_11100000
            }
            return val
        case 0b10:
            var val = UInt16(((input.ins >> 6) & 0b11100) | (input.ins & 0b11))
            if (val & (1 << 4)) != 0 {
                val = val | 0b11111111_11100000
            }
            return val
        case 0b11:
            var val = UInt16(input.ins & 2047)
            if (val & (1 << 10)) != 0 {
                val = val | 0b11111000_00000000
            }
            return val
        default:
            assert(false)
            fatalError("unreachable")
        }
    }

    public func selectStoreOperand(input: Input) -> UInt16 {
        let sel = (input.ctl >> 1) & 3
        switch sel {
        case 0b00:
            return input.b
        case 0b01:
            return input.pc
        case 0b10:
            var val = UInt16(input.ins & 0xff)
            if (val & (1 << 7)) != 0 {
                val = val | 0b11111111_00000000
            }
            return val
        case 0b11:
            let val = UInt16(UInt16(input.ins & 0xff) << 8) & 0xff00
            return val
        default:
            assert(false)  // unreachable
            fatalError("unreachable")
        }
    }

    public required override init() {
    }

    public required init?(coder: NSCoder) {
        guard let associatedPC = coder.decodeObject(forKey: "associatedPC") as? UInt16? else {
            return nil
        }
        self.associatedPC = associatedPC
    }

    public func encode(with coder: NSCoder) {
        coder.encode(associatedPC, forKey: "associatedPC")
    }

    public static func decode(from data: Data) throws -> EX {
        var decodedObject: EX? = nil
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        decodedObject = unarchiver.decodeObject(of: self, forKey: NSKeyedArchiveRootObjectKey)
        if let error = unarchiver.error {
            fatalError(
                "Error occured while attempting to decode \(self) from data: \(error.localizedDescription)"
            )
        }
        guard let decodedObject else {
            fatalError("Failed to decode \(self) from data.")
        }
        return decodedObject
    }

    public static func == (lhs: EX, rhs: EX) -> Bool {
        lhs.isEqual(rhs)
    }

    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard let rhs = rhs as? EX else {
            return false
        }
        guard associatedPC == rhs.associatedPC else {
            return false
        }
        return true
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(associatedPC)
        return hasher.finalize()
    }
}
