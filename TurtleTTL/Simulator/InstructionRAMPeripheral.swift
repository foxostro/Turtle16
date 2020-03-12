//
//  InstructionRAMPeripheral.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 1/2/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class InstructionRAMPeripheral: ComputerPeripheral {
    public let store: (_ value: UInt8, _ address: Int) -> Void
    public let load: (_ address: Int) -> UInt8
    
    public init(name: String = "Instruction RAM Slice",
                store: @escaping (_ value: UInt8, _ address: Int) -> Void,
                load: @escaping (_ address: Int) -> UInt8) {
        self.store = store
        self.load = load
        super.init(name: name)
    }
    
    public override func onControlClock() {
        if (PO == .active) {
            bus = Register(withValue: load(valueOfXYPair()))
        }
    }
    
    public override func onRegisterClock() {
        if (PI == .active) {
            store(bus.value, valueOfXYPair())
        }
    }
}
