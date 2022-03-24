//
//  SnapDebugConsole.swift
//  SnapCore
//
//  Created by Andrew Fox on 3/22/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import Turtle16SimulatorCore

public class SnapDebugConsole : DebugConsole {
    public var symbols: SymbolTable? = nil
    
    public func loadSymbolU8(_ identifier: String) -> UInt8? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .constU8 else {
            return nil
        }
        let word = computer.ram[symbol.offset]
        return UInt8(word & 0x00ff)
    }
    
    public func loadSymbolU16(_ identifier: String) -> UInt16? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .constU16 else {
            return nil
        }
        let word = computer.ram[symbol.offset]
        return word
    }
    
    public func loadSymbolBool(_ identifier: String) -> Bool? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .constBool else {
            return nil
        }
        let word = computer.ram[symbol.offset]
        return word != 0
    }
    
    public func loadSymbolPointer(_ identifier: String) -> UInt16? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard case .constPointer = symbol.type.correspondingConstType else {
            return nil
        }
        let word = computer.ram[symbol.offset]
        return word
    }
}
