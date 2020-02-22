//
//  Interpreter.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/21/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public protocol InterpreterDelegate: NSObject {
    func fetchInstruction(from: ProgramCounter) -> Instruction
}

// Interpreter for revision one of the computer hardware.
public class Interpreter: NSObject {
    public weak var delegate: InterpreterDelegate? = nil
    public let cpuState: CPUStateSnapshot
    let instructionDecoder: InstructionDecoder
    
    public init(cpuState: CPUStateSnapshot,
                instructionDecoder: InstructionDecoder) {
        self.cpuState = cpuState
        self.instructionDecoder = instructionDecoder
    }

    // This method duplicates the functionality of the hardware reset button.
    // The pipeline is flushed and the program counter is reset to zero.
    public func reset() {
        cpuState.bus = Register()
        cpuState.pc = ProgramCounter()
        cpuState.pc_if = ProgramCounter()
        cpuState.if_id = Instruction()
        cpuState.controlWord = ControlWord()
    }
    
    // Emulates one hardware clock tick.
    public func step() {
        onControlClock()
    }
    
    fileprivate func onControlClock() {
        doID()
        doIF()
        doPCIF()
        incrementPC()
    }
    
    func doID() {
        cpuState.registerC = Register(withValue: cpuState.if_id.immediate)
        let opcode = Int(cpuState.if_id.opcode)
        let b = instructionDecoder.load(opcode: opcode,
                                        carryFlag: cpuState.flags.carryFlag,
                                        equalFlag: cpuState.flags.equalFlag)
        cpuState.controlWord = ControlWord(withValue: UInt(b))
    }
    
    func doIF() {
        cpuState.if_id = delegate?.fetchInstruction(from: cpuState.pc_if) ?? Instruction()
    }
    
    func doPCIF() {
        cpuState.pc_if = ProgramCounter(withValue: cpuState.pc.value)
    }
    
    func incrementPC() {
        cpuState.pc = cpuState.pc.increment()
    }
}
