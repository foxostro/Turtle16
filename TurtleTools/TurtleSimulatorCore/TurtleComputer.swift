//
//  TurtleComputer.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

public enum ResetType {
    case soft, hard
}

extension Notification.Name {
    public static let computerStateDidChange = Notification.Name("computerStateDidChange")
    public static let computerIsFreeRunningDidChange = Notification.Name(
        "computerIsFreeRunningDidChange"
    )
}

// Models the Turtle16 Computer as a whole.
// This is where we simulate memory mapping and integration with peripherals.
public class TurtleComputer: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true
    public private(set) var cpu: CPU
    public var ram: [UInt16]
    public var decoder: InstructionDecoder {
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

    let isFreeRunningLock = NSLock()
    var isFreeRunningInternal = false

    public var isFreeRunning: Bool {
        set(newValue) {
            isFreeRunningLock.withLock {
                isFreeRunningInternal = newValue
                DispatchQueue.global().async { [weak self] in
                    guard let self else { return }
                    NotificationCenter.default.post(
                        name: .computerIsFreeRunningDidChange,
                        object: self
                    )
                }
            }
        }
        get {
            isFreeRunningLock.withLock {
                isFreeRunningInternal
            }
        }
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

    public private(set) var bank = 0 {
        didSet {
            assert(bank >= 0 && bank <= 7)
            cachedDisassembly = nil
        }
    }

    public required init(cpu: CPU, ram: [UInt16], isFreeRunning: Bool = false) {
        self.ram = ram
        self.cpu = cpu
        isFreeRunningInternal = isFreeRunning
        isFreeRunningLock.name = "TurtleComputer.isFreeRunningLock"
        super.init()
        cpu.store = { [weak self] in
            self?.store(value: $0, address: $1)
        }
        cpu.load = { [weak self] in
            guard let self else { return 0 }
            return self.load(address: $0)
        }
    }

    public let bankRegisterAddress = MemoryAddress(0xffff)

    private func store(value: UInt16, address: MemoryAddress) {
        if address == bankRegisterAddress {
            bank = Int(value & 0b111)
        }

        ram[address.value] = value
    }

    private func load(address: MemoryAddress) -> UInt16 {
        ram[address.value]
    }

    public convenience init(_ cpu: CPU) {
        self.init(cpu: cpu, ram: [UInt16](repeating: 0, count: Int(UInt16.max) + 1))
    }

    public required convenience init?(coder: NSCoder) {
        guard let cpu = coder.decodeObject(of: SchematicLevelCPUModel.self, forKey: "cpu"),
            let ram = coder.decodeObject(forKey: "ram") as? [UInt16]
        else {
            return nil
        }
        let isFreeRunning = coder.decodeBool(forKey: "isFreeRunning")
        self.init(cpu: cpu, ram: ram, isFreeRunning: isFreeRunning)
    }

    public func encode(with coder: NSCoder) {
        coder.encode(cpu, forKey: "cpu")
        coder.encode(ram, forKey: "ram")
        coder.encode(isFreeRunning, forKey: "isFreeRunning")
    }

    public static func decode(from data: Data) throws -> TurtleComputer {
        var decodedObject: TurtleComputer? = nil
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

    public func setRegister(_ idx: Int, _ val: UInt16) {
        cpu.setRegister(idx, val)
    }

    public func getRegister(_ idx: Int) -> UInt16 {
        cpu.getRegister(idx)
    }

    public func reset(_ type: ResetType = .soft) {
        bank = 0

        switch type {
        case .soft:
            cpu.reset()

        case .hard:
            cpu.reset()
            for i in 0..<numberOfRegisters {
                setRegister(i, 0)
            }
            ram = [UInt16](repeating: 0, count: ram.count)
        }
    }

    public func run() {
        _ = cpu.run(until: Date.distantFuture)
    }

    public func run(until date: Date = Date.distantFuture) -> Bool {
        cpu.run(until: date)
    }

    public func step() {
        cpu.step()
    }

    public struct Disassembly {
        public let labels: [Int: String]
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

    public static func == (lhs: TurtleComputer, rhs: TurtleComputer) -> Bool {
        lhs.isEqual(rhs)
    }

    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? TurtleComputer,
            ram == rhs.ram,
            cpu == rhs.cpu
        else {
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
        let snapshot = try! NSKeyedArchiver.archivedData(
            withRootObject: self,
            requiringSecureCoding: false
        )
        return snapshot
    }

    public func restore(from snapshot: Data) {
        var decodedComputer: TurtleComputer? = nil
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: snapshot)
            unarchiver.requiresSecureCoding = false
            decodedComputer = unarchiver.decodeObject(
                of: TurtleComputer.self,
                forKey: NSKeyedArchiveRootObjectKey
            )
            if let error = unarchiver.error {
                fatalError(
                    "Error occured while attempting to restore computer state from snapshot: \(error.localizedDescription)"
                )
            }
        }
        catch {
            fatalError(
                "Exception occured while attempting to restore computer state from snapshot: \(error.localizedDescription)"
            )
        }
        guard let decodedComputer else {
            fatalError("Failed to restore computer state from snapshot.")
        }
        cpu = decodedComputer.cpu
        ram = decodedComputer.ram
        cachedDisassembly = nil
        NotificationCenter.default.post(name: .computerStateDidChange, object: snapshot)
    }
}
