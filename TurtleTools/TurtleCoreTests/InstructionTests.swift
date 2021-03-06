//
//  InstructionTests.swift
//  TurtleCoreTests
//
//  Created by Andrew Fox on 8/15/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore

class InstructionTests: XCTestCase {
    func testInit_1() {
        let instruction = Instruction.makeNOP()
        XCTAssertEqual(instruction.opcode, 0)
        XCTAssertEqual(instruction.immediate, 0)
    }
    
    func testInit_2() {
        let instruction = Instruction(opcode: 1, immediate: 2)
        XCTAssertEqual(instruction.opcode, 1)
        XCTAssertEqual(instruction.immediate, 2)
    }
    
    func testInit_3() {
        let instruction = Instruction(opcode: UInt8(1), immediate: UInt8(2))
        XCTAssertEqual(instruction.opcode, 1)
        XCTAssertEqual(instruction.immediate, 2)
    }
    
    func testInitWithNilString() {
        let instruction = Instruction("")
        XCTAssertNil(instruction)
    }
    
    func testInitWithZero() {
        let maybeInstruction = Instruction("{op=0b0, imm=0b0}")
        XCTAssertNotNil(maybeInstruction)
        XCTAssertEqual(maybeInstruction?.opcode, 0)
        XCTAssertEqual(maybeInstruction?.immediate, 0)
    }
    
    func testInitWithOneMatch_1() {
        XCTAssertNil(Instruction("{op=0b0, imm=0bXXXX}"))
    }
    
    func testInitWithOneMatch_2() {
        XCTAssertNil(Instruction("{op=0bX, imm=0b0}"))
    }
    
    func testInitWithTooLargeOpcode() {
        XCTAssertNil(Instruction("{op=0b1111111111111111, imm=0b0}"))
    }
    
    func testInitWithTooLargeImmediate() {
        XCTAssertNil(Instruction("{op=0b0, imm=0b1111111111111111}"))
    }
    
    func testTwoDefaultInitInstructionsAreEqual() {
        XCTAssertTrue(Instruction.makeNOP() == Instruction.makeNOP())
        XCTAssertEqual(Instruction.makeNOP(), Instruction.makeNOP())
    }
    
    func testDifferentInstructionsTestNotEqual() {
        XCTAssertNotEqual(Instruction.makeNOP(), Instruction(opcode: 1, immediate: 2))
    }
    
    func testInstructionTestsNotEqualAgainstDifferentObject() {
        XCTAssertNotEqual([Instruction.makeNOP() as NSObject], [1 as NSObject])
    }
    
    func testInstructionWithProvidedDisassembly() {
        XCTAssertEqual(Instruction("{op=0b0, imm=0b0}"),
                       Instruction(opcode: 0, immediate: 0, disassembly: "NOP"))
    }
    
    func testHash() {
        XCTAssertEqual(Instruction.makeNOP().hashValue,
                       Instruction.makeNOP().hashValue)
    }
    
    func testWithProgramCounter() {
        let ins1 = Instruction.makeNOP()
        let ins2 = ins1.withProgramCounter(ProgramCounter(withValue: 0xffff))
        XCTAssertEqual(ins1.opcode, ins2.opcode)
        XCTAssertEqual(ins1.immediate, ins2.immediate)
        XCTAssertEqual(ins1.disassembly, ins2.disassembly)
        XCTAssertEqual(ins2.pc.value, 0xffff)
        XCTAssertEqual(ins1.guardFail, ins2.guardFail)
        XCTAssertEqual(ins1.guardFlags, ins2.guardFlags)
        XCTAssertEqual(ins1.guardAddress, ins2.guardAddress)
        XCTAssertEqual(ins1.isBreakpoint, ins2.isBreakpoint)
    }
    
    func testWithGuardFail_true() {
        let ins1 = Instruction.makeNOP()
        let ins2 = ins1.withGuard(fail: true)
        XCTAssertEqual(ins1.opcode, ins2.opcode)
        XCTAssertEqual(ins1.immediate, ins2.immediate)
        XCTAssertEqual(ins1.disassembly, ins2.disassembly)
        XCTAssertEqual(ins1.pc, ins2.pc)
        XCTAssertEqual(ins2.guardFail, true)
        XCTAssertEqual(ins1.guardFlags, ins2.guardFlags)
        XCTAssertEqual(ins1.guardAddress, ins2.guardAddress)
        XCTAssertEqual(ins1.isBreakpoint, ins2.isBreakpoint)
    }
    
