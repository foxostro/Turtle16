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
public class SerialInterface: BankOperation {
    public required init() {
        super.init(name: "Serial")
        self.store = {(state: ComputerState) -> ComputerState in
            return self.doStore(state)
        }
        self.load = {(state: ComputerState) -> ComputerState in
            return self.doLoad(state)
        }
    }
    
    func doStore(_ state: ComputerState) -> ComputerState {
        var serialOutput = state.serialOutput
        serialOutput.append(state.bus.value)
        return state.withSerialOutput(serialOutput)
    }
    
    func doLoad(_ state: ComputerState) -> ComputerState {
        let selectedRegister: Int = Int(state.registerY.value & 1)
        if selectedRegister == 1 {
            return state.withBus(UInt8(state.serialInput.count))
        }
        
        if let byte = state.serialInput.first {
            var serialInput = state.serialInput
            serialInput.removeFirst()
            return state.withBus(byte).withSerialInput(serialInput)
        }
        
        return state.withBus(0xff)
    }
}
