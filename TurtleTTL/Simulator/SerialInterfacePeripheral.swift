//
//  SerialInterfacePeripheral.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 1/2/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class SerialInterfacePeripheral: ComputerPeripheral {
    public var serialInput: [UInt8] = []
    public var serialOutput: [UInt8] = []
//    public var payload: UInt8 = 0
//    public var sck: UInt8 = 0
//    public var addr: UInt8 = 0

    var selectedRegister: Int {
        return registerY.integerValue & 1
    }
    
    public func provideSerialInput(bytes: [UInt8]) {
        serialInput += bytes
    }
    
    public func describeSerialOutput() -> String {
        var result = ""
        for byte in serialOutput {
            result += String(bytes: [byte], encoding: .utf8) ?? "�"
        }
        return result
    }

    public init() {
        super.init(name: "Serial")
    }
    
    public override func onRegisterClock() {
        if (PI == .active) {
            store(bus.value)
        }
    }
        
    public override func onControlClock() {
        if (PO == .active) {
            load(bus.value)
        }
    }
    
    func store(_ value: UInt8) {
        serialOutput.append(value)
    }
    
    func load(_ value: UInt8) {
        if selectedRegister == 1 {
            let value = UInt8(serialInput.count)
            bus = Register(withValue: value)
            return
        }
        
        if let byte = serialInput.first {
            serialInput.removeFirst()
            bus = Register(withValue: byte)
            return
        }
        
        bus = Register(withValue: 0xff)
    }
}
