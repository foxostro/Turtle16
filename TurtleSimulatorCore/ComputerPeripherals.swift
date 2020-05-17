//
//  ComputerPeripherals.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 1/2/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class ComputerPeripherals: NSObject {
    public var logger:Logger? = nil
    public var bus = Register()
    public var registerX = Register()
    public var registerY = Register()
    public private(set) var uptime: UInt64 = 0
    public var peripherals: [ComputerPeripheral] = [ComputerPeripheral(),
                                                    ComputerPeripheral(),
                                                    ComputerPeripheral(),
                                                    ComputerPeripheral(),
                                                    ComputerPeripheral(),
                                                    ComputerPeripheral(),
                                                    ComputerPeripheral(),
                                                    ComputerPeripheral()]
    
    public func populate(_ storeUpperInstructionRAM: @escaping (_ value: UInt8, _ address: Int) -> Void,
                         _ loadUpperInstructionRAM: @escaping (_ address: Int) -> UInt8,
                         _ storeLowerInstructionRAM: @escaping (_ value: UInt8, _ address: Int) -> Void,
                         _ loadLowerInstructionRAM: @escaping (_ address: Int) -> UInt8,
                         toneGenerator: ToneGenerator? = nil) {
        peripherals = [
            InstructionRAMPeripheral(name: "Upper Instruction RAM",
                                     store: storeUpperInstructionRAM,
                                     load: loadUpperInstructionRAM),
            InstructionRAMPeripheral(name: "Lower Instruction RAM",
                                     store: storeLowerInstructionRAM,
                                     load: loadLowerInstructionRAM),
            ComputerPeripheral(),
            ComputerPeripheral(),
            ComputerPeripheral(),
            ComputerPeripheral(),
            AudioDevicePeripheral(toneGenerator: toneGenerator),
            SerialInterfacePeripheral()
        ]
    }
    
    public func resetControlSignals() {
        for peripheral in peripherals {
            peripheral.PI = .inactive
            peripheral.PO = .inactive
        }
    }
    
    public func activateSignalPO(_ index: Int) {
        peripherals[index].PO = .active
    }
    
    public func activateSignalPI(_ index: Int) {
        peripherals[index].PI = .active
    }
    
    public func getName(at index: Int) -> String {
        return peripherals[index].name
    }
    
    public func onControlClock() {
        for peripheral in peripherals {
            peripheral.bus = bus
            peripheral.registerX = registerX
            peripheral.registerY = registerY
            peripheral.onControlClock()
            if peripheral.PO == .active {
                logger?.append("PO -- Peripheral \"%@\" outputs %@ to bus",
                               peripheral.name, bus)
                bus = peripheral.bus
            }
        }
    }
    
    public func onRegisterClock() {
        for peripheral in peripherals {
            peripheral.bus = bus
            peripheral.registerX = registerX
            peripheral.registerY = registerY
            peripheral.onRegisterClock()
            if peripheral.PI == .active {
                logger?.append("PI -- Peripheral \"%@\" inputs %02x from bus at address 0x%04x",
                               peripheral.name,
                               bus.value,
                               valueOfXYPair())
            }
        }
    }
    
    public func onPeripheralClock() {
        for peripheral in peripherals {
            peripheral.onPeripheralClock()
        }
        uptime += 1
    }
    
    public func valueOfXYPair() -> Int {
        return registerX.integerValue<<8 | registerY.integerValue
    }
    
    public func getSerialInterface() -> SerialInterfacePeripheral {
        return peripherals[7] as! SerialInterfacePeripheral
    }
    
    public func catchUp(uptime desiredUptime: UInt64) {
        logger?.append("Peripherals are catching up to CPU now. -- " +
                       "peripheral uptime: \(uptime) ; " +
                       "CPU uptime: \(desiredUptime)")
        while uptime < desiredUptime {
            resetControlSignals()
            
            bus = Register(withValue: 0)
            registerX = Register(withValue: 0)
            registerY = Register(withValue: 0)
            onControlClock()
            
            bus = Register(withValue: 0)
            registerX = Register(withValue: 0)
            registerY = Register(withValue: 0)
            onRegisterClock()
            
            onPeripheralClock()
        }
        
        resetControlSignals()
    }
}
