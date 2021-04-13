//
//  DebugConsoleCommandLineCompilerTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class DebugConsoleCommandLineCompilerTests: XCTestCase {
    func testEmptyString() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("")
        XCTAssertEqual(compiler.syntaxTree, TopLevel(children: []))
    }
    
    func testLexerError() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("*step")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "unexpected character: `*\'")
        XCTAssertEqual(compiler.errors.first?.context, "\t*step\n\t^")
    }
    
    func testParserError() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("step ,")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "operand type mismatch: `,\'")
        XCTAssertEqual(compiler.errors.first?.context, "\tstep ,\n\t     ^")
    }
    
    func testUnrecognizedInstructionError() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("a")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "unrecognized instruction: `a\'")
        XCTAssertEqual(compiler.errors.first?.context, "\ta\n\t^")
    }
    
    func testStepWithDefaultCount() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("s")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.step(count: 1)])
    }
    
    func testStepWithTwo() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("s 2")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.step(count: 2)])
    }
    
    func testStepWithNonNumericStepCount() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("s asdf")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "expected a number for the step count: `s'")
        XCTAssertEqual(compiler.errors.first?.context, "\ts asdf\n\t  ^~~~")
    }
    
    func testHelpWithZeroParameters() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("help")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.help(nil)])
    }
    
    func testHelpWithZeroParameters_h() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("h")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.help(nil)])
    }
    
    func testHelpWithUnexpectedNumberParameter() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("h 123")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.help(nil)])
    }
    
    func testHelpWithUnexpectedTopicIdentifier() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("h foo")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.help(nil)])
    }
    
    func testHelpWithHelp() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("h help")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.help(.help)])
    }
    
    func testHelpWithQuit() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("h quit")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.help(.quit)])
    }
    
    func testHelpWithQuit_q() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("h q")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.help(.quit)])
    }
    
    func testHelpWithReset() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("h reset")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.help(.reset)])
    }
    
    func testHelpWithStep() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("h step")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.help(.step)])
    }
    
    func testHelpWithStep_s() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("h s")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.help(.step)])
    }
    
    func testHelpWithReg() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("h reg")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.help(.reg)])
    }
    
    func testHelpWithReg_r() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("h r")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.help(.reg)])
    }
    
    func testHelpWithReg_regs() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("h regs")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.help(.reg)])
    }
    
    func testHelpWithReg_registers() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("h registers")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.help(.reg)])
    }
    
    func testHelpWithX() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("h x")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.help(.readMemory)])
    }
    
    func testHelpWithWritemem() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("h writemem")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.help(.writeMemory)])
    }
    
    func testQuit() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("q")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.quit])
    }
    
    func testQuitTakesNoParameters() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("q a")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction takes no parameters: `q'")
        XCTAssertEqual(compiler.errors.first?.context, "\tq a\n\t  ^")
    }
    
    func testReset() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("reset")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.reset])
    }
    
    func testResetTakesNoParameters() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("reset abcd")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction takes no parameters: `reset'")
        XCTAssertEqual(compiler.errors.first?.context, "\treset abcd\n\t      ^~~~")
    }
    
    func testRegisters_R_TakesNoParameters() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("r 1")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction takes no parameters: `r'")
        XCTAssertEqual(compiler.errors.first?.context, "\tr 1\n\t  ^")
    }
    
    func testRegisters_R() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("r")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.reg])
    }
    
    func testRegisters_Reg() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("reg")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.reg])
    }
    
    func testRegisters_Regs() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("regs")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.reg])
    }
    
    func testRegisters_Registers() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("registers")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.reg])
    }
    
    func testReadMemoryWithX_ExpectsAtLeastOneParameter() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("x")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "expected at least one parameter for the memory address: `x'")
        XCTAssertEqual(compiler.errors.first?.context, "\tx\n\t^")
    }
    
    func testReadMemoryWithX_WithAddress() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("x 0x1000")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.readMemory(base: 0x1000, count: 1)])
    }
    
    func testReadMemoryWithX_WithLengthAndNoAddress() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("x /1")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "expected a number for the memory address: `x'")
        XCTAssertEqual(compiler.errors.first?.context, "\tx /1\n\t  ^~")
    }
    
    func testReadMemoryWithX_WithAddressAndBadLength() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("x /foo 0x1000")
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "expected a number for the length: `x'")
        XCTAssertEqual(compiler.errors.first?.context, "\tx /foo 0x1000\n\t  ^~~~")
    }
    
    func testReadMemoryWithX_WithLengthAndSomeAddress() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("x /4 0x1000")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.readMemory(base: 0x1000, count: 4)])
    }
    
    func testWriteMemoryWithZeroParameters() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("writemem")
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "expected a memory address and data words: `writemem'")
        XCTAssertEqual(compiler.errors.first?.context, "\twritemem\n\t^~~~~~~~")
    }
    
    func testWriteMemoryWithBadBaseAddress() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("writemem foo")
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "expected a memory address and data words: `writemem'")
        XCTAssertEqual(compiler.errors.first?.context, "\twritemem foo\n\t         ^~~")
    }
    
    func testWriteMemoryWithBadDataWord1() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("writemem 0 foo")
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "expected a number for the data word: `writemem'")
        XCTAssertEqual(compiler.errors.first?.context, "\twritemem 0 foo\n\t           ^~~")
    }
    
    func testWriteMemoryWithBadDataWord2() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("writemem 0 0xffff foo")
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "expected a number for the data word: `writemem'")
        XCTAssertEqual(compiler.errors.first?.context, "\twritemem 0 0xffff foo\n\t                  ^~~")
    }
    
    func testWriteMemoryWithBadDataWord_TooBig() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("writemem 0 0x10000")
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "not enough bits to represent the passed value: `writemem'")
        XCTAssertEqual(compiler.errors.first?.context, "\twritemem 0 0x10000\n\t           ^~~~~~~")
    }
    
    func testWriteMemoryWithOneDataWord() throws {
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("writemem 0 0")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.writeMemory(base: 0, words: [0])])
    }
    
    func testWriteMemoryWithNegativeDataWord() throws {
        // A negative number of treated as the sixteen-bit unsigned, twos complement equivalent.
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("writemem 0 -1")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.writeMemory(base: 0, words: [0xffff])])
    }
    
    func testWriteMemoryWithTooBigNegativeDataWord() throws {
        // A negative number of treated as the sixteen-bit unsigned, twos complement equivalent.
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("writemem 0 -100000")
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "not enough bits to represent the passed value: `writemem'")
        XCTAssertEqual(compiler.errors.first?.context, "\twritemem 0 -100000\n\t           ^~~~~~~")
    }
    
    func testWriteMemoryWithNegativeAddress() throws {
        // A negative number of treated as the sixteen-bit unsigned, twos complement equivalent.
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("writemem -1 0")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions, [.writeMemory(base: 0xffff, words: [0])])
    }
    
    func testWriteMemoryWithTooBigAddress() throws {
        // A negative number of treated as the sixteen-bit unsigned, twos complement equivalent.
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("writemem 1000000 0")
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "not enough bits to represent the passed value: `writemem'")
        XCTAssertEqual(compiler.errors.first?.context, "\twritemem 1000000 0\n\t         ^~~~~~~")
    }
    
    func testWriteMemoryWithTooBigNegativeAddress() throws {
        // A negative number of treated as the sixteen-bit unsigned, twos complement equivalent.
        let compiler = DebugConsoleCommandLineCompiler()
        compiler.compile("writemem -100000 0")
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "not enough bits to represent the passed value: `writemem'")
        XCTAssertEqual(compiler.errors.first?.context, "\twritemem -100000 0\n\t         ^~~~~~~")
    }
}
