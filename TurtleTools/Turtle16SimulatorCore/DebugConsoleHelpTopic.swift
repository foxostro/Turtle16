//
//  DebugConsoleHelpTopic.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/12/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

public enum DebugConsoleHelpTopic: Equatable, CaseIterable {
    case help, quit, reset, step, reg, readMemory, writeMemory
    
    public var name: String {
        switch self {
        case .help:        return "help"
        case .quit:        return "quit"
        case .reset:       return "reset"
        case .step:        return "step"
        case .reg:         return "reg"
        case .readMemory:  return "x"
        case .writeMemory: return "writemem"
        }
    }
    
    public var shortHelp: String {
        switch self {
        case .help:
            return "Show a list of all debugger commands, or give details about a specific command."
        
        case .quit:
            return "Quit the debugger."
            
        case .reset:
            return "Reset the computer."
            
        case .step:
            return "Single step the simulation, executing for one or more clock cycles."
            
        case .reg:
            return "Show CPU register contents."
            
        case .readMemory:
            return "Read from memory."
            
        case .writeMemory:
            return "Write to memory."
        }
    }
    
    public var longHelp: String {
        switch self {
        case .help:
            return """
\(shortHelp)

Syntax: help [<topic>]

"""
        
        case .quit:
            return """
\(shortHelp)

Syntax: quit

"""
            
        case .reset:
            return """
\(shortHelp)

Syntax: reset

"""
            
        case .step:
            return """
\(shortHelp)

Syntax: step [<cycle-count>]

"""
            
        case .reg:
            return """
\(shortHelp)

Syntax: reg

"""
            
        case .readMemory:
            return """
\(shortHelp)

Syntax: x [/<count>] <address>

"""
            
        case .writeMemory:
            return """
\(shortHelp)

Syntax: writemem <address> <word> [<word>...]

"""
        }
    }
}
