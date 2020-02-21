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
    func makeDefaultSnapshot() -> CPUStateSnapshot {
        return CPUStateSnapshot(bus: Register(),
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
                                pc: ProgramCounter(),
                                pc_if: ProgramCounter(),
                                if_id: Instruction(),
                                controlWord: ControlWord())
    }
    
    func testAppendInstruction() {
        let recorder = TraceRecorder()
        recorder.record(instruction: Instruction(),
                        stateBefore: makeDefaultSnapshot(),
                        stateAfter: makeDefaultSnapshot())
        XCTAssertEqual(recorder.trace.elements.count, 1)
    }
}
