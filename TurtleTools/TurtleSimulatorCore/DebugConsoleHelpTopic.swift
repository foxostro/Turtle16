//
//  DebugConsoleHelpTopic.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 4/12/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation

public enum DebugConsoleHelpTopic: Equatable, CaseIterable {
    case help, quit, reset, step, reg, info, readMemory, writeMemory, readInstructions,
         writeInstructions, load, save, disassemble

    public var name: String {
        switch self {
        case .help: "help"
        case .quit: "quit"
        case .reset: "reset"
        case .step: "step"
        case .reg: "reg"
        case .info: "info"
        case .readMemory: "x"
        case .writeMemory: "writemem"
        case .readInstructions: "xi"
        case .writeInstructions: "writememi"
        case .load: "load"
        case .save: "save"
        case .disassemble: "disassemble"
        }
    }

    public var shortHelp: String {
        switch self {
        case .help:
            "Show a list of all debugger commands, or give details about a specific command."

        case .quit:
            "Quit the debugger."

        case .reset:
            "Reset the computer."

        case .step:
            "Single step the simulation, executing for one or more clock cycles."

        case .reg:
            "Show CPU register contents."

        case .info:
            "Show detailed information for a specified device."

        case .readMemory:
            "Read from memory."

        case .writeMemory:
            "Write to memory."

        case .readInstructions:
            "Read from instruction memory."

        case .writeInstructions:
            "Write to instruction memory."

        case .load:
            "Load contents of memory from file."

        case .save:
            "Save contents of memory to file."

        case .disassemble:
            "Disassembles a specified region of instruction memory."
        }
    }

    public var longHelp: String {
        switch self {
        case .help:
            """
            \(shortHelp)

            Syntax: help [<topic>]

            """

        case .quit:
            """
            \(shortHelp)

            Syntax: quit

            """

        case .reset:
            """
            \(shortHelp)

            Syntax: reset

            """

        case .step:
            """
            \(shortHelp)

            Syntax: step [<cycle-count>]

            """

        case .reg:
            """
            \(shortHelp)

            Syntax: reg

            """

        case .info:
            """
            \(shortHelp)

            Devices:
            \tcpu -- Show detailed information on the state of the CPU.

            Syntax: info cpu

            """

        case .readMemory:
            """
            \(shortHelp)

            Syntax: x [/<count>] <address>

            """

        case .writeMemory:
            """
            \(shortHelp)

            Syntax: writemem <address> <word> [<word>...]

            """

        case .readInstructions:
            """
            \(shortHelp)

            Syntax: xi [/<count>] <address>

            """

        case .writeInstructions:
            """
            \(shortHelp)

            Syntax: writememi <address> <word> [<word>...]

            """

        case .load:
            """
            \(shortHelp)

            Destination:
            \tprogram          -- Instruction memory
            \tprogram_lo       -- Instruction memory, low byte (U57)
            \tprogram_hi       -- Instruction memory, high byte (U58)
            \tdata             -- RAM
            \tOpcodeDecodeROM1 -- Opcode Decode ROM 1 (U37)
            \tOpcodeDecodeROM2 -- Opcode Decode ROM 2 (U38)
            \tOpcodeDecodeROM3 -- Opcode Decode ROM 3 (U39)

            Syntax: load <destination> "<path>"

            """

        case .save:
            """
            \(shortHelp)

            Destination:
            \tprogram          -- Instruction memory
            \tprogram_lo       -- Instruction memory, low byte (U57)
            \tprogram_hi       -- Instruction memory, high byte (U58)
            \tdata             -- RAM
            \tOpcodeDecodeROM1 -- Opcode Decode ROM 1 (U37)
            \tOpcodeDecodeROM2 -- Opcode Decode ROM 2 (U38)
            \tOpcodeDecodeROM3 -- Opcode Decode ROM 3 (U39)

            Syntax: save <destination> "<path>"

            """

        case .disassemble:
            """
            \(shortHelp)

            Syntax: disassemble [<base-address>] [<count>]

            """
        }
    }
}
