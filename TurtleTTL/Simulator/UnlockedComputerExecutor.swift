//
//  UnlockedComputerExecutor.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/16/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

class UnlockedComputerExecutor: NSObject {
    let notificationQueue = DispatchQueue.main
    
    public var stopwatch: ComputerStopwatch? {
        didSet {
            computer.stopwatch = stopwatch
        }
    }
    
    public var logger: Logger? {
        get {
            return computer.logger
        }
        set(value) {
            computer.logger = value
        }
    }
    
    public var cpuState: CPUStateSnapshot {
        return computer.cpuState
    }
    
    public func saveMicrocode(to url: URL) throws {
        try computer.saveMicrocode(to: url)
    }
    
    public func provideInstructions(_ instructions: [Instruction]) {
        computer.provideInstructions(instructions)
        reset()
    }
    
    public func loadProgram(from url: URL) throws {
        try computer.loadProgram(from: url)
        reset()
    }
    
    public func saveProgram(to url: URL) throws {
        try computer.saveProgram(to: url)
    }
    
    public var computer: Computer! {
        didSet {
            computer.stopwatch = stopwatch
        }
    }
    public var didUpdateSerialOutput:(String)->Void = {_ in}
    public var didStart:()->Void = {}
    public var didStop:()->Void = {}
    public var didHalt:()->Void = {}
    public var didReset:()->Void = {}
    
    var _numberOfInstructionsRemaining = 0
    public var numberOfInstructionsRemaining: Int {
        get {
            return _numberOfInstructionsRemaining
        }
        set(value) {
            if _numberOfInstructionsRemaining > 0 && value == 0 {
                notifyDidStop()
            }
            _numberOfInstructionsRemaining = value
        }
    }
    
    public var isExecuting: Bool {
        return numberOfInstructionsRemaining > 0
    }
    
    public var isHalted: Bool {
        return .active == computer.cpuState.controlWord.HLT
    }
    
    public func singleStep() {
        numberOfInstructionsRemaining = 0
        notifyDidStart()
        computer.singleStep()
        notifyDidStop()
        if (.active == computer.cpuState.controlWord.HLT) {
            notifyDidHalt()
        }
    }
    
    public func runOrStop() {
        if numberOfInstructionsRemaining == 0 {
            numberOfInstructionsRemaining = Int.max
            notifyDidStart()
        } else {
            numberOfInstructionsRemaining = 0
        }
    }
    
    public func stop() {
        numberOfInstructionsRemaining = 0
    }
    
    func runForABit() {
        guard numberOfInstructionsRemaining > 0 else { return }
        
        if numberOfInstructionsRemaining != Int.max {
            numberOfInstructionsRemaining -= 1
        }
        
        computer.step()
        
        if (.active == computer.cpuState.controlWord.HLT) {
            numberOfInstructionsRemaining = 0
            notifyDidStop()
            notifyDidHalt()
        }
        else if (numberOfInstructionsRemaining == 0) {
            notifyDidStop()
        }
    }
    
    public func reset() {
        if numberOfInstructionsRemaining > 0 {
            notifyDidStop()
        }
        numberOfInstructionsRemaining = 0
        computer.reset()
        
        computer.didUpdateSerialOutput = {[weak self] (aString: String) in
            guard let this = self else { return }
            this.notificationQueue.async {
                this.didUpdateSerialOutput(aString)
            }
        }
        
        notifyDidReset()
    }
    
    func notifyDidStart() {
        notificationQueue.async { [weak self] in
            self?.didStart()
        }
    }
    
    func notifyDidStop() {
        notificationQueue.async { [weak self] in
            self?.didStop()
        }
    }
    
    func notifyDidHalt() {
        notificationQueue.async { [weak self] in
            self?.didHalt()
        }
    }
    
    func notifyDidReset() {
        notificationQueue.async { [weak self] in
            self?.didReset()
        }
    }
}
