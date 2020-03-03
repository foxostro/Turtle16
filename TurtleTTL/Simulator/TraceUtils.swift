//
//  TraceUtils.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/23/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

// Useful for building Traces of programs in unit test.
public class TraceUtils: NSObject {
    fileprivate class InstructionFeed : NSObject, InterpreterDelegate {
        var numberOfInstructionsPastEnd = 0
        var instructions: [Instruction]
        
        init(instructions: [Instruction]) {
            self.instructions = instructions
        }
        
        func fetchInstruction(from: ProgramCounter) -> Instruction {
            if instructions.isEmpty {
                numberOfInstructionsPastEnd += 1
                return Instruction.makeNOP(pc: from)
            } else {
                let instruction = instructions.removeFirst()
                return instruction.withProgramCounter(from)
            }
        }
    }
    
    public static func assemble(_ text: String) -> [Instruction] {
        return  try! tryAssemble(text: text)
    }
    
    fileprivate static func tryAssemble(text: String) throws -> [Instruction] {
        let assembler = AssemblerFrontEnd()
        assembler.compile(text)
        if assembler.hasError {
            let error = assembler.makeOmnibusError(fileName: nil, errors: assembler.errors)
            throw error
        }
        return assembler.instructions
    }
    
    public static func recordTraceForProgram(microcodeGenerator: MicrocodeGenerator, _ text: String) -> Trace {
        let recorder = TraceRecorder(microcodeGenerator: microcodeGenerator)
        let feed = InstructionFeed(instructions: assemble(text))
        let interpreter = Interpreter()
        interpreter.delegate = feed
        var prevCpuState: CPUStateSnapshot!
        while feed.numberOfInstructionsPastEnd < 2 && interpreter.cpuState.controlWord.HLT == .inactive {
            prevCpuState = interpreter.cpuState.copy() as? CPUStateSnapshot
            let instruction = prevCpuState.if_id
            interpreter.step()
            recorder.record(instruction: instruction, stateBefore: prevCpuState)
        }
        return recorder.trace
    }
}
