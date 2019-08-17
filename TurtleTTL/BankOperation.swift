//
//  BankOperation.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/16/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// A memory-like operation which is affected by bank switching.
class BankOperation: NSObject {
    static let nop = {(state: ComputerState) -> ComputerState in
        return state // NOP
    }
    public var name: String
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
