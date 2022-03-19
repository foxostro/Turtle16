//
//  AssemblerSingleInstructionCodeGeneratorTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 5/17/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import Turtle16SimulatorCore

class AssemblerSingleInstructionCodeGeneratorTests: XCTestCase {
    func testNop() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(codeGen.nop(), 0b0000000000000000)
    }
    
    func testHlt() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(codeGen.hlt(), 0b0000100000000000)
    }
    
    func testLoad() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.load(.r3, .r1, 1), 0b0001001100100001) // LOAD r3, 1(r1)
    }
    
    func testLoadWithNegativeOffset() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.load(.r3, .r1, -1), 0b0001001100111111) // LOAD r3, -1(r1)
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
        XCTAssertEqual(try? codeGen.store(.r3, .r1, -1), 0b0001111100101111) // STORE r3, -1(r1)
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
        XCTAssertEqual(try? codeGen.li(.r3, 0xd), 0b0010001100001101) // LI r3, 0xd
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
        XCTAssertEqual(try? codeGen.lui(.r3, 127), 0b0010101101111111) // LUI r3, 127
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
        XCTAssertEqual(try? codeGen.cmp(.r1, .r2), 0b0011000000101000) // CMP r1, r2
    }
    
    func testAdd() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.add(.r0, .r1, .r2), 0b0011100000101000) // ADD r0, r1, r2
    }
    
    func testSub() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.sub(.r0, .r1, .r2), 0b0100000000101000) // SUB r0, r1, r2
    }
    
    func testAnd() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.and(.r0, .r1, .r2), 0b0100100000101000) // AND r0, r1, r2
    }
    
    func testOr() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.or(.r0, .r1, .r2), 0b0101000000101000) // OR r0, r1, r2
    }
    
    func testXor() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.xor(.r0, .r0, .r0), 0b0101100000000000) // XOR r0, r0, r0
    }
    
    func testNot() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.not(.r0, .r1), 0b0110000000100000) // NOT r0, r1
    }
    
    func testCmpi() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.cmpi(.r1, 1), 0b0110100000100001) // CMPI r1, 1
    }
    
    func testAddi() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.addi(.r0, .r1, 2), 0b0111000000100010) // ADDI r0, r1, 2
    }
    
    func testSubi() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.subi(.r0, .r1, 1), 0b0111100000100001) // SUBI r0, r1, 1
    }
    
    func testAndi() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.andi(.r0, .r1, 15), 0b1000000000101111) // ANDI r0, r1, 15
    }
    
    func testOri() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.ori(.r0, .r1, 15), 0b1000100000101111) // ORI r0, r1, 15
    }
    
    func testXori() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.xori(.r0, .r1, 10), 0b1001000000101010) // XORI r0, r1, 10
    }
    
    func testAdc() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.adc(.r0, .r1, .r2), 0b1111000000101000) // ADC r0, r1, r2
    }
    
    func testSbc() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.sbc(.r0, .r1, .r2), 0b1111100000101000) // SBC r0, r1, r2
    }
    
    func testJmp() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.jmp(1023), 0b1010001111111111) // JMP 1023
    }
    
    func testJmpBackwards() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.jmp(-2), 0b1010011111111110) // JMP -2
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
            XCTAssertEqual(compilerError?.message, "offset exceeds negative limit of -1024: `-1025'")
        }
    }
    
    func testJr() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.jr(.r1, 15), 0b1010100000101111) // JR r1, 15
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
        XCTAssertEqual(try? codeGen.jalr(.r7, .r1, 0), 0b1011011100100000) // JALR r7, r1, 0
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
        XCTAssertEqual(try? codeGen.beq(1023), 0b1100001111111111) // BEQ 1023
    }
    
    func testBne() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.bne(1023), 0b1100101111111111) // BNE 1023
    }
    
    func testBlt() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.blt(1023), 0b1101001111111111) // BLT 1023
    }
    
    func testBgt() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.bgt(1023), 0b1101101111111111) // BGT 1023
    }
    
    func testBltu() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.bltu(1023), 0b1110001111111111) // BLTU 1023
    }
    
    func testBgtu() throws {
        let codeGen = AssemblerSingleInstructionCodeGenerator()
        XCTAssertEqual(try? codeGen.bgtu(1023), 0b1110101111111111) // BGTU 1023
    }
}
