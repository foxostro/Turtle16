//
//  ComputerExtensions.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/6/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//


import SnapCore
import TurtleSimulatorCore

extension Computer {    
    public var stackPointer: Int {
        let stackPointerHi = Int(dataRAM.load(from: Int(CrackleToTurtleMachineCodeCompiler.kStackPointerAddressHi)))
        let stackPointerLo = Int(dataRAM.load(from: Int(CrackleToTurtleMachineCodeCompiler.kStackPointerAddressLo)))
        let stackPointer = (stackPointerHi << 8) + stackPointerLo
        return stackPointer
    }
    
    public func stack(at index: Int) -> UInt8 {
        let address = UInt16(stackPointer) + UInt16(index)
        return dataRAM.load(from: Int(address))
    }
    
    public func stack16(at index: Int) -> UInt16 {
        let hi = stack(at: index+0)
        let lo = stack(at: index+1)
        let result = UInt16(hi)<<8 + UInt16(lo)
        return result
    }
    
    public var framePointer: Int {
        let framePointerHi = Int(dataRAM.load(from: Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressHi)))
        let framePointerLo = Int(dataRAM.load(from: Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressLo)))
        let framePointer = (framePointerHi << 8) + framePointerLo
        return framePointer
    }
    
    public func lookupSymbol(_ identifier: String) -> Symbol? {
        guard let info = (programDebugInfo as? SnapDebugInfo) else {
            return nil
        }
        let pc = Int(cpuState.pc.value)
        return info.lookupSymbol(pc: pc, identifier: identifier)
    }
    
    public func loadSymbolBool(_ identifier: String) -> Bool? {
        guard let symbol = lookupSymbol(identifier) else {
            return nil
        }
        assert(symbol.type == .bool || symbol.type == .constBool)
        let value = dataRAM.load(from: symbol.offset)
        return value == 0 ? false : true
    }
    
    public func loadSymbolU8(_ identifier: String) -> UInt8? {
        guard let symbol = lookupSymbol(identifier) else {
            return nil
        }
        assert(symbol.type == .u8 || symbol.type == .constU8)
        let value = dataRAM.load(from: symbol.offset)
        return value
    }
    
    public func loadSymbolU16(_ identifier: String) -> UInt16? {
        guard let symbol = lookupSymbol(identifier) else {
            return nil
        }
        assert(symbol.type == .u16 || symbol.type == .constU16)
        let value = dataRAM.load16(from: symbol.offset)
        return value
    }
    
    public func loadSymbolArrayOfU8(_ count: Int, _ identifier: String) -> [UInt8]? {
        guard let symbol = lookupSymbol(identifier) else {
            return nil
        }
        assert(symbol.type == .array(count: count, elementType: .u8) || symbol.type == .array(count: count, elementType: .constU8))
        var arr: [UInt8] = []
        for i in 0..<count {
            arr.append(dataRAM.load(from: symbol.offset + i*SymbolType.u8.sizeof))
        }
        return arr
    }
    
    public func loadSymbolArrayOfU16(_ count: Int, _ identifier: String) -> [UInt16]? {
        guard let symbol = lookupSymbol(identifier) else {
            return nil
        }
        assert(symbol.type == .array(count: count, elementType: .u16) || symbol.type == .array(count: count, elementType: .constU16))
        var arr: [UInt16] = []
        for i in 0..<count {
            arr.append(dataRAM.load16(from: symbol.offset + i*SymbolType.u16.sizeof))
        }
        return arr
    }
}
