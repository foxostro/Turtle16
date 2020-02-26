//
//  VirtualMachine.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/25/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public protocol VirtualMachine: NSObject {
    var cpuState: CPUStateSnapshot { get }
    var instructionDecoder: InstructionDecoder { get }
    var peripherals: ComputerPeripherals { get }
    var dataRAM: RAM { get }
    var instructionROM: InstructionROM { get }
    var upperInstructionRAM: RAM { get }
    var lowerInstructionRAM: RAM { get }
    var logger:Logger? { get set }
    
    // This method duplicates the functionality of the hardware reset button.
    // The pipeline is flushed and the program counter is reset to zero.
    func reset()
    
    // Emulates one hardware clock tick.
    func step()
    
    // Runs the VM until the CPU is halted via the HLT instruction.
    func runUntilHalted()
}
