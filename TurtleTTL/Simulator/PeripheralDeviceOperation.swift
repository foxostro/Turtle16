//
//  PeripheralDeviceOperation.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/16/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Represents an operation performed aginst a peripheral device.
// The computer can interact with peripheral devices like memory.
public class PeripheralDeviceOperation: NSObject {
    public static let nop = {(state: ComputerState) -> ComputerState in
        return state // NOP
    }
    public let name: String
    public var store: (ComputerState) -> ComputerState
    public var load: (ComputerState) -> ComputerState
    
    public init(name: String = "invalid",
                store:@escaping (ComputerState) -> ComputerState = nop,
                load:@escaping (ComputerState) -> ComputerState = nop) {
        self.name = name
        self.store = store
        self.load = load
    }
}
