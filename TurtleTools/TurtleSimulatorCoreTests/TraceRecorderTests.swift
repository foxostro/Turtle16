//
//  TraceRecorderTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleSimulatorCore

class TraceRecorderTests: XCTestCase {
    var microcodeGenerator: MicrocodeGenerator!
    
    override func setUp() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
    }
    
    func testAppendInstruction() {
        let recorder = TraceRecorder(microcodeGenerator: microcodeGenerator)
        recorder.record(instruction: Instruction.makeNOP(),
                        stateBefore: CPUStateSnapshot())
        XCTAssertEqual(recorder.trace.instructions.count, 1)
        XCTAssertEqual(recorder.trace.description, """
0x0000: NOP ; isBreakpoint=true
""")
    }
    
    func testRecordTraceIncludesPipelineFlushes() {
        let trace = TraceUtils.recordTraceForProgram(microcodeGenerator: microcodeGenerator, """
HLT
""")
        
        // When we record a trace we must include pipeline flushes at the
        // beginning and end of the trace.
        XCTAssertEqual(trace.description, """
0x0000: NOP ; isBreakpoint=true
0x0000: NOP
0x0000: HLT
""")
    }
    
    func testRecordTraceWithAForwardJump() {
        let trace = TraceUtils.recordTraceForProgram(microcodeGenerator: microcodeGenerator, """
LI X, 0x01
LI Y, 0x00
JMP
NOP # branch delay slot
NOP # branch delay slot
LI A, 0x02
HLT
""")
        
        // Every jump has a guard associated with it because all jumps are
        // computed jumps that rely on the value of XY computed previously in
        // the program. The trace will assert the jump destination is as
        // expected, but the jump instruction itself is not present. Then, the
        // trace continues recording instructions at the following PC.
        XCTAssertEqual(trace.description, """
0x0000: NOP ; isBreakpoint=true
0x0000: NOP
0x0000: LI X, 0x01
0x0001: LI Y, 0x00
0x0002: JMP ; guardAddress=0x0100
0x0003: NOP
0x0004: NOP
0x0100: LI A, 0x02
0x0101: HLT
""")
    }
    
    func testRecordTraceWithConditionalForwardJump() {
        let trace = TraceUtils.recordTraceForProgram(microcodeGenerator: microcodeGenerator, """
LI X, 0x01
LI Y, 0x00
LI A, 0x01
LI B, 0x01
CMP
CMP
NOP
JE
NOP # branch delay slot
NOP # branch delay slot
LI D, 0x02
HLT
""")
        
        // When recording a conditional jump, TraceRecorder will insert a guard
        // to assert the values of the flags are as expected. Also, as with an
        // unconditional jump, the jump destination is a computed value which
        // must be asserted with a guard condition.
        XCTAssertEqual(trace.description, """
0x0000: NOP ; isBreakpoint=true
0x0000: NOP
0x0000: LI X, 0x01
0x0001: LI Y, 0x00
0x0002: LI A, 0x01
0x0003: LI B, 0x01
0x0004: CMP
0x0005: CMP
0x0006: NOP
0x0007: JE ; guardAddress=0x0100 ; guardFlags={carryFlag: 1, equalFlag: 1}
0x0008: NOP
0x0009: NOP
0x0100: LI D, 0x02
0x0101: HLT
""")
    }
}
