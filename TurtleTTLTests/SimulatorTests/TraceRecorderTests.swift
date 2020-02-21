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
    
    func assemble(_ text: String) -> [Instruction] {
        return  try! tryAssemble(text: text)
    }
    
    func tryAssemble(text: String) throws -> [Instruction] {
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
        recorder.record(pc: 0, instruction: Instruction())
        XCTAssertEqual(recorder.trace.elements.count, 1)
        XCTAssertEqual(recorder.trace.description, """
0x0000:\tNOP
""")
        
        XCTAssertEqual(recorder.state, .recording)
    }
    
    func testRecordTraceWithoutGuards() {
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
0x0004:\tHLT
""")
        
        XCTAssertEqual(recorder.state, .abandoned)
    }
    
    func recordTraceForProgram(_ recorder: TraceRecorder, _ text: String) {
        let instructions = assemble(text)
        var pc: UInt16 = 0
        for instruction in instructions {
            recorder.record(pc: pc, instruction: instruction)
            pc += 1
        }
    }
}
