//
//  TackDebugger.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/8/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public class TackDebugger: NSObject {
    public typealias Word = TackVirtualMachine.Word
    
    public let vm: TackVirtualMachine
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    public var symbolsOfTopLevelScope: SymbolTable? = nil
    
    public var symbols: SymbolTable? {
        vm.symbols ?? symbolsOfTopLevelScope
    }
    
    public var sourceAnchor: SourceAnchor? {
        vm.sourceAnchor
    }
    
    public func showSourceList(_ pc: Word, _ count: Int) -> String {
        var result = ""
        let limit = pc &+ Word(count)
        for i in pc..<limit {
            guard i < vm.program.sourceAnchor.count,
                  let sourceAnchor = vm.program.sourceAnchor[Int(i)],
                  let line = String(sourceAnchor.text).split(separator: "\n").first else {
                break
            }
            result += "\(line)\n"
        }
        return result
    }
    
    public init(_ vm: TackVirtualMachine, _ memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyTurtle16()) {
        self.vm = vm
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }
    
    public func loadSymbolU8(_ identifier: String) -> UInt8? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .arithmeticType(.immutableInt(.u8)) else {
            return nil
        }
        let word = vm.load(address: Word(symbol.offset))
        let byte = UInt8(word & 0xff)
        return byte
    }
    
    public func addressOfSymbol(_ symbol: Symbol) -> Word {
        let addr: Word
        switch symbol.storage {
        case .automaticStorage:
            let fp = try! vm.getRegister(.fp)
            if symbol.offset < 0 {
                addr = fp &+ Word(-symbol.offset)
            }
            else {
                addr = fp &- Word(symbol.offset)
            }
            
        case .staticStorage:
            addr = Word(symbol.offset)
        }
        return addr
    }
    
    public func loadSymbolU16(_ identifier: String) -> UInt16? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .arithmeticType(.immutableInt(.u16)) else {
            return nil
        }
        let word = vm.load(address: addressOfSymbol(symbol))
        return word
    }
    
    public func loadSymbolI8(_ identifier: String) -> Int8? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .arithmeticType(.immutableInt(.i8)) else {
            return nil
        }
        let word = vm.load(address: addressOfSymbol(symbol))
        let byte = UInt8(word & 0xff)
        let value = Int8(bitPattern: byte)
        return value
    }
    
    public func loadSymbolI16(_ identifier: String) -> Int16? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .arithmeticType(.immutableInt(.i16)) else {
            return nil
        }
        let word = UInt16(vm.load(address: addressOfSymbol(symbol)) & 0xffff)
        let value = Int16(bitPattern: word)
        return value
    }
    
    public func loadSymbolBool(_ identifier: String) -> Bool? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .bool(.immutableBool) else {
            return nil
        }
        let word = vm.load(address: addressOfSymbol(symbol))
        return word != 0
    }
    
    public func loadSymbolPointer(_ identifier: String) -> UInt16? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard case .constPointer = symbol.type.correspondingConstType else {
            return nil
        }
        let word = vm.load(address: addressOfSymbol(symbol))
        return word
    }
    
    public func loadSymbolArrayOfU8(_ count: Int, _ identifier: String) -> [UInt8]? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type == .array(count: count, elementType: .arithmeticType(.mutableInt(.u8))) || symbol.type == .array(count: count, elementType: .arithmeticType(.immutableInt(.u8))) else {
            return nil
        }
        let baseAddr = addressOfSymbol(symbol)
        var arr: [UInt8] = []
        for i in 0..<count {
            let addr = baseAddr &+ Word(i*memoryLayoutStrategy.sizeof(type: .arithmeticType(.mutableInt(.u8))))
            let word = vm.load(address: addr)
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
        let baseAddr = addressOfSymbol(symbol)
        var arr: [UInt16] = []
        for i in 0..<count {
            let addr = baseAddr &+ Word(i*memoryLayoutStrategy.sizeof(type: .arithmeticType(.mutableInt(.u16))))
            let word = vm.load(address: addr)
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
        
        let baseAddr = addressOfSymbol(symbol)
        var arr: [UInt8] = []
        for i in 0..<count {
            let addr = baseAddr &+ Word(i*memoryLayoutStrategy.sizeof(type: .arithmeticType(.mutableInt(.u8))))
            let word = vm.load(address: addr)
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
        
        let baseAddr = addressOfSymbol(symbol)
        let payloadAddr = vm.load(address: baseAddr &+ Word(kSliceBaseAddressOffset))
        let count = vm.load(address: baseAddr &+ Word(kSliceCountOffset))
        
        var arr: [UInt8] = []
        for i in 0..<count {
            let addr = payloadAddr + i
            let word = vm.load(address: addr)
            let value = UInt8(word & 0x00ff)
            arr.append(value)
        }
        
        let str = String(bytes: arr, encoding: .utf8)
        return str
    }
}
