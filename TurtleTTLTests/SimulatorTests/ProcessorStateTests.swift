//
//  ProcessorStateTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 3/14/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class ProcessorStateTests: XCTestCase {
    public class StringLogger: NSObject, Logger {
        public private(set) var string = ""
        
        public func append(_ format: String, _ args: CVarArg...) {
            let message = String(format:format, arguments:args)
            string += message + "\n"
        }
    }
    
    func testInitDefault() {
        let cpuState = ProcessorState()
        XCTAssertEqual(cpuState.uptime, 0)
        XCTAssertEqual(cpuState.bus, Register())
        XCTAssertEqual(cpuState.registerA, Register())
        XCTAssertEqual(cpuState.registerB, Register())
        XCTAssertEqual(cpuState.registerC, Register())
        XCTAssertEqual(cpuState.registerD, Register())
        XCTAssertEqual(cpuState.registerG, Register())
        XCTAssertEqual(cpuState.registerH, Register())
        XCTAssertEqual(cpuState.registerX, Register())
        XCTAssertEqual(cpuState.registerY, Register())
        XCTAssertEqual(cpuState.registerU, Register())
        XCTAssertEqual(cpuState.registerV, Register())
        XCTAssertEqual(cpuState.aluResult, Register())
        XCTAssertEqual(cpuState.aluFlags, Flags())
        XCTAssertEqual(cpuState.flags, Flags())
        XCTAssertEqual(cpuState.pc, ProgramCounter())
        XCTAssertEqual(cpuState.pc_if, ProgramCounter())
        XCTAssertEqual(cpuState.if_id, Instruction.makeNOP())
        XCTAssertEqual(cpuState.controlWord, ControlWord())
    }
    
    func testInitParameterized() {
        let cpuState = ProcessorState(uptime: UInt64.max,
                                      bus: Register(withValue: 0xf0),
                                      registerA: Register(withValue: 0xf1),
                                      registerB: Register(withValue: 0xf2),
                                      registerC: Register(withValue: 0xf3),
                                      registerD: Register(withValue: 0xf4),
                                      registerG: Register(withValue: 0xf5),
                                      registerH: Register(withValue: 0xf6),
                                      registerX: Register(withValue: 0xf7),
                                      registerY: Register(withValue: 0xf8),
                                      registerU: Register(withValue: 0xf9),
                                      registerV: Register(withValue: 0xfa),
                                      aluResult: Register(withValue: 0xfb),
                                      aluFlags: Flags(1, 0),
                                      flags: Flags(0, 1),
                                      pc: ProgramCounter(withValue: 0xcafe),
                                      pc_if: ProgramCounter(withValue: 0xbeef),
                                      if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                      controlWord: ControlWord(withValue: 0xffffffff))
        XCTAssertEqual(cpuState.uptime, UInt64.max)
        XCTAssertEqual(cpuState.bus, Register(withValue: 0xf0))
        XCTAssertEqual(cpuState.registerA, Register(withValue: 0xf1))
        XCTAssertEqual(cpuState.registerB, Register(withValue: 0xf2))
        XCTAssertEqual(cpuState.registerC, Register(withValue: 0xf3))
        XCTAssertEqual(cpuState.registerD, Register(withValue: 0xf4))
        XCTAssertEqual(cpuState.registerG, Register(withValue: 0xf5))
        XCTAssertEqual(cpuState.registerH, Register(withValue: 0xf6))
        XCTAssertEqual(cpuState.registerX, Register(withValue: 0xf7))
        XCTAssertEqual(cpuState.registerY, Register(withValue: 0xf8))
        XCTAssertEqual(cpuState.registerU, Register(withValue: 0xf9))
        XCTAssertEqual(cpuState.registerV, Register(withValue: 0xfa))
        XCTAssertEqual(cpuState.aluResult, Register(withValue: 0xfb))
        XCTAssertEqual(cpuState.aluFlags, Flags(1, 0))
        XCTAssertEqual(cpuState.flags, Flags(0, 1))
        XCTAssertEqual(cpuState.pc, ProgramCounter(withValue: 0xcafe))
        XCTAssertEqual(cpuState.pc_if, ProgramCounter(withValue: 0xbeef))
        XCTAssertEqual(cpuState.if_id, Instruction(opcode: 0xaa, immediate: 0xbb))
        XCTAssertEqual(cpuState.controlWord, ControlWord(withValue: 0xffffffff))
    }
    
    func testValueOfRegisterPairXY() {
        let cpuState = ProcessorState(uptime: UInt64.max,
                                      bus: Register(withValue: 0xf0),
                                      registerA: Register(withValue: 0xf1),
                                      registerB: Register(withValue: 0xf2),
                                      registerC: Register(withValue: 0xf3),
                                      registerD: Register(withValue: 0xf4),
                                      registerG: Register(withValue: 0xf5),
                                      registerH: Register(withValue: 0xf6),
                                      registerX: Register(withValue: 0xf7),
                                      registerY: Register(withValue: 0xf8),
                                      registerU: Register(withValue: 0xf9),
                                      registerV: Register(withValue: 0xfa),
                                      aluResult: Register(withValue: 0xfb),
                                      aluFlags: Flags(1, 0),
                                      flags: Flags(0, 1),
                                      pc: ProgramCounter(withValue: 0xcafe),
                                      pc_if: ProgramCounter(withValue: 0xbeef),
                                      if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                      controlWord: ControlWord(withValue: 0xffffffff))
        XCTAssertEqual(cpuState.valueOfXYPair(), 0xf7f8)
    }
    
    func testValueOfRegisterPairUV() {
        let cpuState = ProcessorState(uptime: UInt64.max,
                                      bus: Register(withValue: 0xf0),
                                      registerA: Register(withValue: 0xf1),
                                      registerB: Register(withValue: 0xf2),
                                      registerC: Register(withValue: 0xf3),
                                      registerD: Register(withValue: 0xf4),
                                      registerG: Register(withValue: 0xf5),
                                      registerH: Register(withValue: 0xf6),
                                      registerX: Register(withValue: 0xf7),
                                      registerY: Register(withValue: 0xf8),
                                      registerU: Register(withValue: 0xf9),
                                      registerV: Register(withValue: 0xfa),
                                      aluResult: Register(withValue: 0xfb),
                                      aluFlags: Flags(1, 0),
                                      flags: Flags(0, 1),
                                      pc: ProgramCounter(withValue: 0xcafe),
                                      pc_if: ProgramCounter(withValue: 0xbeef),
                                      if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                      controlWord: ControlWord(withValue: 0xffffffff))
        XCTAssertEqual(cpuState.valueOfUVPair(), 0xf9fa)
    }
    
    func testEquality_Equal() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        XCTAssertEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_Uptime() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.uptime = 0
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_Bus() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.bus = Register()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_RegisterA() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.registerA = Register()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_RegisterB() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.registerB = Register()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_RegisterC() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.registerC = Register()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_RegisterD() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.registerD = Register()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_RegisterG() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.registerG = Register()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_RegisterH() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.registerH = Register()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_RegisterX() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.registerX = Register()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_RegisterY() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.registerY = Register()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_RegisterU() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.registerU = Register()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_RegisterV() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.registerV = Register()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_AluResult() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.aluResult = Register()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_AluFlags() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.aluFlags = Flags()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_Flags() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.flags = Flags()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_PC() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.pc = ProgramCounter()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_PCIF() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.pc_if = ProgramCounter()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_Instruction() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.if_id = Instruction.makeNOP()
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_ControlWord() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 1),
                                       flags: Flags(1, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = cpuState1.copy() as! ProcessorState
        cpuState2.controlWord = ControlWord(withValue: 0xabababab)
        XCTAssertNotEqual(cpuState1, cpuState2)
    }
    
    func testEquality_Unequal_DifferentTypeObject() {
        XCTAssertNotEqual(ProcessorState(), NSObject())
    }
    
    func testEquality_LogChanges() {
        let cpuState1 = ProcessorState(uptime: UInt64.max,
                                       bus: Register(withValue: 0xf0),
                                       registerA: Register(withValue: 0xf1),
                                       registerB: Register(withValue: 0xf2),
                                       registerC: Register(withValue: 0xf3),
                                       registerD: Register(withValue: 0xf4),
                                       registerG: Register(withValue: 0xf5),
                                       registerH: Register(withValue: 0xf6),
                                       registerX: Register(withValue: 0xf7),
                                       registerY: Register(withValue: 0xf8),
                                       registerU: Register(withValue: 0xf9),
                                       registerV: Register(withValue: 0xfa),
                                       aluResult: Register(withValue: 0xfb),
                                       aluFlags: Flags(1, 0),
                                       flags: Flags(0, 1),
                                       pc: ProgramCounter(withValue: 0xcafe),
                                       pc_if: ProgramCounter(withValue: 0xbeef),
                                       if_id: Instruction(opcode: 0xaa, immediate: 0xbb),
                                       controlWord: ControlWord(withValue: 0xffffffff))
        let cpuState2 = ProcessorState()
        let logger = StringLogger()
        ProcessorState.logChanges(logger: logger,
                                  prevState: cpuState1,
                                  nextState: cpuState2)
        XCTAssertEqual(logger.string, """
uptime: 18446744073709551615 --> 0
pc: 0xcafe --> 0x0000
pc_if: 0xbeef --> 0x0000
if_id: {op=0b10101010, imm=0b10111011} --> NOP
controlWord: 0xffffffff --> 0xfff7efff
controlSignals: {UVInc, XYInc} --> {}
registerA: 0xf1 --> 0x00
registerB: 0xf2 --> 0x00
registerC: 0xf3 --> 0x00
registerD: 0xf4 --> 0x00
registerG: 0xf5 --> 0x00
registerH: 0xf6 --> 0x00
registerX: 0xf7 --> 0x00
registerY: 0xf8 --> 0x00
registerU: 0xf9 --> 0x00
registerV: 0xfa --> 0x00
flags: {carryFlag: 0, equalFlag: 1} --> {carryFlag: 0, equalFlag: 0}

""")
    }
}
