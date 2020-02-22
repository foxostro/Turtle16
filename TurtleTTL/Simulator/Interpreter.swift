//
//  Interpreter.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/21/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

// Interpreter for revision one of the computer hardware.
public class Interpreter: NSObject {
    public let cpuState: CPUStateSnapshot
    
    public init(cpuState: CPUStateSnapshot) {
        self.cpuState = cpuState
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
}
