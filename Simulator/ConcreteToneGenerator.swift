//
//  ConcreteToneGenerator.swift
//  Simulator
//
//  Created by Andrew Fox on 5/10/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleSimulatorCore

final class ConcreteToneGenerator: ToneGenerator {
    private var isRunning = false
    private let oscillator = Oscillator()
    private let lock = NSLock()
    
    public var frequency: Double {
        get {
            return oscillator.frequency
        }
        set (value) {
            oscillator.frequency = value
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
        }
    }
    
    private var _directDrive = 0.0
    public var directDrive: Double {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _directDrive
        }
        set (value) {
            lock.lock()
            _directDrive = value
            lock.unlock()
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
        return triangleFn(theta)*_amplitude1 + sawtoothFn(theta)*_amplitude2 + _directDrive
    }
    
    init() {
        oscillator.transferFunction = { [weak self] (theta: Double) in
            return self?.transferFunction(theta) ?? 0.0
        }
    }
    
    func start() {
        if !isRunning {
            oscillator.start()
            isRunning = true
        }
    }
    
    func stop() {
        if isRunning {
            oscillator.stop()
            isRunning = false
        }
    }
    
    func reset() {
        stop()
        frequency = 0.0
        lock.lock()
        _amplitude1 = 0.0
        _amplitude2 = 0.0
        _directDrive = 0.0
        lock.unlock()
    }
}
