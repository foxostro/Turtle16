//
//  DebugConsoleInstruction.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/13/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

public enum DebugConsoleInstruction: Equatable {
    case help(DebugConsoleHelpTopic?)
    case quit
    case reset
    case run
    case step(count: Int)
    case reg
    case info(String?)
    case readMemory(base: UInt16, count: UInt)
    case writeMemory(base: UInt16, words: [UInt16])
    case readInstructions(base: UInt16, count: UInt)
    case writeInstructions(base: UInt16, words: [UInt16])
    case loadProgram(URL)
    case loadData(URL)
}
