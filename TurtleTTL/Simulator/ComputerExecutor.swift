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
    let unlockedExecutor = UnlockedComputerExecutor()
    let queue = DispatchQueue(label: "com.foxostro.ComputerExecutor")
    
    public func provideMicrocode(microcode: InstructionDecoder) {
        queue.sync {
            unlockedExecutor.provideMicrocode(microcode: microcode)
        }
    }
    
    public func loadMicrocode(from url: URL) throws {
        try queue.sync {
            try unlockedExecutor.loadMicrocode(from: url)
        }
    }
    
    public func saveMicrocode(to url: URL) throws {
        try queue.sync {
            try unlockedExecutor.saveMicrocode(to: url)
        }
    }
    
    public func provideInstructions(_ instructions: [Instruction]) {
        queue.sync {
            unlockedExecutor.provideInstructions(instructions)
        }
    }
    
    public func loadProgram(from url: URL) throws {
        try queue.sync {
            try unlockedExecutor.loadProgram(from: url)
        }
    }
    
    public func saveProgram(to url: URL) throws {
        try queue.sync {
            try unlockedExecutor.saveProgram(to: url)
        }
    }
    
    public func provideSerialInput(bytes: [UInt8]) {
        queue.sync {
            unlockedExecutor.provideSerialInput(bytes: bytes)
        }
    }
    
    public var logger: Logger? {
        get {
            var result: Logger? = nil
            queue.sync {
                result = unlockedExecutor.logger
            }
            return result
        }
        set(value) {
            queue.sync {
                self.unlockedExecutor.logger = value
            }
        }
    }
    
    public var computer:Computer! {
        get {
            var result: Computer? = nil
            queue.sync {
                result = unlockedExecutor.computer
            }
            return result
        }
        set(value) {
            queue.sync {
                self.unlockedExecutor.computer = value
            }
        }
    }
    
    public var onUpdatedCPUState:(CPUStateSnapshot)->Void {
        get {
            var result:(CPUStateSnapshot)->Void = {_ in}
            queue.sync {
                result = unlockedExecutor.onUpdatedCPUState
            }
            return result
        }
        set(value) {
            queue.sync {
                self.unlockedExecutor.onUpdatedCPUState = value
            }
        }
    }

    public var didUpdateSerialOutput:(String)->Void {
        get {
           var result:(String)->Void = {_ in}
           queue.sync {
               result = unlockedExecutor.didUpdateSerialOutput
           }
           return result
        }
        set(value) {
           queue.sync {
               self.unlockedExecutor.didUpdateSerialOutput = value
           }
        }
    }
    
    public var didStart:()->Void {
        get {
            var result:()->Void = {}
            queue.sync {
                result = unlockedExecutor.didStart
            }
            return result
        }
        set(value) {
            queue.sync {
                self.unlockedExecutor.didStart = value
            }
        }
    }
    
    public var didStop:()->Void {
        get {
            var result:()->Void = {}
            queue.sync {
                result = unlockedExecutor.didStop
            }
            return result
        }
        set(value) {
            queue.sync {
                self.unlockedExecutor.didStop = value
            }
        }
    }
    
    public var didHalt:()->Void {
        get {
            var result:()->Void = {}
            queue.sync {
                result = unlockedExecutor.didHalt
            }
            return result
        }
        set(value) {
            queue.sync {
                self.unlockedExecutor.didHalt = value
            }
        }
    }
    
    public var didReset:()->Void {
        get {
            var result:()->Void = {}
            queue.sync {
                result = unlockedExecutor.didReset
            }
            return result
        }
        set(value) {
            queue.sync {
                self.unlockedExecutor.didReset = value
            }
        }
    }
    
    public var numberOfInstructionsRemaining: Int {
        get {
            var result = 0
            queue.sync {
                result = unlockedExecutor.numberOfInstructionsRemaining
            }
            return result
        }
        set(value) {
            queue.sync {
                self.unlockedExecutor.numberOfInstructionsRemaining = value
            }
        }
    }
    
    public var isExecuting: Bool {
        get {
            var result = false
            queue.sync {
                result = unlockedExecutor.isExecuting
            }
            return result
        }
    }
    
    public var isHalted: Bool {
        get {
            var result = false
            queue.sync {
                result = unlockedExecutor.isHalted
            }
            return result
        }
    }
    
    public func step() {
        queue.sync {
            unlockedExecutor.step()
        }
    }
    
    public func runOrStop() {
        queue.sync {
            unlockedExecutor.runOrStop()
            runForABit()
        }
    }
    
    func runForABit() {
        queue.async { [weak self] in
            guard let this = self else { return }
            if this.unlockedExecutor.isExecuting && !this.unlockedExecutor.isHalted {
                this.unlockedExecutor.runForABit()
                this.runForABit()
            }
        }
    }
    
    public func reset() {
        queue.sync {
            unlockedExecutor.reset()
        }
    }
}
