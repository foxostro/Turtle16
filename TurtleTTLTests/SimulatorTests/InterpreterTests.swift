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
    func testInit() {
        _ = Interpreter(cpuState: CPUStateSnapshot())
    }
    
    func testReset() {
        let cpuState = CPUStateSnapshot()
        cpuState.pc = ProgramCounter(withValue: 1)
        let interpreter = Interpreter(cpuState: cpuState)
        interpreter.reset()
        XCTAssertEqual(interpreter.cpuState.pc.value, 0)
        XCTAssertEqual(cpuState.pc.value, 0)
    }
}
