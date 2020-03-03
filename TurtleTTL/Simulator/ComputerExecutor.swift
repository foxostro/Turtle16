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
    let isRunning = AtomicBooleanFlag()
    var flagBreak: AtomicBooleanFlag!
    var serialInput: SerialInput!
    
    public func provideMicrocode(microcode: InstructionDecoder) {
        queue.async { [weak self] in
            self?.unlockedExecutor.provideMicrocode(microcode: microcode)
        }
    }
    
    public func loadMicrocode(from url: URL, errorBlock: @escaping (Error)->Void) {
        queue.async { [weak self] in
            do {
                try self?.unlockedExecutor.loadMicrocode(from: url)
            } catch {
                errorBlock(error)
            }
        }
    }
    
    public func saveMicrocode(to url: URL, errorBlock: @escaping (Error)->Void) {
        queue.async { [weak self] in
            do {
                try self?.unlockedExecutor.saveMicrocode(to: url)
            } catch {
                errorBlock(error)
            }
        }
    }
    
    public func provideInstructions(_ instructions: [Instruction]) {
        queue.async { [weak self] in
            self?.unlockedExecutor.provideInstructions(instructions)
        }
    }
    
    public func loadProgram(from url: URL, errorBlock: @escaping (Error)->Void) {
        queue.async { [weak self] in
            do {
                try self?.unlockedExecutor.loadProgram(from: url)
            } catch {
                errorBlock(error)
            }
        }
    }
    
    public func saveProgram(to url: URL, errorBlock: @escaping (Error)->Void) {
        queue.async { [weak self] in
            do {
                try self?.unlockedExecutor.saveProgram(to: url)
            } catch {
                errorBlock(error)
            }
        }
    }
    
    public func provideSerialInput(bytes: [UInt8]) {
        serialInput.provide(bytes: bytes)
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
            queue.async { [weak self] in
                self?.unlockedExecutor.logger = value
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
                self.flagBreak = value.flagBreak
                self.serialInput = value.serialInput
                self.unlockedExecutor.computer = value
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
           queue.async { [weak self] in
                self?.unlockedExecutor.didUpdateSerialOutput = value
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
            queue.async { [weak self] in
                self?.unlockedExecutor.didStart = value
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
            queue.async { [weak self] in
                self?.unlockedExecutor.didStop = value
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
            queue.async { [weak self] in
                self?.unlockedExecutor.didHalt = value
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
            queue.async { [weak self] in
                self?.unlockedExecutor.didReset = value
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
            queue.async { [weak self] in
                self?.unlockedExecutor.numberOfInstructionsRemaining = value
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
        flagBreak.value = false
        queue.async { [weak self] in
            guard let this = self else { return }
            this.unlockedExecutor.step()
            this.runForABit()
        }
    }
    
    public func runOrStop() {
        flagBreak.value = !isRunning.value
        queue.async { [weak self] in
            guard let this = self else { return }
            this.unlockedExecutor.runOrStop()
            this.runForABit()
        }
    }
    
    public func stop() {
        flagBreak.value = true
        queue.async { [weak self] in
            guard let this = self else { return }
            this.unlockedExecutor.stop()
            this.runForABit()
        }
    }
    
    func runForABit() {
        flagBreak.value = false
        queue.async { [weak self] in
            guard let this = self else { return }
            if this.unlockedExecutor.isExecuting && !this.unlockedExecutor.isHalted {
                this.unlockedExecutor.runForABit()
                this.runForABit()
            }
        }
    }
    
    public func reset() {
        flagBreak.value = false
        queue.async { [weak self] in
            self?.unlockedExecutor.reset()
        }
    }
    
    public var cpuState: CPUStateSnapshot {
        var cpuState: CPUStateSnapshot? = nil
        queue.sync {
            cpuState = unlockedExecutor.cpuState
        }
        return cpuState!
    }
    
    public var stopwatch: ComputerStopwatch? {
        didSet {
            queue.sync {
                unlockedExecutor.stopwatch = stopwatch
            }
        }
    }
}
