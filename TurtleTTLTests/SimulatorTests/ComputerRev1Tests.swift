//
//  ComputerRev1Tests.swift
//  SimulatorTests
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class ComputerRev1Tests: XCTestCase {
    let isVerboseLogging = false
    let kUpperInstructionRAM = 0
    let kLowerInstructionRAM = 1
    
    func makeComputer() -> ComputerRev1 {
        let computer = ComputerRev1()
        computer.logger = isVerboseLogging ? ConsoleLogger() : nil
        return computer
    }
    
    func testReset() {
        let computer = makeComputer()
        computer.reset()
        XCTAssertEqual(computer.cpuState.pc.value, 0)
        XCTAssertEqual(computer.cpuState.pc_if.value, 0)
        XCTAssertEqual(computer.cpuState.registerC.value, 0)
        XCTAssertEqual(computer.cpuState.controlWord.unsignedIntegerValue, ControlWord().unsignedIntegerValue)
    }
    
    func testBasicExample() {
        let computer = makeComputer()
        
        let instructionDecoder = InstructionDecoder()
            .withStore(value: 0b11111111111111111111111111111111, to: 0) // NOP
            .withStore(value: 0b11111111111111111111111111101110, to: 1) // MOV C, A
        
        let instructionROM = InstructionROM()
            .withStore(value: 0b0000000000000000, to: 0) // NOP
            .withStore(value: 0b0000000100000001, to: 1) // Set register A to immediate value 1.
        
        computer.instructionDecoder = instructionDecoder
        computer.instructionROM = instructionROM
        
        computer.reset()
        
        // Fetch the NOP, Decode Whatever, Execute Whatever
        computer.step()
        
        XCTAssertEqual(computer.cpuState.pc.value, 1)
        XCTAssertEqual(computer.cpuState.pc_if.value, 0)
        XCTAssertEqual(computer.cpuState.if_id.description, "{op=0b0, imm=0b0}")
        XCTAssertEqual(computer.cpuState.controlWord.unsignedIntegerValue, 0xffffffff)
        
        // Fetch the assignment to A, Decode the NOP, Execute Whatever
        computer.step()
        
        XCTAssertEqual(computer.cpuState.pc.value, 2)
        XCTAssertEqual(computer.cpuState.pc_if.value, 1)
        XCTAssertEqual(computer.cpuState.if_id.description, "{op=0b0, imm=0b0}")
        XCTAssertEqual(computer.cpuState.controlWord.unsignedIntegerValue, 0xffffffff)
        
        // Fetch whatever, Decode the assignment to A, Execute the NOP
        computer.step()
        
        XCTAssertEqual(computer.cpuState.pc.value, 3)
        XCTAssertEqual(computer.cpuState.pc_if.value, 2)
        XCTAssertEqual(computer.cpuState.if_id.description, "{op=0b1, imm=0b1}")
        XCTAssertEqual(computer.cpuState.controlWord.unsignedIntegerValue, 0xffffffff)
        
        // Fetch whatever, Decode whatever, Execute the assignment to A.
        XCTAssertEqual(computer.cpuState.registerA.value, 0)
        computer.step()
        XCTAssertEqual(computer.cpuState.registerA.value, 1)
    }
    
    func testBasicAddition() {
        let computer = makeComputer()
        
        let nop = ControlWord()
        let lda = ControlWord().withCO(.active).withAI(.active)
        let sum = ControlWord().withEO(.active).withAI(.active).withCarryIn(.active)
        let hlt = ControlWord().withHLT(.active)
        
        var instructionDecoder = InstructionDecoder()
        var instructionROM = InstructionROM()
        
        // NOP
        instructionDecoder = instructionDecoder.withStore(opcode: 0, controlWord: nop)
        instructionROM = instructionROM.withStore(opcode: 0, immediate: 0, to: 0)
        
        // Set register A to immediate value 1.
        instructionDecoder = instructionDecoder.withStore(opcode: 1, controlWord: lda)
        instructionROM = instructionROM.withStore(opcode: 1, immediate: 1, to: 1)
        
        // Set register A to "A plus 1"
        instructionDecoder = instructionDecoder.withStore(opcode: 2, controlWord: sum)
        instructionROM = instructionROM.withStore(opcode: 2, immediate: 0, to: 2)
        
        // Set register A to "A plus 1"
        instructionDecoder = instructionDecoder.withStore(opcode: 3, controlWord: sum)
        instructionROM = instructionROM.withStore(opcode: 3, immediate: 0, to: 3)
        
        // Halt
        instructionDecoder = instructionDecoder.withStore(opcode: 4, controlWord: hlt)
        instructionROM = instructionROM.withStore(opcode: 4, immediate: 0, to: 4)
        
        computer.instructionDecoder = instructionDecoder
        computer.instructionROM = instructionROM
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerA.value, 3)
    }
    
    func testAddTwoOperands() {
        let computer = makeComputer()
        
        let nop = ControlWord()
        let lda = ControlWord().withCO(.active).withAI(.active)
        let ldb = ControlWord().withCO(.active).withBI(.active)
        let sum = ControlWord().withEO(.active).withXI(.active).withCarryIn(.inactive)
        let hlt = ControlWord().withHLT(.active)
        
        var instructionDecoder = InstructionDecoder()
        var instructionROM = InstructionROM()
        
        // NOP
        instructionDecoder = instructionDecoder.withStore(opcode: 0, controlWord: nop)
        instructionROM = instructionROM.withStore(opcode: 0, immediate: 0, to: 0)
        
        // Set register A to immediate value 2.
        instructionDecoder = instructionDecoder.withStore(opcode: 1, controlWord: lda)
        instructionROM = instructionROM.withStore(opcode: 1, immediate: 2, to: 1)
        
        // Set register B to immediate value 2.
        instructionDecoder = instructionDecoder.withStore(opcode: 2, controlWord: ldb)
        instructionROM = instructionROM.withStore(opcode: 2, immediate: 2, to: 2)
        
        // Set register X to "A plus B"
        instructionDecoder = instructionDecoder.withStore(opcode: 3, controlWord: sum)
        instructionROM = instructionROM.withStore(opcode: 3, immediate: 0b01001, to: 3)
        
        // Halt
        instructionDecoder = instructionDecoder.withStore(opcode: 4, controlWord: hlt)
        instructionROM = instructionROM.withStore(opcode: 4, immediate: 0, to: 4)
        
        computer.instructionDecoder = instructionDecoder
        computer.instructionROM = instructionROM
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerX.value, 4)
    }
    
    func testCompareTwoOperands_Equal() {
        let computer = makeComputer()
        
        let nop = ControlWord()
        let lda = ControlWord().withCO(.active).withAI(.active)
        let ldb = ControlWord().withCO(.active).withBI(.active)
        let cmp = ControlWord().withFI(.active).withCarryIn(.inactive)
        let hlt = ControlWord().withHLT(.active)
        
        var instructionDecoder = InstructionDecoder()
        var instructionROM = InstructionROM()
        
        // NOP
        instructionDecoder = instructionDecoder.withStore(opcode: 0, controlWord: nop)
        instructionROM = instructionROM.withStore(opcode: 0, immediate: 0, to: 0)
        
        // Set register A to immediate value 42.
        instructionDecoder = instructionDecoder.withStore(opcode: 1, controlWord: lda)
        instructionROM = instructionROM.withStore(opcode: 1, immediate: 42, to: 1)
        
        // Set register B to immediate value 42.
        instructionDecoder = instructionDecoder.withStore(opcode: 2, controlWord: ldb)
        instructionROM = instructionROM.withStore(opcode: 2, immediate: 42, to: 2)
        
        // Compare
        instructionDecoder = instructionDecoder.withStore(opcode: 3, controlWord: cmp)
        instructionROM = instructionROM.withStore(opcode: 3, immediate: 0b00110, to: 3)
        
        // Halt
        instructionDecoder = instructionDecoder.withStore(opcode: 4, controlWord: hlt)
        instructionROM = instructionROM.withStore(opcode: 4, immediate: 0, to: 4)
        
        computer.instructionDecoder = instructionDecoder
        computer.instructionROM = instructionROM
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.flags.carryFlag, 1)
        XCTAssertEqual(computer.cpuState.flags.equalFlag, 1)
    }
    
    func testCompareTwoOperands_GreaterThan() {
        let computer = makeComputer()
        
        let nop = ControlWord()
        let lda = ControlWord().withCO(.active).withAI(.active)
        let ldb = ControlWord().withCO(.active).withBI(.active)
        let cmp = ControlWord().withFI(.active).withCarryIn(.inactive)
        let hlt = ControlWord().withHLT(.active)
        
        var instructionDecoder = InstructionDecoder()
        var instructionROM = InstructionROM()
        
        // NOP
        instructionDecoder = instructionDecoder.withStore(opcode: 0, controlWord: nop)
        instructionROM = instructionROM.withStore(opcode: 0, immediate: 0, to: 0)
        
        // Set register A to immediate value 42.
        instructionDecoder = instructionDecoder.withStore(opcode: 1, controlWord: lda)
        instructionROM = instructionROM.withStore(opcode: 1, immediate: 42, to: 1)
        
        // Set register B to immediate value 1.
        instructionDecoder = instructionDecoder.withStore(opcode: 2, controlWord: ldb)
        instructionROM = instructionROM.withStore(opcode: 2, immediate: 1, to: 2)
        
        // Compare
        instructionDecoder = instructionDecoder.withStore(opcode: 3, controlWord: cmp)
        instructionROM = instructionROM.withStore(opcode: 3, immediate: 0b00110, to: 3)
        
        // Halt
        instructionDecoder = instructionDecoder.withStore(opcode: 4, controlWord: hlt)
        instructionROM = instructionROM.withStore(opcode: 4, immediate: 0, to: 4)
        
        computer.instructionDecoder = instructionDecoder
        computer.instructionROM = instructionROM
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.flags.carryFlag, 0)
        XCTAssertEqual(computer.cpuState.flags.equalFlag, 0)
    }
    
    func testCompareTwoOperands_LessThan() {
        let computer = makeComputer()
        
        let nop = ControlWord()
        let lda = ControlWord().withCO(.active).withAI(.active)
        let ldb = ControlWord().withCO(.active).withBI(.active)
        let cmp = ControlWord().withFI(.active).withCarryIn(.inactive)
        let hlt = ControlWord().withHLT(.active)
        
        var instructionDecoder = InstructionDecoder()
        var instructionROM = InstructionROM()
        
        // NOP
        instructionDecoder = instructionDecoder.withStore(opcode: 0, controlWord: nop)
        instructionROM = instructionROM.withStore(opcode: 0, immediate: 0, to: 0)
        
        // Set register A to immediate value 1.
        instructionDecoder = instructionDecoder.withStore(opcode: 1, controlWord: lda)
        instructionROM = instructionROM.withStore(opcode: 1, immediate: 1, to: 1)
        
        // Set register B to immediate value 42.
        instructionDecoder = instructionDecoder.withStore(opcode: 2, controlWord: ldb)
        instructionROM = instructionROM.withStore(opcode: 2, immediate: 42, to: 2)
        
        // Compare
        instructionDecoder = instructionDecoder.withStore(opcode: 3, controlWord: cmp)
        instructionROM = instructionROM.withStore(opcode: 3, immediate: 0b00110, to: 3)
        
        // Halt
        instructionDecoder = instructionDecoder.withStore(opcode: 4, controlWord: hlt)
        instructionROM = instructionROM.withStore(opcode: 4, immediate: 0, to: 4)
        
        computer.instructionDecoder = instructionDecoder
        computer.instructionROM = instructionROM
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.flags.carryFlag, 1)
        XCTAssertEqual(computer.cpuState.flags.equalFlag, 0)
    }
    
    func testDescribeALUResult() {
        let computer = makeComputer()
        
        let nop = ControlWord()
        let lda = ControlWord().withCO(.active).withAI(.active)
        let sum = ControlWord().withEO(.active).withAI(.active).withCarryIn(.active)
        let hlt = ControlWord().withHLT(.active)
        
        var instructionDecoder = InstructionDecoder()
        var instructionROM = InstructionROM()
        
        // NOP
        instructionDecoder = instructionDecoder.withStore(opcode: 0, controlWord: nop)
        instructionROM = instructionROM.withStore(opcode: 0, immediate: 0, to: 0)
        
        // Set register A to immediate value 1.
        instructionDecoder = instructionDecoder.withStore(opcode: 1, controlWord: lda)
        instructionROM = instructionROM.withStore(opcode: 1, immediate: 1, to: 1)
        
        // Set register A to "A plus 1"
        instructionDecoder = instructionDecoder.withStore(opcode: 2, controlWord: sum)
        instructionROM = instructionROM.withStore(opcode: 2, immediate: 0, to: 2)
        
        // Set register A to "A plus 1"
        instructionDecoder = instructionDecoder.withStore(opcode: 3, controlWord: sum)
        instructionROM = instructionROM.withStore(opcode: 3, immediate: 0, to: 3)
        
        // Halt
        instructionDecoder = instructionDecoder.withStore(opcode: 4, controlWord: hlt)
        instructionROM = instructionROM.withStore(opcode: 4, immediate: 0, to: 4)
        
        computer.instructionDecoder = instructionDecoder
        computer.instructionROM = instructionROM
        
        computer.step()
        computer.step()
        computer.step()
        computer.step()
        computer.step()
        computer.step()
        
        XCTAssertEqual(computer.cpuState.aluResult.value, 3)
        XCTAssertEqual(computer.cpuState.bus.value, 3)
        XCTAssertEqual(computer.cpuState.controlWord.stringValue, "11111011111101111110111110111110")
        XCTAssertEqual(computer.cpuState.controlWord.description, "{AI, EO, CarryIn}")
    }
    
    func testReadWriteRegistersXY() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let ldx = 1
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let movyx = 2
        let moveyxControl = ControlWord().withXO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: movyx, controlWord: moveyxControl)
        
        let movay = 3
        let moveayControl = ControlWord().withYO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: movay, controlWord: moveayControl)
        
        let hlt = 4
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),
            Instruction(opcode: ldx, immediate: 42),
            Instruction(opcode: movyx, immediate: 0),
            Instruction(opcode: movay, immediate: 0),
            Instruction(opcode: hlt, immediate: 0)])
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerX.value, 42)
        XCTAssertEqual(computer.cpuState.registerY.value, 42)
        XCTAssertEqual(computer.cpuState.registerA.value, 42)
    }
    
    func testReadWriteRegistersUV() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let ldu = 1
        let lduControl = ControlWord().withCO(.active).withUI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldu, controlWord: lduControl)
        
        let movvu = 2
        let movevuControl = ControlWord().withUO(.active).withVI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: movvu, controlWord: movevuControl)
        
        let movav = 3
        let moveavControl = ControlWord().withVO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: movav, controlWord: moveavControl)
        
        let hlt = 4
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),
            Instruction(opcode: ldu, immediate: 42),
            Instruction(opcode: movvu, immediate: 0),
            Instruction(opcode: movav, immediate: 0),
            Instruction(opcode: hlt, immediate: 0)])
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerU.value, 42)
        XCTAssertEqual(computer.cpuState.registerV.value, 42)
        XCTAssertEqual(computer.cpuState.registerA.value, 42)
    }
    
    func testReadWriteRegistersAB() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let lda = 1
        let ldaControl = ControlWord().withAI(.active).withCO(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let movba = 2
        let movebaControl = ControlWord().withBI(.active).withAO(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: movba, controlWord: movebaControl)
        
        let movdb = 3
        let movedbControl = ControlWord().withDI(.active).withBO(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: movdb, controlWord: movedbControl)
        
        let hlt = 4
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),
            Instruction(opcode: lda, immediate: 42),
            Instruction(opcode: movba, immediate: 0),
            Instruction(opcode: movdb, immediate: 0),
            Instruction(opcode: hlt, immediate: 0)])
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerD.value, 42)
    }
    
    func testRAMStoreLoad() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let ldu = 1
        let lduControl = ControlWord().withCO(.active).withUI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldu, controlWord: lduControl)
        
        let ldv = 2
        let ldvControl = ControlWord().withCO(.active).withVI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldv, controlWord: ldvControl)
        
        let store = 3
        let storeControl = ControlWord().withMI(.active).withCO(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: store, controlWord: storeControl)
        
        let load = 4
        let loadControl = ControlWord().withMO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: load, controlWord: loadControl)
        
        let hlt = 5
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop,   immediate: 0),        // NOP
            Instruction(opcode: ldu,   immediate: 0),        // LDU $0
            Instruction(opcode: ldv,   immediate: 0),        // LDV $0
            Instruction(opcode: store, immediate: 42),       // STORE $42
            Instruction(opcode: load,  immediate: 0),        // LOAD A
            Instruction(opcode: hlt,   immediate: 0)])       // HLT
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerA.value, 42)
    }
    
    func testUnconditionalJump() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let hlt = 1
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let lda = 2
        let ldaControl = ControlWord().withCO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let ldx = 3
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 4
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let jmp = 5
        let jmpControl = ControlWord().withJ(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: jmp, controlWord: jmpControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),  // NOP
            Instruction(opcode: lda, immediate: 1),  // LDA $1
            Instruction(opcode: ldx, immediate: 0),  // LDX $0
            Instruction(opcode: ldy, immediate: 8),  // LDY $8
            Instruction(opcode: jmp, immediate: 0),  // JMP
            Instruction(opcode: nop, immediate: 0),  // NOP
            Instruction(opcode: nop, immediate: 0),  // NOP
            Instruction(opcode: lda, immediate: 2),  // LDA $2
            Instruction(opcode: hlt, immediate: 0)]) // HLT
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerA.value, 1)
    }
    
    func testConditionalJumpOnCarry_DontTakeTheJump() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let hlt = 1
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let lda = 2
        let ldaControl = ControlWord().withCO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let ldb = 3
        let ldbControl = ControlWord().withCO(.active).withBI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldb, controlWord: ldbControl)
        
        let ldx = 4
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 5
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let alu = 6
        let aluControl = ControlWord().withEO(.active).withDI(.active).withFI(.active).withCarryIn(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: alu, controlWord: aluControl)
        
        let jc = 7
        let jcControl = ControlWord().withJ(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: jc,
                                                          carryFlag:0,
                                                          equalFlag:0,
                                                          controlWord: nopControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jc,
                                                          carryFlag:1,
                                                          equalFlag:0,
                                                          controlWord: jcControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jc,
                                                          carryFlag:0,
                                                          equalFlag:1,
                                                          controlWord: nopControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jc,
                                                          carryFlag:1,
                                                          equalFlag:1,
                                                          controlWord: jcControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: lda, immediate: 2),          // LDA $2
            Instruction(opcode: ldb, immediate: 1),          // LDB $1
            Instruction(opcode: ldx, immediate: 0),          // LDX $0
            Instruction(opcode: ldy, immediate: 11),         // LDY $11
            Instruction(opcode: alu, immediate: 0b00000110), // SUB
            Instruction(opcode: nop, immediate: 0),          // NOP (We must at least one instruction between setting the flags and testing the flags)
            Instruction(opcode:  jc, immediate: 0),          // JC
            Instruction(opcode: nop, immediate: 0),          // NOP (We must have two NOPs following a jump to prevent the pipeline from filling with incorrect instructions)
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: lda, immediate: 42),         // LDA $42
            Instruction(opcode: hlt, immediate: 0)])         // HLT
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerD.value, 1)
        XCTAssertEqual(computer.cpuState.registerA.value, 42)
    }
    
    func testConditionalJumpOnCarry_TakeTheJump() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let hlt = 1
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let lda = 2
        let ldaControl = ControlWord().withCO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let ldb = 3
        let ldbControl = ControlWord().withCO(.active).withBI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldb, controlWord: ldbControl)
        
        let ldx = 4
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 5
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let alu = 6
        let aluControl = ControlWord().withEO(.active).withFI(.active).withDI(.active).withCarryIn(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: alu, controlWord: aluControl)
        
        let jc = 7
        let jcControl = ControlWord().withJ(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: jc,
                                                          carryFlag:1,
                                                          equalFlag:0,
                                                          controlWord: jcControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jc,
                                                          carryFlag:0,
                                                          equalFlag:0,
                                                          controlWord: nopControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jc,
                                                          carryFlag:1,
                                                          equalFlag:1,
                                                          controlWord: jcControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jc,
                                                          carryFlag:0,
                                                          equalFlag:1,
                                                          controlWord: nopControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: lda, immediate: 1),          // LDA $1
            Instruction(opcode: ldb, immediate: 2),          // LDB $2
            Instruction(opcode: ldx, immediate: 0),          // LDX $0
            Instruction(opcode: ldy, immediate: 11),         // LDY $11
            Instruction(opcode: alu, immediate: 0b00000110), // SUB
            Instruction(opcode: nop, immediate: 0),          // NOP (We must at least one instruction between setting the flags and testing the flags)
            Instruction(opcode:  jc, immediate: 0),          // JC $11
            Instruction(opcode: nop, immediate: 0),          // NOP (We must have two NOPs following a jump to prevent the pipeline from filling with incorrect instructions)
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: lda, immediate: 42),         // LDA $42
            Instruction(opcode: hlt, immediate: 0)])         // HLT
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerD.value, 255)
        XCTAssertEqual(computer.cpuState.registerA.value, 1)
    }
    
    func testUpperInstructionRAMStoreLoad() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let ldx = 1
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 2
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let store = 3
        let storeControl = ControlWord().withPI(.active).withCO(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: store, controlWord: storeControl)
        
        let load = 4
        let loadControl = ControlWord().withPO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: load, controlWord: loadControl)
        
        let hlt = 5
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let ldd = 6
        let lddControl = ControlWord().withCO(.active).withDI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldd, controlWord: lddControl)
        
        let lda = 7
        let ldaControl = ControlWord().withCO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop,   immediate: 0),    // NOP
            Instruction(opcode: ldd,   immediate: kUpperInstructionRAM),    // LDD $kUpperInstructionRAM
            Instruction(opcode: ldx,   immediate: 0),    // LDX $0
            Instruction(opcode: ldy,   immediate: 0),    // LDY $0
            Instruction(opcode: store, immediate: 42),   // STORE $42
            Instruction(opcode: lda,   immediate: 0),    // LDA $0
            Instruction(opcode: load,  immediate: 0),    // LOAD A
            Instruction(opcode: hlt,   immediate: 0)])   // HLT
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerA.value, 42)
    }
    
    func testLowerInstructionRAMStoreLoad() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let ldx = 1
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 2
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let store = 3
        let storeControl = ControlWord().withPI(.active).withCO(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: store, controlWord: storeControl)
        
        let load = 4
        let loadControl = ControlWord().withPO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: load, controlWord: loadControl)
        
        let hlt = 5
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let ldd = 6
        let lddControl = ControlWord().withCO(.active).withDI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldd, controlWord: lddControl)
        
        let lda = 7
        let ldaControl = ControlWord().withCO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop,   immediate: 0),    // NOP
            Instruction(opcode: ldd,   immediate: kLowerInstructionRAM),    // LDD $kLowerInstructionRAM
            Instruction(opcode: ldx,   immediate: 0),    // LDX $0
            Instruction(opcode: ldy,   immediate: 0),    // LDY $0
            Instruction(opcode: store, immediate: 42),   // STORE $42
            Instruction(opcode: lda,   immediate: 0),    // LDA $0
            Instruction(opcode: load,  immediate: 0),    // LOAD A
            Instruction(opcode: hlt,   immediate: 0)])   // HLT
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerA.value, 42)
    }
    
    func testExecuteInInstructionRAM() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let ldx = 1
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 2
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let store = 3
        let storeControl = ControlWord().withPI(.active).withCO(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: store, controlWord: storeControl)
        
        let hlt = 4
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let ldd = 5
        let lddControl = ControlWord().withCO(.active).withDI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldd, controlWord: lddControl)
        
        let lda = 6
        let ldaControl = ControlWord().withCO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let jmp = 7
        let jmpControl = ControlWord().withJ(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: jmp, controlWord: jmpControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop,   immediate: 0),    // NOP
            Instruction(opcode: ldx,   immediate: 0),    // LDX $0
            Instruction(opcode: ldy,   immediate: 0),    // LDY $0
            Instruction(opcode: ldd,   immediate: kUpperInstructionRAM),    // LDD $kUpperInstructionRAM
            Instruction(opcode: store, immediate: lda),  // STORE
            Instruction(opcode: ldd,   immediate: kLowerInstructionRAM),    // LDD $kLowerInstructionRAM
            Instruction(opcode: store, immediate: 42),   // STORE
            Instruction(opcode: ldx,   immediate: 1),    // LDX $1
            Instruction(opcode: ldy,   immediate: 1),    // LDY $1
            Instruction(opcode: ldd,   immediate: kUpperInstructionRAM),    // LDD $kUpperInstructionRAM
            Instruction(opcode: store, immediate: hlt),  // STORE
            Instruction(opcode: ldd,   immediate: kLowerInstructionRAM),    // LDD $kLowerInstructionRAM
            Instruction(opcode: store, immediate: 0),    // STORE
            Instruction(opcode: ldx,   immediate: 0x80), // LDX $0x80
            Instruction(opcode: ldy,   immediate: 0x00), // LDY $0x00
            Instruction(opcode: jmp,   immediate: 0),    // JMP
            Instruction(opcode: nop,   immediate: 0),    // NOP
            Instruction(opcode: nop,   immediate: 0),    // NOP
            Instruction(opcode: lda,   immediate: 1),    // LDA $1
            Instruction(opcode: hlt,   immediate: 0)])   // HLT
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerA.value, 42)
    }
    
    func testStoreLoadToPeripheralDeviceSevenDoesNothing() {
        // We've currently bound device seven to no peripheral devices.
        // In this case, an attempt to read or write to device seven will have
        // no effect.
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let ldx = 1
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 2
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let store = 3
        let storeControl = ControlWord().withPI(.active).withCO(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: store, controlWord: storeControl)
        
        let load = 4
        let loadControl = ControlWord().withPO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: load, controlWord: loadControl)
        
        let hlt = 5
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let ldd = 6
        let lddControl = ControlWord().withCO(.active).withDI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldd, controlWord: lddControl)
        
        let lda = 7
        let ldaControl = ControlWord().withCO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop,   immediate: 0),    // NOP
            Instruction(opcode: ldd,   immediate: 7),    // LDD $7
            Instruction(opcode: ldx,   immediate: 0),    // LDX $0
            Instruction(opcode: ldy,   immediate: 0),    // LDY $0
            Instruction(opcode: store, immediate: 42),   // STORE $42
            Instruction(opcode: lda,   immediate: 0),    // LDA $0
            Instruction(opcode: load,  immediate: 0),    // LOAD A
            Instruction(opcode: hlt,   immediate: 0)])   // HLT
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerA.value, 0)
    }
    
    func disabled_too_slow_testSaveLoadMicrocode() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let hlt = 5
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(NSUUID().uuidString)
        let oldDecoder = computer.instructionDecoder
        try! computer.saveMicrocode(to: url)
        
        computer.provideMicrocode(microcode: InstructionDecoder())
        
        for i in 0...oldDecoder.rom.count {
            XCTAssertNotEqual(oldDecoder.rom[i].data, computer.instructionDecoder.rom[i].data)
        }
        
        try! computer.loadMicrocode(from: url)
        
        for i in 0...oldDecoder.rom.count {
            XCTAssertEqual(oldDecoder.rom[i].data, computer.instructionDecoder.rom[i].data)
        }
    }
    
    func disabled_too_slow_testSaveLoadProgram() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let hlt = 1
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop,   immediate: 0),    // NOP
            Instruction(opcode: hlt,   immediate: 0)])   // HLT
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(NSUUID().uuidString)
        let oldProgram = computer.instructionROM
        try! computer.saveProgram(to: url)
        
        computer.provideInstructions([
            Instruction(opcode: nop,   immediate: 1),    // NOP
            Instruction(opcode: nop,   immediate: 1),    // NOP
            Instruction(opcode: nop,   immediate: 1),    // NOP
            Instruction(opcode: nop,   immediate: 1),    // NOP
            Instruction(opcode: hlt,   immediate: 1)])   // HLT
        XCTAssertNotEqual(oldProgram.upperROM.data, computer.instructionROM.upperROM.data)
        XCTAssertNotEqual(oldProgram.lowerROM.data, computer.instructionROM.lowerROM.data)
        
        try! computer.loadProgram(from: url)
        XCTAssertEqual(oldProgram.upperROM.data, computer.instructionROM.upperROM.data)
        XCTAssertEqual(oldProgram.lowerROM.data, computer.instructionROM.lowerROM.data)
    }
    
    func testIncrementXY() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let ldx = 1
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 2
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let inc = 3
        let incControl = ControlWord().withXYInc(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: inc, controlWord: incControl)
        
        let hlt = 4
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),
            Instruction(opcode: ldx, immediate: 0),
            Instruction(opcode: ldy, immediate: 0),
            Instruction(opcode: inc, immediate: 0),
            Instruction(opcode: hlt, immediate: 0)])
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerX.value, 0)
        XCTAssertEqual(computer.cpuState.registerY.value, 1)
    }
    
    func testIncrementUV() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let ldu = 1
        let lduControl = ControlWord().withCO(.active).withUI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldu, controlWord: lduControl)
        
        let ldv = 2
        let ldvControl = ControlWord().withCO(.active).withVI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldv, controlWord: ldvControl)
        
        let inc = 3
        let incControl = ControlWord().withUVInc(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: inc, controlWord: incControl)
        
        let hlt = 4
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),
            Instruction(opcode: ldu, immediate: 0),
            Instruction(opcode: ldv, immediate: 0),
            Instruction(opcode: inc, immediate: 0),
            Instruction(opcode: hlt, immediate: 0)])
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerU.value, 0)
        XCTAssertEqual(computer.cpuState.registerV.value, 1)
    }
    
    func testJALR() {
        // The JALR instruction enters the pipeline when PC is equal to 3.
        // The value of PC has been incremented to 5 by the time the EX stage
        // produces the control signal which causes the Link register to load.
        // So, the Link register will contain the address of the second delay
        // slot after the jump. (typically a NOP) The program can return to the
        // point immediately after the jump by jumping to the address stored in
        // the link register. This is useful for returning from a function call.
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let ldx = 1
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 2
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let jalr = 3
        let jalrControl = ControlWord().withLinkIn(.active).withJ(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: jalr, controlWord: jalrControl)
        
        let hlt = 4
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop,  immediate: 0),    // 0
            Instruction(opcode: ldx,  immediate: 0),    // 1
            Instruction(opcode: ldy,  immediate: 7),    // 2
            Instruction(opcode: jalr, immediate: 0),    // 3
            Instruction(opcode: nop,  immediate: 0),    // 4
            Instruction(opcode: nop,  immediate: 0),    // 5
            Instruction(opcode: ldx,  immediate: 0xff), // 6
            Instruction(opcode: hlt,  immediate: 0),    // 7
            Instruction(opcode: hlt,  immediate: 0),    // 8
            Instruction(opcode: hlt,  immediate: 0)])   // 9
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerG.value, 0)
        XCTAssertEqual(computer.cpuState.registerH.value, 7) // There's a hardware bug in Rev 1 where the Link register always loads from PC during a JALR instruction. As a result, the JALR instruction always latches the jump destination instead of the previous value of PC as intended.
        XCTAssertEqual(computer.cpuState.registerX.value, 0) // Assert that instruction 6 was skipped.
    }
    
    func testJE_TakeTheJump() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let hlt = 1
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let lda = 2
        let ldaControl = ControlWord().withCO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let ldb = 3
        let ldbControl = ControlWord().withCO(.active).withBI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldb, controlWord: ldbControl)
        
        let ldx = 4
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 5
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let cmp = 6
        let cmpControl = ControlWord().withFI(.active).withCarryIn(.inactive)
        instructionDecoder = instructionDecoder.withStore(opcode: cmp, controlWord: cmpControl)
        
        let je = 7
        let jeControl = ControlWord().withJ(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: je, carryFlag:0, equalFlag:0, controlWord: nopControl)
        instructionDecoder = instructionDecoder.withStore(opcode: je, carryFlag:1, equalFlag:0, controlWord: nopControl)
        instructionDecoder = instructionDecoder.withStore(opcode: je, carryFlag:0, equalFlag:1, controlWord: nopControl)
        instructionDecoder = instructionDecoder.withStore(opcode: je, carryFlag:1, equalFlag:1, controlWord: jeControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: ldx, immediate: 0),          // LDX 0
            Instruction(opcode: ldy, immediate: 11),         // LDY 11
            Instruction(opcode: lda, immediate: 16),         // LDA 16
            Instruction(opcode: ldb, immediate: 16),         // LDB 16
            Instruction(opcode: cmp, immediate: 0b00000110), // CMP
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode:  je, immediate: 0),          // JE 11
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: lda, immediate: 42),         // LDA 42
            Instruction(opcode: hlt, immediate: 0)])         // HLT
        
        computer.execute()
        
        XCTAssertNotEqual(computer.cpuState.registerA.value, 42)
    }
    
    func testJNE_TakeTheJump() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let hlt = 1
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let lda = 2
        let ldaControl = ControlWord().withCO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let ldb = 3
        let ldbControl = ControlWord().withCO(.active).withBI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldb, controlWord: ldbControl)
        
        let ldx = 4
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 5
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let cmp = 6
        let cmpControl = ControlWord().withFI(.active).withCarryIn(.inactive)
        instructionDecoder = instructionDecoder.withStore(opcode: cmp, controlWord: cmpControl)
        
        let jne = 7
        let jneControl = ControlWord().withJ(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: jne, carryFlag:0, equalFlag:0, controlWord: jneControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jne, carryFlag:1, equalFlag:0, controlWord: jneControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jne, carryFlag:0, equalFlag:1, controlWord: jneControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jne, carryFlag:1, equalFlag:1, controlWord: nopControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: ldx, immediate: 0),          // LDX 0
            Instruction(opcode: ldy, immediate: 11),         // LDY 11
            Instruction(opcode: lda, immediate: 16),         // LDA 16
            Instruction(opcode: ldb, immediate: 12),         // LDB 16
            Instruction(opcode: cmp, immediate: 0b00000110), // CMP
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: jne, immediate: 0),          // JNE 11
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: lda, immediate: 42),         // LDA 42
            Instruction(opcode: hlt, immediate: 0)])         // HLT
        
        computer.execute()
        
        XCTAssertNotEqual(computer.cpuState.registerA.value, 42)
    }
    
    func testJG_TakeTheJump() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let hlt = 1
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let lda = 2
        let ldaControl = ControlWord().withCO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let ldb = 3
        let ldbControl = ControlWord().withCO(.active).withBI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldb, controlWord: ldbControl)
        
        let ldx = 4
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 5
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let cmp = 6
        let cmpControl = ControlWord().withFI(.active).withCarryIn(.inactive)
        instructionDecoder = instructionDecoder.withStore(opcode: cmp, controlWord: cmpControl)
        
        let jg = 7
        let jgControl = ControlWord().withJ(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: jg, carryFlag:0, equalFlag:0, controlWord: jgControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jg, carryFlag:1, equalFlag:0, controlWord: nopControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jg, carryFlag:0, equalFlag:1, controlWord: nopControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jg, carryFlag:1, equalFlag:1, controlWord: nopControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: ldx, immediate: 0),          // LDX 0
            Instruction(opcode: ldy, immediate: 11),         // LDY 11
            Instruction(opcode: lda, immediate: 16),         // LDA 16
            Instruction(opcode: ldb, immediate: 12),         // LDB 12
            Instruction(opcode: cmp, immediate: 0b00000110), // CMP
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode:  jg, immediate: 0),          // JG 11
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: lda, immediate: 42),         // LDA 42
            Instruction(opcode: hlt, immediate: 0)])         // HLT
        
        computer.execute()
        
        XCTAssertNotEqual(computer.cpuState.registerA.value, 42)
    }
    
    func testJLE_TakeTheJump() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let hlt = 1
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let lda = 2
        let ldaControl = ControlWord().withCO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let ldb = 3
        let ldbControl = ControlWord().withCO(.active).withBI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldb, controlWord: ldbControl)
        
        let ldx = 4
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 5
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let cmp = 6
        let cmpControl = ControlWord().withFI(.active).withCarryIn(.inactive)
        instructionDecoder = instructionDecoder.withStore(opcode: cmp, controlWord: cmpControl)
        
        let jle = 7
        let jleControl = ControlWord().withJ(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: jle, carryFlag:0, equalFlag:0, controlWord: nopControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jle, carryFlag:1, equalFlag:0, controlWord: jleControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jle, carryFlag:0, equalFlag:1, controlWord: jleControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jle, carryFlag:1, equalFlag:1, controlWord: jleControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: ldx, immediate: 0),          // LDX 0
            Instruction(opcode: ldy, immediate: 11),         // LDY 11
            Instruction(opcode: lda, immediate: 12),         // LDA 12
            Instruction(opcode: ldb, immediate: 15),         // LDB 15
            Instruction(opcode: cmp, immediate: 0b00000110), // CMP
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: jle, immediate: 0),          // JLE 11
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: lda, immediate: 42),         // LDA 42
            Instruction(opcode: hlt, immediate: 0)])         // HLT
        
        computer.execute()
        
        XCTAssertNotEqual(computer.cpuState.registerA.value, 42)
    }
    
    func testJL_TakeTheJump() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let hlt = 1
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let lda = 2
        let ldaControl = ControlWord().withCO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let ldb = 3
        let ldbControl = ControlWord().withCO(.active).withBI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldb, controlWord: ldbControl)
        
        let ldx = 4
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 5
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let cmp = 6
        let cmpControl = ControlWord().withFI(.active).withCarryIn(.inactive)
        instructionDecoder = instructionDecoder.withStore(opcode: cmp, controlWord: cmpControl)
        
        let jl = 7
        let jlControl = ControlWord().withJ(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: jl, carryFlag:0, equalFlag:0, controlWord: nopControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jl, carryFlag:1, equalFlag:0, controlWord: jlControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jl, carryFlag:0, equalFlag:1, controlWord: nopControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jl, carryFlag:1, equalFlag:1, controlWord: nopControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: ldx, immediate: 0),          // LDX 0
            Instruction(opcode: ldy, immediate: 11),         // LDY 11
            Instruction(opcode: lda, immediate: 0),          // LDA 0
            Instruction(opcode: ldb, immediate: 1),          // LDB 1
            Instruction(opcode: cmp, immediate: 0b00000110), // CMP
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode:  jl, immediate: 0),          // JL 11
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: lda, immediate: 42),         // LDA 42
            Instruction(opcode: hlt, immediate: 0)])         // HLT
        
        computer.execute()
        
        XCTAssertNotEqual(computer.cpuState.registerA.value, 42)
    }
    
    func testJGE_TakeTheJump() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let hlt = 1
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let lda = 2
        let ldaControl = ControlWord().withCO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let ldb = 3
        let ldbControl = ControlWord().withCO(.active).withBI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldb, controlWord: ldbControl)
        
        let ldx = 4
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 5
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let cmp = 6
        let cmpControl = ControlWord().withFI(.active).withCarryIn(.inactive)
        instructionDecoder = instructionDecoder.withStore(opcode: cmp, controlWord: cmpControl)
        
        let jge = 7
        let jgeControl = ControlWord().withJ(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: jge, carryFlag:0, equalFlag:0, controlWord: jgeControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jge, carryFlag:1, equalFlag:0, controlWord: nopControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jge, carryFlag:0, equalFlag:1, controlWord: jgeControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jge, carryFlag:1, equalFlag:1, controlWord: jgeControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: ldx, immediate: 0),          // LDX 0
            Instruction(opcode: ldy, immediate: 11),         // LDY 11
            Instruction(opcode: lda, immediate: 1),          // LDA 5
            Instruction(opcode: ldb, immediate: 0),          // LDB 5
            Instruction(opcode: cmp, immediate: 0b00000110), // CMP
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: jge, immediate: 0),          // JGE 11
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: lda, immediate: 42),         // LDA 42
            Instruction(opcode: hlt, immediate: 0)])         // HLT
        
        computer.execute()
        
        XCTAssertNotEqual(computer.cpuState.registerA.value, 42)
    }
    
    func testJNC_TakeTheJump() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let hlt = 1
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let lda = 2
        let ldaControl = ControlWord().withCO(.active).withAI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let ldb = 3
        let ldbControl = ControlWord().withCO(.active).withBI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldb, controlWord: ldbControl)
        
        let ldx = 4
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 5
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
         let alu = 6
        let aluControl = ControlWord().withEO(.active).withFI(.active).withDI(.active).withCarryIn(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: alu, controlWord: aluControl)
        
        let jnc = 7
        let jncControl = ControlWord().withJ(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: jnc,
                                                          carryFlag:1,
                                                          equalFlag:0,
                                                          controlWord: nopControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jnc,
                                                          carryFlag:0,
                                                          equalFlag:0,
                                                          controlWord: jncControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jnc,
                                                          carryFlag:1,
                                                          equalFlag:1,
                                                          controlWord: nopControl)
        instructionDecoder = instructionDecoder.withStore(opcode: jnc,
                                                          carryFlag:0,
                                                          equalFlag:1,
                                                          controlWord: jncControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: lda, immediate: 2),          // LDA 2
            Instruction(opcode: ldb, immediate: 1),          // LDB 1
            Instruction(opcode: ldx, immediate: 0),          // LDX 0
            Instruction(opcode: ldy, immediate: 11),         // LDY 11
            Instruction(opcode: alu, immediate: 0b00000110), // SUB
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: jnc, immediate: 0),          // JNC 11
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: nop, immediate: 0),          // NOP
            Instruction(opcode: lda, immediate: 42),         // LDA 42
            Instruction(opcode: hlt, immediate: 0)])         // HLT
        
        computer.execute()
        
        XCTAssertEqual(computer.cpuState.registerD.value, 1)
        XCTAssertNotEqual(computer.cpuState.registerA.value, 42)
    }
    
    func testMethodToIncrementXY() {
        let computer = ComputerRev1()
        computer.incrementXY()
        XCTAssertEqual(computer.cpuState.registerX.value, 0)
        XCTAssertEqual(computer.cpuState.registerY.value, 1)
    }
    
    func testMethodToIncrementXY_CarryFromYToX() {
        let computer = ComputerRev1()
        computer.cpuState.registerY = Register(withValue: 255)
        computer.incrementXY()
        XCTAssertEqual(computer.cpuState.registerX.value, 1)
        XCTAssertEqual(computer.cpuState.registerY.value, 0)
    }
    
    func testMethodToIncrementXY_Overflow() {
        let computer = ComputerRev1()
        computer.cpuState.registerX = Register(withValue: 255)
        computer.cpuState.registerY = Register(withValue: 255)
        computer.incrementXY()
        XCTAssertEqual(computer.cpuState.registerX.value, 0)
        XCTAssertEqual(computer.cpuState.registerY.value, 0)
    }
    
    func testMethodToIncrementUV() {
        let computer = ComputerRev1()
        computer.incrementUV()
        XCTAssertEqual(computer.cpuState.registerU.value, 0)
        XCTAssertEqual(computer.cpuState.registerV.value, 1)
    }
    
    func testMethodToIncrementUV_CarryFromVToU() {
        let computer = ComputerRev1()
        computer.cpuState.registerV = Register(withValue: 255)
        computer.incrementUV()
        XCTAssertEqual(computer.cpuState.registerU.value, 1)
        XCTAssertEqual(computer.cpuState.registerV.value, 0)
    }
    
    func testMethodToIncrementUV_Overflow() {
        let computer = ComputerRev1()
        computer.cpuState.registerU = Register(withValue: 255)
        computer.cpuState.registerV = Register(withValue: 255)
        computer.incrementUV()
        XCTAssertEqual(computer.cpuState.registerU.value, 0)
        XCTAssertEqual(computer.cpuState.registerV.value, 0)
    }
}
