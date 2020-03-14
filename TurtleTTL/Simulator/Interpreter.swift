//
//  Interpreter.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/21/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public protocol InterpreterDelegate: NSObject {
    // Fetch an instruction for the IF stage. This may fetch from instruction
    // RAM, or from some other source.
    func fetchInstruction(from: ProgramCounter) -> Instruction
}

// Interpreter for revision one of the computer hardware.
public protocol Interpreter: NSObject {
    var delegate: InterpreterDelegate? { get set }
    var cpuState: CPUStateSnapshot { get }
    var instructionDecoder: InstructionDecoder { get set }
    var peripherals: ComputerPeripherals { get set }
    var dataRAM: Memory { get set }

    // This method duplicates the functionality of the hardware reset button.
    // The pipeline is flushed and the program counter is reset to zero.
    func reset()
    
    // Emulates one hardware clock tick.
    func step()
}
