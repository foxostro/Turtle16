//
//  ComputerExecutor.swift
//  Simulator
//
//  Created by Andrew Fox on 7/29/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Executes a simulation on a background thread.
public class ComputerExecutor: NSObject {
    public var logger: Logger? {
        get {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            return computer.logger
        }
        set(value) {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            computer.logger = value
        }
    }
    
    public func provideMicrocode(microcode: InstructionDecoder) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        computer.provideMicrocode(microcode: microcode)
    }
    
    public func loadMicrocode(from url: URL) throws {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        try computer.loadMicrocode(from: url)
    }
    
    public func saveMicrocode(to url: URL) throws {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        try computer.saveMicrocode(to: url)
    }
    
    public func provideInstructions(_ instructions: [Instruction]) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        computer.provideInstructions(instructions)
    }
    
    public func loadProgram(from url: URL) throws {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        try computer.loadProgram(from: url)
    }
    
    public func saveProgram(to url: URL) throws {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        try computer.saveProgram(to: url)
    }
    
    public func provideSerialInput(bytes: [UInt8]) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        computer.provideSerialInput(bytes: bytes)
    }
    
    public var computer:Computer!
    public var onUpdatedCPUState:(CPUStateSnapshot)->Void = {_ in}
    public var appendSerialOutput:(String)->Void = {_ in}
    public var didStart:()->Void = {}
    public var didStop:()->Void = {}
    public var didHalt:()->Void = {}
    public var didReset:()->Void = {}
    
    var thread: Thread!
    let semaCancellationComplete = DispatchSemaphore(value: 0)
    let semaGoSignal = DispatchSemaphore(value: 0)
    var numberOfInstructionsRemaining = 0
    
    public func step() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        numberOfInstructionsRemaining = 1
        semaGoSignal.signal()
    }
    
    public func runOrStop() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if numberOfInstructionsRemaining == 0 {
            numberOfInstructionsRemaining = -1
            DispatchQueue.main.async {
                self.didStart()
            }
            semaGoSignal.signal()
        } else {
           numberOfInstructionsRemaining = 0
        }
    }
    
    public func start() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        reset()
        computer.appendSerialOutput = {(aString: String) in
            DispatchQueue.main.async {
                self.appendSerialOutput(aString)
            }
        }
        thread = Thread(block: {
            self.run()
        })
        thread.start()
    }
    
    @objc func run() {
        while !thread.isCancelled {
            objc_sync_enter(self)
            
            if (numberOfInstructionsRemaining == 0) {
                DispatchQueue.main.async {
                    self.didStop()
                }
                objc_sync_exit(self)
                semaGoSignal.wait()
                objc_sync_enter(self)
            }
            else if (.active == computer.controlWord.HLT) {
                DispatchQueue.main.async {
                    self.didHalt()
                }
                objc_sync_exit(self)
                semaGoSignal.wait()
                objc_sync_enter(self)
            }
            else if numberOfInstructionsRemaining != 0 {
                if numberOfInstructionsRemaining > 0 {
                    numberOfInstructionsRemaining -= 1
                }
                computer.step()
                let cpuState = self.computer.cpuState
                DispatchQueue.main.async {
                    self.onUpdatedCPUState(cpuState)
                }
            }
            
            objc_sync_exit(self)
        }
        semaCancellationComplete.signal()
    }
    
    public func shutdown() {
        thread.cancel()
        semaCancellationComplete.wait()
    }
    
    public func reset() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        numberOfInstructionsRemaining = 0
        computer.reset()
        let cpuState = computer.cpuState
        DispatchQueue.main.async {
            self.onUpdatedCPUState(cpuState)
            self.didReset()
        }
    }
}
