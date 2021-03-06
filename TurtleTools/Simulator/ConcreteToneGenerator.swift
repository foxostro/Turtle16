//
//  ConcreteToneGenerator.swift
//  Simulator
//
//  Created by Andrew Fox on 5/10/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleSimulatorCore

final class ConcreteToneGenerator: AudioRenderer, ToneGenerator {
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
    
    private var _triangleWaveFrequency = 0.0
    public var triangleWaveFrequency: Double {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _triangleWaveFrequency
        }
        set (value) {
            lock.lock()
            _triangleWaveFrequency = value
            lock.unlock()
        }
    }
    
    private var _triangleWaveAmplitude = 0.0
    public var triangleWaveAmplitude: Double {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _triangleWaveAmplitude
        }
        set (value) {
            lock.lock()
            _triangleWaveAmplitude = value
            lock.unlock()
        }
    }
    
    private var _pulseWaveFrequency = 0.0
    public var pulseWaveFrequency: Double {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _pulseWaveFrequency
        }
        set (value) {
            lock.lock()
            _pulseWaveFrequency = value
            lock.unlock()
        }
    }
    
    private var _pulseWaveModulation = 0.0
    public var pulseWaveModulation: Double {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _pulseWaveModulation
        }
        set (value) {
            lock.lock()
            _pulseWaveModulation = value
            lock.unlock()
        }
    }
    
    private var _pulseWaveAmplitude = 0.0
    public var pulseWaveAmplitude: Double {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _pulseWaveAmplitude
        }
        set (value) {
            lock.lock()
            _pulseWaveAmplitude = value
            lock.unlock()
        }
    }
    
    private var _noiseAmplitude = 0.0
    public var noiseAmplitude: Double {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _noiseAmplitude
        }
        set (value) {
            lock.lock()
            _noiseAmplitude = value
            lock.unlock()
        }
    }
    
    private var _masterGain = 0.0
    public var masterGain: Double {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _masterGain
        }
        set (value) {
            lock.lock()
            _masterGain = value
            lock.unlock()
        }
    }
    
    private var triangleWaveTheta = 0.0
    private var pulseWaveTheta = 0.0
    
    override func render(_ inNumberFrames: UInt32, _ samples: UnsafeMutableBufferPointer<Float>) {
        lock.lock()
        defer { lock.unlock() }
        
        let triangleWaveTheta_increment = 2.0 * .pi * _triangleWaveFrequency / sampleRate
        let pulseWaveTheta_increment = 2.0 * .pi * _pulseWaveFrequency / sampleRate
        
        for frame in 0..<inNumberFrames {
            samples[Int(frame)] = Float(unlockedTransferFunction())
            
            triangleWaveTheta += triangleWaveTheta_increment
            if (triangleWaveTheta > 2.0 * .pi) {
                triangleWaveTheta -= 2.0 * .pi
            }
            
            pulseWaveTheta += pulseWaveTheta_increment
            if (pulseWaveTheta > 2.0 * .pi) {
                pulseWaveTheta -= 2.0 * .pi
            }
        }
    }
    
    func unlockedTransferFunction() -> Double {
        let triangleWave = unlockedTriangleWaveTransferFunction()
        let pulseWave = unlockedPulseWaveTransferFunction()
        let noise = unlockedNoiseTransferFunction()
        return (triangleWave + pulseWave + _directDrive + noise) * _masterGain
    }
    
    func unlockedTriangleWaveTransferFunction() -> Double {
        let triangleWave: Double
        if triangleWaveTheta > .pi {
            triangleWave = 1 - (triangleWaveTheta / .pi)
        } else {
            triangleWave = triangleWaveTheta / .pi
        }
        return triangleWave * _triangleWaveAmplitude
    }
    
    func unlockedPulseWaveTransferFunction() -> Double {
        let pulseWave: Double
        if pulseWaveTheta > (.pi * _pulseWaveModulation) {
            pulseWave = 1
        } else {
            pulseWave = 0
        }
        return pulseWave * _pulseWaveAmplitude
    }
    
    func unlockedNoiseTransferFunction() -> Double {
        return Double.random(in: 0.0 ... _noiseAmplitude)
    }
    
    func reset() {
        stop()
        lock.lock()
        _directDrive = 0.0
        _triangleWaveFrequency = 0.0
        _triangleWaveAmplitude = 0.0
        _pulseWaveFrequency = 0.0
        _pulseWaveModulation = 0.0
        _pulseWaveAmplitude = 0.0
        _noiseAmplitude = 0.0
        _masterGain = 0.0
        pulseWaveTheta = 0.0
        triangleWaveTheta = 0.0
        lock.unlock()
    }
}
