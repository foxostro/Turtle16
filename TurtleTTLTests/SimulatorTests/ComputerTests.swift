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
    let isVerboseLogging = true
    let kUpperInstructionRAM = 0
    let kLowerInstructionRAM = 1
    
    class ConsoleLogger: NSObject, Logger {
        func append(_ format: String, _ args: CVarArg...) {
            let message = String(format:format, arguments:args)
            NSLog(message)
        }
    }
    
    func makeComputer() -> Computer {
        let computer = Computer()
        computer.logger = isVerboseLogging ? ConsoleLogger() : nil
        return computer
    }
    
    func testReset() {
        let computer = makeComputer()
        computer.reset()
        XCTAssertEqual(computer.currentState.pc.value, 0)
        XCTAssertEqual(computer.currentState.pc_if.value, 0)
        XCTAssertEqual(computer.currentState.registerC.value, 0)
    }
    
    func testBasicExample() {
        let computer = makeComputer()
        
        let instructionDecoder = InstructionDecoder()
            .withStore(value: 0b11111111111111111111111111111111, to: 0) // NOP
            .withStore(value: 0b11111111111111111111111111101110, to: 1) // MOV C, A
        
        let instructionROM = InstructionROM()
            .withStore(value: 0b0000000000000000, to: 0) // NOP
            .withStore(value: 0b0000000100000001, to: 1) // Set register A to immediate value 1.
        
        computer.currentState = computer.currentState
            .withInstructionDecoder(instructionDecoder)
            .withInstructionROM(instructionROM)
        
        computer.reset()
        
        // Fetch the NOP, Decode Whatever, Execute Whatever
        computer.step()
        
        XCTAssertEqual(computer.currentState.pc.value, 1)
        XCTAssertEqual(computer.currentState.pc_if.value, 0)
        XCTAssertEqual(computer.currentState.if_id.description, "{op=0b0, imm=0b0}")
        XCTAssertEqual(computer.currentState.controlWord.unsignedIntegerValue, 0xffffffff)
        
        // Fetch the assignment to A, Decode the NOP, Execute Whatever
        computer.step()
        
        XCTAssertEqual(computer.currentState.pc.value, 2)
        XCTAssertEqual(computer.currentState.pc_if.value, 1)
        XCTAssertEqual(computer.currentState.if_id.description, "{op=0b0, imm=0b0}")
        XCTAssertEqual(computer.currentState.controlWord.unsignedIntegerValue, 0xffffffff)
        
        // Fetch whatever, Decode the assignment to A, Execute the NOP
        computer.step()
        
        XCTAssertEqual(computer.currentState.pc.value, 3)
        XCTAssertEqual(computer.currentState.pc_if.value, 2)
        XCTAssertEqual(computer.currentState.if_id.description, "{op=0b1, imm=0b1}")
        XCTAssertEqual(computer.currentState.controlWord.unsignedIntegerValue, 0xffffffff)
        
        // Fetch whatever, Decode whatever, Execute the assignment to A.
        XCTAssertEqual(computer.currentState.registerA.value, 0)
        computer.step()
        XCTAssertEqual(computer.currentState.registerA.value, 1)
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
        
        computer.currentState = computer.currentState
            .withInstructionDecoder(instructionDecoder)
            .withInstructionROM(instructionROM)
        
        computer.execute()
        
        XCTAssertEqual(computer.currentState.registerA.value, 3)
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
        
        computer.currentState = computer.currentState
            .withInstructionDecoder(instructionDecoder)
            .withInstructionROM(instructionROM)
        
        computer.step()
        computer.step()
        computer.step()
        computer.step()
        computer.step()
        computer.step()
        
        XCTAssertEqual(computer.describeALUResult(), "3")
        XCTAssertEqual(computer.describeBus(), "3")
        XCTAssertEqual(computer.describeControlWord(), "11111011111111111111111110111110")
        XCTAssertEqual(computer.describeControlSignals(), "{AI, EO, CarryIn}")
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
        
        XCTAssertEqual(computer.currentState.registerX.value, 42)
        XCTAssertEqual(computer.currentState.registerY.value, 42)
        XCTAssertEqual(computer.currentState.registerA.value, 42)
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
        
        XCTAssertEqual(computer.currentState.registerU.value, 42)
        XCTAssertEqual(computer.currentState.registerV.value, 42)
        XCTAssertEqual(computer.currentState.registerA.value, 42)
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
        
        XCTAssertEqual(computer.currentState.registerD.value, 42)
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
        
        XCTAssertEqual(computer.currentState.registerA.value, 42)
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
        
        XCTAssertEqual(computer.currentState.registerA.value, 1)
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
        
        XCTAssertEqual(computer.currentState.registerD.value, 1)
        XCTAssertEqual(computer.currentState.registerA.value, 42)
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
        
        XCTAssertEqual(computer.currentState.registerD.value, 255)
        XCTAssertEqual(computer.currentState.registerA.value, 1)
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
        
        XCTAssertEqual(computer.currentState.registerA.value, 42)
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
        
        XCTAssertEqual(computer.currentState.registerA.value, 42)
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
        
        XCTAssertEqual(computer.currentState.registerA.value, 42)
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
        
        XCTAssertEqual(computer.currentState.registerA.value, 0)
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
        let oldDecoder = computer.currentState.instructionDecoder
        try! computer.saveMicrocode(to: url)
        
        computer.provideMicrocode(microcode: InstructionDecoder())
        
        for i in 0...oldDecoder.rom.count {
            XCTAssertNotEqual(oldDecoder.rom[i].data, computer.currentState.instructionDecoder.rom[i].data)
        }
        
        try! computer.loadMicrocode(from: url)
        
        for i in 0...oldDecoder.rom.count {
            XCTAssertEqual(oldDecoder.rom[i].data, computer.currentState.instructionDecoder.rom[i].data)
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
        let oldProgram = computer.currentState.instructionROM
        try! computer.saveProgram(to: url)
        
        computer.provideInstructions([
            Instruction(opcode: nop,   immediate: 1),    // NOP
            Instruction(opcode: nop,   immediate: 1),    // NOP
            Instruction(opcode: nop,   immediate: 1),    // NOP
            Instruction(opcode: nop,   immediate: 1),    // NOP
            Instruction(opcode: hlt,   immediate: 1)])   // HLT
        XCTAssertNotEqual(oldProgram.upperROM.data, computer.currentState.instructionROM.upperROM.data)
        XCTAssertNotEqual(oldProgram.lowerROM.data, computer.currentState.instructionROM.lowerROM.data)
        
        try! computer.loadProgram(from: url)
        XCTAssertEqual(oldProgram.upperROM.data, computer.currentState.instructionROM.upperROM.data)
        XCTAssertEqual(oldProgram.lowerROM.data, computer.currentState.instructionROM.lowerROM.data)
    }
    
    func testModifyRegisterA_InvalidInput() {
        let computer = makeComputer()
        computer.modifyRegisterA(withString: "foo")
        XCTAssertEqual(computer.describeRegisterA(), "0")
    }
    
    func testModifyRegisterA() {
        let computer = makeComputer()
        computer.modifyRegisterA(withString: "ff")
        XCTAssertEqual(computer.describeRegisterA(), "ff")
        XCTAssertEqual(computer.currentState.registerA.value, 255)
    }
    
    func testModifyRegisterB_InvalidInput() {
        let computer = makeComputer()
        computer.modifyRegisterB(withString: "foo")
        XCTAssertEqual(computer.describeRegisterB(), "0")
    }
    
    func testModifyRegisterB() {
        let computer = makeComputer()
        computer.modifyRegisterB(withString: "ff")
        XCTAssertEqual(computer.describeRegisterB(), "ff")
        XCTAssertEqual(computer.currentState.registerB.value, 255)
    }
    
    func testModifyRegisterC_InvalidInput() {
        let computer = makeComputer()
        computer.modifyRegisterB(withString: "foo")
        XCTAssertEqual(computer.describeRegisterC(), "0")
    }
    
    func testModifyRegisterC() {
        let computer = makeComputer()
        computer.modifyRegisterC(withString: "ff")
        XCTAssertEqual(computer.describeRegisterC(), "ff")
        XCTAssertEqual(computer.currentState.registerC.value, 255)
    }
    
    func testModifyRegisterD_InvalidInput() {
        let computer = makeComputer()
        computer.modifyRegisterD(withString: "foo")
        XCTAssertEqual(computer.describeRegisterD(), "0")
    }
    
    func testModifyRegisterD() {
        let computer = makeComputer()
        computer.modifyRegisterD(withString: "ff")
        XCTAssertEqual(computer.describeRegisterD(), "ff")
        XCTAssertEqual(computer.currentState.registerD.value, 255)
    }
    
    func testModifyRegisterX_InvalidInput() {
        let computer = makeComputer()
        computer.modifyRegisterX(withString: "foo")
        XCTAssertEqual(computer.describeRegisterX(), "0")
    }
    
    func testModifyRegisterX() {
        let computer = makeComputer()
        computer.modifyRegisterX(withString: "ff")
        XCTAssertEqual(computer.describeRegisterX(), "ff")
        XCTAssertEqual(computer.currentState.registerX.value, 255)
    }
    
    func testModifyRegisterY_InvalidInput() {
        let computer = makeComputer()
        computer.modifyRegisterY(withString: "foo")
        XCTAssertEqual(computer.describeRegisterY(), "0")
    }
    
    func testModifyRegisterY() {
        let computer = makeComputer()
        computer.modifyRegisterY(withString: "ff")
        XCTAssertEqual(computer.describeRegisterY(), "ff")
        XCTAssertEqual(computer.currentState.registerY.value, 255)
    }
    
    func testModifyRegisterU_InvalidInput() {
        let computer = makeComputer()
        computer.modifyRegisterU(withString: "foo")
        XCTAssertEqual(computer.describeRegisterU(), "0")
    }
    
    func testModifyRegisterU() {
        let computer = makeComputer()
        computer.modifyRegisterU(withString: "ff")
        XCTAssertEqual(computer.describeRegisterU(), "ff")
        XCTAssertEqual(computer.currentState.registerU.value, 255)
    }
    
    func testModifyRegisterV_InvalidInput() {
        let computer = makeComputer()
        computer.modifyRegisterV(withString: "foo")
        XCTAssertEqual(computer.describeRegisterV(), "0")
    }
    
    func testModifyRegisterV() {
        let computer = makeComputer()
        computer.modifyRegisterV(withString: "ff")
        XCTAssertEqual(computer.describeRegisterV(), "ff")
        XCTAssertEqual(computer.currentState.registerV.value, 255)
    }
    
    func testModifyPC_InvalidInput() {
        let computer = makeComputer()
        computer.modifyPC(withString: "foo")
        XCTAssertEqual(computer.describePC(), "0")
    }
    
    func testModifyPC() {
        let computer = makeComputer()
        computer.modifyPC(withString: "ff")
        XCTAssertEqual(computer.describePC(), "ff")
        XCTAssertEqual(computer.currentState.pc.value, 255)
    }
    
    func testModifyPCIF_InvalidInput() {
        let computer = makeComputer()
        computer.modifyPCIF(withString: "foo")
        XCTAssertEqual(computer.describePCIF(), "0")
    }
    
    func testModifyPCIF() {
        let computer = makeComputer()
        computer.modifyPCIF(withString: "ff")
        XCTAssertEqual(computer.describePCIF(), "ff")
        XCTAssertEqual(computer.currentState.pc_if.value, 255)
    }
    
    func testModifyIFID_InvalidInput() {
        let computer = makeComputer()
        computer.modifyIFID(withString: "foo")
        XCTAssertEqual(computer.describeIFID(), "{op=0b0, imm=0b0}")
    }
    
    func testModifyIFID() {
        let computer = makeComputer()
        computer.modifyIFID(withString: "{op=0b11111111, imm=0b11111111}")
        XCTAssertEqual(computer.describeIFID(), "{op=0b11111111, imm=0b11111111}")
        XCTAssertEqual(computer.currentState.if_id.value, 0xffff)
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
        
        XCTAssertEqual(computer.currentState.registerX.value, 0)
        XCTAssertEqual(computer.currentState.registerY.value, 1)
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
        
        XCTAssertEqual(computer.currentState.registerU.value, 0)
        XCTAssertEqual(computer.currentState.registerV.value, 1)
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
        
        XCTAssertEqual(computer.currentState.registerG.value, 0)
        XCTAssertEqual(computer.currentState.registerH.value, 5)
        XCTAssertEqual(computer.currentState.registerX.value, 0) // Assert that instruction 6 was skipped.
    }
    
    func testBlockCopyIncrement() {
        // We can construct a special instruction to aid in block copies from
        // data RAM to to a peripheral destination. This could be used, for
        // example, to accelerate copies from data RAM to video RAM.
        // This instruction copies from one memory to the other,
        // simultaneously increments the UV and XY registers.
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let ldd = 1
        let lddControl = ControlWord().withCO(.active).withDI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldd, controlWord: lddControl)
        
        let ldx = 2
        let ldxControl = ControlWord().withCO(.active).withXI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 3
        let ldyControl = ControlWord().withCO(.active).withYI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let ldu = 4
        let lduControl = ControlWord().withCO(.active).withUI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldu, controlWord: lduControl)
        
        let ldv = 5
        let ldvControl = ControlWord().withCO(.active).withVI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: ldv, controlWord: ldvControl)
        
        let blt = 6
        let bltControl = ControlWord()
            .withUVInc(.active)
            .withXYInc(.active)
            .withMO(.active)
            .withPI(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: blt, controlWord: bltControl)
        
        let hlt = 7
        let hltControl = ControlWord().withHLT(.active)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop,  immediate: 0),
            Instruction(opcode: ldd,  immediate: 6),
            Instruction(opcode: ldx,  immediate: 0),
            Instruction(opcode: ldy,  immediate: 255),
            Instruction(opcode: ldu,  immediate: 0),
            Instruction(opcode: ldv,  immediate: 255),
            Instruction(opcode: blt,  immediate: 0),
            Instruction(opcode: blt,  immediate: 0),
            Instruction(opcode: blt,  immediate: 0),
            Instruction(opcode: hlt,  immediate: 0)])
        
        computer.execute()
        
        XCTAssertEqual(computer.currentState.registerU.value, 1)
        XCTAssertEqual(computer.currentState.registerV.value, 2)
        XCTAssertEqual(computer.currentState.registerX.value, 1)
        XCTAssertEqual(computer.currentState.registerY.value, 2)
        XCTAssertEqual(computer.currentState.serialOutput, [0, 0, 0])
    }
}
