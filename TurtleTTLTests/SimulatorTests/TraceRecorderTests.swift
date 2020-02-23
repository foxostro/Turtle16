//
//  TraceRecorderTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class TraceRecorderTests: XCTestCase {
    let microcodeGenerator = MicrocodeGenerator()
    
    class InstructionFeed : NSObject, InterpreterDelegate {
        var instructions: [Instruction]
        
        init(instructions: [Instruction]) {
            self.instructions = instructions
        }
        
        func fetchInstruction(from: ProgramCounter) -> Instruction {
            if instructions.isEmpty {
                return Instruction()
            } else {
                return instructions.removeFirst()
            }
        }
        
        func storeToRAM(value: UInt8, at address: Int) {}
        func loadFromRAM(at address: Int) -> UInt8 { return 0 }
        func willJump(from: ProgramCounter, to: ProgramCounter) {}
        func activateSignalPO(_ index: Int) {}
        func activateSignalPI(_ index: Int) {}
        func didTickControlClock() {}
        func didTickRegisterClock() {}
    }
    
    fileprivate func assemble(_ text: String) -> [Instruction] {
        return  try! tryAssemble(text: text)
    }
    
    fileprivate func tryAssemble(text: String) throws -> [Instruction] {
        let assembler = AssemblerFrontEnd()
        assembler.compile(text)
        if assembler.hasError {
            let error = assembler.makeOmnibusError(fileName: nil, errors: assembler.errors)
            throw error
        }
        return assembler.instructions
    }
    
    fileprivate func recordTraceForProgram(_ recorder: TraceRecorder, _ text: String) {
        let feed = InstructionFeed(instructions: assemble(text))
        let interpreter = Interpreter()
        interpreter.delegate = feed
        while interpreter.cpuState.controlWord.HLT == .inactive {
            let prevCpuState = interpreter.cpuState.copy() as! CPUStateSnapshot
            let instruction = prevCpuState.if_id
            interpreter.step()
            recorder.record(instruction: instruction,
                            stateBefore: prevCpuState,
                            stateAfter: interpreter.cpuState)
        }
    }
    
    override func setUp() {
        microcodeGenerator.generate()
    }
    
    func testAppendInstruction() {
        let recorder = TraceRecorder(microcodeGenerator: microcodeGenerator)
        recorder.record(instruction: Instruction(), stateBefore: CPUStateSnapshot(), stateAfter: CPUStateSnapshot())
        XCTAssertEqual(recorder.trace.elements.count, 1)
        XCTAssertEqual(recorder.trace.description, """
0x0000:\tNOP
""")
    }
    
    func testRecordTraceWithAForwardJump() {
        let recorder = TraceRecorder(microcodeGenerator: microcodeGenerator)
        recordTraceForProgram(recorder, """
LI X, 1
LI Y, 0
JMP
LI A, 2
HLT
""")
        
        // Every jump has a guard associated with it because all jumps are
        // computed jumps that rely on the value of XY computed previously in
        // the program. The trace will assert the jump destination is as
        // expected, but the jump instruction itself is not present. Then, the
        // trace continues recording instructions at the following PC.
        XCTAssertEqual(recorder.trace.description, """
0x0000:\tNOP
0x0001:\tNOP
0x0002:\tLI X, 1
0x0003:\tLI Y, 0
guard:\taddress=0x0100, traceExitingPC=0x0004
0x0100:\tLI A, 2
0x0101:\tHLT
""")
    }
}
