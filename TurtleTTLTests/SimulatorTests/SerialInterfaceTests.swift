//
//  SerialInterfaceTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/17/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class SerialInterfaceTests: XCTestCase {
    func testInitSerialInterface() {
        let serial = SerialInterface()
        XCTAssertEqual(serial.name, "Serial")
    }
    
    func disabled_testZeroBytesAvailableByDefault() {
        let serial = SerialInterface()
        let state = ComputerState()
            .withBus(0xff)
            .withRegisterY(1)
            .withControlWord(ControlWord().withPO(.active))
        
        let updatedState = serial.load(state)
        
        XCTAssertEqual(updatedState.bus.value, 0)
    }
    
    func disabled_testAvailableBytesAfterProvidingZeroBytes() {
        let serial = SerialInterface()
        let state = ComputerState()
            .withBus(0xff)
            .withRegisterY(1)
            .withControlWord(ControlWord().withPO(.active))
            .withSerialInput([])
        
        let updatedState = serial.load(state)
        
        XCTAssertEqual(updatedState.bus.value, 0)
    }
    
    func disabled_testAvailableBytesAfterProvidingSomeBytes() {
        let serial = SerialInterface()
        let state = ComputerState()
            .withBus(0xff)
            .withRegisterY(1)
            .withControlWord(ControlWord().withPO(.active))
            .withSerialInput([1, 2, 3])
        
        let updatedState = serial.load(state)
        
        XCTAssertEqual(updatedState.bus.value, 3)
    }
    
    func disabled_testLoadAByteFromSerial() {
        let serial = SerialInterface()
        let state = ComputerState()
            .withBus(0xff)
            .withRegisterY(0)
            .withControlWord(ControlWord().withPO(.active))
            .withSerialInput([1, 2, 3])
        
        let updatedState = serial.load(state)
        
        XCTAssertEqual(updatedState.bus.value, 1)
    }
    
    func disabled_testLoadAFewBytesFromSerial() {
        let serial = SerialInterface()
        var state = ComputerState()
            .withBus(0xff)
            .withRegisterY(0)
            .withControlWord(ControlWord().withPO(.active))
            .withSerialInput([1, 2, 3])
        
        state = serial.load(state)
        XCTAssertEqual(state.bus.value, 1)
        
        state = serial.load(state)
        XCTAssertEqual(state.bus.value, 2)
        
        state = serial.load(state)
        XCTAssertEqual(state.bus.value, 3)
    }
    
    func disabled_testLoadYields255WhenNoBytesAreAvailable() {
        let serial = SerialInterface()
        var state = ComputerState()
            .withBus(0xff)
            .withRegisterY(0)
            .withControlWord(ControlWord().withPO(.active))
        
        state = serial.load(state)
        XCTAssertEqual(state.bus.value, 0xff)
    }
    
    func disabled_testStoreAByteToSerial() {
        let serial = SerialInterface()
        let state = ComputerState()
            .withBus(2)
            .withRegisterY(0)
            .withControlWord(ControlWord().withPO(.active))
            .withSerialOutput([1])
        
        let updatedState = serial.store(state)
        
        XCTAssertEqual(updatedState.serialOutput, [1, 2])
    }
}
