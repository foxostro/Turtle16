//
//  InterpreterTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 2/21/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class InterpreterTests: XCTestCase {
    class TestInterpreterDelegate : NSObject, InterpreterDelegate {
        let nop = Instruction(opcode: 0, immediate: 0, disassembly: "NOP")
        
        var instructions: [Instruction]
        
        init(instructions: [Instruction]) {
            self.instructions = instructions
        }
        
        func fetchInstruction(from: ProgramCounter) -> Instruction {
            if instructions.isEmpty {
                return nop
            } else {
                return instructions.removeFirst()
            }
        }
    }
    
    fileprivate func assemble(_ text: String) -> [Instruction] {
        return try! tryAssemble(text)
    }

    fileprivate func tryAssemble(_ text: String) throws -> [Instruction] {
        let assembler = AssemblerFrontEnd()
        assembler.compile(text)
        if assembler.hasError {
            let error = assembler.makeOmnibusError(fileName: nil, errors: assembler.errors)
            throw error
        }
        return assembler.instructions
    }
    
    func testReset() {
        let cpuState = CPUStateSnapshot()
        cpuState.pc = ProgramCounter(withValue: 1)
        let interpreter = makeInterpreter(cpuState: cpuState)
        interpreter.reset()
        XCTAssertEqual(interpreter.cpuState.pc.value, 0)
        XCTAssertEqual(cpuState.pc.value, 0)
    }
    
    func testInterpretNOP() {
        let expectedFinalState = CPUStateSnapshot()
        expectedFinalState.pc = ProgramCounter(withValue: 3)
        expectedFinalState.pc_if = ProgramCounter(withValue: 2)
        
        let interpreter = makeInterpreter()
        let delegate = TestInterpreterDelegate(instructions: assemble("NOP"))
        interpreter.delegate = delegate
        
        interpreter.step()
        interpreter.step()
        interpreter.step()
        
        XCTAssertEqual(interpreter.cpuState, expectedFinalState)
    }
    
    fileprivate func makeInterpreter(cpuState: CPUStateSnapshot = CPUStateSnapshot()) -> Interpreter {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let instructionDecoder = microcodeGenerator.microcode
        let interpreter = Interpreter(cpuState: cpuState,
                                      instructionDecoder: instructionDecoder)
        return interpreter
    }
    
    func testInterpretHLT_EnsureThreeClockPipelineLatency() {
        // The pipeline takes three clocks to execute an instruction.
        let interpreter = makeInterpreter()
        let delegate = TestInterpreterDelegate(instructions: assemble("HLT"))
        interpreter.delegate = delegate
        
        interpreter.step()
        XCTAssertEqual(.inactive, interpreter.cpuState.controlWord.HLT)
        XCTAssertEqual(1, interpreter.cpuState.pc.value)
        
        interpreter.step()
        XCTAssertEqual(.inactive, interpreter.cpuState.controlWord.HLT)
        XCTAssertEqual(2, interpreter.cpuState.pc.value)
        
        interpreter.step()
        XCTAssertEqual(.active, interpreter.cpuState.controlWord.HLT)
        XCTAssertEqual(3, interpreter.cpuState.pc.value)
    }
}
