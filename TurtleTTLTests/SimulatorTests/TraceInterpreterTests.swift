//
//  TraceInterpreterTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 2/23/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class TraceInterpreterTests: XCTestCase {
    let isVerboseLogging = false
    
    fileprivate func makeTraceInterpreter(cpuState: CPUStateSnapshot, program: String) -> TraceInterpreter {
        let trace = TraceUtils.recordTraceForProgram(program)
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let traceInterpreter = TraceInterpreter(cpuState: cpuState,
                                                peripherals: ComputerPeripherals(),
                                                instructionDecoder: microcodeGenerator.microcode,
                                                trace: trace)
        traceInterpreter.logger = makeLogger()
        return traceInterpreter
    }
    
    fileprivate func makeLogger() -> Logger {
        return isVerboseLogging ? ConsoleLogger() : NullLogger()
    }
    
    func testRunSimplestProgram() {
        let cpuState = CPUStateSnapshot()
        let traceInterpreter = makeTraceInterpreter(cpuState: cpuState, program: "HLT")
        traceInterpreter.run()
        XCTAssertEqual(cpuState.controlWord.HLT, .active)
    }
    
    func testRunProgramWhichActuallyModifiesCPUState() {
        let cpuState = CPUStateSnapshot()
        let traceInterpreter = makeTraceInterpreter(cpuState: cpuState, program: "LI A, 42")
        traceInterpreter.run()
        XCTAssertEqual(cpuState.registerA.value, 42)
    }
}
