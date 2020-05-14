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
        var amplitude1: Double = 0.0
        var amplitude2: Double = 0.0
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
    
    func testStoreSetsAmplitude1() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.store(42, peripheral.kAmplitude1RegisterAddr)
        XCTAssertEqual(peripheral.amplitude1Register, 42)
    }
    
    func testStoreSetsAmplitude2() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.store(42, peripheral.kAmplitude2RegisterAddr)
        XCTAssertEqual(peripheral.amplitude2Register, 42)
    }
    
    func testStoreToSomeOtherAddressDoesNothing() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.store(42, 5)
        XCTAssertEqual(peripheral.frequencyRegister, 0)
        XCTAssertEqual(peripheral.amplitude1Register, 0)
        XCTAssertEqual(peripheral.amplitude2Register, 0)
    }
    
    func testLoadProducesZeroNotFrequency() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.frequencyRegister = 42
        XCTAssertEqual(peripheral.load(peripheral.kFrequencyRegisterAddr), 0)
    }
    
    func testLoadProducesZeroNotGain() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.amplitude1Register = 42
        XCTAssertEqual(peripheral.load(peripheral.kAmplitude1RegisterAddr), 0)
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
    
    func testMappingBetweenGainRegisterAndAmplitude1() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        
        let expectedMapping: [UInt8 : Double] = [
            0 : 0.0,
            51 : 0.2,
            255 : 1.0
        ]
        
        for (value, amplitude) in expectedMapping {
            peripheral.amplitude1Register = value
            XCTAssertEqual(mockToneGenerator.amplitude1, amplitude)
        }
    }
    
    func testMappingBetweenGainRegisterAndAmplitude2() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        
        let expectedMapping: [UInt8 : Double] = [
            0 : 0.0,
            51 : 0.2,
            255 : 1.0
        ]
        
        for (value, amplitude) in expectedMapping {
            peripheral.amplitude2Register = value
            XCTAssertEqual(mockToneGenerator.amplitude2, amplitude)
        }
    }
}
