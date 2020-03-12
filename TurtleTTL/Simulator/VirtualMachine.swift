//
//  VirtualMachine.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/25/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

public struct VirtualMachineError: Error {
    public let message: String
    
    public init(format: String, _ args: CVarArg...) {
        message = String(format:format, arguments:args)
    }
    
    public init(_ message: String) {
        self.message = message
    }
}

public class VirtualMachine: NSObject, InterpreterDelegate {
    public var logger: Logger?
    public var stopwatch: ComputerStopwatch?
    public let cpuState: CPUStateSnapshot
    public let microcodeGenerator: MicrocodeGenerator
    public let peripherals: ComputerPeripherals
    public let dataRAM: Memory
    public let instructionMemory: InstructionMemory
    
    // For debugging and diagnostics, the virtual machine can optionally record
    // execution states over time.
    public var shouldRecordStatesOverTime = false
    public var recordedStatesOverTime: [CPUStateSnapshot] = []
    public var numberOfStepsExecuted = 0
    
    // Raise this boolean flag to request execution stop on the next breakpoint.
    public let flagBreak: AtomicBooleanFlag
    
    public init(cpuState: CPUStateSnapshot,
                microcodeGenerator: MicrocodeGenerator,
                peripherals: ComputerPeripherals,
                dataRAM: Memory,
                instructionMemory: InstructionMemory,
                flagBreak: AtomicBooleanFlag = AtomicBooleanFlag()) {
        self.cpuState = cpuState
        self.microcodeGenerator = microcodeGenerator
        self.peripherals = peripherals
        self.dataRAM = dataRAM
        self.instructionMemory = instructionMemory
        self.flagBreak = flagBreak
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
    
    // Emulates a single hardware clock tick.
    public func singleStep() {
        assert(false) // override in a subclass
    }
    
    // Executes a comfortable emulation unit, which may be a single instruction
    // or it may be a block representing multiple instructions. The details
    // depend on the emulation strategy employed by the concrete subclass.
    public func step() {
        assert(false) // override in a subclass
    }
    
    // Runs the VM until the CPU is halted via the HLT instruction.
    public func runUntilHalted(maxSteps: Int = Int.max) throws {
        var stepCount = 0
        logger?.append("\(String(describing: type(of: self))): runUntilHalted")
        while .inactive == cpuState.controlWord.HLT {
            if stepCount >= maxSteps {
                throw VirtualMachineError("Exceeded maximum number of step: stepCount=\(stepCount) ; maxSteps=\(maxSteps)")
            }
            step()
            stepCount += 1
        }
    }
    
    public func fetchInstruction(from pc: ProgramCounter) -> Instruction {
        let instruction = instructionMemory.load(from: pc.integerValue)
        logger?.append("\(String(describing: type(of: self))): Fetched instruction from memory at \(pc) -> \(instruction)")
        return instruction
    }
    
    // Indicates to the virtual machine that instruction memory was modified by
    // an external actor. This provides the virtual machine with an opportunity
    // to invalidate internal caches and perform other book keeping.
    public func didModifyInstructionMemory() {
        // override in a subclass
    }
}
