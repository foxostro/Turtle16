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
    let kOutputDisplay = 1
    let kUpperInstructionRAM = 3
    let kLowerInstructionRAM = 4
    let kDataRAM = 5
    
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
            .withStore(value: 0b1111111111111111, to: 0) // NOP
            .withStore(value: 0b1111011111111110, to: 1) // Set register A to immediate value 1.
        
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
        XCTAssertEqual(computer.currentState.controlWord.unsignedIntegerValue, 0xffff)
        
        // Fetch the assignment to A, Decode the NOP, Execute Whatever
        computer.step()
        
        XCTAssertEqual(computer.currentState.pc.value, 2)
        XCTAssertEqual(computer.currentState.pc_if.value, 1)
        XCTAssertEqual(computer.currentState.if_id.description, "{op=0b0, imm=0b0}")
        XCTAssertEqual(computer.currentState.controlWord.unsignedIntegerValue, 0xffff)
        
        // Fetch whatever, Decode the assignment to A, Execute the NOP
        computer.step()
        
        XCTAssertEqual(computer.currentState.pc.value, 3)
        XCTAssertEqual(computer.currentState.pc_if.value, 2)
        XCTAssertEqual(computer.currentState.if_id.description, "{op=0b1, imm=0b1}")
        XCTAssertEqual(computer.currentState.controlWord.unsignedIntegerValue, 0xffff)
        
        // Fetch whatever, Decode whatever, Execute the assignment to A.
        XCTAssertEqual(computer.currentState.registerA.value, 0)
        computer.step()
        XCTAssertEqual(computer.currentState.registerA.value, 1)
    }
    
    func testBasicAddition() {
        let computer = makeComputer()
        
        let nop = ControlWord()
        let lda = ControlWord().withCO(false).withAI(false)
        let sum = ControlWord().withEO(false).withAI(false)
        let hlt = ControlWord().withHLT(false)
        
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
        let lda = ControlWord().withCO(false).withAI(false)
        let sum = ControlWord().withEO(false).withAI(false)
        let hlt = ControlWord().withHLT(false)
        
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
        XCTAssertEqual(computer.describeControlWord(), "1111011011111111")
        XCTAssertEqual(computer.describeControlSignals(), "{EO, AI}")
    }
    
    func testReadWriteRegistersXY() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let ldx = 1
        let ldxControl = ControlWord().withCO(false).withXI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let movyx = 2
        let moveyxControl = ControlWord().withXO(false).withYI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: movyx, controlWord: moveyxControl)
        
        let movay = 3
        let moveayControl = ControlWord().withYO(false).withAI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: movay, controlWord: moveayControl)
        
        let hlt = 4
        let hltControl = ControlWord().withHLT(false)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop, immediate: 0),
            Instruction(opcode: ldx, immediate: 42),
            Instruction(opcode: movyx, immediate: 0),
            Instruction(opcode: movay, immediate: 0),
            Instruction(opcode: hlt, immediate: 0)])
        
        computer.execute()
        
        XCTAssertEqual(computer.currentState.registerA.value, 42)
    }
    
    func testReadWriteRegistersAB() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let lda = 1
        let ldaControl = ControlWord().withAI(false).withCO(false)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let movba = 2
        let movebaControl = ControlWord().withBI(false).withAO(false)
        instructionDecoder = instructionDecoder.withStore(opcode: movba, controlWord: movebaControl)
        
        let movdb = 3
        let movedbControl = ControlWord().withDI(false).withBO(false)
        instructionDecoder = instructionDecoder.withStore(opcode: movdb, controlWord: movedbControl)
        
        let hlt = 4
        let hltControl = ControlWord().withHLT(false)
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
        
        let ldx = 1
        let ldxControl = ControlWord().withCO(false).withXI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 2
        let ldyControl = ControlWord().withCO(false).withYI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let store = 3
        let storeControl = ControlWord().withMI(false).withCO(false)
        instructionDecoder = instructionDecoder.withStore(opcode: store, controlWord: storeControl)
        
        let load = 4
        let loadControl = ControlWord().withMO(false).withAI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: load, controlWord: loadControl)
        
        let hlt = 5
        let hltControl = ControlWord().withHLT(false)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let ldd = 6
        let lddControl = ControlWord().withCO(false).withDI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldd, controlWord: lddControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop,   immediate: 0),        // NOP
            Instruction(opcode: ldd,   immediate: kDataRAM), // LDD $kDataRAM
            Instruction(opcode: ldx,   immediate: 0),        // LDX $0
            Instruction(opcode: ldy,   immediate: 0),        // LDY $0
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
        let hltControl = ControlWord().withHLT(false)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let lda = 2
        let ldaControl = ControlWord().withCO(false).withAI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let ldx = 3
        let ldxControl = ControlWord().withCO(false).withXI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 4
        let ldyControl = ControlWord().withCO(false).withYI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let jmp = 5
        let jmpControl = ControlWord().withJ(false)
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
        let hltControl = ControlWord().withHLT(false)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let lda = 2
        let ldaControl = ControlWord().withCO(false).withAI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let ldb = 3
        let ldbControl = ControlWord().withCO(false).withBI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldb, controlWord: ldbControl)
        
        let ldx = 4
        let ldxControl = ControlWord().withCO(false).withXI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 5
        let ldyControl = ControlWord().withCO(false).withYI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let alu = 6
        let aluControl = ControlWord().withEO(false).withDI(false).withFI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: alu, controlWord: aluControl)
        
        let jc = 7
        let jcControl = ControlWord().withJ(false)
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
        let hltControl = ControlWord().withHLT(false)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let lda = 2
        let ldaControl = ControlWord().withCO(false).withAI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let ldb = 3
        let ldbControl = ControlWord().withCO(false).withBI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldb, controlWord: ldbControl)
        
        let ldx = 4
        let ldxControl = ControlWord().withCO(false).withXI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 5
        let ldyControl = ControlWord().withCO(false).withYI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let alu = 6
        let aluControl = ControlWord().withEO(false).withFI(false).withDI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: alu, controlWord: aluControl)
        
        let jc = 7
        let jcControl = ControlWord().withJ(false)
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
        let ldxControl = ControlWord().withCO(false).withXI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 2
        let ldyControl = ControlWord().withCO(false).withYI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let store = 3
        let storeControl = ControlWord().withMI(false).withCO(false)
        instructionDecoder = instructionDecoder.withStore(opcode: store, controlWord: storeControl)
        
        let load = 4
        let loadControl = ControlWord().withMO(false).withAI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: load, controlWord: loadControl)
        
        let hlt = 5
        let hltControl = ControlWord().withHLT(false)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let ldd = 6
        let lddControl = ControlWord().withCO(false).withDI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldd, controlWord: lddControl)
        
        let lda = 7
        let ldaControl = ControlWord().withCO(false).withAI(false)
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
        let ldxControl = ControlWord().withCO(false).withXI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 2
        let ldyControl = ControlWord().withCO(false).withYI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let store = 3
        let storeControl = ControlWord().withMI(false).withCO(false)
        instructionDecoder = instructionDecoder.withStore(opcode: store, controlWord: storeControl)
        
        let load = 4
        let loadControl = ControlWord().withMO(false).withAI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: load, controlWord: loadControl)
        
        let hlt = 5
        let hltControl = ControlWord().withHLT(false)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let ldd = 6
        let lddControl = ControlWord().withCO(false).withDI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldd, controlWord: lddControl)
        
        let lda = 7
        let ldaControl = ControlWord().withCO(false).withAI(false)
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
        let ldxControl = ControlWord().withCO(false).withXI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 2
        let ldyControl = ControlWord().withCO(false).withYI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let store = 3
        let storeControl = ControlWord().withMI(false).withCO(false)
        instructionDecoder = instructionDecoder.withStore(opcode: store, controlWord: storeControl)
        
        let hlt = 4
        let hltControl = ControlWord().withHLT(false)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let ldd = 5
        let lddControl = ControlWord().withCO(false).withDI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldd, controlWord: lddControl)
        
        let lda = 6
        let ldaControl = ControlWord().withCO(false).withAI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        let jmp = 7
        let jmpControl = ControlWord().withJ(false)
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
    
    func testStoreLoadToBankZeroDoesNothing() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let ldx = 1
        let ldxControl = ControlWord().withCO(false).withXI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldx, controlWord: ldxControl)
        
        let ldy = 2
        let ldyControl = ControlWord().withCO(false).withYI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldy, controlWord: ldyControl)
        
        let store = 3
        let storeControl = ControlWord().withMI(false).withCO(false)
        instructionDecoder = instructionDecoder.withStore(opcode: store, controlWord: storeControl)
        
        let load = 4
        let loadControl = ControlWord().withMO(false).withAI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: load, controlWord: loadControl)
        
        let hlt = 5
        let hltControl = ControlWord().withHLT(false)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let ldd = 6
        let lddControl = ControlWord().withCO(false).withDI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldd, controlWord: lddControl)
        
        let lda = 7
        let ldaControl = ControlWord().withCO(false).withAI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop,   immediate: 0),    // NOP
            Instruction(opcode: ldd,   immediate: 0),    // LDD $0
            Instruction(opcode: ldx,   immediate: 0),    // LDX $0
            Instruction(opcode: ldy,   immediate: 0),    // LDY $0
            Instruction(opcode: store, immediate: 42),   // STORE $42
            Instruction(opcode: lda,   immediate: 0),    // LDA $0
            Instruction(opcode: load,  immediate: 0),    // LOAD A
            Instruction(opcode: hlt,   immediate: 0)])   // HLT
        
        computer.execute()
        
        XCTAssertEqual(computer.currentState.registerA.value, 0)
    }
    
    func testStoreToOutputDisplay() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let store = 3
        let storeControl = ControlWord().withMI(false).withCO(false)
        instructionDecoder = instructionDecoder.withStore(opcode: store, controlWord: storeControl)
        
        let load = 4
        let loadControl = ControlWord().withMO(false).withAI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: load, controlWord: loadControl)
        
        let hlt = 5
        let hltControl = ControlWord().withHLT(false)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let ldd = 6
        let lddControl = ControlWord().withCO(false).withDI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldd, controlWord: lddControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop,   immediate: 0),    // NOP
            Instruction(opcode: ldd,   immediate: kOutputDisplay),    // LDD $kOutputDisplay
            Instruction(opcode: store, immediate: 42),   // STORE $42
            Instruction(opcode: hlt,   immediate: 0)])   // HLT
        
        computer.execute()
        
        XCTAssertEqual(computer.currentState.outputDisplay.value, 42)
        XCTAssertEqual(computer.describeOutputDisplay(), String(42, radix: 10))
    }
    
    func testLoadFromOutputDisplay() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let store = 3
        let storeControl = ControlWord().withMI(false).withCO(false)
        instructionDecoder = instructionDecoder.withStore(opcode: store, controlWord: storeControl)
        
        let load = 4
        let loadControl = ControlWord().withMO(false).withAI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: load, controlWord: loadControl)
        
        let hlt = 5
        let hltControl = ControlWord().withHLT(false)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        let ldd = 6
        let lddControl = ControlWord().withCO(false).withDI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: ldd, controlWord: lddControl)
        
        let lda = 7
        let ldaControl = ControlWord().withCO(false).withAI(false)
        instructionDecoder = instructionDecoder.withStore(opcode: lda, controlWord: ldaControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        computer.provideInstructions([
            Instruction(opcode: nop,   immediate: 0),    // NOP
            Instruction(opcode: ldd,   immediate: kOutputDisplay),    // LDD $kOutputDisplay
            Instruction(opcode: store, immediate: 42),   // STORE $42
            Instruction(opcode: lda,   immediate: 0),    // LDA $0
            Instruction(opcode: load,  immediate: 0),    // LOAD A
            Instruction(opcode: hlt,   immediate: 0)])   // HLT
        
        computer.execute()
        
        XCTAssertEqual(computer.currentState.registerA.value, 42)
    }
    
    func testSaveLoadMicrocode() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let hlt = 5
        let hltControl = ControlWord().withHLT(false)
        instructionDecoder = instructionDecoder.withStore(opcode: hlt, controlWord: hltControl)
        
        computer.provideMicrocode(microcode: instructionDecoder)
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(NSUUID().uuidString)
        let oldDecoder = computer.currentState.instructionDecoder
        try! computer.saveMicrocode(to: url)
        
        computer.provideMicrocode(microcode: InstructionDecoder())
        XCTAssertNotEqual(oldDecoder.upperROM.data, computer.currentState.instructionDecoder.upperROM.data)
        XCTAssertNotEqual(oldDecoder.lowerROM.data, computer.currentState.instructionDecoder.lowerROM.data)
        
        try! computer.loadMicrocode(from: url)
        XCTAssertEqual(oldDecoder.upperROM.data, computer.currentState.instructionDecoder.upperROM.data)
        XCTAssertEqual(oldDecoder.lowerROM.data, computer.currentState.instructionDecoder.lowerROM.data)
    }
    
    func testSaveLoadProgram() {
        let computer = makeComputer()
        
        var instructionDecoder = InstructionDecoder()
        
        let nop = 0
        let nopControl = ControlWord()
        instructionDecoder = instructionDecoder.withStore(opcode: nop, controlWord: nopControl)
        
        let hlt = 1
        let hltControl = ControlWord().withHLT(false)
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
}
