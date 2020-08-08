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
}
