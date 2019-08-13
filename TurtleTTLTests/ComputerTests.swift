//
//  ComputerTests.swift
//  SimulatorTests
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class ComputerTests: XCTestCase {
    func testReset() {
        let computer = Computer()
        computer.instructionROM.store(address: 0, value: 0)
        computer.reset()
        XCTAssertEqual(computer.programCounter.contents, 0)
        XCTAssertEqual(computer.registerC.contents, 0)
    }
    
    func testBasicExample() {
        let computer = Computer()
        
        // NOP
        computer.instructionDecoder.store(address: 0, value: 0b1111111111111111)
        computer.instructionROM.store(address: 0, value: 0b0000000000000000)
        
        // Set register A to immediate value 1.
        computer.instructionDecoder.store(address: 1, value: 0b1111011111111110)
        computer.instructionROM.store(address: 1, value: 0b0000000100000001)
        
        computer.reset()
        
        // Fetch the NOP, Decode Whatever, Execute Whatever
        computer.step()
        
        // Fetch the assignment to A, Decode the NOP, Execute Whatever
        computer.step()
        
        // Fetch whatever, Decode the assignment to A, Execute the NOP
        computer.step()
        
        // Fetch whatever, Decode whatever, Execute the assignment to A.
        XCTAssertEqual(computer.registerA.contents, 0)
        computer.step()
        XCTAssertEqual(computer.registerA.contents, 1)
    }
    
    func testBasicAddition() {
        let computer = Computer()
        
        let nop = ControlWord()
        
        let lda = ControlWord()
        lda.CO = false
        lda.AI = false
        
        let sum = ControlWord()
        sum.EO = false
        sum.AI = false
        
        let hlt = ControlWord()
        hlt.HLT = false

        // NOP
        computer.instructionDecoder.store(opcode: 0, controlWord: nop)
        computer.instructionROM.store(address: 0, opcode: 0, immediate: 0)

        // Set register A to immediate value 1.
        computer.instructionDecoder.store(opcode: 1, controlWord: lda)
        computer.instructionROM.store(address: 1, opcode: 1, immediate: 1)

        // Set register A to "A plus 1"
        computer.instructionDecoder.store(opcode: 2, controlWord: sum)
        computer.instructionROM.store(address: 2, opcode: 2, immediate: 0)
        
        // Set register A to "A plus 1"
        computer.instructionDecoder.store(opcode: 3, controlWord: sum)
        computer.instructionROM.store(address: 3, opcode: 3, immediate: 0)

        // Halt
        computer.instructionDecoder.store(opcode: 4, controlWord: hlt)
        computer.instructionROM.store(address: 4, opcode: 4, immediate: 0)

        computer.execute()
        
        XCTAssertEqual(computer.registerA.contents, 3)
    }
    
    func testRAMStoreLoad() {
        let computer = Computer()
        
        let nop = 0
        let nopControl = ControlWord()
        computer.instructionDecoder.store(opcode: nop, controlWord: nopControl)
        
        let ldx = 1
        let ldxControl = ControlWord()
        ldxControl.CO = false
        ldxControl.XI = false
        computer.instructionDecoder.store(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 2
        let ldyControl = ControlWord()
        ldyControl.CO = false
        ldyControl.YI = false
        computer.instructionDecoder.store(opcode: ldy, controlWord: ldyControl)
        
        let store = 3
        let storeControl = ControlWord()
        storeControl.MI = false
        storeControl.CO = false
        computer.instructionDecoder.store(opcode: store, controlWord: storeControl)
        
        let load = 4
        let loadControl = ControlWord()
        loadControl.MO = false
        loadControl.AI = false
        computer.instructionDecoder.store(opcode: load, controlWord: loadControl)
        
        let hlt = 5
        let hltControl = ControlWord()
        hltControl.HLT = false
        computer.instructionDecoder.store(opcode: hlt, controlWord: hltControl)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),    // NOP
            Instruction(opcode: ldx, immediate: 0),    // LDX $0
            Instruction(opcode: ldy, immediate: 0),    // LDY $0
            Instruction(opcode: store, immediate: 42), // STORE $42
            Instruction(opcode: load, immediate: 0),   // LOAD A
            Instruction(opcode: hlt, immediate: 0)])   // HLT
        
        computer.execute()
        
        XCTAssertEqual(computer.registerA.contents, 42)
    }
    
    func testUnconditionalJump() {
        let computer = Computer()
        
        let nop = 0
        let nopControl = ControlWord()
        computer.instructionDecoder.store(opcode: nop, controlWord: nopControl)
        
        let hlt = 1
        let hltControl = ControlWord()
        hltControl.HLT = false
        computer.instructionDecoder.store(opcode: hlt, controlWord: hltControl)
        
        let lda = 2
        let ldaControl = ControlWord()
        ldaControl.CO = false
        ldaControl.AI = false
        computer.instructionDecoder.store(opcode: lda, controlWord: ldaControl)
        
        let ldx = 3
        let ldxControl = ControlWord()
        ldxControl.CO = false
        ldxControl.XI = false
        computer.instructionDecoder.store(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 4
        let ldyControl = ControlWord()
        ldyControl.CO = false
        ldyControl.YI = false
        computer.instructionDecoder.store(opcode: ldy, controlWord: ldyControl)
        
        let jmp = 5
        let jmpControl = ControlWord()
        jmpControl.J = false
        computer.instructionDecoder.store(opcode: jmp, controlWord: jmpControl)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),  // NOP
            Instruction(opcode: lda, immediate: 1),  // LDA $1
            Instruction(opcode: ldx, immediate: 0),  // LDX $0
            Instruction(opcode: ldy, immediate: 8),  // LDY $0
            Instruction(opcode: jmp, immediate: 0),  // JMP $8
            Instruction(opcode: nop, immediate: 0),  // NOP
            Instruction(opcode: nop, immediate: 0),  // NOP
            Instruction(opcode: lda, immediate: 2),  // LDA $2
            Instruction(opcode: hlt, immediate: 0)]) // HLT
        
        computer.execute()
        
        XCTAssertEqual(computer.registerA.contents, 1)
    }
    
    func testConditionalJumpOnCarry_DontTakeTheJump() {
        let computer = Computer()
        
        let nop = 0
        let nopControl = ControlWord()
        computer.instructionDecoder.store(opcode: nop, controlWord: nopControl)
        
        let hlt = 1
        let hltControl = ControlWord()
        hltControl.HLT = false
        computer.instructionDecoder.store(opcode: hlt, controlWord: hltControl)
        
        let lda = 2
        let ldaControl = ControlWord()
        ldaControl.CO = false
        ldaControl.AI = false
        computer.instructionDecoder.store(opcode: lda, controlWord: ldaControl)
        
        let ldb = 3
        let ldbControl = ControlWord()
        ldbControl.CO = false
        ldbControl.BI = false
        computer.instructionDecoder.store(opcode: ldb, controlWord: ldbControl)
        
        let ldx = 4
        let ldxControl = ControlWord()
        ldxControl.CO = false
        ldxControl.XI = false
        computer.instructionDecoder.store(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 5
        let ldyControl = ControlWord()
        ldyControl.CO = false
        ldyControl.YI = false
        computer.instructionDecoder.store(opcode: ldy, controlWord: ldyControl)
        
        let alu = 6
        let aluControl = ControlWord()
        aluControl.EO = false
        aluControl.DI = false
        aluControl.FI = false
        computer.instructionDecoder.store(opcode: alu, controlWord: aluControl)
        
        let jc = 7
        let jcControl = ControlWord()
        jcControl.J = false
        computer.instructionDecoder.store(opcode: jc,
                                          carryFlag:0,
                                          equalFlag:0,
                                          controlWord: nopControl)
        computer.instructionDecoder.store(opcode: jc,
                                          carryFlag:1,
                                          equalFlag:0,
                                          controlWord: jcControl)
        computer.instructionDecoder.store(opcode: jc,
                                          carryFlag:0,
                                          equalFlag:1,
                                          controlWord: nopControl)
        computer.instructionDecoder.store(opcode: jc,
                                          carryFlag:1,
                                          equalFlag:1,
                                          controlWord: jcControl)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: lda, immediate: 2),          // LDA $2
            Instruction(opcode: ldb, immediate: 1),          // LDB $1
            Instruction(opcode: ldx, immediate: 0),          // LDX $0
            Instruction(opcode: ldy, immediate: 11),         // LDY $0
            Instruction(opcode: alu, immediate: 0b00000110), // SUB
            Instruction(opcode: nop, immediate: 0),          // NOP (We must at least one instruction between setting the flags and testing the flags)
            Instruction(opcode:  jc, immediate: 0),          // JC $11
            Instruction(opcode: nop, immediate: 0),          // NOP (We must have two NOPs following a jump to prevent the pipeline from filling with incorrect instructions)
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: lda, immediate: 42),         // LDA $42
            Instruction(opcode: hlt, immediate: 0)])         // HLT
        
        computer.execute()
        
        XCTAssertEqual(computer.registerD.contents, 1)
        XCTAssertEqual(computer.registerA.contents, 42)
    }
    
    func testConditionalJumpOnCarry_TakeTheJump() {
        let computer = Computer()
        
        let nop = 0
        let nopControl = ControlWord()
        computer.instructionDecoder.store(opcode: nop, controlWord: nopControl)
        
        let hlt = 1
        let hltControl = ControlWord()
        hltControl.HLT = false
        computer.instructionDecoder.store(opcode: hlt, controlWord: hltControl)
        
        let lda = 2
        let ldaControl = ControlWord()
        ldaControl.CO = false
        ldaControl.AI = false
        computer.instructionDecoder.store(opcode: lda, controlWord: ldaControl)
        
        let ldb = 3
        let ldbControl = ControlWord()
        ldbControl.CO = false
        ldbControl.BI = false
        computer.instructionDecoder.store(opcode: ldb, controlWord: ldbControl)
        
        let ldx = 4
        let ldxControl = ControlWord()
        ldxControl.CO = false
        ldxControl.XI = false
        computer.instructionDecoder.store(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 5
        let ldyControl = ControlWord()
        ldyControl.CO = false
        ldyControl.YI = false
        computer.instructionDecoder.store(opcode: ldy, controlWord: ldyControl)
        
        let alu = 6
        let aluControl = ControlWord()
        aluControl.EO = false
        aluControl.DI = false
        aluControl.FI = false
        computer.instructionDecoder.store(opcode: alu, controlWord: aluControl)
        
        let jc = 7
        let jcControl = ControlWord()
        jcControl.J = false
        computer.instructionDecoder.store(opcode: jc,
                                          carryFlag:1,
                                          equalFlag:0,
                                          controlWord: jcControl)
        computer.instructionDecoder.store(opcode: jc,
                                          carryFlag:0,
                                          equalFlag:0,
                                          controlWord: nopControl)
        computer.instructionDecoder.store(opcode: jc,
                                          carryFlag:1,
                                          equalFlag:1,
                                          controlWord: jcControl)
        computer.instructionDecoder.store(opcode: jc,
                                          carryFlag:0,
                                          equalFlag:1,
                                          controlWord: nopControl)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: lda, immediate: 1),          // LDA $1
            Instruction(opcode: ldb, immediate: 2),          // LDB $2
            Instruction(opcode: ldx, immediate: 0),          // LDX $0
            Instruction(opcode: ldy, immediate: 11),         // LDY $0
            Instruction(opcode: alu, immediate: 0b00000110), // SUB
            Instruction(opcode: nop, immediate: 0),          // NOP (We must at least one instruction between setting the flags and testing the flags)
            Instruction(opcode:  jc, immediate: 0),          // JC $11
            Instruction(opcode: nop, immediate: 0),          // NOP (We must have two NOPs following a jump to prevent the pipeline from filling with incorrect instructions)
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: lda, immediate: 42),         // LDA $42
            Instruction(opcode: hlt, immediate: 0)])         // HLT
        
        computer.execute()
        
        XCTAssertEqual(computer.registerD.contents, 255)
        XCTAssertEqual(computer.registerA.contents, 1)
    }
}
