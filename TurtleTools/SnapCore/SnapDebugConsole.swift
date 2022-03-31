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
    public let memoryLayoutStrategy = MemoryLayoutStrategyTurtle16()
    
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
    
    public func loadSymbolArrayOfU8(_ count: Int, _ identifier: String) -> [UInt8]? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type == .array(count: count, elementType: .u8) || symbol.type == .array(count: count, elementType: .constU8) else {
            return nil
        }
        var arr: [UInt8] = []
        for i in 0..<count {
            let word = computer.ram[symbol.offset + i*memoryLayoutStrategy.sizeof(type: .u8)]
            let value = UInt8(word & 0x00ff)
            arr.append(value)
        }
        return arr
    }
    
    public func loadSymbolArrayOfU16(_ count: Int, _ identifier: String) -> [UInt16]? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type == .array(count: count, elementType: .u16) || symbol.type == .array(count: count, elementType: .constU16) else {
            return nil
        }
        var arr: [UInt16] = []
        for i in 0..<count {
            let word = computer.ram[symbol.offset + i*memoryLayoutStrategy.sizeof(type: .u16)]
            arr.append(word)
        }
        return arr
    }
    
    public func loadSymbolString(_ identifier: String) -> String? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        
        let count: Int
        switch symbol.type {
        case .array(count: let n, elementType: .u8), .array(count: let n, elementType: .constU8):
            count = n!
            break
            
        default:
            return nil
        }
        
        var arr: [UInt8] = []
        for i in 0..<count {
            let word = computer.ram[symbol.offset + i*memoryLayoutStrategy.sizeof(type: .u8)]
            let value = UInt8(word & 0x00ff)
            arr.append(value)
        }
        
        let str = String(bytes: arr, encoding: .utf8)
        return str
    }
}
