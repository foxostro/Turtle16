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
    var injectCode: (CrackleToTurtleMachineCodeCompiler) throws -> Void = {_ in}
    var programDebugInfo: SnapDebugInfo? = nil
    let microcodeGenerator: MicrocodeGenerator
    let assembler: AssemblerBackEnd
    
    override init() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
    }
    
    func execute(ir: [CrackleInstruction]) throws -> Computer {
        if isVerboseLogging {
            print("IR:\n" + CrackleInstructionListingMaker.makeListing(instructions: ir, programDebugInfo: programDebugInfo) + "\n\n")
        }
        
        var computer: Computer!
        
        do {
            let compiler = CrackleToTurtleMachineCodeCompiler(assembler: assembler)
            compiler.doAtEpilogue = { [weak self] (compiler: CrackleToTurtleMachineCodeCompiler) in
                try self!.injectCode(compiler)
                if self!.injectPanicStub {
                    try compiler.label("panic")
                    try compiler.push16(0xdead)
                }
                compiler.hlt()
            }
            let base = 0
            try compiler.compile(ir: ir, base: base)
            let instructions = compiler.instructions
            
            if isVerboseLogging {
                let disassembly = AssemblyListingMaker.makeListing(base, instructions, programDebugInfo)
                print("Assembly:\n\(disassembly)\n")
            }
            
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
