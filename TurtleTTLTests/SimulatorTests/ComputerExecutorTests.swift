//
//  ComputerExecutorTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 9/4/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class ComputerExecutorTests: XCTestCase {
    let sourceCode = "NOP\nHLT"
    
    func mustCompile(_ sourceCode: String) -> [Instruction] {
        let frontEnd = AssemblerFrontEnd()
        frontEnd.compile(sourceCode)
        assert(!frontEnd.hasError)
        return frontEnd.instructions
    }
    
    func makeComputer() -> Computer {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        
        let computer = ComputerRev1()
        computer.provideMicrocode(microcode: microcodeGenerator.microcode)
        computer.provideInstructions(mustCompile(sourceCode))
        
        return computer
    }
    
    func makeExecutor() -> ComputerExecutor {
        let executor = ComputerExecutor()
        executor.computer = makeComputer()
        return executor
    }
    
    func testNotExecutingAtFirst() {
        let executor = makeExecutor()
        XCTAssertFalse(executor.isExecuting)
    }
    
    func testNotHaltedAtFirst() {
        let executor = makeExecutor()
        XCTAssertFalse(executor.isHalted)
    }
    
    func testStartStopHaltCallbacksAreCalledAsExpected() {
        let executor = makeExecutor()
        executor.start()
        let semaphore = DispatchSemaphore(value: 0)
        var numberOfTimesCPUStateWasPublished = 0
        var didStart = false
        var didStop = false
        var didHalt = false
        var didReset = false
        executor.didReset = {
            didReset = true
        }
        executor.didStart = {
            didStart = true
        }
        executor.onUpdatedCPUState = { _ in
            numberOfTimesCPUStateWasPublished += 1
        }
        executor.didStop = {
            didStop = true
        }
        executor.didHalt = {
            didHalt = true
            semaphore.signal()
        }
        executor.runOrStop()
        while .success != semaphore.wait(timeout: DispatchTime.now()) {
            RunLoop.main.run(mode: .default, before: Date())
        }
        
        // Resets once at start.
        XCTAssertTrue(didReset)
        
        // Starts when runOrStop() is called.
        XCTAssertTrue(didStart)
        
        // Computer stops executing instructions when it encounters the
        // HLT instruction.
        XCTAssertTrue(didStop)
        
        // Halts when it encounters the HLT instruction. This is a special state
        // which prevents the clock from ticking again.
        XCTAssertTrue(didHalt)
        
        // Computer agrees that is in the special halted state.
        XCTAssertTrue(executor.isHalted)
        
        // We expect CPU state to be published when the computer resets and when
        // execution halts. It may be published more times than this, e.g.,
        // it may be published after each emulated instruction.
        XCTAssertGreaterThanOrEqual(numberOfTimesCPUStateWasPublished, 2)
        
        // Computer background thread is not executing now.
        XCTAssertFalse(executor.isExecuting)
        
        executor.shutdown()
    }
}
