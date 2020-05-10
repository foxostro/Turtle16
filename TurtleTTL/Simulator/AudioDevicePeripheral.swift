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
    var gain: Double { get set }
}

public class AudioDevicePeripheral: ComputerPeripheral {
    public let kFrequencyRegisterAddr = 0x00
    public let kGainRegisterAddr = 0x01
    public let toneGenerator: ToneGenerator
    
    public var frequencyRegister: UInt8 = 0
    public var gainRegister: UInt8 = 0
    
    public init(toneGenerator: ToneGenerator) {
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
}
