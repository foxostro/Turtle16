//
//  AudioDevicePeripheralTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 5/10/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleSimulatorCore

class AudioDevicePeripheralTests: XCTestCase {
    class MockToneGenerator : ToneGenerator {
        var directDrive = 0.0
        var triangleWaveFrequency = 0.0
        var triangleWaveAmplitude = 0.0
        var pulseWaveFrequency = 0.0
        var pulseWaveModulation = 0.0
        var pulseWaveAmplitude = 0.0
        var noiseAmplitude = 0.0
        var masterGain = 0.0
    }
    
    let mockToneGenerator = MockToneGenerator()
    
    func testName() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        XCTAssertEqual(peripheral.name, "Audio Device")
    }
    
    func testStoreSetsTriangleWaveFrequency() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.store(42, peripheral.kTriangleWaveFrequencyRegisterAddr)
        XCTAssertEqual(peripheral.triangleWaveFrequencyRegister, 42)
    }
    
    func testStoreSetsTriangleWaveAmplitude() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.store(42, peripheral.kTriangleWaveAmplitudeRegisterAddr)
        XCTAssertEqual(peripheral.triangleWaveAmplitudeRegister, 42)
    }
    
    func testStoreSetsPulseWaveFrequency() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.store(42, peripheral.kTriangleWaveFrequencyRegisterAddr)
        XCTAssertEqual(peripheral.triangleWaveFrequencyRegister, 42)
    }
    
    func testStoreSetsPulseWaveAmplitude() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.store(42, peripheral.kPulseWaveAmplitudeRegisterAddr)
        XCTAssertEqual(peripheral.pulseWaveAmplitudeRegister, 42)
    }
    
    func testStoreSetsPulseWaveModulation() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.store(42, peripheral.kPulseWaveModulationRegisterAddr)
        XCTAssertEqual(peripheral.pulseWaveModulationRegister, 42)
    }
    
    func testStoreSetsNoiseAmplitude() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.store(42, peripheral.kNoiseAmplitudeRegisterAddr)
        XCTAssertEqual(peripheral.noiseAmplitudeRegister, 42)
    }
    
    func testStoreSetsMasterGain() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.store(42, peripheral.kMasterGainRegisterAddr)
        XCTAssertEqual(peripheral.masterGainRegister, 42)
    }
    
    func testStoreToSomeOtherAddressDoesNothing() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.store(42, 0x100)
        XCTAssertEqual(peripheral.triangleWaveFrequencyRegister, 0)
        XCTAssertEqual(peripheral.triangleWaveAmplitudeRegister, 0)
        XCTAssertEqual(peripheral.pulseWaveFrequencyRegister, 0)
        XCTAssertEqual(peripheral.pulseWaveAmplitudeRegister, 0)
        XCTAssertEqual(peripheral.noiseAmplitudeRegister, 0)
        XCTAssertEqual(peripheral.masterGainRegister, 0)
    }
    
    func testLoadProducesZeroNotFrequency() {
        let peripheral = AudioDevicePeripheral(toneGenerator: mockToneGenerator)
        peripheral.triangleWaveFrequencyRegister = 42
        XCTAssertEqual(peripheral.load(peripheral.kTriangleWaveFrequencyRegisterAddr), 0)
    }
}
