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
        let stackPointerHi = Int(dataRAM.load(from: Int(YertleToTurtleMachineCodeCompiler.kStackPointerAddressHi)))
        let stackPointerLo = Int(dataRAM.load(from: Int(YertleToTurtleMachineCodeCompiler.kStackPointerAddressLo)))
        let stackPointer = (stackPointerHi << 8) + stackPointerLo
        return stackPointer
    }
    
    public var stackTop: UInt8 {
        return dataRAM.load(from: stackPointer)
    }
}
