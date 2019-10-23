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
        if (.active == computer.currentState.controlWord.HLT) {
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
