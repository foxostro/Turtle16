//
//  Turtle16Computer.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

// Models the Turtle16 Computer as a whole.
// This is where we simulate memory mapping and integration with peripherals.
public class Turtle16Computer: NSObject {
    public let cpu: CPU
    public var ram: [UInt16]
    
    public init(_ cpu: CPU) {
        self.cpu = cpu
        self.ram = Array<UInt16>(repeating: 0, count: 65535)
    }
    
    public var isHalted: Bool {
        cpu.isHalted
    }
    
    public var isResetting: Bool {
        cpu.isResetting
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
    
    public func reset() {
        cpu.reset()
    }
    
    public func run() {
        cpu.run()
    }
    
    public func step() {
        cpu.step()
    }
}