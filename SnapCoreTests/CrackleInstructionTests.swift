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
        XCTAssertEqual(CrackleInstruction.nop.description, "NOP")
        XCTAssertEqual(CrackleInstruction.push(0xff).description, "PUSH 0xff")
        XCTAssertEqual(CrackleInstruction.push16(0xffff).description, "PUSH16 0xffff")
        XCTAssertEqual(CrackleInstruction.pop.description, "POP")
        XCTAssertEqual(CrackleInstruction.pop16.description, "POP16")
        XCTAssertEqual(CrackleInstruction.subi16(0xffff, 0xaaaa, 0xbbbb).description, "SUBI16 0xffff, 0xaaaa, 0xbbbb")
        XCTAssertEqual(CrackleInstruction.addi16(0xffff, 0xaaaa, 0xbbbb).description, "ADDI16 0xffff, 0xaaaa, 0xbbbb")
        XCTAssertEqual(CrackleInstruction.storeImmediate(0xaaaa, 0xbb).description, "STORE-IMMEDIATE 0xaaaa, 0xbb")
        XCTAssertEqual(CrackleInstruction.storeImmediate16(0xaaaa, 0xbbbb).description, "STORE-IMMEDIATE16 0xaaaa, 0xbbbb")
        XCTAssertEqual(CrackleInstruction.label(L0).description, ".L0:")
        XCTAssertEqual(CrackleInstruction.jmp(L0).description, "JMP .L0")
        XCTAssertEqual(CrackleInstruction.jalr(L0).description, "JALR .L0")
        XCTAssertEqual(CrackleInstruction.indirectJalr(0xabcd).description, "INDIRECT-JALR 0xabcd")
        XCTAssertEqual(CrackleInstruction.enter.description, "ENTER")
        XCTAssertEqual(CrackleInstruction.leave.description, "LEAVE")
        XCTAssertEqual(CrackleInstruction.pushReturnAddress.description, "PUSH-RETURN-ADDRESS")
        XCTAssertEqual(CrackleInstruction.ret.description, "RET")
        XCTAssertEqual(CrackleInstruction.leafRet.description, "LEAF-RET")
        XCTAssertEqual(CrackleInstruction.hlt.description, "HLT")
        XCTAssertEqual(CrackleInstruction.peekPeripheral.description, "PEEK-PERIPHERAL")
        XCTAssertEqual(CrackleInstruction.pokePeripheral.description, "POKE-PERIPHERAL")
        XCTAssertEqual(CrackleInstruction.add(0xffff, 0xffff, 0xffff).description, "ADD 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.add16(0xffff, 0xffff, 0xffff).description, "ADD16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.sub(0xffff, 0xffff, 0xffff).description, "SUB 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.sub16(0xffff, 0xffff, 0xffff).description, "SUB16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.mul(0xffff, 0xffff, 0xffff).description, "MUL 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.mul16(0xffff, 0xffff, 0xffff).description, "MUL16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.div(0xffff, 0xffff, 0xffff).description, "DIV 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.div16(0xffff, 0xffff, 0xffff).description, "DIV16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.mod(0xffff, 0xffff, 0xffff).description, "MOD 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.mod16(0xffff, 0xffff, 0xffff).description, "MOD16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.eq(0xffff, 0xffff, 0xffff).description, "EQ 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.eq16(0xffff, 0xffff, 0xffff).description, "EQ16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.ne(0xffff, 0xffff, 0xffff).description, "NE 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.ne16(0xffff, 0xffff, 0xffff).description, "NE16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.lt(0xffff, 0xffff, 0xffff).description, "LT 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.lt16(0xffff, 0xffff, 0xffff).description, "LT16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.gt(0xffff, 0xffff, 0xffff).description, "GT 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.gt16(0xffff, 0xffff, 0xffff).description, "GT16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.le(0xffff, 0xffff, 0xffff).description, "LE 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.le16(0xffff, 0xffff, 0xffff).description, "LE16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.ge(0xffff, 0xffff, 0xffff).description, "GE 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.ge16(0xffff, 0xffff, 0xffff).description, "GE16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.and(0xffff, 0xffff, 0xffff).description, "AND 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.and16(0xffff, 0xffff, 0xffff).description, "AND16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.or(0xffff, 0xffff, 0xffff).description, "OR 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.or16(0xffff, 0xffff, 0xffff).description, "OR16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.xor(0xffff, 0xffff, 0xffff).description, "XOR 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.xor16(0xffff, 0xffff, 0xffff).description, "XOR16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.lsl(0xffff, 0xffff, 0xffff).description, "LSL 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.lsl16(0xffff, 0xffff, 0xffff).description, "LSL16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.lsr(0xffff, 0xffff, 0xffff).description, "LSR 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.lsr16(0xffff, 0xffff, 0xffff).description, "LSR16 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.neg(0xffff, 0xffff).description, "NEG 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.neg16(0xffff, 0xffff).description, "NEG16 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.not(0xffff, 0xffff).description, "NOT 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.jz(L0, 0xffff).description, "JZ .L0, 0xffff")
        XCTAssertEqual(CrackleInstruction.jnz(L0, 0xffff).description, "JNZ .L0, 0xffff")
        XCTAssertEqual(CrackleInstruction.copyWordZeroExtend(0xbbbb, 0xaaaa).description, "COPY-ZX 0xbbbb, 0xaaaa")
        XCTAssertEqual(CrackleInstruction.copyWords(0xa, 0xb, 0xc).description, "COPY 0x000a, 0x000b, 12")
        XCTAssertEqual(CrackleInstruction.copyWordsIndirectSource(0xa, 0xb, 0xc).description, "COPY-IS 0x000a, 0x000b, 12")
        XCTAssertEqual(CrackleInstruction.copyWordsIndirectDestination(0xa, 0xb, 0xc).description, "COPY-ID 0x000a, 0x000b, 12")
        XCTAssertEqual(CrackleInstruction.copyWordsIndirectDestinationIndirectSource(0xa, 0xb, 0xc).description, "COPY-IDIS 0x000a, 0x000b, 12")
        XCTAssertEqual(CrackleInstruction.copyLabel(0xa, "label").description, "COPY-LABEL 0x000a, label")
    }
}
