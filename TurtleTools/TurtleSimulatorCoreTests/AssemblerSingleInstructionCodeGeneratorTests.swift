//
//  AssemblerSingleInstructionCodeGeneratorTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 5/17/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleSimulatorCore
import XCTest

final class AssemblerSingleInstructionCodeGeneratorTests: XCTestCase {
    func testNop() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(codeGen.nop(), 0b00000000_00000000)
    }

    func testHlt() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(codeGen.hlt(), 0b00001000_00000000)
    }

    func testLoad() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.load(.r3, .r1, 1), 0b00010011_00100001) // LOAD r3, 1(r1)
    }

    func testLoadWithNegativeOffset() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.load(.r3, .r1, -1), 0b00010011_00111111) // LOAD r3, -1(r1)
    }

    func testLoadWithOffsetExceedingPositiveLimit() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertThrowsError(try codeGen.load(.r3, .r1, 16)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds positive limit of 15: `16'")
        }
    }

    func testLoadWithOffsetExceedingNegativeLimit() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertThrowsError(try codeGen.load(.r3, .r1, -17)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds negative limit of -16: `-17'")
        }
    }

    func testStore() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.store(.r3, .r1, -1), 0b00011111_00101111) // STORE r3, -1(r1)
    }

    func testStoreWithOffsetExceedingPositiveLimit() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertThrowsError(try codeGen.store(.r3, .r1, 16)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds positive limit of 15: `16'")
        }
    }

    func testStoreWithOffsetExceedingNegativeLimit() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertThrowsError(try codeGen.store(.r3, .r1, -17)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds negative limit of -16: `-17'")
        }
    }

    func testLi() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.li(.r3, 0xd), 0b00100011_00001101) // LI r3, 0xd
    }

    func testLiWithOffsetExceedingPositiveLimit() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertThrowsError(try codeGen.li(.r3, 256)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds positive limit of 255: `256'")
        }
    }

    func testLiWithOffsetExceedingNegativeLimit() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertThrowsError(try codeGen.li(.r3, -129)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds negative limit of -128: `-129'")
        }
    }

    func testLui() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.lui(.r3, 127), 0b00101011_01111111) // LUI r3, 127
    }

    func testLuiWithOffsetExceedingPositiveLimit() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertThrowsError(try codeGen.lui(.r3, 256)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds positive limit of 255: `256'")
        }
    }

    func testLuiWithOffsetExceedingNegativeLimit() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertThrowsError(try codeGen.lui(.r3, -129)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds negative limit of -128: `-129'")
        }
    }

    func testCmp() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.cmp(.r1, .r2), 0b00110000_00101000) // CMP r1, r2
    }

    func testAdd() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.add(.r0, .r1, .r2), 0b00111000_00101000) // ADD r0, r1, r2
    }

    func testSub() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.sub(.r0, .r1, .r2), 0b01000000_00101000) // SUB r0, r1, r2
    }

    func testAnd() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.and(.r0, .r1, .r2), 0b01001000_00101000) // AND r0, r1, r2
    }

    func testOr() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.or(.r0, .r1, .r2), 0b01010000_00101000) // OR r0, r1, r2
    }

    func testXor() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.xor(.r0, .r0, .r0), 0b01011000_00000000) // XOR r0, r0, r0
    }

    func testNot() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.not(.r0, .r1), 0b01100000_00100000) // NOT r0, r1
    }

    func testCmpi() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.cmpi(.r1, 1), 0b01101000_00100001) // CMPI r1, 1
    }

    func testAddi() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.addi(.r0, .r1, 2), 0b01110000_00100010) // ADDI r0, r1, 2
    }

    func testSubi() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.subi(.r0, .r1, 1), 0b01111000_00100001) // SUBI r0, r1, 1
    }

    func testAndi() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.andi(.r0, .r1, 15), 0b10000000_00101111) // ANDI r0, r1, 15
    }

    func testOri() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.ori(.r0, .r1, 15), 0b10001000_00101111) // ORI r0, r1, 15
    }

    func testXori() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.xori(.r0, .r1, 10), 0b10010000_00101010) // XORI r0, r1, 10
    }

    func testAdc() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.adc(.r0, .r1, .r2), 0b11110000_00101000) // ADC r0, r1, r2
    }

    func testSbc() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.sbc(.r0, .r1, .r2), 0b11111000_00101000) // SBC r0, r1, r2
    }

    func testJmp() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.jmp(1023), 0b10100011_11111111) // JMP 1023
    }

    func testJmpBackwards() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.jmp(-2), 0b10100111_11111110) // JMP -2
    }

    func testJmpWithOffsetExceedingPositiveLimit() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertThrowsError(try codeGen.jmp(1024)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds positive limit of 1023: `1024'")
        }
    }

    func testJmpWithOffsetExceedingNegativeLimit() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertThrowsError(try codeGen.jmp(-1025)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(
                compilerError?.message,
                "offset exceeds negative limit of -1024: `-1025'"
            )
        }
    }

    func testJr() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.jr(.r1, 15), 0b10101000_00101111) // JR r1, 15
    }

    func testJrWithOffsetExceedingPositiveLimit() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertThrowsError(try codeGen.jr(.r1, 16)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds positive limit of 15: `16'")
        }
    }

    func testJrWithOffsetExceedingNegativeLimit() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertThrowsError(try codeGen.jr(.r1, -17)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds negative limit of -16: `-17'")
        }
    }

    func testJalr() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.jalr(.r7, .r1, 0), 0b10110111_00100000) // JALR r7, r1, 0
    }

    func testJalrWithOffsetExceedingPositiveLimit() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertThrowsError(try codeGen.jalr(.r7, .r1, 16)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds positive limit of 15: `16'")
        }
    }

    func testJalrWithOffsetExceedingNegativeLimit() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertThrowsError(try codeGen.jalr(.r7, .r1, -17)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds negative limit of -16: `-17'")
        }
    }

    func testBeq() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.beq(1023), 0b11000011_11111111) // BEQ 1023
    }

    func testBne() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.bne(1023), 0b11001011_11111111) // BNE 1023
    }

    func testBlt() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.blt(1023), 0b11010011_11111111) // BLT 1023
    }

    func testBgt() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.bgt(1023), 0b11011011_11111111) // BGT 1023
    }

    func testBltu() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.bltu(1023), 0b11100011_11111111) // BLTU 1023
    }

    func testBgtu() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.bgtu(1023), 0b11101011_11111111) // BGTU 1023
    }
}
