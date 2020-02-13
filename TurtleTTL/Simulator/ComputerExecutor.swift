//
//  ComputerExecutor.swift
//  Simulator
//
//  Created by Andrew Fox on 7/29/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

class ThrottledQueue {
    let queue: DispatchQueue
    let maxInterval: Double
    
    var job: DispatchWorkItem = DispatchWorkItem(block: {})
    var previousRun: Date = Date.distantPast
    
    init(queue: DispatchQueue, maxInterval: Double) {
        self.queue = queue
        self.maxInterval = maxInterval
    }
    
    func async(block: @escaping () -> ()) {
        job.cancel()
        job = DispatchWorkItem(){ [weak self] in
            self?.previousRun = Date()
            block()
        }
        let delay = Date().timeIntervalSince(previousRun) > maxInterval ? 0 : maxInterval
        queue.asyncAfter(deadline: .now() + Double(delay), execute: job)
    }
}

// Executes a simulation on a background thread.
public class ComputerExecutor: NSObject {
    let cpuUpdateQueue: ThrottledQueue
    let serialOutputUpdateQueue: ThrottledQueue
    
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
    
    public override init() {
        cpuUpdateQueue = ThrottledQueue(queue: DispatchQueue.main, maxInterval: 1.0 / 30.0)
        serialOutputUpdateQueue = ThrottledQueue(queue: DispatchQueue.main, maxInterval: 1.0 / 30.0)
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
    public var didUpdateSerialOutput:(String)->Void = {_ in}
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
            notifyDidStart()
            semaGoSignal.signal()
        } else {
            numberOfInstructionsRemaining = 0
        }
    }
    
    public func start() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        reset()
        thread = Thread(block: { self.run() })
        thread.start()
    }
    
    func run() {
        while !thread.isCancelled {
            objc_sync_enter(self)
            
            if (numberOfInstructionsRemaining == 0) {
                notifyDidStop()
                objc_sync_exit(self)
                semaGoSignal.wait()
                objc_sync_enter(self)
            }
            else if numberOfInstructionsRemaining != 0 {
                if numberOfInstructionsRemaining > 0 {
                    numberOfInstructionsRemaining -= 1
                }
                computer.step()
                let cpuState = publishCPUStateSnapshot()
                if (.active == cpuState.controlWord.HLT) {
                    notifyDidHalt()
                    objc_sync_exit(self)
                    semaGoSignal.wait()
                    objc_sync_enter(self)
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
        computer.didUpdateSerialOutput = {(aString: String) in
            self.serialOutputUpdateQueue.async {
                self.didUpdateSerialOutput(aString)
            }
        }
        computer.reset()
        publishCPUStateSnapshot()
        notifyDidReset()
    }
    
    func notifyDidStart() {
        DispatchQueue.main.async {
            self.didStart()
        }
    }
    
    func notifyDidStop() {
        DispatchQueue.main.async {
            self.didStop()
        }
    }
    
    func notifyDidHalt() {
        DispatchQueue.main.async {
            self.didHalt()
        }
    }
    
    func notifyDidReset() {
        DispatchQueue.main.async {
            self.didReset()
        }
    }
    
    @discardableResult func publishCPUStateSnapshot() -> CPUStateSnapshot {
        let cpuState = computer.cpuState
        cpuUpdateQueue.async {
            self.onUpdatedCPUState(cpuState)
        }
        return cpuState
    }
}
