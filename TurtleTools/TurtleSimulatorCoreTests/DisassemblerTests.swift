//
//  DisassemblerTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 6/6/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleSimulatorCore

class DisassemblerTests: XCTestCase {
    func testNOP() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0x0000), "NOP")
    }
    
    func testHLT() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0x0800), "HLT")
    }
    
    func testLOAD() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b0001001100100001), "LOAD r3, r1, 1")
    }
    
    func testLOAD_NegativeOffset() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b0001001100111111), "LOAD r3, r1, -1")
    }
    
    func testSTORE() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b0001111100101111), "STORE r3, r1, -1")
    }
    
    func testLI() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b0010001100001101), "LI r3, 13")
    }
    
    func testLI_Negative() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b0010001111111111), "LI r3, -1")
    }
    
    func testLUI() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b0010101111001101), "LUI r3, 205")
    }
    
    func testCMP() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b0011000000101000), "CMP r1, r2")
    }
    
    func testADD() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b0011100000101000), "ADD r0, r1, r2")
    }
    
    func testSUB() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b0100000000101000), "SUB r0, r1, r2")
    }
    
    func testAND() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b0100100000101000), "AND r0, r1, r2")
    }
    
    func testOR() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b0101000000101000), "OR r0, r1, r2")
    }
    
    func testXOR() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b0101100000000000), "XOR r0, r0, r0")
    }
    
    func testNOT() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b0110000000101000), "NOT r0, r1")
    }
    
    func testCMPI() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b0110100000100001), "CMPI r1, 1")
    }
    
    func testADDI() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b0111000000100010), "ADDI r0, r1, 2")
    }
    
    func testSUBI() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b0111100000100001), "SUBI r0, r1, 1")
    }
    
    func testANDI() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b1000000000101111), "ANDI r0, r1, 15")
    }
    
    func testORI() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b1000100000101111), "ORI r0, r1, 15")
    }
    
    func testXORI() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b1001000000101010), "XORI r0, r1, 10")
    }
    
    func testADC() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b1111000000101000), "ADC r0, r1, r2")
    }
    
    func testSBC() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b1111100000101000), "SBC r0, r1, r2")
    }
    
    func testJMP() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b1010001111111111), "JMP 1023")
    }
    
    func testJMP_NegativeOffset() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b1010011111111111), "JMP -1")
    }
    
    func testJR() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b1010100000100000), "JR r1, 0")
    }
    
    func testJALR() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b1011011100100000), "JALR r7, r1, 0")
    }
    
    func testBEQ() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b1100001111111111), "BEQ 1023")
    }
    
    func testBNE() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b1100101111111111), "BNE 1023")
    }
    
    func testBLT() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b1101001111111111), "BLT 1023")
    }
    
    func testCreateLabelForJumpInstruction1() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(pc: 0, ins: 0b1010011111111110), "JMP L0")
        XCTAssertEqual(disassembler.labels, [
            0 : "L0"
        ])
    }
    
    func testCreateLabelForJumpInstruction2() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(pc: 0, ins: 0b1010011111111110), "JMP L0")
        XCTAssertEqual(disassembler.disassembleOne(pc: 1, ins: 0b1010011111111101), "JMP L0")
        XCTAssertEqual(disassembler.labels, [
            0 : "L0"
        ])
    }
    
    func testCreateLabelForJumpInstruction3() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(pc: 0, ins: 0b1010011111111110), "JMP L0")
        XCTAssertEqual(disassembler.disassembleOne(pc: 1, ins: 0b1010011111111110), "JMP L1")
        XCTAssertEqual(disassembler.disassembleOne(pc: 2, ins: 0b1010011111111110), "JMP L2")
        XCTAssertEqual(disassembler.labels, [
            0 : "L0",
            1 : "L1",
            2 : "L2"
        ])
    }
    
    func testCreateLabelForJumpInstruction4() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(pc: 0, ins: 0b1010011111111110), "JMP L0")
        XCTAssertEqual(disassembler.disassembleOne(pc: 1, ins: 0b1010011111111110), "JMP L1")
        XCTAssertEqual(disassembler.disassembleOne(pc: 2, ins: 0b1010011111111101), "JMP L1")
        XCTAssertEqual(disassembler.labels, [
            0 : "L0",
            1 : "L1"
        ])
    }
    
    func testDisassembleSeveralInstructions() throws {
        let disassembler = Disassembler()
        let program: [UInt16] = [
            0b0010000000000000, // LI r0, 0
            0b0010000100000001, // LI r1, 1
            0b0010011100000000, // LI r7, 0
            0b0011101000000100, // ADD r2, r0, r1
            0b0111000000100000, // ADDI r0, r1, 0
            0b0111011111100001, // ADDI r7, r7, 1
            0b0111000101000000, // ADDI r1, r2, 0
            0b0110100011101001, // CMPI r7, 9
            0b0000100000000000, // HLT
        ]
        let result = disassembler.disassembleToText(program)
        XCTAssertEqual(result, """
LI r0, 0
LI r1, 1
LI r7, 0
ADD r2, r0, r1
ADDI r0, r1, 0
ADDI r7, r7, 1
ADDI r1, r2, 0
CMPI r7, 9
HLT
""")
        XCTAssertEqual(disassembler.labels, [:])
    }
    
    func testDisassembleSeveralInstructionsWithLabels() throws {
        let disassembler = Disassembler()
        let program: [UInt16] = [
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
        ]
        let result = disassembler.disassembleToText(program)
        XCTAssertEqual(result, """
LI r0, 0
LI r1, 1
LI r7, 0
L0: ADD r2, r0, r1
ADDI r0, r1, 0
ADDI r7, r7, 1
ADDI r1, r2, 0
CMPI r7, 9
BLT L0
HLT
""")
        XCTAssertEqual(disassembler.labels, [
            3 : "L0"
        ])
    }
    
    func testDisassembleBadInstruction_Opcode19() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b1001101111111111), nil)
    }
    
    func testDisassembleBadInstruction_Opcode23() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b1011101111111111), nil)
    }
    
    func testDisassembleSeveralInstructionsWithBadInstruction() throws {
        let disassembler = Disassembler()
        let program: [UInt16] = [
            0b0010000000000000, // LI r0, 0
            0b0010000100000001, // LI r1, 1
            0b0010011100000000, // LI r7, 0
            0b0011101000000100, // ADD r2, r0, r1
            0b0111000000100000, // ADDI r0, r1, 0
            0b0111011111100001, // ADDI r7, r7, 1
            0b0111000101000000, // ADDI r1, r2, 0
            0b1011101111111111, // 0xBBFF
            0b0000100000000000, // HLT
        ]
        let result = disassembler.disassembleToText(program)
        XCTAssertEqual(result, """
LI r0, 0
LI r1, 1
LI r7, 0
ADD r2, r0, r1
ADDI r0, r1, 0
ADDI r7, r7, 1
ADDI r1, r2, 0

HLT
""")
        XCTAssertEqual(disassembler.labels, [:])
    }
}
