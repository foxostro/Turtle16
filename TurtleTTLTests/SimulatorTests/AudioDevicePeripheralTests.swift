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
        var gain: Double = 0.0
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
}
