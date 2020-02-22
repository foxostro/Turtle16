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
    
    override func setUp() {
        microcodeGenerator.generate()
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
    
    func testAppendInstruction() {
        let recorder = TraceRecorder(microcodeGenerator: microcodeGenerator)
        recorder.record(instruction: makeNOP(), stateBefore: CPUStateSnapshot(), stateAfter: CPUStateSnapshot())
        XCTAssertEqual(recorder.trace.elements.count, 1)
        XCTAssertEqual(recorder.trace.description, """
0x0000:\tNOP
""")
        
        XCTAssertEqual(recorder.state, .recording)
    }
    
    fileprivate func makeNOP() -> Instruction {
        return Instruction(opcode: 0, immediate: 0, disassembly: "NOP")
    }
    
    func testRecordTraceThatAbortsOnHLT() {
        let recorder = TraceRecorder(microcodeGenerator: microcodeGenerator)
        recordTraceForProgram(recorder, """
NOP
MOV A, B
LI A, 100
HLT
""")
        XCTAssertEqual(recorder.trace.description, """
0x0000:\tNOP
0x0001:\tNOP
0x0002:\tMOV A, B
0x0003:\tLI A, 100
""")
        
        XCTAssertEqual(recorder.state, .abandoned)
    }
    
    func recordTraceForProgram(_ recorder: TraceRecorder, _ text: String) {
        let instructions = assemble(text)
        let cpuState = CPUStateSnapshot()
        for instruction in instructions {
            let prevCpuState = cpuState.copy() as! CPUStateSnapshot
            cpuState.pc = cpuState.pc.increment()
            recorder.record(instruction: instruction,
                            stateBefore: prevCpuState, // FIXME: These are fake state changes.
                            stateAfter: cpuState)
        }
    }
    
    func testRecordTraceWithAForwardJump() {
        // FIXME: Setting up a unit test like this is really tedious. It would
        // be better to use an interpreter to step through each instruction and
        // generate computer states automatically.
        let liX1 = Instruction(opcode: microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!,
                               immediate: 1,
                               disassembly: "LI X, 1")
        let liY0 = Instruction(opcode: microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!,
                               immediate: 0,
                               disassembly: "LI Y, 0")
        let jmp = Instruction(opcode: microcodeGenerator.getOpcode(withMnemonic: "JMP")!,
                              immediate: 0,
                              disassembly: "JMP")
        let liA2 = Instruction(opcode: microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!,
                               immediate: 0,
                               disassembly: "LI A, 2")
        
        let before_0x0000 = CPUStateSnapshot(bus: Register(),
                                             registerA: Register(),
                                             registerB: Register(),
                                             registerC: Register(),
                                             registerD: Register(),
                                             registerG: Register(),
                                             registerH: Register(),
                                             registerX: Register(),
                                             registerY: Register(),
                                             registerU: Register(),
                                             registerV: Register(),
                                             aluResult: Register(),
                                             aluFlags: Flags(),
                                             flags: Flags(),
                                             pc: ProgramCounter(withValue: 0x0000),
                                             pc_if: ProgramCounter(),
                                             if_id: Instruction(),
                                             controlWord: ControlWord())
        
        let before_0x0001 = CPUStateSnapshot(bus: Register(),
                                             registerA: Register(),
                                             registerB: Register(),
                                             registerC: Register(),
                                             registerD: Register(),
                                             registerG: Register(),
                                             registerH: Register(),
                                             registerX: Register(withValue: 1),
                                             registerY: Register(),
                                             registerU: Register(),
                                             registerV: Register(),
                                             aluResult: Register(),
                                             aluFlags: Flags(),
                                             flags: Flags(),
                                             pc: ProgramCounter(withValue: 0x0001),
                                             pc_if: ProgramCounter(),
                                             if_id: Instruction(),
                                             controlWord: ControlWord())
        
        let before_0x0002 = CPUStateSnapshot(bus: Register(),
                                             registerA: Register(),
                                             registerB: Register(),
                                             registerC: Register(),
                                             registerD: Register(),
                                             registerG: Register(),
                                             registerH: Register(),
                                             registerX: Register(withValue: 1),
                                             registerY: Register(withValue: 0),
                                             registerU: Register(),
                                             registerV: Register(),
                                             aluResult: Register(),
                                             aluFlags: Flags(),
                                             flags: Flags(),
                                             pc: ProgramCounter(withValue: 0x0002),
                                             pc_if: ProgramCounter(),
                                             if_id: Instruction(),
                                             controlWord: ControlWord())
        
        let before_0x0100 = CPUStateSnapshot(bus: Register(),
                                             registerA: Register(),
                                             registerB: Register(),
                                             registerC: Register(),
                                             registerD: Register(),
                                             registerG: Register(),
                                             registerH: Register(),
                                             registerX: Register(withValue: 1),
                                             registerY: Register(withValue: 0),
                                             registerU: Register(),
                                             registerV: Register(),
                                             aluResult: Register(),
                                             aluFlags: Flags(),
                                             flags: Flags(),
                                             pc: ProgramCounter(withValue: 0x0100),
                                             pc_if: ProgramCounter(),
                                             if_id: Instruction(),
                                             controlWord: ControlWord())
        
        let before_0x0101 = CPUStateSnapshot(bus: Register(),
                                             registerA: Register(withValue: 2),
                                             registerB: Register(),
                                             registerC: Register(),
                                             registerD: Register(),
                                             registerG: Register(),
                                             registerH: Register(),
                                             registerX: Register(withValue: 1),
                                             registerY: Register(withValue: 0),
                                             registerU: Register(),
                                             registerV: Register(),
                                             aluResult: Register(),
                                             aluFlags: Flags(),
                                             flags: Flags(),
                                             pc: ProgramCounter(withValue: 0x0101),
                                             pc_if: ProgramCounter(),
                                             if_id: Instruction(),
                                             controlWord: ControlWord())
                               
        let recorder = TraceRecorder(microcodeGenerator: microcodeGenerator)
        recorder.record(instruction: liX1, stateBefore: before_0x0000, stateAfter: before_0x0001)
        recorder.record(instruction: liY0, stateBefore: before_0x0001, stateAfter: before_0x0002)
        recorder.record(instruction: jmp,  stateBefore: before_0x0002, stateAfter: before_0x0100)
        recorder.record(instruction: liA2, stateBefore: before_0x0100, stateAfter: before_0x0101)
        
        // Every jump has a guard associated with it because all jumps are
        // computed jumps that rely on the value of XY computed previously in
        // the program. The trace will assert the jump destination is as
        // expected, but the jump instruction itself is not present. Then, the
        // trace continues recording instructions at the following PC.
        XCTAssertEqual(recorder.trace.description, """
0x0000:\tLI X, 1
0x0001:\tLI Y, 0
guard:\taddress=0x0100, traceExitingPC=0x0002
0x0100:\tLI A, 2
""")
        
        XCTAssertEqual(recorder.state, .recording)
    }
}
