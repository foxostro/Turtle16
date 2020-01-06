//
//  SerialInterfacePeripheral.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 1/2/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class SerialInterfacePeripheral: ComputerPeripheral {
    public let kDataRegister: UInt16 = 1
    public let kControlRegister: UInt16 = 0
    
    public let kStatusSuccess: UInt8 = 0xff
    
    public let kCommandResetSerialLink: UInt8 = 0
    public let kCommandPutByte: UInt8 = 1
    public let kCommandGetByte: UInt8 = 2
    public let kCommandGetNumBytes: UInt8 = 3
    
    var microState: UInt8
    let kMicroStateWaitingForRisingSCK: UInt8 = 0
    let kMicroStateWaitingForFallingSCK: UInt8 = 1
    let kMicroStateProcessing: UInt8 = 2
    
    var state: UInt8
    let kStateIdle: UInt8 = 0
    let kStateWaitingForOutputByte: UInt8 = 1
    
    public var inputBuffer: UInt8 = 0
    public var outputBuffer: UInt8 = 0
    public var sck: UInt8 = 0
    
    public var serialInput: [UInt8] = []
    public var serialOutput: [UInt8] = []

    public var address: UInt16 {
        set(address) {
            registerX = Register(withValue: UInt8((address & 0xff) >> 8))
            registerY = Register(withValue: UInt8(address & 0xff))
        }
        get {
            return (UInt16(registerX.value) << 8) | UInt16(registerY.value)
        }
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
        microState = kMicroStateWaitingForRisingSCK
        state = kStateIdle
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
    
    public override func onPeripheralClock() {
        tickMicroStateMachine()
    }
    
    func store(_ value: UInt8) {
        if address == kControlRegister {
            sck = bus.value
        } else {
            inputBuffer = bus.value
        }
    }
    
    func load(_ value: UInt8) {
        bus = Register(withValue: outputBuffer)
    }
    
    func tickMicroStateMachine() {
        switch microState {
        case kMicroStateWaitingForRisingSCK:
            if sck != 0 {
                microState = kMicroStateProcessing
            }
            
        case kMicroStateWaitingForFallingSCK:
            if sck == 0 {
                microState = kMicroStateWaitingForRisingSCK
            }
            
        case kMicroStateProcessing:
            tickMacroStateMachine()
            microState = kMicroStateWaitingForFallingSCK
            
        default:
            assert(false)
        }
    }
    
    func tickMacroStateMachine() {
        var nextState = kStateIdle
        switch (state) {
        case kStateIdle:
            nextState = doStateIdle(mosi: inputBuffer)
        
        case kStateWaitingForOutputByte:
            nextState = doStateWaiting(mosi: inputBuffer)
              
        default:
              assert(false)
        }
        state = nextState
    }
    
    func doStateIdle(mosi: UInt8) -> UInt8 {
        var nextState = kStateIdle
        switch (mosi) {
        case kCommandResetSerialLink:
            nextState = doCommandReset()

        case kCommandPutByte:
            nextState = doCommandPutByte()

        case kCommandGetByte:
            nextState = doCommandGetByte()

        case kCommandGetNumBytes:
            nextState = doCommandGetNumBytes()

        default:
            assert(false)
        }
        return nextState
    }

    func doCommandReset() -> UInt8 {
        outputBuffer = kStatusSuccess
        serialInput = []
        serialOutput = []
        return kStateIdle
    }

    func doCommandPutByte() -> UInt8 {
        outputBuffer = kStatusSuccess
        return kStateWaitingForOutputByte
    }
    
    func doCommandGetByte() -> UInt8 {
        outputBuffer = getNextByte()
        return kStateIdle
    }

    func getNextByte() -> UInt8 {
        if let byte = serialInput.first {
            serialInput.removeFirst()
            return byte
        } else {
            return 255
        }
    }

    func doCommandGetNumBytes() -> UInt8 {
        outputBuffer = UInt8(serialInput.count)
        return kStateIdle
    }
    
    func doStateWaiting(mosi: UInt8) -> UInt8 {
        serialOutput.append(mosi)
        outputBuffer = kStatusSuccess
        return kStateIdle
    }
}
