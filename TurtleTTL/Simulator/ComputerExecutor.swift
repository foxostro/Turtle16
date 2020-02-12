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
            return computer.logger
        }
        set(value) {
            computer.logger = value
        }
    }
    
    public var controlWord: ControlWord {
        get {
            return computer.controlWord
        }
        set(value) {
            computer.controlWord = value
        }
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
    
    public func describeRegisterA() -> String {
        return computer.describeRegisterA()
    }
    
    public func describeRegisterB() -> String {
        return computer.describeRegisterB()
    }
    
    public func describeRegisterC() -> String {
        return computer.describeRegisterC()
    }
    
    public func describeRegisterD() -> String {
        return computer.describeRegisterD()
    }
    
    public func describeRegisterG() -> String {
        return computer.describeRegisterG()
    }
    
    public func describeRegisterH() -> String {
        return computer.describeRegisterH()
    }
    
    public func describeRegisterU() -> String {
        return computer.describeRegisterU()
    }
    
    public func describeRegisterV() -> String {
        return computer.describeRegisterV()
    }
    
    public func describeRegisterX() -> String {
        return computer.describeRegisterX()
    }
    
    public func describeRegisterY() -> String {
        return computer.describeRegisterY()
    }
    
    public func describePC() -> String {
        return computer.describePC()
    }
    
    public func describePCIF() -> String {
        return computer.describePCIF()
    }
    
    public func describeIFID() -> String {
        return computer.describeIFID()
    }
    
    public func describeBus() -> String {
        return computer.describeBus()
    }
    
    public func describeALUResult() -> String {
        return computer.describeALUResult()
    }
    
    public func describeControlWord() -> String {
        return computer.describeControlWord()
    }
    
    public func describeControlSignals() -> String {
        return computer.describeControlSignals()
    }
    
    public func describeSerialOutput() -> String {
        return computer.describeSerialOutput()
    }
    
    
    
    
    public var computer:Computer!
    public var onStep:()->Void = {}
    public var didStart:()->Void = {}
    public var didStop:()->Void = {}
    public var didHalt:()->Void = {}
    public var didReset:()->Void = {}
    var timer: Timer? = nil
    
    public var isExecuting = false {
        didSet {
            if (isExecuting) {
                didStart()
            } else {
                didStop()
            }
        }
    }
    
    public var isHalted = false {
        didSet {
            isExecuting = false
            if (isHalted) {
                didHalt()
            }
        }
    }
    
    public func step() {
        computer.step()
        onStep()
    }
    
    public func runOrStop() {
        isExecuting = !isExecuting
    }
    
    public func beginTimer() {
        isHalted = false
        isExecuting = false
        reset()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0, repeats: true, block: {timer in
            self.tick()
        })
    }
    
    public func shutdown() {
        timer?.invalidate()
        timer = nil
    }
    
    public func tick() {
        if (.active == computer.controlWord.HLT) {
            isHalted = true
        }
        
        if (isExecuting) {
            step()
        }
    }
    
    public func reset() {
        isHalted = false
        isExecuting = false
        computer.reset()
        didReset()
    }
}
