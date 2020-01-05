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
    func doLoad(at address: UInt16) {
        setAddress(address)
        bus = Register(withValue: 0)
        PI = .inactive
        PO = .active
        onControlClock()
        onRegisterClock()
    }
    
    func doStore(value: UInt8, at address: UInt16) {
        setAddress(address)
        bus = Register(withValue: value)
        PI = .active
        PO = .inactive
        onControlClock()
        onRegisterClock()
    }
    
    func setAddress(_ address: UInt16) {
        registerX = Register(withValue: UInt8((address & 0xff) >> 8))
        registerY = Register(withValue: UInt8(address & 0xff))
    }
}

class SerialInterfacePeripheralTests: XCTestCase {
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
    
    func testReadFromRegisterOneToGetCount() {
        let serial = SerialInterfacePeripheral()
        serial.serialInput = makeStringBytes("hello")
        serial.doLoad(at: 1)
        XCTAssertEqual(serial.bus.value, 5)
    }
    
    func testReadFromRegisterZeroToGetNextCharacter() {
        let serial = SerialInterfacePeripheral()
        serial.serialInput = makeStringBytes("hello")
        serial.doLoad(at: 0)
        XCTAssertEqual(serial.bus.value, makeStringBytes("h").first!)
    }
    
    func testReadFromRegisterZeroYields255WhenNoInput() {
        let serial = SerialInterfacePeripheral()
        serial.serialInput = makeStringBytes("")
        serial.doLoad(at: 0)
        XCTAssertEqual(serial.bus.value, 255)
    }
    
    func testWriteToRegisterZeroToOutputCharacter() {
        let serial = SerialInterfacePeripheral()
        serial.doStore(value: 65, at: 0)
        XCTAssertEqual(serial.describeSerialOutput(), "A")
    }
    
    func makeStringBytes(_ string: String) -> [UInt8] {
        return Array(string.data(using: .utf8)!)
    }
}
