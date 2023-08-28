//
//  Turtle16Computer.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

public enum ResetType {
    case soft, hard
}

public extension Notification.Name {
    static let virtualMachineStateDidChange = Notification.Name("VirtualMachineStateDidChange")
}

// Models the Turtle16 Computer as a whole.
// This is where we simulate memory mapping and integration with peripherals.
public class Turtle16Computer: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true
    public private(set) var cpu: CPU
    public var ram: [UInt16]
    public var decoder: Decoder {
        set(value) {
            cpu.decoder = value
        }
        get {
            cpu.decoder
        }
    }
    
    public var timeStamp: UInt {
        cpu.timeStamp
    }
    
    public var isHalted: Bool {
        cpu.isHalted
    }
    
    public var isResetting: Bool {
        cpu.isResetting
    }
    
    public var isStalling: Bool {
        cpu.isStalling
    }
    
    public var pc: UInt16 {
        set(pc) {
            cpu.pc = pc
        }
        get {
            cpu.pc
        }
    }
    
    public var instructions: [UInt16] {
        set(instructions) {
            cpu.instructions = instructions
            cachedDisassembly = nil
        }
        get {
            cpu.instructions
        }
    }
    
    public var n: UInt {
        cpu.n
    }
    
    public var c: UInt {
        cpu.c
    }
    
    public var z: UInt {
        cpu.z
    }
    
    public var v: UInt {
        cpu.v
    }
    
    public var numberOfRegisters: Int {
        cpu.numberOfRegisters
    }
    
    public required init(cpu: CPU, ram: [UInt16]) {
        self.cpu = cpu
        self.ram = ram
    }
    
    public convenience init(_ cpu: CPU) {
        self.init(cpu: cpu, ram: Array<UInt16>(repeating: 0, count: Int(UInt16.max)+1))
    }
    
    public required convenience init?(coder: NSCoder) {
        guard let cpu = coder.decodeObject(of: SchematicLevelCPUModel.self, forKey: "cpu"),
              let ram = coder.decodeObject(forKey: "ram") as? [UInt16] else {
            return nil
        }
        self.init(cpu: cpu, ram: ram)
    }

    public func encode(with coder: NSCoder) {
        coder.encode(cpu, forKey: "cpu")
        coder.encode(ram, forKey: "ram")
    }
    
    public func setRegister(_ idx: Int, _ val: UInt16) {
        cpu.setRegister(idx, val)
    }
    
    public func getRegister(_ idx: Int) -> UInt16 {
        cpu.getRegister(idx)
    }
    
    public func reset(_ type: ResetType = .soft) {
        switch type {
        case .soft:
            cpu.reset()
            
        case .hard:
            cpu.reset()
            for i in 0..<numberOfRegisters {
                setRegister(i, 0)
            }
        }
    }
    
    public func run() {
        cpu.run()
    }
    
    public func step() {
        cpu.step()
    }
    
    public struct Disassembly {
        public let labels: [Int : String]
        public let entries: [Disassembler.Entry]
    }
    
    fileprivate var cachedDisassembly: Disassembly? = nil
    
    public var disassembly: Disassembly {
        if nil == cachedDisassembly {
            let disassembler = Disassembler()
            let entries = disassembler.disassemble(cpu.instructions)
            let labels = disassembler.labels
            cachedDisassembly = Disassembly(labels: labels, entries: entries)
        }
        return cachedDisassembly!
    }
    
    public static func ==(lhs: Turtle16Computer, rhs: Turtle16Computer) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? Turtle16Computer,
              ram == rhs.ram,
              cpu == rhs.cpu else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(cpu.hash)
        hasher.combine(ram)
        return hasher.finalize()
    }
    
    public func snapshot() -> Data {
        let snapshot = try! NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
        return snapshot
    }
    
    public func restore(from snapshot: Data) {
        var decodedComputer: Turtle16Computer? = nil
        do {
            decodedComputer = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(snapshot) as? Turtle16Computer
        }
        catch {
            fatalError("Exception occured while attempting to restore computer state from snapshot: \(error.localizedDescription)")
        }
        guard let decodedComputer else {
            fatalError("Failed to restore computer state from snapshot.")
        }
        cpu = decodedComputer.cpu
        ram = decodedComputer.ram
        cachedDisassembly = nil
        NotificationCenter.default.post(name: .virtualMachineStateDidChange, object: self)
    }
}
