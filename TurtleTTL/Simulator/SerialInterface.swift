//
//  SerialInterface.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/17/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Represents the serial interface module, a hardware peripheral which
// enables bidirectional communication with a PC.
public class SerialInterface: PeripheralDeviceOperation {
    let kPortStatus = 0
    let kPortCommand = 1
    let kPortData = 2
    let kStatusReady: UInt8 = 0
    let kStatusWaiting: UInt8 = 1
    let kCommandAck = 0
    let kCommandRead = 1
    let kCommandWrite = 2
    let kCommandAvail = 3
    let kCommandInit = 4
    
    public required init() {
        super.init(name: "Serial")
        self.store = {(state: ComputerState) -> ComputerState in
            return self.doStore(state)
        }
        self.load = {(state: ComputerState) -> ComputerState in
            return self.doLoad(state)
        }
    }
    
    func doLoad(_ state: ComputerState) -> ComputerState {
        return state.withBus(state.serialDeviceRAM.load(from: state.valueOfXYPair()))
    }
    
    func doStore(_ state: ComputerState) -> ComputerState {
        var state = state.withSerialDeviceRAM(state.serialDeviceRAM.withStore(value: state.bus.value, to: state.valueOfXYPair()))
        processCommand(&state)
        return state
    }
    
    func processCommand(_ state: inout ComputerState) {
        if state.serialDeviceState == .Waiting {
            processCommandWaiting(&state)
        } else if state.serialDeviceState == .Ready {
            processCommandReady(&state)
        }
    }
    
    func processCommandWaiting(_ state: inout ComputerState) {
        let command = state.serialDeviceRAM.load(from: kPortCommand)
        if command == kCommandAck {
            state = state.withSerialDeviceState(.Ready)
            state = state.withSerialDeviceRAM(state.serialDeviceRAM.withStore(value: kStatusReady, to: kPortStatus))
        }
    }
    
    func processCommandReady(_ state: inout ComputerState) {
        let command = state.serialDeviceRAM.load(from: kPortCommand)
        if command == kCommandRead {
            processCommandRead(&state)
        } else if command == kCommandWrite {
            processCommandWrite(&state)
        } else if command == kCommandAvail {
            processCommandAvail(&state)
        } else if command == kCommandInit {
            processCommandInit(&state)
        }
    }
    
    func processCommandRead(_ state: inout ComputerState) {
        var serialInput = state.serialInput
        var nextByte: UInt8 = 0xff
        if let byte = state.serialInput.first {
            serialInput.removeFirst()
            nextByte = byte
        }
        state = state.withSerialInput(serialInput)
        state = state.withSerialDeviceRAM(state.serialDeviceRAM.withStore(value: nextByte, to: kPortData))
        state = state.withSerialDeviceRAM(state.serialDeviceRAM.withStore(value: kStatusWaiting, to: kPortStatus))
        state = state.withSerialDeviceState(.Waiting)
    }
    
    func processCommandWrite(_ state: inout ComputerState) {
        let nextByte = state.serialDeviceRAM.load(from: kPortData)
        var serialOutput = state.serialOutput
        serialOutput.append(nextByte)
        state = state.withSerialOutput(serialOutput)
        state = state.withSerialDeviceRAM(state.serialDeviceRAM.withStore(value: kStatusWaiting, to: kPortStatus))
        state = state.withSerialDeviceState(.Waiting)
    }
    
    func processCommandAvail(_ state: inout ComputerState) {
        let numberOfBytesAvailable = state.serialInput.count
        state = state.withSerialDeviceRAM(state.serialDeviceRAM.withStore(value: UInt8(numberOfBytesAvailable), to: kPortData))
        state = state.withSerialDeviceRAM(state.serialDeviceRAM.withStore(value: kStatusWaiting, to: kPortStatus))
        state = state.withSerialDeviceState(.Waiting)
    }
    
    func processCommandInit(_ state: inout ComputerState) {
        state = state.withSerialDeviceRAM(state.serialDeviceRAM.withStore(value: kStatusWaiting, to: kPortStatus))
        state = state.withSerialDeviceState(.Waiting)
    }
}
