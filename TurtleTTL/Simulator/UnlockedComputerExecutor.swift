//
//  UnlockedComputerExecutor.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/16/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

class UnlockedComputerExecutor: NSObject {
    let cpuUpdateQueue: ThrottledQueue
    let serialOutputUpdateQueue: ThrottledQueue
    let notificationQueue = DispatchQueue.main
    
    public var logger: Logger? {
        get {
            return computer.logger
        }
        set(value) {
            computer.logger = value
        }
    }
    
    public override init() {
        cpuUpdateQueue = ThrottledQueue(queue: DispatchQueue.main, maxInterval: 1.0 / 30.0)
        serialOutputUpdateQueue = ThrottledQueue(queue: DispatchQueue.main, maxInterval: 1.0 / 30.0)
    }
    
    public func provideMicrocode(microcode: InstructionDecoder) {
        computer.provideMicrocode(microcode: microcode)
    }
    
    public func loadMicrocode(from url: URL) throws {
        try computer.loadMicrocode(from: url)
    }
    
    public func saveMicrocode(to url: URL) throws {
        try computer.saveMicrocode(to: url)
    }
    
    public func provideInstructions(_ instructions: [Instruction]) {
        computer.provideInstructions(instructions)
    }
    
    public func loadProgram(from url: URL) throws {
        try computer.loadProgram(from: url)
    }
    
    public func saveProgram(to url: URL) throws {
        try computer.saveProgram(to: url)
    }
    
    public func provideSerialInput(bytes: [UInt8]) {
        computer.provideSerialInput(bytes: bytes)
    }
    
    public var computer:Computer!
    public var onUpdatedCPUState:(CPUStateSnapshot)->Void = {_ in}
    public var didUpdateSerialOutput:(String)->Void = {_ in}
    public var didStart:()->Void = {}
    public var didStop:()->Void = {}
    public var didHalt:()->Void = {}
    public var didReset:()->Void = {}
    
    public var numberOfInstructionsRemaining = 0
    
    public var isExecuting: Bool {
        return numberOfInstructionsRemaining != 0
    }
    
    public var isHalted: Bool {
        return .active == computer.cpuState.controlWord.HLT
    }
    
    public func step() {
        numberOfInstructionsRemaining = 1
    }
    
    public func runOrStop() {
        if numberOfInstructionsRemaining == 0 {
            numberOfInstructionsRemaining = -1
            notifyDidStart()
        } else {
            numberOfInstructionsRemaining = 0
        }
    }
    
    func runForABit() {
        if numberOfInstructionsRemaining == 0 {
            return
        }
        if numberOfInstructionsRemaining > 0 {
            numberOfInstructionsRemaining -= 1
        }
        computer.step()
        let cpuState = computer.cpuState
        publish(cpuState: cpuState)
        if (.active == cpuState.controlWord.HLT) {
            numberOfInstructionsRemaining = 0
            notifyDidStop()
            notifyDidHalt()
        }
        else if (numberOfInstructionsRemaining == 0) {
            notifyDidStop()
        }
    }
    
    public func reset() {
        numberOfInstructionsRemaining = 0
        computer.didUpdateSerialOutput = {[weak self] (aString: String) in
            guard let this = self else { return }
            this.serialOutputUpdateQueue.async {
                this.didUpdateSerialOutput(aString)
            }
        }
        computer.reset()
        publish(cpuState: computer.cpuState)
        notifyDidReset()
    }
    
    func notifyDidStart() {
        notificationQueue.async {
            self.didStart()
        }
    }
    
    func notifyDidStop() {
        notificationQueue.async {
            self.didStop()
        }
    }
    
    func notifyDidHalt() {
        notificationQueue.async {
            self.didHalt()
        }
    }
    
    func notifyDidReset() {
        notificationQueue.async {
            self.didReset()
        }
    }
    
    func publish(cpuState: CPUStateSnapshot) {
        cpuUpdateQueue.async {
            self.onUpdatedCPUState(cpuState)
        }
    }
}
