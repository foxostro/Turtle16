//
//  AudioDevicePeripheral.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 5/10/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public protocol ToneGenerator {
    var directDrive: Double { get set }
    var triangleWaveFrequency: Double { get set }
    var triangleWaveAmplitude: Double { get set }
    var pulseWaveFrequency: Double { get set }
    var pulseWaveModulation: Double { get set }
    var pulseWaveAmplitude: Double { get set }
    var noiseAmplitude: Double { get set }
    var masterGain: Double { get set }
}

public class AudioDevicePeripheral: ComputerPeripheral {
    public let kDirectDriveRegisterAddr = 0x00
    public let kTriangleWaveFrequencyRegisterAddr = 0x01
    public let kPulseWaveModulationRegisterAddr = 0x02
    public let kPulseWaveFrequencyRegisterAddr = 0x03
    public let kTriangleWaveAmplitudeRegisterAddr = 0x04
    public let kPulseWaveAmplitudeRegisterAddr = 0x05
    public let kNoiseAmplitudeRegisterAddr = 0x06
    public let kMasterGainRegisterAddr = 0x07
    public var toneGenerator: ToneGenerator?
    
    public var directDriveRegister: UInt8 = 0 {
        didSet {
            toneGenerator?.directDrive = Double(directDriveRegister) / Double(UInt8.max)
        }
    }
    
    public var triangleWaveFrequencyRegister: UInt8 = 0 {
        didSet {
            let cv = Double(triangleWaveFrequencyRegister) / Double(UInt8.max) * 5.0
            let frequency = calcFrequency(cv: cv)
            print("frequency: \(frequency)")
            toneGenerator?.triangleWaveFrequency = frequency
        }
    }
    
    private func calcFrequency(cv: Double) -> Double {
        // I just plugged the CV/gate table in Wikipedia for CV vs Frequency
        // into a curve fitting web app online and got this.
        // <https://en.wikipedia.org/wiki/CV/gate#CV>
        let frequency = 502954100.0 + (60.3568 - 502954100) / (1 + pow(cv / 280.6998, 3.314591))
        return frequency
    }
    
    public var pulseWaveModulationRegister: UInt8 = 0 {
        didSet {
            let unitInterval = Double(pulseWaveModulationRegister) / Double(UInt8.max)
            toneGenerator?.pulseWaveModulation = unitInterval
        }
    }
    
    public var pulseWaveFrequencyRegister: UInt8 = 0 {
        didSet {
            let cv = Double(pulseWaveFrequencyRegister) / Double(UInt8.max) * 5.0
            let frequency = calcFrequency(cv: cv)
            toneGenerator?.pulseWaveFrequency = frequency
        }
    }
    
    public var triangleWaveAmplitudeRegister: UInt8 = 0 {
        didSet {
            let unitInterval = Double(triangleWaveFrequencyRegister) / Double(UInt8.max)
            toneGenerator?.triangleWaveAmplitude = unitInterval
        }
    }
    
    public var pulseWaveAmplitudeRegister: UInt8 = 0 {
        didSet {
            let unitInterval = Double(pulseWaveAmplitudeRegister) / Double(UInt8.max)
            toneGenerator?.pulseWaveAmplitude = unitInterval
        }
    }
    
    public var noiseAmplitudeRegister: UInt8 = 0 {
        didSet {
            let unitInterval = Double(noiseAmplitudeRegister) / Double(UInt8.max)
            toneGenerator?.noiseAmplitude = unitInterval
        }
    }
    
    public var masterGainRegister: UInt8 = 0 {
        didSet {
            let unitInterval = Double(masterGainRegister) / Double(UInt8.max)
            toneGenerator?.masterGain = unitInterval
        }
    }
    
    public init(toneGenerator: ToneGenerator?) {
        self.toneGenerator = toneGenerator
        super.init(name: "Audio Device")
    }
    
    public func store(_ value: UInt8, _ address: Int) -> Void {
        switch address {
        case kDirectDriveRegisterAddr:           directDriveRegister = value
        case kTriangleWaveFrequencyRegisterAddr: triangleWaveFrequencyRegister = value
        case kPulseWaveModulationRegisterAddr:   pulseWaveModulationRegister = value
        case kPulseWaveFrequencyRegisterAddr:    pulseWaveFrequencyRegister = value
        case kTriangleWaveAmplitudeRegisterAddr: triangleWaveAmplitudeRegister = value
        case kPulseWaveAmplitudeRegisterAddr:    pulseWaveAmplitudeRegister = value
        case kNoiseAmplitudeRegisterAddr:        noiseAmplitudeRegister = value
        case kMasterGainRegisterAddr:            masterGainRegister = value
        default: break // nothing to do
        }
    }
    
    public func load(_ address: Int) -> UInt8 {
        return 0
    }
    
    public override func onControlClock() {
        if (PO == .active) {
            bus = Register(withValue: load(valueOfXYPair()))
        }
    }
    
    public override func onRegisterClock() {
        if (PI == .active) {
            store(bus.value, valueOfXYPair())
        }
    }
}
