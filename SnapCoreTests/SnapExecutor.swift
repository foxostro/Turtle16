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
    public var shouldEnableOptimizations = true
    public var shouldAlwaysPrintIR = false
    public var shouldRunSpecificTest: String? = nil
    let microcodeGenerator: MicrocodeGenerator
    public let compiler = SnapCompiler()
    var configure: (Computer)->Void = {_ in}
    
    override init() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
    }
    
    func execute(program: String) throws -> Computer {
        compiler.isUsingStandardLibrary = isUsingStandardLibrary
        compiler.shouldRunSpecificTest = shouldRunSpecificTest
        compiler.shouldEnableOptimizations = shouldEnableOptimizations
        compiler.compile(program: program, base: 0)
        if compiler.hasError {
            print(CompilerError.makeOmnibusError(fileName: nil, errors: compiler.errors).message)
            return Computer()
        } else {
            let instructions = compiler.instructions
            let programDebugInfo = compiler.programDebugInfo
            
            if isVerboseLogging {
                print("AST:\n\(compiler.ast.description)\n\n")
            }
            
            if shouldAlwaysPrintIR || isVerboseLogging {
                let listing = CrackleInstructionListingMaker.makeListing(instructions: compiler.ir, programDebugInfo: programDebugInfo)
                print("IR:\n\(listing)\n\n")
            }

            let computer = try execute(instructions: instructions, programDebugInfo: programDebugInfo)
            return computer
        }
    }
    
    func execute(instructions: [Instruction], programDebugInfo: ProgramDebugInfo? = nil) throws -> Computer {
        let computer = makeComputer(microcodeGenerator: microcodeGenerator)
        computer.programDebugInfo = programDebugInfo
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
    
    private func makeLogger() -> Logger? {
        return isVerboseLogging ? ConsoleLogger() : nil
    }
    
    public func injectModule(name: String, sourceCode: String) {
        compiler.injectModule(name: name, sourceCode: sourceCode)
    }
}
