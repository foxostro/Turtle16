//
//  SnapDebugConsole.swift
//  SnapCore
//
//  Created by Andrew Fox on 3/22/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import TurtleSimulatorCore

public class SnapDebugConsole : DebugConsole {
    public var symbols: Env? = nil
    public let memoryLayoutStrategy = MemoryLayoutStrategyNull()
    
    public func loadSymbolU8(_ identifier: String) -> UInt8? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .arithmeticType(.immutableInt(.u8)) else {
            return nil
        }
        switch symbol.storage {
        case .automaticStorage(offset: let offset),
             .staticStorage(offset: let offset):
            guard let offset else {
                return nil
            }
            let word = computer.ram[offset]
            return UInt8(word & 0x00ff)
        }
    }
    
    public func loadSymbolU16(_ identifier: String) -> UInt16? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .arithmeticType(.immutableInt(.u16)) else {
            return nil
        }
        switch symbol.storage {
        case .automaticStorage(offset: let offset),
             .staticStorage(offset: let offset):
            guard let offset else {
                return nil
            }
            let word = computer.ram[offset]
            return word
        }
    }
    
    public func loadSymbolI8(_ identifier: String) -> Int8? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .arithmeticType(.immutableInt(.i8)) else {
            return nil
        }
        switch symbol.storage {
        case .automaticStorage(offset: let offset),
             .staticStorage(offset: let offset):
            guard let offset else {
                return nil
            }
            let word = UInt8(computer.ram[offset] & 0x00ff)
            let value = Int8(bitPattern: word)
            return value
        }
    }
    
    public func loadSymbolI16(_ identifier: String) -> Int16? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .arithmeticType(.immutableInt(.i16)) else {
            return nil
        }
        switch symbol.storage {
        case .automaticStorage(offset: let offset),
             .staticStorage(offset: let offset):
            guard let offset else {
                return nil
            }
            let word = UInt16(computer.ram[offset] & 0xffff)
            let value = Int16(bitPattern: word)
            return value
        }
    }
    
    public func loadSymbolBool(_ identifier: String) -> Bool? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .constBool else {
            return nil
        }
        switch symbol.storage {
        case .automaticStorage(offset: let offset),
             .staticStorage(offset: let offset):
            guard let offset else {
                return nil
            }
            let word = computer.ram[offset]
            return word != 0
        }
    }
    
    public func loadSymbolPointer(_ identifier: String) -> UInt16? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard case .constPointer = symbol.type.correspondingConstType else {
            return nil
        }
        switch symbol.storage {
        case .automaticStorage(offset: let offset),
             .staticStorage(offset: let offset):
            guard let offset else {
                return nil
            }
            let word = computer.ram[offset]
            return word
        }
    }
    
    public func loadSymbolArrayOfU8(_ count: Int, _ identifier: String) -> [UInt8]? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type == .array(count: count, elementType: .u8) || symbol.type == .array(count: count, elementType: .arithmeticType(.immutableInt(.u8))) else {
            return nil
        }
        
        let offset: Int? = switch symbol.storage {
            case .automaticStorage(offset: let offset),
                 .staticStorage(offset: let offset):
                offset
            }
        guard let offset else {
            return nil
        }
        
        var arr: [UInt8] = []
        for i in 0..<count {
            let word = computer.ram[offset + i*memoryLayoutStrategy.sizeof(type: .u8)]
            let value = UInt8(word & 0x00ff)
            arr.append(value)
        }
        return arr
    }
    
    public func loadSymbolArrayOfU16(_ count: Int, _ identifier: String) -> [UInt16]? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type == .array(count: count, elementType: .u16) || symbol.type == .array(count: count, elementType: .arithmeticType(.immutableInt(.u16))) else {
            return nil
        }
        
        let offset: Int? = switch symbol.storage {
            case .automaticStorage(offset: let offset),
                 .staticStorage(offset: let offset):
                offset
            }
        guard let offset else {
            return nil
        }
        
        var arr: [UInt16] = []
        for i in 0..<count {
            let word = computer.ram[offset + i*memoryLayoutStrategy.sizeof(type: .u16)]
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
        case .array(count: let n, elementType: .u8), .array(count: let n, elementType: .arithmeticType(.immutableInt(.u8))):
            count = n!
            break
            
        default:
            return nil
        }
        
        let offset: Int? = switch symbol.storage {
            case .automaticStorage(offset: let offset),
                 .staticStorage(offset: let offset):
                offset
            }
        guard let offset else {
            return nil
        }
        
        var arr: [UInt8] = []
        for i in 0..<count {
            let word = computer.ram[offset + i*memoryLayoutStrategy.sizeof(type: .u8)]
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
        case .dynamicArray(elementType: .u8),
             .dynamicArray(elementType: .arithmeticType(.immutableInt(.u8))),
             .constDynamicArray(elementType: .u8),
             .constDynamicArray(elementType: .arithmeticType(.immutableInt(.u8))):
            break
            
        default:
            return nil
        }
        
        let offset: Int? = switch symbol.storage {
            case .automaticStorage(offset: let offset),
                 .staticStorage(offset: let offset):
                offset
            }
        guard let offset else {
            return nil
        }
        
        let kSliceBaseAddressOffset = 0
        let kSliceCountOffset = 1
        
        let payloadAddr = MemoryAddress(computer.ram[offset + kSliceBaseAddressOffset])
        let count = Int(computer.ram[offset + kSliceCountOffset])
        
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
