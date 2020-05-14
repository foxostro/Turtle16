//
//  ConcreteToneGenerator.swift
//  Simulator
//
//  Created by Andrew Fox on 5/10/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleTTL

class ConcreteToneGenerator: ToneGenerator {
    private var isRunning = false
    private let oscillator = Oscillator()
    private let lock = NSLock()
    
    public var frequency: Double = 0.0 {
        didSet {
            update()
        }
    }
    
    private var _amplitude1 = 0.0
    public var amplitude1: Double {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _amplitude1
        }
        set (value) {
            lock.lock()
            _amplitude1 = value
            lock.unlock()
            update()
        }
    }
    
    private var _amplitude2 = 0.0
    public var amplitude2: Double {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _amplitude2
        }
        set (value) {
            lock.lock()
            _amplitude2 = value
            lock.unlock()
            update()
        }
    }
    
    let sawtoothFn: Oscillator.TransferFunction = { theta in
        return theta / (2.0 * .pi)
    }
    
    let triangleFn: Oscillator.TransferFunction = { theta in
        if theta > .pi {
            return 1 - (theta / .pi)
        } else {
            return theta / .pi
        }
    }
    
    func transferFunction(_ theta: Double) -> Double {
        lock.lock()
        defer { lock.unlock() }
        return triangleFn(theta)*_amplitude1 + sawtoothFn(theta)*_amplitude2
    }
    
    init() {
        oscillator.transferFunction = { [weak self] (theta: Double) in
            return self?.transferFunction(theta) ?? 0.0
        }
    }
    
    func isSilent() -> Bool {
        return amplitude1 == 0.0 && amplitude2 == 0.0
    }
    
    func update() {
        if (frequency == 0.0 || isSilent()) && isRunning {
            oscillator.stop()
            isRunning = false
        } else {
            oscillator.frequency = frequency
            if !isRunning {
                oscillator.start()
            }
            isRunning = true
        }
    }
}
