//
//  DebugConsoleInstruction.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 4/13/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

public enum DebugConsoleInstruction: Equatable {
    public enum DisassembleMode: Equatable {
        case unspecified
        case base(UInt16)
        case baseCount(UInt16, UInt)
        case identifier(String)
        case identifierCount(String, UInt)
    }

    case help(DebugConsoleHelpTopic?)
    case quit
    case reset(type: ResetType)
    case run
    case step(count: Int)
    case reg
    case info(String?)
    case readMemory(base: UInt16, count: UInt)
    case writeMemory(base: UInt16, words: [UInt16])
    case readInstructions(base: UInt16, count: UInt)
    case writeInstructions(base: UInt16, words: [UInt16])
    case load(String, URL)
    case save(String, URL)
    case disassemble(DisassembleMode)

    public var actionName: String {
        switch self {
        case .help: "Help"
        case .quit: "Quit"
        case .reset: "Reset"
        case .run: "Run"
        case .step: "Step"
        case .reg: "Reg"
        case .info: "Info"
        case .readMemory: "Read Memory"
        case .writeMemory: "Write Memory"
        case .readInstructions: "Read Instructions"
        case .writeInstructions: "Write Instructions"
        case .load: "Load"
        case .save: "Save"
        case .disassemble: "Disassemble"
        }
    }

    public var undoable: Bool {
        switch self {
        case .help: false
        case .quit: false
        case .reset: true
        case .run: true
        case .step: true
        case .reg: false
        case .info: false
        case .readMemory: false
        case .writeMemory: true
        case .readInstructions: false
        case .writeInstructions: true
        case .load: true
        case .save: false
        case .disassemble: false
        }
    }
}
