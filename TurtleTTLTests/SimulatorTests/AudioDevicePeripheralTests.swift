//
//  AudioDevicePeripheralTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 5/10/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class AudioDevicePeripheralTests: XCTestCase {
    class MockToneGenerator : ToneGenerator {
        var frequency: Double = 0.0
        var amplitude: Double = 0.0
    }
    
    let mockToneGenerator = MockToneGenerator()
    
    func testName() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        XCTAssertEqual(peripheral.name, "Audio Device")
    }
    
    func testStoreSetsFrequency() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.store(42, peripheral.kFrequencyRegisterAddr)
        XCTAssertEqual(peripheral.frequencyRegister, 42)
    }
    
    func testStoreSetsGain() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.store(42, peripheral.kGainRegisterAddr)
        XCTAssertEqual(peripheral.gainRegister, 42)
    }
    
    func testStoreToSomeOtherAddressDoesNothing() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.store(42, 5)
        XCTAssertEqual(peripheral.frequencyRegister, 0)
        XCTAssertEqual(peripheral.gainRegister, 0)
    }
    
    func testLoadProducesZeroNotFrequency() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.frequencyRegister = 42
        XCTAssertEqual(peripheral.load(peripheral.kFrequencyRegisterAddr), 0)
    }
    
    func testLoadProducesZeroNotGain() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.gainRegister = 42
        XCTAssertEqual(peripheral.load(peripheral.kGainRegisterAddr), 0)
    }
    
    func testMappingBetweenFrequenyRegisterAndFrequency() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        
        let expectedMapping: [UInt8 : Double] = [
            0 : 138.0,
            15 : 147.0,
            31 : 183.0,
            63 : 316.0,
            127 : 692.0,
            255 : 1585.0
        ]
        
        for (value, frequency) in expectedMapping {
            peripheral.frequencyRegister = value
            XCTAssertEqual(mockToneGenerator.frequency, frequency)
        }
    }
    
    func testMappingBetweenGainRegisterAndGain() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        
        let expectedMapping: [UInt8 : Double] = [
            0 : 0.0,
            51 : 0.2,
            255 : 1.0
        ]
        
        for (value, gain) in expectedMapping {
            peripheral.gainRegister = value
            XCTAssertEqual(mockToneGenerator.amplitude, gain)
        }
    }
}
