//
//  TackDebugger.swift
//  SnapCore
//
//  Created by Andrew Fox on 11/8/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

public final class TackDebugger {
    public typealias Word = TackVirtualMachine.Word
    
    public let vm: TackVirtualMachine
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    public var symbolsOfTopLevelScope: Env? = nil
    
    public var symbols: Env? {
        vm.symbols ?? symbolsOfTopLevelScope
    }
    
    public var symbolicatedBacktrace: [String] {
        vm.backtrace.compactMap { ra in
            showFunctionName(pc: ra)
        }
    }
    
    public var formattedBacktrace: String {
        var lines: [String] = []
        for i in 0..<symbolicatedBacktrace.count {
            lines.append("\(i)\t\(symbolicatedBacktrace[i])")
        }
        return lines.joined(separator: "\n")
    }
    
    public func showSourceList(pc: UInt, count: Int) -> String? {
        guard let sourceAnchor = vm.findSourceAnchor(pc: pc),
              let lineNumbers = sourceAnchor.lineNumbers else {
            return nil
        }
        
        let currentlyExecutingLineNumber = vm.findSourceAnchor(pc: vm.pc)?.lineNumbers?.first
        
        let lines = sourceAnchor.lineMapper.text.split(separator: "\n")
        let lineNumber = lineNumbers.first!
        let lineRange = lineNumber..<(lineNumber+count)
        
        var result = ""
        for i in lineRange {
            guard i >= 0 && i < lines.count else {
                break
            }
            let line = lines[i]
            
            let kLineNumberColWidth = 5
            let lineNumberStr = "\(i)"
            let pad = String(repeating: " ", count: kLineNumberColWidth-lineNumberStr.count)
            let lineNumberCol = pad + lineNumberStr
            
            let indicator: String
            if let currentlyExecutingLineNumber, i == currentlyExecutingLineNumber {
                indicator = "->"
            }
            else {
                indicator = ""
            }
            
            result += "\(lineNumberCol)\t\(indicator)\t\(line)\n"
        }
        
        return result
    }
    
    public func showFunctionName(pc: UInt) -> String? {
        guard pc < vm.program.subroutines.count else {
            return nil
        }
        return vm.program.subroutines[Int(pc)]
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
        let offset: Int? = switch symbol.storage {
        case .automaticStorage(offset: let offset),
             .staticStorage(offset: let offset):
            offset
        case .registerStorage:
            nil
        }
        guard let offset else {
            return nil
        }
        let word = vm.loadb(address: UInt(offset))
        let byte = UInt8(word & 0xff)
        return byte
    }
    
    public func addressOfSymbol(_ symbol: Symbol) -> UInt {
        let addr: UInt
        switch symbol.storage {
        case .automaticStorage(let offset):
            guard let offset else { return 0xFFFF } // TODO: addressOfSymbol() should be able to return nil
            let fp = try! vm.getRegister(p: .fp)
            if offset < 0 {
                addr = fp &+ UInt(-offset)
            }
            else {
                addr = fp &- UInt(offset)
            }
            
        case .staticStorage(let offset):
            guard let offset else { return 0xFFFF } // TODO: addressOfSymbol() should be able to return nil
            addr = UInt(offset)
            
        case .registerStorage:
            return 0xFFFF // TODO: addressOfSymbol() should be able to return nil
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
        let word = vm.loadw(address: addressOfSymbol(symbol))
        return word
    }
    
    public func loadSymbolI8(_ identifier: String) -> Int8? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .arithmeticType(.immutableInt(.i8)) else {
            return nil
        }
        let byte = vm.loadb(address: addressOfSymbol(symbol))
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
        let word = vm.loadw(address: addressOfSymbol(symbol))
        let value = Int16(bitPattern: word)
        return value
    }
    
    public func loadSymbolBool(_ identifier: String) -> Bool? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type.correspondingConstType == .constBool else {
            return nil
        }
        let word = vm.loado(address: addressOfSymbol(symbol))
        return word
    }
    
    public func loadSymbolPointer(_ identifier: String) -> Word? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard case .constPointer = symbol.type.correspondingConstType else {
            return nil
        }
        let word = vm.loadw(address: addressOfSymbol(symbol))
        return word
    }
    
    public func loadSymbolArrayOfU8(_ count: Int, _ identifier: String) -> [UInt8]? {
        guard let symbol = symbols?.maybeResolve(identifier: identifier) else {
            return nil
        }
        guard symbol.type == .array(count: count, elementType: .u8) || symbol.type == .array(count: count, elementType: .arithmeticType(.immutableInt(.u8))) else {
            return nil
        }
        let baseAddr = addressOfSymbol(symbol)
        var arr: [UInt8] = []
        for i in 0..<count {
            let addr = baseAddr &+ UInt(i*memoryLayoutStrategy.sizeof(type: .u8))
            let value = vm.loadb(address: addr)
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
        let baseAddr = addressOfSymbol(symbol)
        var arr: [UInt16] = []
        for i in 0..<count {
            let addr = baseAddr &+ UInt(i*memoryLayoutStrategy.sizeof(type: .u16))
            let word = vm.loadw(address: addr)
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
        
        let baseAddr = addressOfSymbol(symbol)
        var arr: [UInt8] = []
        for i in 0..<count {
            let addr = baseAddr &+ UInt(i*memoryLayoutStrategy.sizeof(type: .u8))
            let value = vm.loadb(address: addr)
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
        
        let kSliceBaseAddressOffset = 0
        let kSliceCountOffset = 1
        
        let baseAddr = addressOfSymbol(symbol)
        let payloadAddr = vm.loadp(address: baseAddr &+ UInt(kSliceBaseAddressOffset))
        let count = UInt(vm.loadw(address: baseAddr &+ UInt(kSliceCountOffset)))
        
        var arr: [UInt8] = []
        for i in 0..<count {
            let addr = payloadAddr + i
            let value = vm.loadb(address: addr)
            arr.append(value)
        }
        
        let str = String(bytes: arr, encoding: .utf8)
        return str
    }
}
