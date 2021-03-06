//
//  CrackleExecutor.swift
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
class CrackleExecutor: NSObject {
    var isVerboseLogging = false
    var injectPanicStub = true
    var configure: (Computer) -> Void = {_ in}
    var injectCode: (CrackleToPopCompiler) throws -> Void = {_ in}
    var programDebugInfo: SnapDebugInfo? = nil
    let microcodeGenerator: MicrocodeGenerator
    
    override init() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
    }
    
    func execute(crackle: [CrackleInstruction]) throws -> Computer {
        let base = 0
        
        if isVerboseLogging {
            print("IR:\n" + CrackleInstructionListingMaker.makeListing(instructions: crackle, programDebugInfo: programDebugInfo) + "\n\n")
        }
        
        // Compile the Crackle IR code to Pop IR code.
        let crackleToPopCompiler = CrackleToPopCompiler()
        crackleToPopCompiler.programDebugInfo = programDebugInfo
        do {
            crackleToPopCompiler.doAtEpilogue = { [weak self] (compiler: CrackleToPopCompiler) in
                try self!.injectCode(compiler)
                if self!.injectPanicStub {
                    try compiler.injectCode([
                        .label("__oob"),
                        .push16(0xdead)
                    ])
                }
                try compiler.injectCode([
                    .hlt
                ])
            }
            try crackleToPopCompiler.compile(ir: crackle)
        } catch let error as CompilerError {
            print(error.message)
            throw error
        } catch {
            abort()
        }
        let pop = crackleToPopCompiler.instructions
        
        // Compiler the Pop IR code to machine code.
        let popToMachineCodeCompiler = PopCompiler()
        popToMachineCodeCompiler.programDebugInfo = programDebugInfo
        do {
            try popToMachineCodeCompiler.compile(pop: pop, base: base)
        } catch let error as CompilerError {
            print(error.message)
            throw error
        } catch {
            abort()
        }
        let machineCode = popToMachineCodeCompiler.instructions
        
        if isVerboseLogging {
            let disassembly = AssemblyListingMaker.makeListing(base, machineCode, programDebugInfo)
            print("Assembly:\n\(disassembly)\n")
        }
        
        let computer = try execute(instructions: machineCode)
        return computer
    }
    
    func execute(instructions: [Instruction]) throws -> Computer {
        let computer = makeComputer(microcodeGenerator: microcodeGenerator)
        computer.provideInstructions(instructions)
        computer.programDebugInfo = programDebugInfo
        
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
}
