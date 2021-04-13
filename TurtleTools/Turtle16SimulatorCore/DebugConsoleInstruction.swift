//
//  DebugConsoleInstruction.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/13/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

public enum DebugConsoleInstruction: Equatable {
    case help(DebugConsoleHelpTopic?), quit, reset, step(count: Int), reg, readMemory(base: UInt16, count: UInt), writeMemory(base: UInt16, words: [UInt16])
}
