//
//  MemoryExtensions.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/15/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore
import SnapCore
import TurtleSimulatorCore

extension Memory {
    public func loadValue(ofType elementType: SymbolType, from address: Int) -> Int {
        switch elementType.sizeof {
        case 2:
            return Int(load16(from: address))
        case 1:
            return Int(load(from: address))
        default:
            abort() // unimplemented
        }
    }
    
    public func storeValue(value: Int, ofType elementType: SymbolType, to address: Int) {
        switch elementType.sizeof {
        case 2:
            store16(value: UInt16(value), to: address)
        case 1:
            store(value: UInt8(value), to: address)
        default:
            abort()
        }
    }
}
