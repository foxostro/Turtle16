//
//  MEM.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 12/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

public class MEM_Output: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true

    public let y: UInt16
    public let storeOp: UInt16
    public let selC: UInt
    public let ctl: UInt
    public let associatedPC: UInt16?

    public override var description: String {
        "y: \(String(format: "%04x", y)), storeOp: \(String(format: "%04x", storeOp)), selC: \(selC), ctl: \(String(format: "%x", ctl))"
    }

    public init(y: UInt16, storeOp: UInt16, selC: UInt, ctl: UInt, associatedPC: UInt16? = nil) {
        self.y = y
        self.storeOp = storeOp
        self.selC = selC
        self.ctl = ctl
        self.associatedPC = associatedPC
    }

    public required init?(coder: NSCoder) {
        guard let y = coder.decodeObject(forKey: "y") as? UInt16,
              let storeOp = coder.decodeObject(forKey: "storeOp") as? UInt16,
              let selC = coder.decodeObject(forKey: "selC") as? UInt,
              let ctl = coder.decodeObject(forKey: "ctl") as? UInt,
              let associatedPC = coder.decodeObject(forKey: "associatedPC") as? UInt16?
        else {
            return nil
        }
        self.y = y
        self.storeOp = storeOp
        self.selC = selC
        self.ctl = ctl
        self.associatedPC = associatedPC
    }

    public func encode(with coder: NSCoder) {
        coder.encode(y, forKey: "y")
        coder.encode(storeOp, forKey: "storeOp")
        coder.encode(selC, forKey: "selC")
        coder.encode(ctl, forKey: "ctl")
        coder.encode(associatedPC, forKey: "associatedPC")
    }

    public static func == (lhs: MEM_Output, rhs: MEM_Output) -> Bool {
        lhs.isEqual(rhs)
    }

    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard let rhs = rhs as? MEM_Output else {
            return false
        }
        guard y == rhs.y,
              storeOp == rhs.storeOp,
              selC == rhs.selC,
              ctl == rhs.ctl,
              associatedPC == rhs.associatedPC
        else {
            return false
        }
        return true
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(y)
        hasher.combine(storeOp)
        hasher.combine(selC)
        hasher.combine(ctl)
        hasher.combine(associatedPC)
        return hasher.finalize()
    }
}

// Models the MEM (memory) stage of the Turtle16 pipeline.
// Please refer to MEM.sch for details.
// Classes in the simulator intentionally model specific pieces of hardware,
// following naming conventions and organization that matches the schematics.
public class MEM: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true

    public var associatedPC: UInt16?

    public struct Input: Hashable {
        public let rdy: UInt
        public let y: UInt16
        public let storeOp: UInt16
        public let selC: UInt
        public let ctl: UInt
        public let associatedPC: UInt16?

        public init(
            rdy: UInt,
            y: UInt16,
            storeOp: UInt16,
            selC: UInt,
            ctl: UInt,
            associatedPC: UInt16? = nil
        ) {
            self.rdy = rdy
            self.y = y
            self.storeOp = storeOp
            self.selC = selC
            self.ctl = ctl
            self.associatedPC = associatedPC
        }
    }

    public var load: (MemoryAddress) -> UInt16 = { (_: MemoryAddress) in
        0 // do nothing
    }

    public var store: (UInt16, MemoryAddress) -> Void = { (_: UInt16, _: MemoryAddress) in
        // do nothing
    }

    public func step(input: Input) -> MEM_Output {
        var storeOp: UInt16 = 0
        if input.rdy == 0 {
            let isLoad = UInt((input.ctl >> 14) & 1) == 0
            let isStore = UInt((input.ctl >> 15) & 1) == 0
            let isAssertingStoreOp = UInt((input.ctl >> 16) & 1) == 0
            if isAssertingStoreOp {
                storeOp = input.storeOp
            }
            if isStore {
                store(storeOp, MemoryAddress(input.y))
            }
            if isLoad {
                assert(!isAssertingStoreOp)
                storeOp = load(MemoryAddress(input.y))
            }
        }
        associatedPC = input.associatedPC
        return MEM_Output(
            y: input.y,
            storeOp: storeOp,
            selC: input.selC,
            ctl: input.ctl,
            associatedPC: associatedPC
        )
    }

    public override required init() {}

    public required init?(coder: NSCoder) {
        guard let associatedPC = coder.decodeObject(forKey: "associatedPC") as? UInt16? else {
            return nil
        }
        self.associatedPC = associatedPC
    }

    public func encode(with coder: NSCoder) {
        coder.encode(associatedPC, forKey: "associatedPC")
    }

    public static func decode(from data: Data) throws -> MEM {
        var decodedObject: MEM? = nil
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

    public static func == (lhs: MEM, rhs: MEM) -> Bool {
        lhs.isEqual(rhs)
    }

    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard let rhs = rhs as? MEM else {
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
