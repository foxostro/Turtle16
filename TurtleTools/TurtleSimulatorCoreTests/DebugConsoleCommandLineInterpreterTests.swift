//
//  DebugConsoleCommandLineInterpreterTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 4/12/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleSimulatorCore

class DebugConsoleCommandLineInterpreterTests: XCTestCase {
    func testQuit() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .quit)
        XCTAssertTrue(interpreter.shouldQuit)
    }
    
    func testResetSoft() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.reset()
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        computer.cpu.pc = 1000
        interpreter.runOne(instruction: .reset(type: .soft))
        XCTAssertEqual(computer.cpu.pc, 0)
    }
    
    func testResetHard() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        computer.reset()
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        computer.cpu.pc = 1000
        computer.setRegister(0, 0xffff)
        interpreter.runOne(instruction: .reset(type: .hard))
        XCTAssertEqual(computer.cpu.pc, 0)
        XCTAssertEqual(computer.cpu.getRegister(0), 0)
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
isStalling: false
isHalted: false
isResetting: true

IF\t0000\tins: 0000, pc: 0000
ID\t0000\tstall: 0, ctl_EX: 1fffff, a: 0000, b: 0000, ins: 0000
EX\t0000\tnczvjah, y: 0000, storeOp: 0000, ctl: 1fffff, selC: 0
MEM\t0000\ty: 0000, storeOp: 0000, selC: 0, ctl: 1fffff
WB\t0000\tc: 0000, wrl: 1, wrh: 1, wben: 1

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
\thelp        -- Show a list of all debugger commands, or give details about a specific command.
\tquit        -- Quit the debugger.
\treset       -- Reset the computer.
\tstep        -- Single step the simulation, executing for one or more clock cycles.
\treg         -- Show CPU register contents.
\tinfo        -- Show detailed information for a specified device.
\tx           -- Read from memory.
\twritemem    -- Write to memory.
\txi          -- Read from instruction memory.
\twritememi   -- Write to instruction memory.
\tload        -- Load contents of memory from file.
\tsave        -- Save contents of memory to file.
\tdisassemble -- Disassembles a specified region of instruction memory.

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
Load contents of memory from file.

Destination:
\tprogram          -- Instruction memory
\tprogram_lo       -- Instruction memory, low byte (U57)
\tprogram_hi       -- Instruction memory, high byte (U58)
\tdata             -- RAM
\tOpcodeDecodeROM1 -- Opcode Decode ROM 1 (U37)
\tOpcodeDecodeROM2 -- Opcode Decode ROM 2 (U38)
\tOpcodeDecodeROM3 -- Opcode Decode ROM 3 (U39)

Syntax: load <destination> "<path>"

""")
    }
    
    func testHelpSave() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.save))
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Save contents of memory to file.

Destination:
\tprogram          -- Instruction memory
\tprogram_lo       -- Instruction memory, low byte (U57)
\tprogram_hi       -- Instruction memory, high byte (U58)
\tdata             -- RAM
\tOpcodeDecodeROM1 -- Opcode Decode ROM 1 (U37)
\tOpcodeDecodeROM2 -- Opcode Decode ROM 2 (U38)
\tOpcodeDecodeROM3 -- Opcode Decode ROM 3 (U39)

Syntax: save <destination> "<path>"

""")
    }
    
    func testHelpDisassemble() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .help(.disassemble))
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Disassembles a specified region of instruction memory.

Syntax: disassemble [<base-address>] [<count>]

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
        computer.instructions = [
            0b0000000000000000, // NOP
            ins
        ]
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.runOne(instruction: .run)
        XCTAssertTrue(computer.cpu.isHalted)
    }
    
    func testInputFibonacciProgramAndRunIt() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .reset(type: .soft),
            .writeInstructions(base: 0, words: [
                0b0000000000000000, // NOP
                0b0010000000000000, // LI r0, 0
                0b0010000100000001, // LI r1, 1
                0b0010011100000000, // LI r7, 0
                0b0011101000000100, // ADD r2, r0, r1
                0b0111000000100000, // ADDI r0, r1, 0
                0b0111011111100001, // ADDI r7, r7, 1
                0b0111000101000000, // ADDI r1, r2, 0
                0b0110100011101001, // CMPI r7, 9
                0b1101011111111001, // BLT -7
                0b0000100000000000, // HLT
            ]),
            .run,
            .info("cpu")
        ])
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
cpu is halted
isStalling: false
isHalted: true
isResetting: false

