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
    
    func makeComputer() -> Computer {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        
        let computer = Computer()
        computer.provideMicrocode(microcode: microcodeGenerator.microcode)
        computer.provideInstructions(try! AssemblerFrontEnd().compile(sourceCode))
        
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
    
    func testToggleExecution() {
        let executor = makeExecutor()
        executor.runOrStop()
        XCTAssertTrue(executor.isExecuting)
    }
    
    func testNotHaltedAtFirst() {
        let executor = makeExecutor()
        XCTAssertFalse(executor.isHalted)
    }
    
    func testStartStopHaltCallbacksAreCalledAsExpected() {
        let executor = makeExecutor()
        executor.beginTimer()
        let semaphore = DispatchSemaphore(value: 0)
        var numberOfSteps = 0
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
        executor.onStep = {
            numberOfSteps += 1
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
        executor.shutdown()
        XCTAssertFalse(didReset)
        XCTAssertTrue(didStart)
        XCTAssertTrue(didStop)
        XCTAssertTrue(didHalt)
        XCTAssertEqual(numberOfSteps, 5) // two coded instructions plus setting up the pipeline
        XCTAssertFalse(executor.isExecuting)
        XCTAssertTrue(executor.isHalted)
    }
}
