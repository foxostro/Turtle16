//
//  ComputerPeripheral.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 1/2/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

open class ComputerPeripheral: NSObject {
    public let name: String
    public var bus = Register()
    public var registerX = Register()
    public var registerY = Register()
    public var PI: ControlSignal = .inactive
    public var PO: ControlSignal = .inactive
    
    public init(name: String = "unknown") {
        self.name = name
    }
    
    open func onControlClock() {
        // override in a subclass
    }
    
    open func onRegisterClock() {
        // override in a subclass
    }
    
    open func onPeripheralClock() {
        // override in a subclass
    }
    
    public func valueOfXYPair() -> Int {
        return registerX.integerValue<<8 | registerY.integerValue
    }
}
