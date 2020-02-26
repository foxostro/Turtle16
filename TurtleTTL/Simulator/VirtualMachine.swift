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
    public let dataRAM: RAM
    public let instructionROM: InstructionROM
    public let upperInstructionRAM: RAM
    public let lowerInstructionRAM: RAM
    public let instructionFormatter: InstructionFormatter
    public let microcodeGenerator = MicrocodeGenerator()
    
    public init(cpuState: CPUStateSnapshot,
                instructionDecoder: InstructionDecoder,
                peripherals: ComputerPeripherals,
                dataRAM: RAM,
                instructionROM: InstructionROM,
                upperInstructionRAM: RAM,
                lowerInstructionRAM: RAM) {
        self.cpuState = cpuState
        self.instructionDecoder = instructionDecoder
        self.peripherals = peripherals
        self.dataRAM = dataRAM
        self.instructionROM = instructionROM
        self.upperInstructionRAM = upperInstructionRAM
        self.lowerInstructionRAM = lowerInstructionRAM
        microcodeGenerator.generate()
        instructionFormatter = InstructionFormatter(microcodeGenerator: microcodeGenerator)
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
        let offset = 0x8000
        
        let temp: Instruction
        if pc.value < offset {
            temp = instructionROM.load(from: pc.integerValue)
        } else {
            let opcode = upperInstructionRAM.load(from: pc.integerValue - offset)
            let immediate = lowerInstructionRAM.load(from: pc.integerValue - offset)
            temp = Instruction(opcode: opcode, immediate: immediate)
        }

        let disassembly = instructionFormatter.format(instruction: temp)
        let instruction = Instruction(opcode: temp.opcode,
                                      immediate: temp.immediate,
                                      disassembly: disassembly,
                                      pc: pc)
        
        logger?.append("\(String(describing: type(of: self))): Fetched instruction from memory at \(pc) -> \(instruction)")
        return instruction
    }
}
