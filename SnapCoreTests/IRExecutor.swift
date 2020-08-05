//
//  IRExecutor.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import TurtleCompilerToolbox
import TurtleSimulatorCore

// Simulates execution of a program written in the intermediate language.
class IRExecutor: NSObject {
    public var isVerboseLogging = false
    let microcodeGenerator: MicrocodeGenerator
    let assembler: AssemblerBackEnd
    var configure: (Computer) -> Void = {_ in}
    
    override init() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
    }
    
    func execute(ir: [IRInstruction]) throws -> Computer {
        if isVerboseLogging {
            print("IR:\n" + IRInstruction.makeListing(instructions: ir) + "\n\n")
        }
        
        var computer: Computer!
        
        do {
            let compiler = IRToTurtleMachineCodeCompiler(assembler: assembler)
            compiler.injectCode = { (compiler: IRToTurtleMachineCodeCompiler) in
                try compiler.label("panic")
                try compiler.push16(0xdead)
                compiler.hlt()
            }
            try compiler.compile(ir: ir, base: 0)
            let instructions = compiler.instructions
            computer = try execute(instructions: instructions)
        } catch let e as CompilerError {
            print(e.message)
            throw e
        }
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
