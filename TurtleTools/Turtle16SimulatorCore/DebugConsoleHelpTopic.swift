//
//  DebugConsoleHelpTopic.swift
//  Turtle16SimulatorCore
//
//  Created by Andrew Fox on 4/12/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

public enum DebugConsoleHelpTopic: Equatable, CaseIterable {
    case help, quit, reset, step, reg, info, readMemory, writeMemory, readInstructions, writeInstructions, load, save
    
    public var name: String {
        switch self {
        case .help:              return "help"
        case .quit:              return "quit"
        case .reset:             return "reset"
        case .step:              return "step"
        case .reg:               return "reg"
        case .info:              return "info"
        case .readMemory:        return "x"
        case .writeMemory:       return "writemem"
        case .readInstructions:  return "xi"
        case .writeInstructions: return "writememi"
        case .load:              return "load"
        case .save:              return "save"
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
            
        case .info:
            return "Show detailed information for a specified device."
            
        case .readMemory:
            return "Read from memory."
            
        case .writeMemory:
            return "Write to memory."
            
        case .readInstructions:
            return "Read from instruction memory."
            
        case .writeInstructions:
            return "Write to instruction memory."
            
        case .load:
            return "Load contents of memory from file."
            
        case .save:
            return "Save contents of memory to file."
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
            
        case .info:
            return """
\(shortHelp)

Devices:
\tcpu -- Show detailed information on the state of the CPU.

Syntax: info cpu

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
        
        case .readInstructions:
            return """
\(shortHelp)

Syntax: xi [/<count>] <address>

"""
            
        case .writeInstructions:
            return """
\(shortHelp)

Syntax: writememi <address> <word> [<word>...]

"""
        
        case .load:
            return """
\(shortHelp)

Destination:
\tprogram          -- Instruction memory
\tdata             -- RAM
\tOpcodeDecodeROM1 -- Opcode Decode ROM 1 (U37)
\tOpcodeDecodeROM2 -- Opcode Decode ROM 2 (U38)
\tOpcodeDecodeROM3 -- Opcode Decode ROM 3 (U39)

Syntax: load <destination> "<path>"

"""
            
        case .save:
            return """
\(shortHelp)

Destination:
\tprogram          -- Instruction memory
\tdata             -- RAM
\tOpcodeDecodeROM1 -- Opcode Decode ROM 1 (U37)
\tOpcodeDecodeROM2 -- Opcode Decode ROM 2 (U38)
\tOpcodeDecodeROM3 -- Opcode Decode ROM 3 (U39)

Syntax: save <destination> "<path>"

"""
        }
    }
}
