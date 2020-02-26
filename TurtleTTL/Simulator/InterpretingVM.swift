//
//  InterpretingVM.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/25/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class InterpretingVM: NSObject, VirtualMachine, InterpreterDelegate {
    public let cpuState: CPUStateSnapshot
    public let instructionDecoder: InstructionDecoder
    public let peripherals: ComputerPeripherals
    public let dataRAM: RAM
    public let instructionROM: InstructionROM
    public var logger:Logger? = nil
    public var upperInstructionRAM: RAM
    public var lowerInstructionRAM: RAM
    
    let interpreter: Interpreter
    let instructionFormatter: InstructionFormatter
    
    public init(cpuState: CPUStateSnapshot,
                microcodeGenerator: MicrocodeGenerator,
                peripherals: ComputerPeripherals,
                dataRAM: RAM,
                instructionROM: InstructionROM,
                upperInstructionRAM: RAM,
                lowerInstructionRAM: RAM) {
        self.cpuState = cpuState
        instructionDecoder = microcodeGenerator.microcode
        self.peripherals = peripherals
        self.dataRAM = dataRAM
        self.instructionROM = instructionROM
        self.upperInstructionRAM = upperInstructionRAM
        self.lowerInstructionRAM = lowerInstructionRAM
        interpreter = Interpreter(cpuState: cpuState,
                                  peripherals: peripherals,
                                  dataRAM: dataRAM,
                                  instructionDecoder: instructionDecoder)
        instructionFormatter = InstructionFormatter(microcodeGenerator: microcodeGenerator)
        
        super.init()
        
        interpreter.delegate = self
    }
    
    public func reset() {
        logger?.append("InterpretingVM: reset")
        interpreter.reset()
    }
    
    public func step() {
        logger?.append("InterpretingVM: step")
        
        // TODO: Is it a problem to allocate a state object every tick?
        let prevState = cpuState.copy() as! CPUStateSnapshot
        
        interpreter.step()
        
        if let logger = logger {
            CPUStateSnapshot.logChanges(logger: logger,
                                        prevState: prevState,
                                        nextState: cpuState)
            logger.append("-----")
        }
    }
    
    public func fetchInstruction(from pc: ProgramCounter) -> Instruction {
        let offset = 0x8000
        
        let temp: Instruction
        if pc.value < offset {
            temp = instructionROM.load(from: cpuState.pc_if.integerValue)
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
        
        logger?.append("InterpretingVM: Fetched instruction from memory at \(pc) -> \(instruction)")
        return instruction
    }
    
    public func runUntilHalted() {
        while .inactive == cpuState.controlWord.HLT {
            step()
        }
    }
}
