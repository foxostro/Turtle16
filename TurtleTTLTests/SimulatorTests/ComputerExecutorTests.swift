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
    let isVerboseLogging = false
    
    fileprivate func makeExecutor() -> ComputerExecutor {
        let executor = ComputerExecutor()
        executor.computer = makeComputer()
        executor.logger = makeLogger()
        return executor
    }
    
    fileprivate func makeComputer() -> Computer {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        
        let computer = Computer()
        computer.provideMicrocode(microcode: microcodeGenerator.microcode)
        computer.provideInstructions(TraceUtils.assemble("NOP\nHLT"))
        
        return computer
    }
    
    fileprivate func makeLogger() -> Logger {
        return isVerboseLogging ? ConsoleLogger() : NullLogger()
    }
    
    fileprivate func assembleSerialOutputTestProgram() -> [Instruction] {
        return TraceUtils.assemble("""
LI A, 0
LI B, 0
LI D, 6 # The Serial Interface device
LI X, 0
LI Y, 0
LI U, 0
LI V, 0

LI A, 'r'
LXY serial_put
LINK
JMP
NOP
NOP

LI A, 'e'
LXY serial_put
LINK
JMP
NOP
NOP

LI A, 'a'
LXY serial_put
LINK
JMP
NOP
NOP

LI A, 'd'
LXY serial_put
LINK
JMP
NOP
NOP

LI A, 'y'
LXY serial_put
LINK
JMP
NOP
NOP

LI A, '.'
LXY serial_put
LINK
JMP
NOP
NOP

LI A, 10
LXY serial_put
LINK
JMP
NOP
NOP

HLT





serial_put:

# Preserve the value of the link register by
# storing return address at address 10 and 11.
LI U, 0
LI V, 10
MOV M, G
LI V, 11
MOV M, H

# The A register contains the character to output.
# Copy it into memory at address 5.
LI U, 0
LI V, 5
MOV M, A

LI D, 6 # The Serial Interface device
LI Y, 1 # Data Port
LI P, 1 # Put Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay
LINK
JMP
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LXY delay
LINK
JMP
NOP
NOP
LI Y, 1 # Data Port
LI U, 0
LI V, 5
MOV P, M # Retrieve the byte from address 5 and pass it to the serial device.
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
LXY delay
LINK
JMP
NOP
NOP
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
LXY delay
LINK
JMP
NOP
NOP

# Retrieve the return address from memory at address 10 and 11,
# and then return from the call.
LI U, 0
LI V, 10
MOV X, M
LI V, 11
MOV Y, M
INXY # Must adjust the return address.
JMP
NOP
NOP





# We only require a single clock cycle delay in the Simulator.
# However, this delay should be a few milliseconds on real hardware.
delay:

MOV X, G
MOV Y, H
INXY # Must adjust the return address.
JMP
NOP
NOP

""")
    }
    
    fileprivate func assembleInfiniteLoopProgram() -> [Instruction] {
        return TraceUtils.assemble("""
beginning:
LXY beginning
JMP
NOP
NOP
""")
    }
    
    fileprivate func waitOrFailTest(semaphore: DispatchSemaphore, timeout: CFAbsoluteTime) {
        let beginTime = CFAbsoluteTimeGetCurrent()
        while .success != semaphore.wait(timeout: DispatchTime.now()) {
            RunLoop.main.run(mode: .default, before: Date())
            let currentTime = CFAbsoluteTimeGetCurrent()
            let elapsedTime = currentTime - beginTime
            if elapsedTime > timeout {
                XCTFail()
                break
            }
        }
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
        let semaphore = DispatchSemaphore(value: 0)
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
        executor.didStop = {
            didStop = true
        }
        executor.didHalt = {
            didHalt = true
            semaphore.signal()
        }
        
        executor.reset()
        executor.runOrStop()
        
        waitOrFailTest(semaphore: semaphore, timeout: 0.1)
        
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
        
        // Computer background thread is not executing now.
        XCTAssertFalse(executor.isExecuting)
    }
    
    func testSerialOutput() {
        let semaphore = DispatchSemaphore(value: 0)
        let executor = makeExecutor()
        executor.provideInstructions(assembleSerialOutputTestProgram())
        
        var serialOutput = ""
        
        executor.didUpdateSerialOutput = {
            serialOutput = $0
        }
        
        executor.didHalt = {
            semaphore.signal()
        }
        
        executor.reset()
        executor.runOrStop()
        
        waitOrFailTest(semaphore: semaphore, timeout: 0.1)
        
        XCTAssertEqual(serialOutput, """
ready.

""")
    }
    
    func testSerialInput() {
        let semaphore = DispatchSemaphore(value: 0)
        let executor = makeExecutor()
        executor.provideInstructions(TraceUtils.assemble("""
LI D, 6 # The Serial Interface device
LI Y, 1 # Data Port
LI P, 2 # "Get" Command
LI Y, 0 # Control Port
LI P, 1 # Raise SCK
NOP # delay
MOV A, P # Store the input byte in register A
LI Y, 0 # Control Port
LI P, 0 # Lower SCK
NOP # delay
HLT
"""))
        
        var serialOutput = ""
        executor.didUpdateSerialOutput = {
            serialOutput += $0
        }
        
        executor.didHalt = {
            semaphore.signal()
        }
        
        executor.provideSerialInput(bytes: [65])
        executor.reset()
        executor.runOrStop()
        
        waitOrFailTest(semaphore: semaphore, timeout: 0.1)
        
        XCTAssertEqual(executor.cpuState.registerA.value, 65)
    }
    
    func testGetAndSetCallbackClosures() {
        let executor = makeExecutor()
        
        var serialOutput = ""
        var didStart = false
        var didStop = false
        var didHalt = false
        var didReset = false
        
        executor.didUpdateSerialOutput = {
            serialOutput = $0
        }
        
        executor.didReset = {
            didReset = true
        }
        executor.didStart = {
            didStart = true
        }
        executor.didStop = {
            didStop = true
        }
        executor.didHalt = {
            didHalt = true
        }
        
        executor.didUpdateSerialOutput("foo")
        XCTAssertEqual("foo", serialOutput)
        
        executor.didReset()
        XCTAssertEqual(true, didReset)
        
        executor.didStart()
        XCTAssertEqual(true, didStart)
        
        executor.didStop()
        XCTAssertEqual(true, didStop)
        
        executor.didHalt()
        XCTAssertEqual(true, didHalt)
    }
    
    func testSingleStep() {
        let executor = makeExecutor()
        executor.stopwatch = ComputerStopwatch()
        executor.reset()
        executor.singleStep()
        XCTAssertEqual(executor.stopwatch!.numberOfInstructionRetired, 1)
    }
    
    func testSingleStepInvokesTheHaltCallback() {
        let semaphore = DispatchSemaphore(value: 0)
        let executor = makeExecutor()
        executor.stopwatch = ComputerStopwatch()
        var didHalt = false
        executor.didHalt = {
            didHalt = true
            semaphore.signal()
        }
        executor.reset()
        executor.singleStep()
        executor.singleStep()
        executor.singleStep()
        executor.singleStep()
        executor.singleStep()
        
        waitOrFailTest(semaphore: semaphore, timeout: 0.1)
        XCTAssertTrue(didHalt)
    }
    
    func testGetComputerCPUState() {
        let semaphore = DispatchSemaphore(value: 0)
        let executor = makeExecutor()
        executor.provideInstructions(TraceUtils.assemble("""
LI A, 42
HLT
"""))
        
        executor.didHalt = {
            semaphore.signal()
        }
        
        executor.reset()
        executor.runOrStop()
        
        waitOrFailTest(semaphore: semaphore, timeout: 1)
        
        XCTAssertEqual(executor.cpuState.registerA.value, 42)
        XCTAssertEqual(executor.computer.cpuState.registerA.value, 42)
    }
    
    func testExplicitlyStopComputerFromRunning() {
        let semaphore = DispatchSemaphore(value: 0)
        let executor = makeExecutor()
        executor.provideInstructions(assembleInfiniteLoopProgram())
        
        executor.didStop = {
            semaphore.signal()
        }
        
        executor.reset()
        executor.runOrStop()
        executor.stop()
        
        waitOrFailTest(semaphore: semaphore, timeout: 0.1)
    }
    
    func testImplicitlyStopComputerFromRunning() {
        let semaphore = DispatchSemaphore(value: 0)
        let executor = makeExecutor()
        executor.provideInstructions(assembleInfiniteLoopProgram())
        
        executor.didStop = {
            semaphore.signal()
        }
        
        executor.reset()
        executor.runOrStop()
        executor.runOrStop()
        
        waitOrFailTest(semaphore: semaphore, timeout: 0.1)
    }
    
    func testComputerLoggerIsTheExecutorLogger() {
        let executor = makeExecutor()
        executor.logger = NullLogger()
        let a: NullLogger = executor.logger! as! NullLogger
        let b: NullLogger = executor.computer.logger! as! NullLogger
        XCTAssertTrue(a === b)
    }
    
    func testRoundTripProgramSaveLoad() {
        let semaphore = DispatchSemaphore(value: 0)
        let executor = makeExecutor()
        executor.provideInstructions(TraceUtils.assemble("""
LI A, 42
HLT
"""))
        
        let tempUrl: URL = FileManager.default.temporaryDirectory.appendingPathComponent(NSUUID().uuidString)
        defer { try! FileManager.default.removeItem(at: tempUrl) }
        executor.saveProgram(to: tempUrl) { _ in XCTFail() }

        executor.provideInstructions(TraceUtils.assemble("HLT")) // reset
        
        executor.loadProgram(from: tempUrl) { _ in XCTFail() }
        
        executor.didHalt = {
            semaphore.signal()
        }
        
        executor.reset()
        executor.runOrStop()
        
        waitOrFailTest(semaphore: semaphore, timeout: 1)
        
        XCTAssertEqual(executor.cpuState.registerA.value, 42)
        XCTAssertEqual(executor.computer.cpuState.registerA.value, 42)
    }
    
    func testLoadProgramFailsDueToBadURL() {
        let executor = makeExecutor()
        let tempUrl = URL(fileURLWithPath: "")
        let expectation = XCTestExpectation(description: "ComputerExecutor.loadProgram fails")
        executor.loadProgram(from: tempUrl) { (error: Error) in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testSaveProgramFailsDueToBadURL() {
        let executor = makeExecutor()
        let tempUrl = URL(fileURLWithPath: "/")
        let expectation = XCTestExpectation(description: "ComputerExecutor.saveProgram fails")
        executor.saveProgram(to: tempUrl) { (error: Error) in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testSaveMicrocodeToFile() {
        let executor = makeExecutor()
        
        let tempUrl: URL = FileManager.default.temporaryDirectory.appendingPathComponent(NSUUID().uuidString)
        defer { try! FileManager.default.removeItem(at: tempUrl) }
        
        let expectation = XCTestExpectation(description: "ComputerExecutor.saveMicrocode does not fail")
        expectation.isInverted = true
        executor.saveMicrocode(to: tempUrl) { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testSaveMicrocodeToFileFailsDueToBadUrl() {
        let executor = makeExecutor()
        
        let tempUrl = URL(fileURLWithPath: "/")
        
        let expectation = XCTestExpectation(description: "ComputerExecutor.saveMicrocode fails")
        executor.saveMicrocode(to: tempUrl) { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
}
