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
public class Turtle16Computer: NSObject {
    public let cpu: CPU
    public var ram: [UInt16]
    public var opcodeDecodeROM: [UInt] {
        set(value) {
            cpu.opcodeDecodeROM = value
        }
        get {
            cpu.opcodeDecodeROM
        }
    }
    
    public var timeStamp: UInt {
        cpu.timeStamp
    }
    
    public init(_ cpu: CPU) {
        self.cpu = cpu
        self.ram = Array<UInt16>(repeating: 0, count: Int(UInt16.max)+1)
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
        }
        get {
            cpu.instructions
        }
    }
    
    public var carry: UInt {
        cpu.carry
    }
    
    public var z: UInt {
        cpu.z
    }
    
    public var ovf: UInt {
        cpu.ovf
    }
    
    public var numberOfRegisters: Int {
        cpu.numberOfRegisters
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
}
