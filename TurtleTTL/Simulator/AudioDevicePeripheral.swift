//
//  AudioDevicePeripheral.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 5/10/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public protocol ToneGenerator {
    var frequency: Double { get set }
    var amplitude: Double { get set }
}

public class AudioDevicePeripheral: ComputerPeripheral {
    public let kFrequencyRegisterAddr = 0x00
    public let kGainRegisterAddr = 0x01
    public var toneGenerator: ToneGenerator?
    
    public var frequencyRegister: UInt8 = 0 {
        didSet {
            let mapping: [Range<Int> : (Double,Double)] = [
                0..<15 : (138.0, 147.0),
                15..<31 : (147.0, 183.0),
                31..<63 : (183.0, 316.0),
                63..<127 : (316.0, 692.0),
                127..<255 : (692.0, 1585.0),
                255..<256 : (1585.0, 1585.0)
            ]
            
            for (rangeValue, rangeFrequency) in mapping {
                let value = Int(frequencyRegister)
                if rangeValue ~= value {
                    let proportion = Double(value - rangeValue.lowerBound) / Double(rangeValue.upperBound - rangeValue.lowerBound)
                    let frequency = rangeFrequency.0 + proportion * (rangeFrequency.1 - rangeFrequency.0)
                    toneGenerator?.frequency = frequency
                    break
                }
            }
        }
    }
    
    public var gainRegister: UInt8 = 0 {
        didSet {
            toneGenerator?.amplitude = Double(gainRegister) / 255.0
        }
    }
    
    func lerp(_ x: Double, _ x0: Double, _ x1: Double) -> Double {
        return x0 + (x * (x1 - x0))
    }
    
    public init(toneGenerator: ToneGenerator?) {
        self.toneGenerator = toneGenerator
        super.init(name: "Audio Device")
    }
    
    public func store(_ value: UInt8, _ address: Int) -> Void {
        if address == kFrequencyRegisterAddr {
            frequencyRegister = value
        }
            
        if address == kGainRegisterAddr {
            gainRegister = value
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
