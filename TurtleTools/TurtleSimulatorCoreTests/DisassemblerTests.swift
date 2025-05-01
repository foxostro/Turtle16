//
//  DisassemblerTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 6/6/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleSimulatorCore
import XCTest

final class DisassemblerTests: XCTestCase {
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
        XCTAssertEqual(disassembler.disassembleOne(0b00010011_00100001), "LOAD r3, r1, 1")
    }

    func testLOAD_NegativeOffset() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b00010011_00111111), "LOAD r3, r1, -1")
    }

    func testSTORE() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b00011111_00101111), "STORE r3, r1, -1")
    }

    func testLI() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b00100011_00001101), "LI r3, 13")
    }

    func testLI_Negative() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b00100011_11111111), "LI r3, -1")
    }

    func testLUI() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b00101011_11001101), "LUI r3, 205")
    }

    func testCMP() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b00110000_00101000), "CMP r1, r2")
    }

    func testADD() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b00111000_00101000), "ADD r0, r1, r2")
    }

    func testSUB() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b01000000_00101000), "SUB r0, r1, r2")
    }

    func testAND() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b01001000_00101000), "AND r0, r1, r2")
    }

    func testOR() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b01010000_00101000), "OR r0, r1, r2")
    }

    func testXOR() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b01011000_00000000), "XOR r0, r0, r0")
    }

    func testNOT() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b01100000_00101000), "NOT r0, r1")
    }

    func testCMPI() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b01101000_00100001), "CMPI r1, 1")
    }

    func testADDI() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b01110000_00100010), "ADDI r0, r1, 2")
    }

    func testSUBI() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b01111000_00100001), "SUBI r0, r1, 1")
    }

    func testANDI() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b10000000_00101111), "ANDI r0, r1, 15")
    }

    func testORI() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b10001000_00101111), "ORI r0, r1, 15")
    }

    func testXORI() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b10010000_00101010), "XORI r0, r1, 10")
    }

    func testADC() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b11110000_00101000), "ADC r0, r1, r2")
    }

    func testSBC() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b11111000_00101000), "SBC r0, r1, r2")
    }

    func testJMP() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b10100011_11111111), "JMP 1023")
    }

    func testJMP_NegativeOffset() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b10100111_11111111), "JMP -1")
    }

    func testJR() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b10101000_00100000), "JR r1, 0")
    }

    func testJALR() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b10110111_00100000), "JALR r7, r1, 0")
    }

    func testBEQ() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b11000011_11111111), "BEQ 1023")
    }

    func testBNE() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b11001011_11111111), "BNE 1023")
    }

    func testBLT() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b11010011_11111111), "BLT 1023")
    }

    func testCreateLabelForJumpInstruction1() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(pc: 0, ins: 0b10100111_11111110), "JMP L0")
        XCTAssertEqual(
            disassembler.labels,
            [
                0: "L0"
            ]
        )
    }

    func testCreateLabelForJumpInstruction2() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(pc: 0, ins: 0b10100111_11111110), "JMP L0")
        XCTAssertEqual(disassembler.disassembleOne(pc: 1, ins: 0b10100111_11111101), "JMP L0")
        XCTAssertEqual(
            disassembler.labels,
            [
                0: "L0"
            ]
        )
    }

    func testCreateLabelForJumpInstruction3() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(pc: 0, ins: 0b10100111_11111110), "JMP L0")
        XCTAssertEqual(disassembler.disassembleOne(pc: 1, ins: 0b10100111_11111110), "JMP L1")
        XCTAssertEqual(disassembler.disassembleOne(pc: 2, ins: 0b10100111_11111110), "JMP L2")
        XCTAssertEqual(
            disassembler.labels,
            [
                0: "L0",
                1: "L1",
                2: "L2",
            ]
        )
    }

    func testCreateLabelForJumpInstruction4() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(pc: 0, ins: 0b10100111_11111110), "JMP L0")
        XCTAssertEqual(disassembler.disassembleOne(pc: 1, ins: 0b10100111_11111110), "JMP L1")
        XCTAssertEqual(disassembler.disassembleOne(pc: 2, ins: 0b10100111_11111101), "JMP L1")
        XCTAssertEqual(
            disassembler.labels,
            [
                0: "L0",
                1: "L1",
            ]
        )
    }

    func testDisassembleSeveralInstructions() throws {
        let disassembler = Disassembler()
        let program: [UInt16] = [
            0b00100000_00000000,  // LI r0, 0
            0b00100001_00000001,  // LI r1, 1
            0b00100111_00000000,  // LI r7, 0
            0b00111010_00000100,  // ADD r2, r0, r1
            0b01110000_00100000,  // ADDI r0, r1, 0
            0b01110111_11100001,  // ADDI r7, r7, 1
            0b01110001_01000000,  // ADDI r1, r2, 0
            0b01101000_11101001,  // CMPI r7, 9
            0b00001000_00000000,  // HLT
        ]
        let result = disassembler.disassembleToText(program)
        XCTAssertEqual(
            result,
            """
            LI r0, 0
            LI r1, 1
            LI r7, 0
            ADD r2, r0, r1
            ADDI r0, r1, 0
            ADDI r7, r7, 1
            ADDI r1, r2, 0
            CMPI r7, 9
            HLT
            """
        )
        XCTAssertEqual(disassembler.labels, [:])
    }

    func testDisassembleSeveralInstructionsWithLabels() throws {
        let disassembler = Disassembler()
        let program: [UInt16] = [
            0b00100000_00000000,  // LI r0, 0
            0b00100001_00000001,  // LI r1, 1
            0b00100111_00000000,  // LI r7, 0
            0b00111010_00000100,  // ADD r2, r0, r1
            0b01110000_00100000,  // ADDI r0, r1, 0
            0b01110111_11100001,  // ADDI r7, r7, 1
            0b01110001_01000000,  // ADDI r1, r2, 0
            0b01101000_11101001,  // CMPI r7, 9
            0b11010111_11111001,  // BLT -7
            0b00001000_00000000,  // HLT
        ]
        let result = disassembler.disassembleToText(program)
        XCTAssertEqual(
            result,
            """
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
            """
        )
        XCTAssertEqual(
            disassembler.labels,
            [
                3: "L0"
            ]
        )
    }

    func testDisassembleBadInstruction_Opcode19() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b10011011_11111111), nil)
    }

    func testDisassembleBadInstruction_Opcode23() throws {
        let disassembler = Disassembler()
        XCTAssertEqual(disassembler.disassembleOne(0b10111011_11111111), nil)
    }

    func testDisassembleSeveralInstructionsWithBadInstruction() throws {
        let disassembler = Disassembler()
        let program: [UInt16] = [
            0b00100000_00000000,  // LI r0, 0
            0b00100001_00000001,  // LI r1, 1
            0b00100111_00000000,  // LI r7, 0
            0b00111010_00000100,  // ADD r2, r0, r1
            0b01110000_00100000,  // ADDI r0, r1, 0
            0b01110111_11100001,  // ADDI r7, r7, 1
            0b01110001_01000000,  // ADDI r1, r2, 0
            0b10111011_11111111,  // 0xBBFF
            0b00001000_00000000,  // HLT
        ]
        let result = disassembler.disassembleToText(program)
        XCTAssertEqual(
            result,
            """
            LI r0, 0
            LI r1, 1
            LI r7, 0
            ADD r2, r0, r1
            ADDI r0, r1, 0
            ADDI r7, r7, 1
            ADDI r1, r2, 0

            HLT
            """
        )
        XCTAssertEqual(disassembler.labels, [:])
    }
}
