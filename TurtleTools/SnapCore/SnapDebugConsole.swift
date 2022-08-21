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
        guard symbol.type.correspondingConstType == .arithmeticType(.immutableInt(.u8)) else {
            return nil
        }
        let word = computer.ram[symbol.offset]
        return UInt8(word & 0x00ff)
    }
    
    public func loadSymbolU16(_ identifier: String) -> UInt16? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .arithmeticType(.immutableInt(.u16)) else {
            return nil
        }
        let word = computer.ram[symbol.offset]
        return word
    }
    
    public func loadSymbolBool(_ identifier: String) -> Bool? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .bool(.immutableBool) else {
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
        guard symbol.type == .array(count: count, elementType: .arithmeticType(.mutableInt(.u8))) || symbol.type == .array(count: count, elementType: .arithmeticType(.immutableInt(.u8))) else {
            return nil
        }
        var arr: [UInt8] = []
        for i in 0..<count {
            let word = computer.ram[symbol.offset + i*memoryLayoutStrategy.sizeof(type: .arithmeticType(.mutableInt(.u8)))]
            let value = UInt8(word & 0x00ff)
            arr.append(value)
        }
        return arr
    }
    
    public func loadSymbolArrayOfU16(_ count: Int, _ identifier: String) -> [UInt16]? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type == .array(count: count, elementType: .arithmeticType(.mutableInt(.u16))) || symbol.type == .array(count: count, elementType: .arithmeticType(.immutableInt(.u16))) else {
            return nil
        }
        var arr: [UInt16] = []
        for i in 0..<count {
            let word = computer.ram[symbol.offset + i*memoryLayoutStrategy.sizeof(type: .arithmeticType(.mutableInt(.u16)))]
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
        case .array(count: let n, elementType: .arithmeticType(.mutableInt(.u8))), .array(count: let n, elementType: .arithmeticType(.immutableInt(.u8))):
            count = n!
            break
            
        default:
            return nil
        }
        
        var arr: [UInt8] = []
        for i in 0..<count {
            let word = computer.ram[symbol.offset + i*memoryLayoutStrategy.sizeof(type: .arithmeticType(.mutableInt(.u8)))]
            let value = UInt8(word & 0x00ff)
            arr.append(value)
        }
        
        let str = String(bytes: arr, encoding: .utf8)
        return str
    }
    
    public func loadSymbolStringSlice(_ identifier: String) -> String? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        
        switch symbol.type {
        case .dynamicArray(elementType: .arithmeticType(.mutableInt(.u8))),
             .dynamicArray(elementType: .arithmeticType(.immutableInt(.u8))),
             .constDynamicArray(elementType: .arithmeticType(.mutableInt(.u8))),
             .constDynamicArray(elementType: .arithmeticType(.immutableInt(.u8))):
            break
            
        default:
            return nil
        }
        
        let kSliceBaseAddressOffset = 0
        let kSliceCountOffset = 1
        
        let payloadAddr = MemoryAddress(computer.ram[symbol.offset + kSliceBaseAddressOffset])
        let count = Int(computer.ram[symbol.offset + kSliceCountOffset])
        
        var arr: [UInt8] = []
        for i in 0..<count {
            let word = computer.ram[payloadAddr.value + i]
            let value = UInt8(word & 0x00ff)
            arr.append(value)
        }
        
        let str = String(bytes: arr, encoding: .utf8)
        return str
    }
}