    func testWithGuardFail_false() {
        let ins1 = Instruction.makeNOP()
        let ins2 = ins1.withGuard(fail: false)
        XCTAssertEqual(ins1.opcode, ins2.opcode)
        XCTAssertEqual(ins1.immediate, ins2.immediate)
        XCTAssertEqual(ins1.disassembly, ins2.disassembly)
        XCTAssertEqual(ins1.pc, ins2.pc)
        XCTAssertEqual(ins1.guardFail, ins2.guardFail)
        XCTAssertEqual(ins1.guardFlags, ins2.guardFlags)
        XCTAssertEqual(ins1.guardAddress, ins2.guardAddress)
        XCTAssertEqual(ins1.isBreakpoint, ins2.isBreakpoint)
    }
    
    func testWithGuardFlags() {
        let ins1 = Instruction.makeNOP()
        let ins2 = ins1.withGuard(flags: Flags())
        XCTAssertEqual(ins1.opcode, ins2.opcode)
        XCTAssertEqual(ins1.immediate, ins2.immediate)
        XCTAssertEqual(ins1.disassembly, ins2.disassembly)
        XCTAssertEqual(ins1.pc, ins2.pc)
        XCTAssertEqual(ins1.guardFail, ins2.guardFail)
        XCTAssertEqual(ins2.guardFlags, Flags())
        XCTAssertEqual(ins1.guardAddress, ins2.guardAddress)
        XCTAssertEqual(ins1.isBreakpoint, ins2.isBreakpoint)
    }
    
    func testWithGuardAddress() {
        let ins1 = Instruction.makeNOP()
        let ins2 = ins1.withGuard(address: 0xffff)
        XCTAssertEqual(ins1.opcode, ins2.opcode)
        XCTAssertEqual(ins1.immediate, ins2.immediate)
        XCTAssertEqual(ins1.disassembly, ins2.disassembly)
        XCTAssertEqual(ins1.pc, ins2.pc)
        XCTAssertEqual(ins1.guardFail, ins2.guardFail)
        XCTAssertEqual(ins1.guardFlags, ins2.guardFlags)
        XCTAssertEqual(ins2.guardAddress, 0xffff)
        XCTAssertEqual(ins1.isBreakpoint, ins2.isBreakpoint)
    }
    
    func testWithBreakpoint_true() {
        let ins1 = Instruction.makeNOP()
        let ins2 = ins1.withBreakpoint(true)
        XCTAssertEqual(ins1.opcode, ins2.opcode)
        XCTAssertEqual(ins1.immediate, ins2.immediate)
        XCTAssertEqual(ins1.disassembly, ins2.disassembly)
        XCTAssertEqual(ins1.pc, ins2.pc)
        XCTAssertEqual(ins1.guardFail, ins2.guardFail)
        XCTAssertEqual(ins1.guardFlags, ins2.guardFlags)
        XCTAssertEqual(ins1.guardAddress, ins2.guardAddress)
        XCTAssertEqual(ins2.isBreakpoint, true)
    }
    
    func testWithBreakpoint_false() {
        let ins1 = Instruction.makeNOP()
        let ins2 = ins1.withBreakpoint(false)
        XCTAssertEqual(ins1.opcode, ins2.opcode)
        XCTAssertEqual(ins1.immediate, ins2.immediate)
        XCTAssertEqual(ins1.disassembly, ins2.disassembly)
        XCTAssertEqual(ins1.pc, ins2.pc)
        XCTAssertEqual(ins1.guardFail, ins2.guardFail)
        XCTAssertEqual(ins1.guardFlags, ins2.guardFlags)
        XCTAssertEqual(ins1.guardAddress, ins2.guardAddress)
        XCTAssertEqual(ins1.isBreakpoint, ins2.isBreakpoint)
    }
}
