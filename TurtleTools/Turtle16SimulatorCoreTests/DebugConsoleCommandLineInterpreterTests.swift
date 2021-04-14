//
//  DebugConsoleCommandLineInterpreterTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 4/12/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
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
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
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
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
r0: 0x0000\tr4: 0x0004
r1: 0x0001\tr5: 0x0005
r2: 0x0002\tr6: 0x0006
r3: 0x0003\tr7: 0x0007
pc: 0xabcd

""")
    }
    
    func testPrintInfoOnNil() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .info(nil))
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Show detailed information for a specified device.

Devices:
\tcpu -- Show detailed information on the state of the CPU.

Syntax: info cpu

""")
    }
    
    func testPrintInfoOnUnrecognizedDevice() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .info("asdf"))
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
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
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
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
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
0x1000: 0xaaaa 0xbbbb

""")
    }
    
    func testHelp() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.none))
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Debugger commands:
\thelp      -- Show a list of all debugger commands, or give details about a specific command.
\tquit      -- Quit the debugger.
\treset     -- Reset the computer.
\tstep      -- Single step the simulation, executing for one or more clock cycles.
\treg       -- Show CPU register contents.
\tinfo      -- Show detailed information for a specified device.
\tx         -- Read from memory.
\twritemem  -- Write to memory.
\txi        -- Read from instruction memory.
\twritememi -- Write to instruction memory.
\tload      -- Load a program from file.

For more information on any command, type `help <command-name>'.

""")
    }
    
    func testHelpHelp() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.help))
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Show a list of all debugger commands, or give details about a specific command.

Syntax: help [<topic>]

""")
    }
    
    func testHelpQuit() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.quit))
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Quit the debugger.

Syntax: quit

""")
    }
    
    func testHelpReset() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.reset))
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Reset the computer.

Syntax: reset

""")
    }
    
    func testHelpStep() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.step))
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Single step the simulation, executing for one or more clock cycles.

Syntax: step [<cycle-count>]

""")
    }
    
    func testHelpInfo() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.info))
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
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
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Show CPU register contents.

Syntax: reg

""")
    }
    
    func testHelpReadMemory() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.readMemory))
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Read from memory.

Syntax: x [/<count>] <address>

""")
    }
    
    func testHelpWriteMemory() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.writeMemory))
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Write to memory.

Syntax: writemem <address> <word> [<word>...]

""")
    }
    
    func testHelpLoad() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.load))
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Load a program from file.

Syntax: load <path>

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
    
    func testReadInstructions() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.reset()
        computer.instructions[0] = ~UInt16(0)
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .readInstructions(base: 0, count: 2))
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
0x0000: 0xffff 0x0000

""")
    }
    
    func testWriteInstructions() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.reset()
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .writeInstructions(base: 0x1000, words: [0xaaaa, 0xbbbb]))
        XCTAssertEqual(computer.instructions[0x1000], 0xaaaa)
        XCTAssertEqual(computer.instructions[0x1001], 0xbbbb)
    }
    
    func testHelpReadInstructions() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.readInstructions))
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Read from instruction memory.

Syntax: xi [/<count>] <address>

""")
    }
    
    func testHelpWriteInstructions() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.writeInstructions))
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Write to instruction memory.

Syntax: writememi <address> <word> [<word>...]

""")
    }
    
    func testContinue() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.reset()
        let hltOpcode: UInt = 1
        let ins: UInt16 = UInt16(hltOpcode << 11)
        computer.instructions = [ins]
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .run)
        XCTAssertTrue(computer.cpu.isHalted)
    }
    
    func testInputFibonacciProgramAndRunIt() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .reset,
            .writeInstructions(base: 0, words: [
                0b0010000000000000, // LI r0, #0
                0b0010000100000001, // LI r1, #1
                0b0010011100000000, // LI r7, #0
                0b0011101000000100, // ADD r2, r0, r1
                0b0111000000100000, // ADDI r0, r1, #0
                0b0111011111100001, // ADDI r7, r7, #1
                0b0111000101000000, // ADDI r1, r2, #0
                0b0110100011101001, // CMPI r7, #9
                0b1101011111111001, // BLT #-7
                0b0000100000000000, // HLT
            ]),
            .run,
            .info("cpu")
        ])
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
isHalted: true
isResetting: false

r0: 0x0022\tr4: 0x0000
r1: 0x0037\tr5: 0x0000
r2: 0x0037\tr6: 0x0000
r3: 0x0000\tr7: 0x0009
pc: 0x000d

""")
    }
    
    func testFailToLoadProgramBecauseFileDoesNotExist() throws {
        let url = URL(fileURLWithPath: "doesnotexistdoesnotexistdoesnotexistdoesnotexist")
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .load(url)
        ])
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
failed to load file: `doesnotexistdoesnotexistdoesnotexistdoesnotexist'

""")
    }
    
    func testLoadFibonacciProgramFromFileAndRunIt() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .reset,
            .load(url),
            .run,
            .info("cpu")
        ])
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
isHalted: true
isResetting: false

r0: 0x0022\tr4: 0x0000
r1: 0x0037\tr5: 0x0000
r2: 0x0037\tr6: 0x0000
r3: 0x0000\tr7: 0x0009
pc: 0x000d

""")
    }
}