IF\t000c\tins: 0000, pc: 000d
ID\t000b\tstall: 0, ctl_EX: 1fffff, a: 0022, b: 0022, ins: 0000
EX\t000a\tNczvjaH, y: ffff, storeOp: 0000, ctl: 1ffffe, selC: 0
MEM\t0009\ty: ffff, storeOp: 0000, selC: 7, ctl: 1fffff
WB\t0000\tc: 0000, wrl: 1, wrh: 1, wben: 1

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
            .load("program", url)
        ])
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
failed to load file: `doesnotexistdoesnotexistdoesnotexistdoesnotexist'
The file doesn’t exist.

""")
    }
    
    func testLoadFibonacciProgramFromFileAndRunIt() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .reset(type: .soft),
            .load("program", url),
            .run,
            .info("cpu")
        ])
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Wrote 65536 words to instruction memory.
cpu is halted
isStalling: false
isHalted: true
isResetting: false

IF\t000c\tins: 0000, pc: 000d
ID\t000b\tstall: 0, ctl_EX: 1fffff, a: 0022, b: 0022, ins: 0000
EX\t000a\tNczvjaH, y: ffff, storeOp: 0000, ctl: 1ffffe, selC: 0
MEM\t0009\ty: ffff, storeOp: 0000, selC: 7, ctl: 1fffff
WB\t0000\tc: 0000, wrl: 1, wrh: 1, wben: 1

r0: 0x0022\tr4: 0x0000
r1: 0x0037\tr5: 0x0000
r2: 0x0037\tr6: 0x0000
r3: 0x0000\tr7: 0x0009
pc: 0x000d


""")
    }
    
    func testLoadProgramHi() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .reset(type: .soft),
            .load("program_hi", url)
        ])
        let gold = try! Data(contentsOf: url)
        for i in 0..<min(gold.count, computer.instructions.count) {
            let hi = UInt8((computer.instructions[i] & 0xff00) >> 8)
            XCTAssertEqual(hi, gold[i])
        }
    }
    
    func testLoadProgramLo() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .reset(type: .soft),
            .load("program_lo", url)
        ])
        let gold = try! Data(contentsOf: url)
        for i in 0..<min(gold.count, computer.instructions.count) {
            let hi = UInt8(computer.instructions[i] & 0x00ff)
            XCTAssertEqual(hi, gold[i])
        }
    }
    
    func testLoadDataFromFile() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .load("data", url)
        ])
        XCTAssertEqual(computer.ram[1], 0x2000)
    }
    
    func testFailToLoadFromInvalidDestination() throws {
        let url = URL(fileURLWithPath: "doesnotexistdoesnotexistdoesnotexistdoesnotexist")
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .load("asdf", url)
        ])
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Load contents of memory from file.

Destination:
\tprogram          -- Instruction memory
\tprogram_lo       -- Instruction memory, low byte (U57)
\tprogram_hi       -- Instruction memory, high byte (U58)
\tdata             -- RAM
\tOpcodeDecodeROM1 -- Opcode Decode ROM 1 (U37)
\tOpcodeDecodeROM2 -- Opcode Decode ROM 2 (U38)
\tOpcodeDecodeROM3 -- Opcode Decode ROM 3 (U39)

Syntax: load <destination> "<path>"

""")
    }
    
    func testLoadDataFromFileForOpcodeDecodeROM1() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .load("OpcodeDecodeROM1", url)
        ])
        XCTAssertEqual(computer.decoder.decode(2) & 0xff, 0x20)
    }
    
    func testLoadDataFromFileForOpcodeDecodeROM2() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .load("OpcodeDecodeROM2", url)
        ])
        XCTAssertEqual((computer.decoder.decode(2)>>8) & 0xff, 0x20)
    }
    
    func testLoadDataFromFileForOpcodeDecodeROM3() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .load("OpcodeDecodeROM3", url)
        ])
        XCTAssertEqual((computer.decoder.decode(2)>>16) & 0xff, 0x20)
    }
    
    func testSaveProgram() throws {
        let tempUrl = NSURL.fileURL(withPathComponents: [NSTemporaryDirectory(), NSUUID().uuidString])!
        defer {
            try? FileManager.default.removeItem(at: tempUrl)
        }
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .reset(type: .soft),
            .load("program", url),
            .save("program", tempUrl)
        ])
        let data1 = try! Data(contentsOf: url)
        guard let data2 = try? Data(contentsOf: tempUrl) else {
            XCTFail()
            return
        }
        XCTAssertEqual(data1, data2.subdata(in: 0..<data1.count))
        XCTAssertEqual(data2.subdata(in: data1.count..<data2.count), Data(count: data2.count - data1.count))
    }
    
    func testSaveProgramHi() throws {
        let tempUrl = NSURL.fileURL(withPathComponents: [NSTemporaryDirectory(), NSUUID().uuidString])!
        defer {
            try? FileManager.default.removeItem(at: tempUrl)
        }
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .reset(type: .soft),
            .load("program", url),
            .save("program_hi", tempUrl)
        ])
        let data1 = try! Data(contentsOf: url)
        guard let data2 = try? Data(contentsOf: tempUrl) else {
            XCTFail()
            return
        }
        for i in 0..<min(data1.count/2, data2.count) {
            XCTAssertEqual(data1[i*2], data2[i])
        }
    }
    
    func testSaveProgramLo() throws {
        let tempUrl = NSURL.fileURL(withPathComponents: [NSTemporaryDirectory(), NSUUID().uuidString])!
        defer {
            try? FileManager.default.removeItem(at: tempUrl)
        }
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .reset(type: .soft),
            .load("program", url),
            .save("program_lo", tempUrl)
        ])
        let data1 = try! Data(contentsOf: url)
        guard let data2 = try? Data(contentsOf: tempUrl) else {
            XCTFail()
            return
        }
        for i in 0..<min(data1.count/2, data2.count) {
            XCTAssertEqual(data1[i*2+1], data2[i])
        }
    }
    
    func testSaveData() throws {
        let tempUrl = NSURL.fileURL(withPathComponents: [NSTemporaryDirectory(), NSUUID().uuidString])!
        defer {
            try? FileManager.default.removeItem(at: tempUrl)
        }
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .reset(type: .soft),
            .load("data", url),
            .save("data", tempUrl)
        ])
        let data1 = try! Data(contentsOf: url)
        guard let data2 = try? Data(contentsOf: tempUrl) else {
            XCTFail()
            return
        }
        XCTAssertEqual(data1, data2.subdata(in: 0..<data1.count))
        XCTAssertEqual(data2.subdata(in: data1.count..<data2.count), Data(count: data2.count - data1.count))
    }
    
    func testSaveOpcodeDecodeROM1() throws {
        let tempUrl = NSURL.fileURL(withPathComponents: [NSTemporaryDirectory(), NSUUID().uuidString])!
        defer {
            try? FileManager.default.removeItem(at: tempUrl)
        }
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .reset(type: .soft),
            .load("OpcodeDecodeROM1", url),
            .save("OpcodeDecodeROM1", tempUrl)
        ])
        let data1 = try! Data(contentsOf: url)
        guard let data2 = try? Data(contentsOf: tempUrl) else {
            XCTFail()
            return
        }
        XCTAssertEqual(data1, data2.subdata(in: 0..<data1.count))
        XCTAssertEqual(data2.subdata(in: data1.count..<data2.count), Data(count: data2.count - data1.count))
    }
    
    func testSaveOpcodeDecodeROM2() throws {
        let tempUrl = NSURL.fileURL(withPathComponents: [NSTemporaryDirectory(), NSUUID().uuidString])!
        defer {
            try? FileManager.default.removeItem(at: tempUrl)
        }
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .reset(type: .soft),
            .load("OpcodeDecodeROM2", url),
            .save("OpcodeDecodeROM2", tempUrl)
        ])
        let data1 = try! Data(contentsOf: url)
        guard let data2 = try? Data(contentsOf: tempUrl) else {
            XCTFail()
            return
        }
        XCTAssertEqual(data1, data2.subdata(in: 0..<data1.count))
        XCTAssertEqual(data2.subdata(in: data1.count..<data2.count), Data(count: data2.count - data1.count))
    }
    
    func testSaveOpcodeDecodeROM3() throws {
        let tempUrl = NSURL.fileURL(withPathComponents: [NSTemporaryDirectory(), NSUUID().uuidString])!
        defer {
            try? FileManager.default.removeItem(at: tempUrl)
        }
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .reset(type: .soft),
            .load("OpcodeDecodeROM3", url),
            .save("OpcodeDecodeROM3", tempUrl)
        ])
        let data1 = try! Data(contentsOf: url)
        guard let data2 = try? Data(contentsOf: tempUrl) else {
            XCTFail()
            return
        }
        XCTAssertEqual(data1, data2.subdata(in: 0..<data1.count))
        XCTAssertEqual(data2.subdata(in: data1.count..<data2.count), Data(count: data2.count - data1.count))
    }
    
    func testDisassembleWithZeroParameters() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .load("program", url),
            .disassemble(.unspecified)
        ])
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Wrote 65536 words to instruction memory.
0000\t0000\tNOP
0001\t2000\tLI r0, 0
0002\t2101\tLI r1, 1
0003\t2700\tLI r7, 0
0004\t3a04\tL0: ADD r2, r0, r1
0005\t7020\tADDI r0, r1, 0
0006\t77e1\tADDI r7, r7, 1
0007\t7140\tADDI r1, r2, 0
0008\t68e9\tCMPI r7, 9
0009\td7f9\tBLT L0
000a\t0800\tHLT
000b\t0000\tNOP
000c\t0000\tNOP
000d\t0000\tNOP
000e\t0000\tNOP
000f\t0000\tNOP

""")
    }
    
    func testDisassembleWithBaseAddress() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .load("program", url),
            .disassemble(.base(1))
        ])
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Wrote 65536 words to instruction memory.
0001\t2000\tLI r0, 0
0002\t2101\tLI r1, 1
0003\t2700\tLI r7, 0
0004\t3a04\tL0: ADD r2, r0, r1
0005\t7020\tADDI r0, r1, 0
0006\t77e1\tADDI r7, r7, 1
0007\t7140\tADDI r1, r2, 0
0008\t68e9\tCMPI r7, 9
0009\td7f9\tBLT L0
000a\t0800\tHLT
000b\t0000\tNOP
000c\t0000\tNOP
000d\t0000\tNOP
000e\t0000\tNOP
000f\t0000\tNOP
0010\t0000\tNOP

""")
    }
    
    func testDisassembleWithBaseAddressAndCount() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .load("program", url),
            .disassemble(.baseCount(1, 4))
        ])
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Wrote 65536 words to instruction memory.
0001\t2000\tLI r0, 0
0002\t2101\tLI r1, 1
0003\t2700\tLI r7, 0
0004\t3a04\tL0: ADD r2, r0, r1

""")
    }
    
    func testDisassembleWithIdentifier() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .load("program", url),
            .disassemble(.identifier("L0"))
        ])
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Wrote 65536 words to instruction memory.
0004\t3a04\tL0: ADD r2, r0, r1
0005\t7020\tADDI r0, r1, 0
0006\t77e1\tADDI r7, r7, 1
0007\t7140\tADDI r1, r2, 0
0008\t68e9\tCMPI r7, 9
0009\td7f9\tBLT L0
000a\t0800\tHLT
000b\t0000\tNOP
000c\t0000\tNOP
000d\t0000\tNOP
000e\t0000\tNOP
000f\t0000\tNOP
0010\t0000\tNOP
0011\t0000\tNOP
0012\t0000\tNOP
0013\t0000\tNOP

""")
    }
    
    func testDisassembleWithIdentifierAndCount() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "fib", withExtension: "bin")!
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .load("program", url),
            .disassemble(.identifierCount("L0", 6))
        ])
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Wrote 65536 words to instruction memory.
0004\t3a04\tL0: ADD r2, r0, r1
0005\t7020\tADDI r0, r1, 0
0006\t77e1\tADDI r7, r7, 1
0007\t7140\tADDI r1, r2, 0
0008\t68e9\tCMPI r7, 9
0009\td7f9\tBLT L0

""")
    }
    
    func testDisassembleWithUnresolvedIdentifier() throws {
        let computer = Turtle16Computer(SchematicLevelCPUModel())
        let interpreter = DebugConsoleCommandLineInterpreter(computer)
        interpreter.run(instructions:[
            .disassemble(.identifier("foo"))
        ])
        XCTAssertEqual((interpreter.logger as! StringLogger).stringValue, """
Use of unresolved identifier: `foo'

""")
    }
}
