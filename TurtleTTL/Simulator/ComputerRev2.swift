//
//  ComputerRev2.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 3/14/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class ComputerRev2: ComputerRev1 {
    override func makeInterpreter() -> Interpreter {
        return InterpreterRev2(cpuState: cpuState,
                               peripherals: peripherals,
                               dataRAM: dataRAM,
                               instructionDecoder: microcodeGenerator.microcode)
    }
}
