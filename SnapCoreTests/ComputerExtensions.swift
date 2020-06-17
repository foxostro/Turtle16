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
    public var expressionStackPointer: Int {
        let stackPointerHi = Int(YertleToTurtleMachineCodeCompiler.kExpressionStackPointerHi)
        let stackPointerLo = Int(dataRAM.load(from: Int(YertleToTurtleMachineCodeCompiler.kExpressionStackPointerAddress)))
        let stackPointer = (stackPointerHi << 8) + stackPointerLo
        return stackPointer
    }
    
    public func expressionStack(_ index: Int) -> UInt8 {
        let address = UInt16(expressionStackPointer) + UInt16(index)
        return dataRAM.load(from: Int(address))
    }
    
    public var stackPointer: Int {
        let stackPointerHi = Int(dataRAM.load(from: Int(YertleToTurtleMachineCodeCompiler.kStackPointerAddressHi)))
        let stackPointerLo = Int(dataRAM.load(from: Int(YertleToTurtleMachineCodeCompiler.kStackPointerAddressLo)))
        let stackPointer = (stackPointerHi << 8) + stackPointerLo
        return stackPointer
    }
    
    public var stackTop: UInt8 {
        return dataRAM.load(from: stackPointer)
    }
    
    public var framePointer: Int {
        let framePointerHi = Int(dataRAM.load(from: Int(YertleToTurtleMachineCodeCompiler.kFramePointerAddressHi)))
        let framePointerLo = Int(dataRAM.load(from: Int(YertleToTurtleMachineCodeCompiler.kFramePointerAddressLo)))
        let framePointer = (framePointerHi << 8) + framePointerLo
        return framePointer
    }
}
