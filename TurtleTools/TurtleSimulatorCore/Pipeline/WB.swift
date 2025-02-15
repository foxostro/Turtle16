//
//  WB.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 12/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

public class WB_Output: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true
    
    public let c: UInt16
    public let wrl: UInt
    public let wrh: UInt
    public let wben: UInt
    
    public override var description: String {
        return "c: \(String(format: "%04x", c)), wrl: \(wrl), wrh: \(wrh), wben: \(wben)"
    }
    
    public init(c: UInt16, wrl: UInt, wrh: UInt, wben: UInt) {
        self.c = c
        self.wrl = wrl
        self.wrh = wrh
        self.wben = wben
    }
    
    public required init?(coder: NSCoder) {
        guard let c = coder.decodeObject(forKey: "c") as? UInt16,
              let wrl = coder.decodeObject(forKey: "wrl") as? UInt,
              let wrh = coder.decodeObject(forKey: "wrh") as? UInt,
              let wben = coder.decodeObject(forKey: "wben") as? UInt else {
            return nil
        }
        self.c = c
        self.wrl = wrl
        self.wrh = wrh
        self.wben = wben
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(c, forKey: "c")
        coder.encode(wrl, forKey: "wrl")
        coder.encode(wrh, forKey: "wrh")
        coder.encode(wben, forKey: "wben")
    }
    
    public static func ==(lhs: WB_Output, rhs: WB_Output) -> Bool {
        lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard let rhs = rhs as? WB_Output else {
            return false
        }
        guard c == rhs.c,
              wrl == rhs.wrl,
              wrh == rhs.wrh,
              wben == rhs.wben else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(c)
        hasher.combine(wrl)
        hasher.combine(wrh)
        hasher.combine(wben)
        return hasher.finalize()
    }
}

// Models the WB (write back) stage of the Turtle16 pipeline.
// Please refer to WB.sch for details.
// Classes in the simulator intentionally model specific pieces of hardware,
// following naming conventions and organization that matches the schematics.
public class WB: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true
    
    public var associatedPC: UInt16? = nil
    
    public struct Input: Hashable {
        public let y: UInt16
        public let storeOp: UInt16
        public let ctl: UInt
        public let associatedPC: UInt16?
        
        public init(ctl: UInt) {
            self.y = 0
            self.storeOp = 0
            self.ctl = ctl
            self.associatedPC = nil
        }
        
        public init(y: UInt16, storeOp: UInt16, ctl: UInt, associatedPC: UInt16? = nil) {
            self.y = y
            self.storeOp = storeOp
            self.ctl = ctl
            self.associatedPC = associatedPC
        }
    }
    
    public func step(input: Input) -> WB_Output {
        let writeBackSrc = UInt((input.ctl >> 17) & 1)
        let c = (writeBackSrc == 0) ? input.y : input.storeOp
        let wrl: UInt = UInt((input.ctl >> 18) & 1)
        let wrh: UInt = UInt((input.ctl >> 19) & 1)
        let wben: UInt = UInt((input.ctl >> 20) & 1)
        associatedPC = input.associatedPC
        return WB_Output(c: c, wrl: wrl, wrh: wrh, wben: wben)
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
    
    public static func decode(from data: Data) throws -> WB {
        var decodedObject: WB? = nil
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
    
    public static func ==(lhs: WB, rhs: WB) -> Bool {
        lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard let rhs = rhs as? WB else {
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
