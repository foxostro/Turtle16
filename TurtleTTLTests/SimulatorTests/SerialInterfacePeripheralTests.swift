//
//  SerialInterfacePeripheralTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 1/2/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

extension SerialInterfacePeripheral {
    func tick() {
        onControlClock()
        onRegisterClock()
        onPeripheralClock()
    }
    
    func doLoad(at address: UInt16) {
        self.address = address
        bus = Register(withValue: 0)
        PI = .inactive
        PO = .active
        tick()
    }
    
    func doStore(value: UInt8, at address: UInt16) {
        self.address = address
        bus = Register(withValue: value)
        PI = .active
        PO = .inactive
        tick()
    }
    
    func doCommand(command: UInt8) -> UInt8 {
        doStore(value: command, at: kDataRegister)
        doStore(value: 1, at: kControlRegister)
        tick() // NOP
        doLoad(at: kDataRegister)
        let byte = bus.value
        doStore(value: 0, at: kControlRegister)
        return byte
    }
}

class SerialInterfacePeripheralTests: XCTestCase {
    func makeStringBytes(_ string: String) -> [UInt8] {
        return Array(string.data(using: .utf8)!)
    }
    
    func testInitiallyEmptySerialInputAndOutput() {
        let serial = SerialInterfacePeripheral()
        XCTAssertEqual(serial.serialInput, [])
        XCTAssertEqual(serial.serialOutput, [])
        XCTAssertEqual(serial.describeSerialOutput(), "")
    }
    
    func testDescribeSerialBytesAsBasicUTF8String() {
        let serial = SerialInterfacePeripheral()
        serial.serialOutput = Array("hello".data(using: .utf8)!)
        XCTAssertEqual(serial.describeSerialOutput(), "hello")
    }
    
    func testDescribeSerialBytesContainingInvalidUTF8Character() {
        let serial = SerialInterfacePeripheral()
        serial.serialOutput = [65, 255, 66]
        XCTAssertEqual(serial.describeSerialOutput(), "A�B")
    }
    
    func testReadOutputBuffer() {
        let serial = SerialInterfacePeripheral()
        serial.outputBuffer = 1
        serial.doLoad(at: serial.kDataRegister)
        XCTAssertEqual(serial.bus.value, 1)
    }
    
    func testWriteToInputBuffer() {
        let serial = SerialInterfacePeripheral()
        serial.doStore(value: 1, at: serial.kDataRegister)
        XCTAssertEqual(serial.inputBuffer, 1)
    }
    
    func testWriteToSCK() {
        let serial = SerialInterfacePeripheral()
        serial.doStore(value: 1, at: serial.kControlRegister)
        XCTAssertEqual(serial.sck, 1)
    }
    
    func testCommandResetSerialLink() {
        let serial = SerialInterfacePeripheral()
        serial.serialInput = [1, 2, 3]
        serial.serialOutput = [1, 2, 3]
        
        let status = serial.doCommand(command: serial.kCommandResetSerialLink)
        
        XCTAssertEqual(status, serial.kStatusSuccess)
        XCTAssertEqual(serial.serialInput, [])
        XCTAssertEqual(serial.serialOutput, [])
    }
    
    func testCommandPutByte() {
        let serial = SerialInterfacePeripheral()
        
        let status1 = serial.doCommand(command: serial.kCommandPutByte)
        let status2 = serial.doCommand(command: 65)
        
        XCTAssertEqual(status1, serial.kStatusSuccess)
        XCTAssertEqual(status2, serial.kStatusSuccess)
        XCTAssertEqual(serial.serialInput, [])
        XCTAssertEqual(serial.serialOutput, [65])
    }
    
    func testCommandGetNumBytesWithNoneAvailable() {
        let serial = SerialInterfacePeripheral()
        
        let count = serial.doCommand(command: serial.kCommandGetNumBytes)
        
        XCTAssertEqual(count, 0)
    }
    
    func testCommandGetNumBytesWithSomeAvailable() {
        let serial = SerialInterfacePeripheral()
        serial.serialInput = [1, 2, 3]
        
        let count = serial.doCommand(command: serial.kCommandGetNumBytes)
        
        XCTAssertEqual(count, 3)
    }
    
    func testCommandGetByteWithNoneAvailable() {
        let serial = SerialInterfacePeripheral()
        
        let byte = serial.doCommand(command: serial.kCommandGetByte)
        
        XCTAssertEqual(byte, 255)
    }
    
    func testCommandGetByteWithSomeAvailable() {
        let serial = SerialInterfacePeripheral()
        serial.serialInput = [1, 2, 3]
        
        let byte = serial.doCommand(command: serial.kCommandGetByte)
        
        XCTAssertEqual(byte, 1)
        XCTAssertEqual(serial.serialInput, [2, 3])
    }
}
