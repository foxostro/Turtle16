//
//  DebugConsoleCommandLineInterpreterTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 4/12/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class DebugConsoleCommandLineInterpreterTests: XCTestCase {
    func testQuit() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .quit)
        XCTAssertTrue(interpreter.shouldQuit)
    }
    
    func testReset() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.reset()
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        computer.cpu.pc = 1000
        interpreter.runOne(instruction: .reset)
        XCTAssertEqual(computer.cpu.pc, 0)
    }
    
    func testStepOnce() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.reset()
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .step(count: 1))
        XCTAssertEqual(computer.cpu.pc, 1)
    }
    
    func testStepTwice() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.reset()
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .step(count: 2))
        XCTAssertEqual(computer.cpu.pc, 2)
    }
    
    func testStepUntilHalted() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.reset()
        let hltOpcode: UInt = 1
        let ins: UInt16 = UInt16(hltOpcode << 11)
        computer.instructions = [ins]
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .step(count: 4))
        XCTAssertTrue(computer.cpu.isHalted)
    }
    
    func testStepWhileHalted() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.reset()
        let hltOpcode: UInt = 1
        let ins: UInt16 = UInt16(hltOpcode << 11)
        computer.instructions = [ins]
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .step(count: 5))
        XCTAssertEqual(interpreter.stdout as! String, """
cpu is halted

""")
    }
    
    func testPrintRegisters() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.setRegister(0, 0x0000)
        computer.setRegister(1, 0x0001)
        computer.setRegister(2, 0x0002)
        computer.setRegister(3, 0x0003)
        computer.setRegister(4, 0x0004)
        computer.setRegister(5, 0x0005)
        computer.setRegister(6, 0x0006)
        computer.setRegister(7, 0x0007)
        computer.pc = 0xabcd
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .reg)
        XCTAssertEqual(interpreter.stdout as! String, """
r0: 0x0000\tr4: 0x0004
r1: 0x0001\tr5: 0x0005
r2: 0x0002\tr6: 0x0006
r3: 0x0003\tr7: 0x0007
pc: 0xabcd

""")
    }
    
    func testPrintInfoOnUnrecognizedDevice() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .info("asdf"))
        XCTAssertEqual(interpreter.stdout as! String, """
Show detailed information for a specified device.

Devices:
\tcpu -- Show detailed information on the state of the CPU.

Syntax: info cpu

""")
    }
    
    func testPrintInfoOnCPU() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.setRegister(0, 0x0000)
        computer.setRegister(1, 0x0001)
        computer.setRegister(2, 0x0002)
        computer.setRegister(3, 0x0003)
        computer.setRegister(4, 0x0004)
        computer.setRegister(5, 0x0005)
        computer.setRegister(6, 0x0006)
        computer.setRegister(7, 0x0007)
        computer.pc = 0xabcd
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .info("cpu"))
        XCTAssertEqual(interpreter.stdout as! String, """
isHalted: false
isResetting: true

r0: 0x0000\tr4: 0x0004
r1: 0x0001\tr5: 0x0005
r2: 0x0002\tr6: 0x0006
r3: 0x0003\tr7: 0x0007
pc: 0xabcd

""")
    }
    
    func testReadMemory() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.reset()
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        computer.ram[0x1000] = 0xaaaa
        computer.ram[0x1001] = 0xbbbb
        interpreter.runOne(instruction: .readMemory(base: 0x1000, count: 2))
        XCTAssertEqual(interpreter.stdout as! String, """
0x1000: 0xaaaa 0xbbbb

""")
    }
    
    func testHelp() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.none))
        XCTAssertEqual(interpreter.stdout as! String, """
Debugger commands:
\thelp     -- Show a list of all debugger commands, or give details about a specific command.
\tquit     -- Quit the debugger.
\treset    -- Reset the computer.
\tstep     -- Single step the simulation, executing for one or more clock cycles.
\treg      -- Show CPU register contents.
\tinfo     -- Show detailed information for a specified device.
\tx        -- Read from memory.
\twritemem -- Write to memory.

For more information on any command, type `help <command-name>'.

""")
    }
    
    func testHelpHelp() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.help))
        XCTAssertEqual(interpreter.stdout as! String, """
Show a list of all debugger commands, or give details about a specific command.

Syntax: help [<topic>]

""")
    }
    
    func testHelpQuit() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.quit))
        XCTAssertEqual(interpreter.stdout as! String, """
Quit the debugger.

Syntax: quit

""")
    }
    
    func testHelpReset() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.reset))
        XCTAssertEqual(interpreter.stdout as! String, """
Reset the computer.

Syntax: reset

""")
    }
    
    func testHelpStep() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.step))
        XCTAssertEqual(interpreter.stdout as! String, """
Single step the simulation, executing for one or more clock cycles.

Syntax: step [<cycle-count>]

""")
    }
    
    func testHelpInfo() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.info))
        XCTAssertEqual(interpreter.stdout as! String, """
Show detailed information for a specified device.

Devices:
\tcpu -- Show detailed information on the state of the CPU.

Syntax: info cpu

""")
    }
    
    func testHelpReg() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.reg))
        XCTAssertEqual(interpreter.stdout as! String, """
Show CPU register contents.

Syntax: reg

""")
    }
    
    func testHelpReadMemory() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.readMemory))
        XCTAssertEqual(interpreter.stdout as! String, """
Read from memory.

Syntax: x [/<count>] <address>

""")
    }
    
    func testHelpWriteMemory() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.writeMemory))
        XCTAssertEqual(interpreter.stdout as! String, """
Write to memory.

Syntax: writemem <address> <word> [<word>...]

""")
    }
    
    func testWriteMemory() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.reset()
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .writeMemory(base: 0x1000, words: [0xaaaa, 0xbbbb]))
        XCTAssertEqual(computer.ram[0x1000], 0xaaaa)
        XCTAssertEqual(computer.ram[0x1001], 0xbbbb)
    }
}
