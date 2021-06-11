//
//  DebugConsoleInstruction.swift
//  Turtle16SimulatorCore
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
        case .help: return "Help"
        case .quit: return "Quit"
        case .reset: return "Reset"
        case .run: return "Run"
        case .step: return "Step"
        case .reg: return "Reg"
        case .info: return "Info"
        case .readMemory: return "Read Memory"
        case .writeMemory: return "Write Memory"
        case .readInstructions: return "Read Instructions"
        case .writeInstructions: return "Write Instructions"
        case .load: return "Load"
        case .save: return "Save"
        case .disassemble: return "Disassemble"
        }
    }
    
    public var undoable: Bool {
        switch self {
        case .help: return false
        case .quit: return false
        case .reset: return true
        case .run: return true
        case .step: return true
        case .reg: return false
        case .info: return false
        case .readMemory: return false
        case .writeMemory: return true
        case .readInstructions: return false
        case .writeInstructions: return true
        case .load: return true
        case .save: return false
        case .disassemble: return false
        }
    }
}
