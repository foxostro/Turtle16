//
//  SnapExecutor.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/6/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import TurtleCompilerToolbox
import TurtleSimulatorCore

// Simulates execution of a program written in the Snap programming language.
class SnapExecutor: NSObject {
    public var isUsingStandardLibrary = false
    public var isVerboseLogging = false
    public var shouldAlwaysPrintIR = false
    let microcodeGenerator: MicrocodeGenerator
    let compiler = SnapCompiler()
    var configure: (Computer)->Void = {_ in}
    
    override init() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
    }
    
    func execute(program: String) throws -> Computer {
        compiler.isUsingStandardLibrary = isUsingStandardLibrary
        compiler.compile(program: program, base: 0)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            return Computer()
        } else {
            let instructions = compiler.instructions
            
            if isVerboseLogging {
                print("AST:\n" + compiler.ast.description + "\n\n")
            }
            
            if shouldAlwaysPrintIR || isVerboseLogging {
                print("IR:\n" + CrackleInstruction.makeListing(instructions: compiler.ir) + "\n\n")
            }

            let computer = try execute(instructions: instructions)
            return computer
        }
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
