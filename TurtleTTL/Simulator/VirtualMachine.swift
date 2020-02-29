//
//  VirtualMachine.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/25/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

public class VirtualMachine: NSObject, InterpreterDelegate {
    public var logger:Logger? = nil
    public let cpuState: CPUStateSnapshot
    public let instructionDecoder: InstructionDecoder
    public let peripherals: ComputerPeripherals
    public let dataRAM: Memory
    public let instructionMemory: InstructionMemory
    
    public init(cpuState: CPUStateSnapshot,
                instructionDecoder: InstructionDecoder,
                peripherals: ComputerPeripherals,
                dataRAM: Memory,
                instructionMemory: InstructionMemory) {
        self.cpuState = cpuState
        self.instructionDecoder = instructionDecoder
        self.peripherals = peripherals
        self.dataRAM = dataRAM
        self.instructionMemory = instructionMemory
    }
    
    // This method duplicates the functionality of the hardware reset button.
    // The pipeline is flushed and the program counter is reset to zero.
    public func reset() {
        logger?.append("\(String(describing: type(of: self))): reset")
        cpuState.bus = Register()
        cpuState.pc = ProgramCounter()
        cpuState.pc_if = ProgramCounter()
        cpuState.if_id = Instruction.makeNOP()
        cpuState.controlWord = ControlWord()
        cpuState.registerC = Register(withValue: 0)
        cpuState.uptime = 0
    }
    
    // Emulates one hardware clock tick.
    public func step() {
        assert(false) // override in a subclass
    }
    
    // Runs the VM until the CPU is halted via the HLT instruction.
    public func runUntilHalted() {
        logger?.append("\(String(describing: type(of: self))): runUntilHalted")
        while .inactive == cpuState.controlWord.HLT {
            step()
        }
    }
    
    public func fetchInstruction(from pc: ProgramCounter) -> Instruction {
        let instruction = instructionMemory.load(from: pc.integerValue)
        logger?.append("\(String(describing: type(of: self))): Fetched instruction from memory at \(pc) -> \(instruction)")
        return instruction
    }
}
