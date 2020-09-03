//
//  CrackleInstructionTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/4/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class CrackleInstructionTests: XCTestCase {
    func testDescription() {
        let L0 = ".L0"
        XCTAssertEqual(CrackleInstruction.push(0xff).description, "PUSH 0xff")
        XCTAssertEqual(CrackleInstruction.push16(0xffff).description, "PUSH16 0xffff")
        XCTAssertEqual(CrackleInstruction.pop.description, "POP")
        XCTAssertEqual(CrackleInstruction.pop16.description, "POP16")
        XCTAssertEqual(CrackleInstruction.popn(42).description, "POPN 42")
        XCTAssertEqual(CrackleInstruction.load(0xffff).description, "LOAD 0xffff")
        XCTAssertEqual(CrackleInstruction.load16(0xffff).description, "LOAD16 0xffff")
        XCTAssertEqual(CrackleInstruction.store(0xffff).description, "STORE 0xffff")
        XCTAssertEqual(CrackleInstruction.storeImmediate(0xaaaa, 0xbb).description, "STORE-IMMEDIATE 0xaaaa, 0xbb")
        XCTAssertEqual(CrackleInstruction.store16(0xffff).description, "STORE16 0xffff")
        XCTAssertEqual(CrackleInstruction.storeImmediate16(0xaaaa, 0xbbbb).description, "STORE-IMMEDIATE16 0xaaaa, 0xbbbb")
        XCTAssertEqual(CrackleInstruction.loadIndirectN(42).description, "LOAD-INDIRECTN 42")
        XCTAssertEqual(CrackleInstruction.label(L0).description, ".L0:")
        XCTAssertEqual(CrackleInstruction.jmp(L0).description, "JMP .L0")
        XCTAssertEqual(CrackleInstruction.jalr(L0).description, "JALR .L0")
        XCTAssertEqual(CrackleInstruction.enter.description, "ENTER")
        XCTAssertEqual(CrackleInstruction.leave.description, "LEAVE")
        XCTAssertEqual(CrackleInstruction.pushReturnAddress.description, "PUSH-RETURN-ADDRESS")
        XCTAssertEqual(CrackleInstruction.ret.description, "RET")
        XCTAssertEqual(CrackleInstruction.leafRet.description, "LEAF-RET")
        XCTAssertEqual(CrackleInstruction.hlt.description, "HLT")
        XCTAssertEqual(CrackleInstruction.peekPeripheral.description, "PEEK-PERIPHERAL")
        XCTAssertEqual(CrackleInstruction.pokePeripheral.description, "POKE-PERIPHERAL")
        XCTAssertEqual(CrackleInstruction.tac_add(0xffff, 0xffff, 0xffff).description, "ADD 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_add16(0xffff, 0xffff, 0xffff).description, "ADD16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_sub(0xffff, 0xffff, 0xffff).description, "SUB 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_sub16(0xffff, 0xffff, 0xffff).description, "SUB16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_mul(0xffff, 0xffff, 0xffff).description, "MUL 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_mul16(0xffff, 0xffff, 0xffff).description, "MUL16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_div(0xffff, 0xffff, 0xffff).description, "DIV 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_div16(0xffff, 0xffff, 0xffff).description, "DIV16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_mod(0xffff, 0xffff, 0xffff).description, "MOD 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_mod16(0xffff, 0xffff, 0xffff).description, "MOD16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_eq(0xffff, 0xffff, 0xffff).description, "EQ 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_eq16(0xffff, 0xffff, 0xffff).description, "EQ16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_ne(0xffff, 0xffff, 0xffff).description, "NE 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_ne16(0xffff, 0xffff, 0xffff).description, "NE16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_lt(0xffff, 0xffff, 0xffff).description, "LT 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_lt16(0xffff, 0xffff, 0xffff).description, "LT16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_gt(0xffff, 0xffff, 0xffff).description, "GT 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_gt16(0xffff, 0xffff, 0xffff).description, "GT16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_le(0xffff, 0xffff, 0xffff).description, "LE 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_le16(0xffff, 0xffff, 0xffff).description, "LE16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_ge(0xffff, 0xffff, 0xffff).description, "GE 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_ge16(0xffff, 0xffff, 0xffff).description, "GE16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_jz(L0, 0xffff).description, "JZ .L0, 0xffff")
        XCTAssertEqual(CrackleInstruction.copyWordZeroExtend(0xbbbb, 0xaaaa).description, "COPY-ZX 0xbbbb, 0xaaaa")
        XCTAssertEqual(CrackleInstruction.copyWords(0xa, 0xb, 0xc).description, "COPY 0x000a, 0x000b, 12")
        XCTAssertEqual(CrackleInstruction.copyWordsIndirectSource(0xa, 0xb, 0xc).description, "COPY-IS 0x000a, 0x000b, 12")
        XCTAssertEqual(CrackleInstruction.copyWordsIndirectDestination(0xa, 0xb, 0xc).description, "COPY-ID 0x000a, 0x000b, 12")
        XCTAssertEqual(CrackleInstruction.copyWordsIndirectDestinationIndirectSource(0xa, 0xb, 0xc).description, "COPY-IDIS 0x000a, 0x000b, 12")
    }
    
    func testMakeListing_Empty() {
        let actual = CrackleInstruction.makeListing(instructions: [])
        XCTAssertEqual(actual, "\n")
    }
    
    func testMakeListing_Example() {
        let actual = CrackleInstruction.makeListing(instructions: [.push(0), .pop])
        XCTAssertEqual(actual, "PUSH 0x00\nPOP\n")
    }
}
