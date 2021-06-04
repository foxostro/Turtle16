//
//  AssemblerCodeGeneratorTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 5/17/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import Turtle16SimulatorCore

class AssemblerCodeGeneratorTests: XCTestCase {
    func testInit() throws {
        let codeGen = AssemblerCodeGenerator()
        XCTAssertEqual(codeGen.instructions, [])
    }
    
    func testNop() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        codeGen.nop()
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0000000000000000)
    }
    
    func testHlt() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        codeGen.hlt()
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0000100000000000)
    }
    
    func testLoad() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.load(.r3, .r1, 1))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0001001100100001) // LOAD r3, 1(r1)
    }
    
    func testLoadWithNegativeOffset() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.load(.r3, .r1, -1))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0001001100111111) // LOAD r3, -1(r1)
    }
    
    func testLoadWithOffsetExceedingPositiveLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.load(.r3, .r1, 16)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds positive limit of 15: `16'")
        }
    }
    
    func testLoadWithOffsetExceedingNegativeLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.load(.r3, .r1, -17)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds negative limit of -16: `-17'")
        }
    }
    
    func testStore() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.store(.r3, .r1, -1))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0001111100101111) // STORE r3, -1(r1)
    }
    
    func testStoreWithOffsetExceedingPositiveLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.store(.r3, .r1, 16)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds positive limit of 15: `16'")
        }
    }
    
    func testStoreWithOffsetExceedingNegativeLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.store(.r3, .r1, -17)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds negative limit of -16: `-17'")
        }
    }
    
    func testLi() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.li(.r3, 0xd))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0010001100001101) // LI r3, 0xd
    }
    
    func testLiWithOffsetExceedingPositiveLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.li(.r3, 128)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds positive limit of 127: `128'")
        }
    }
    
    func testLiWithOffsetExceedingNegativeLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.li(.r3, -129)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds negative limit of -128: `-129'")
        }
    }
    
    func testLiu() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.liu(.r3, 0xff))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0010001111111111) // LIU r3, 0xff
    }
    
    func testLui() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.lui(.r3, 127))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0010101101111111) // LUI r3, 127
    }
    
    func testLuiWithOffsetExceedingPositiveLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.lui(.r3, 256)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "immediate value exceeds upper limit of 255: `256'")
        }
    }
    
    func testLuiWithOffsetExceedingNegativeLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.lui(.r3, -129)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "immediate value must be positive: `-129'")
        }
    }
    
    func testCmp() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.cmp(.r1, .r2))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0011000000101000) // CMP r1, r2
    }
    
    func testAdd() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.add(.r0, .r1, .r2))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0011100000101000) // ADD r0, r1, r2
    }
    
    func testSub() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.sub(.r0, .r1, .r2))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0100000000101000) // SUB r0, r1, r2
    }
    
    func testAnd() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.and(.r0, .r1, .r2))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0100100000101000) // AND r0, r1, r2
    }
    
    func testOr() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.or(.r0, .r1, .r2))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0101000000101000) // OR r0, r1, r2
    }
    
    func testXor() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.xor(.r0, .r0, .r0))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0101100000000000) // XOR r0, r0, r0
    }
    
    func testNot() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.not(.r0, .r1))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0110000000100000) // NOT r0, r1
    }
    
    func testCmpi() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.cmpi(.r1, 1))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0110100000100001) // CMPI r1, 1
    }
    
    func testAddi() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.addi(.r0, .r1, 2))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0111000000100010) // ADDI r0, r1, 2
    }
    
    func testSubi() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.subi(.r0, .r1, 1))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b0111100000100001) // SUBI r0, r1, 1
    }
    
    func testAndi() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.andi(.r0, .r1, 15))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1000000000101111) // ANDI r0, r1, 15
    }
    
    func testOri() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.ori(.r0, .r1, 15))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1000100000101111) // ORI r0, r1, 15
    }
    
    func testXori() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.xori(.r0, .r1, 10))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1001000000101010) // XORI r0, r1, 10
    }
    
    func testAdc() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.adc(.r0, .r1, .r2))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1111000000101000) // ADC r0, r1, r2
    }
    
    func testSbc() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.sbc(.r0, .r1, .r2))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1111100000101000) // SBC r0, r1, r2
    }
    
    func testJmp() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.jmp(offset: 1023))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1010001111111111) // JMP 1023
    }
    
    func testJmpBackwards() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.jmp(offset: -2))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1010011111111110) // JMP -2
    }
    
    func testJmpWithOffsetExceedingPositiveLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.jmp(offset: 1024)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds positive limit of 1023: `1024'")
        }
    }
    
    func testJmpWithOffsetExceedingNegativeLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.jmp(offset: -1025)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds negative limit of -1024: `-1025'")
        }
    }
    
    func testJr() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.jr(.r1, 15))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1010100000101111) // JR r1, 15
    }
    
    func testJrWithOffsetExceedingPositiveLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.jr(.r1, 16)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds positive limit of 15: `16'")
        }
    }
    
    func testJrWithOffsetExceedingNegativeLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.jr(.r1, -17)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds negative limit of -16: `-17'")
        }
    }
    
    func testJalr() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.jalr(.r7, .r1, 0))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1011011100100000) // JALR r7, r1, 0
    }
    
    func testJalrWithOffsetExceedingPositiveLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.jalr(.r7, .r1, 16)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds positive limit of 15: `16'")
        }
    }
    
    func testJalrWithOffsetExceedingNegativeLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.jalr(.r7, .r1, -17)) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds negative limit of -16: `-17'")
        }
    }
    
    func testBeq() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.beq(offset: 1023))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1100001111111111) // BEQ 1023
    }
    
    func testBne() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.bne(offset: 1023))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1100101111111111) // BNE 1023
    }
    
    func testBlt() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.blt(offset: 1023))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1101001111111111) // BLT 1023
    }
    
    func testBge() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.bge(offset: 1023))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1101101111111111) // BGE 1023
    }
    
    func testBltu() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.bltu(offset: 1023))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1110001111111111) // BLTU 1023
    }
    
    func testBgeu() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.bgeu(offset: 1023))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1110101111111111) // BGEU 1023
    }
    
    func testLabel() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        codeGen.nop()
        XCTAssertNoThrow(try codeGen.label("foo"))
        XCTAssertEqual(codeGen.symbols.count, 1)
        XCTAssertEqual(codeGen.symbols["foo"], 1)
    }
    
    func testLabelDuplicate() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.symbols["foo"] = 0
        codeGen.begin()
        XCTAssertThrowsError(try codeGen.label("foo")) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "label redefines existing symbol: `foo'")
        }
    }
    
    func testJmpToLabelWithNoPatching_ZeroOffset() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.symbols["foo"] = 2
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.jmp("foo"))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1010000000000000) // JMP 0
    }
    
    func testJmpToLabelWithNoPatching_ForwardJump() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.symbols["foo"] = 3
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.jmp("foo"))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1010000000000001) // JMP 1
    }
    
    func testJmpToLabelWithNoPatching_BackwardJump() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.symbols["foo"] = 2
        codeGen.begin()
        codeGen.nop()
        XCTAssertNoThrow(try codeGen.jmp("foo"))
        XCTAssertEqual(codeGen.instructions.count, 2)
        XCTAssertEqual(codeGen.instructions.last, 0b1010011111111111) // JMP -1
    }
    
    func testJmpToLabelWithPatching() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.jmp("foo"))
        XCTAssertNoThrow(try codeGen.label("foo"))
        XCTAssertNoThrow(try codeGen.end())
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1010011111111111) // JMP -1
    }
    
    func testJmpToLabelWithPatching_ExceedingNegativeLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        for _ in 0..<1998 {
            codeGen.nop()
        }
        XCTAssertNoThrow(try codeGen.jmp("foo"))
        codeGen.symbols["foo"] = 0
        XCTAssertThrowsError(try codeGen.end()) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds negative limit of -1024: `-2000'")
        }
    }
    
    func testJmpToUnresolvedLabel() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.jmp("foo"))
        XCTAssertThrowsError(try codeGen.end()) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "use of unresolved identifier: `foo'")
        }
    }
    
    func testJmpToLabelWithOffsetExceedingPositiveLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.jmp("foo"))
        for _ in 0..<2000 {
            codeGen.nop()
        }
        XCTAssertNoThrow(try codeGen.label("foo"))
        XCTAssertThrowsError(try codeGen.end()) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds positive limit of 1023: `1999'")
        }
    }
    
    func testJmpToLabelWithOffsetExceedingNegativeLimit() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.label("foo"))
        for _ in 0..<2000 {
            codeGen.nop()
        }
        XCTAssertThrowsError(try codeGen.jmp("foo")) {
            let compilerError = $0 as? CompilerError
            XCTAssertEqual(compilerError?.message, "offset exceeds negative limit of -1024: `-2002'")
        }
    }
    
    func testBeqToLabel() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.symbols["foo"] = 2
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.beq("foo"))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1100000000000000) // BEQ 0
    }
    
    func testBneToLabel() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.symbols["foo"] = 2
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.bne("foo"))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1100100000000000) // BNE 0
    }
    
    func testBltToLabel() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.symbols["foo"] = 2
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.blt("foo"))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1101000000000000) // BLT 0
    }
    
    func testBgeToLabel() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.symbols["foo"] = 2
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.bge("foo"))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1101100000000000) // BGE 0
    }
    
    func testBltuToLabel() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.symbols["foo"] = 2
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.bltu("foo"))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1110000000000000) // BLTU 0
    }
    
    func testBgeuToLabel() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.symbols["foo"] = 2
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.bgeu("foo"))
        XCTAssertEqual(codeGen.instructions.count, 1)
        XCTAssertEqual(codeGen.instructions.first, 0b1110100000000000) // BGEU 0
    }
    
    func testLaWithNoPatching() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.symbols["foo"] = 0xabcd
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.la(.r3, "foo"))
        XCTAssertEqual(codeGen.instructions.count, 2)
        XCTAssertEqual(codeGen.instructions, [
            0b0010001111001101, // LIU r3, 0xcd
            0b0010101110101011, // LUI r3, 0xab
        ])
    }
    
    func testLaWithPatching() throws {
        let codeGen = AssemblerCodeGenerator()
        codeGen.begin()
        XCTAssertNoThrow(try codeGen.la(.r3, "foo"))
        codeGen.symbols["foo"] = 0xabcd
        XCTAssertNoThrow(try codeGen.end())
        XCTAssertEqual(codeGen.instructions.count, 2)
        XCTAssertEqual(codeGen.instructions, [
            0b0010001111001101, // LIU r3, 0xcd
            0b0010101110101011, // LUI r3, 0xab
        ])
    }
}
