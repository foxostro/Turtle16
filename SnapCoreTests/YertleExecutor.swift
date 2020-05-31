//
//  YertleExecutor.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import TurtleCompilerToolbox
import TurtleSimulatorCore

// Simulates execution of a program written in the Yertle intermediate language.
class YertleExecutor: NSObject {
    let isVerboseLogging = false
    let microcodeGenerator: MicrocodeGenerator
    let assembler: AssemblerBackEnd
    var configure: (Computer)->Void = {_ in}
    
    override init() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
    }
    
    func execute(ir: [YertleInstruction]) throws -> Computer {
        let compiler = YertleToTurtleMachineCodeCompiler(assembler: assembler)
        try compiler.compile(ir: ir, base: 0)
        let instructions = compiler.instructions
        let computer = try execute(instructions: instructions)
        return computer
    }
    
    func execute(instructions: [Instruction]) throws -> Computer {
        let computer = makeComputer(microcodeGenerator: microcodeGenerator)
        computer.provideInstructions(instructions)
        
        // Ensure unpatched branches cause the machine to halt by inserting a
        // halt instruction at address 0xffff.
        computer.instructionMemory.store(value: 0x0100, to: 0xffff)
        
        configure(computer)
        try computer.runUntilHalted()
        return computer
    }
    
    func makeComputer(microcodeGenerator: MicrocodeGenerator) -> Computer {
        let computer = Computer()
        computer.provideMicrocode(microcode: microcodeGenerator.microcode)
        computer.logger = makeLogger()
        return computer
    }
    
    func makeLogger() -> Logger {
        return isVerboseLogging ? ConsoleLogger() : NullLogger()
    }
}

extension Computer {
    public var stackPointer: Int {
        let stackPointerHi = Int(dataRAM.load(from: Int(YertleToTurtleMachineCodeCompiler.kStackPointerAddressHi)))
        let stackPointerLo = Int(dataRAM.load(from: Int(YertleToTurtleMachineCodeCompiler.kStackPointerAddressLo)))
        let stackPointer = (stackPointerHi << 8) + stackPointerLo
        return stackPointer
    }
    
    public var stackTop: UInt8 {
        return dataRAM.load(from: stackPointer)
    }
}
