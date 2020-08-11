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
        XCTAssertEqual(CrackleInstruction.pushsp.description, "PUSH-SP")
        XCTAssertEqual(CrackleInstruction.pop.description, "POP")
        XCTAssertEqual(CrackleInstruction.pop16.description, "POP16")
        XCTAssertEqual(CrackleInstruction.popn(42).description, "POPN 42")
        XCTAssertEqual(CrackleInstruction.eq.description, "EQ")
        XCTAssertEqual(CrackleInstruction.eq16.description, "EQ16")
        XCTAssertEqual(CrackleInstruction.ne.description, "NE")
        XCTAssertEqual(CrackleInstruction.ne16.description, "NE16")
        XCTAssertEqual(CrackleInstruction.lt.description, "LT")
        XCTAssertEqual(CrackleInstruction.lt16.description, "LT16")
        XCTAssertEqual(CrackleInstruction.gt.description, "GT")
        XCTAssertEqual(CrackleInstruction.gt16.description, "GT16")
        XCTAssertEqual(CrackleInstruction.le.description, "LE")
        XCTAssertEqual(CrackleInstruction.le16.description, "LE16")
        XCTAssertEqual(CrackleInstruction.ge.description, "GE")
        XCTAssertEqual(CrackleInstruction.ge16.description, "GE16")
        XCTAssertEqual(CrackleInstruction.add.description, "ADD")
        XCTAssertEqual(CrackleInstruction.add16.description, "ADD16")
        XCTAssertEqual(CrackleInstruction.sub.description, "SUB")
        XCTAssertEqual(CrackleInstruction.sub16.description, "SUB16")
        XCTAssertEqual(CrackleInstruction.mul.description, "MUL")
        XCTAssertEqual(CrackleInstruction.mul16.description, "MUL16")
        XCTAssertEqual(CrackleInstruction.div.description, "DIV")
        XCTAssertEqual(CrackleInstruction.div16.description, "DIV16")
        XCTAssertEqual(CrackleInstruction.mod.description, "MOD")
        XCTAssertEqual(CrackleInstruction.mod16.description, "MOD16")
        XCTAssertEqual(CrackleInstruction.load(0xffff).description, "LOAD 0xffff")
        XCTAssertEqual(CrackleInstruction.load16(0xffff).description, "LOAD16 0xffff")
        XCTAssertEqual(CrackleInstruction.store(0xffff).description, "STORE 0xffff")
        XCTAssertEqual(CrackleInstruction.store16(0xffff).description, "STORE16 0xffff")
        XCTAssertEqual(CrackleInstruction.loadIndirect.description, "LOAD-INDIRECT")
        XCTAssertEqual(CrackleInstruction.loadIndirect16.description, "LOAD-INDIRECT16")
        XCTAssertEqual(CrackleInstruction.loadIndirectN(42).description, "LOAD-INDIRECTN 42")
        XCTAssertEqual(CrackleInstruction.storeIndirect.description, "STORE-INDIRECT")
        XCTAssertEqual(CrackleInstruction.storeIndirect16.description, "STORE-INDIRECT16")
        XCTAssertEqual(CrackleInstruction.storeIndirectN(42).description, "STORE-INDIRECTN 42")
        XCTAssertEqual(CrackleInstruction.label(L0).description, ".L0:")
        XCTAssertEqual(CrackleInstruction.jmp(L0).description, "JMP .L0")
        XCTAssertEqual(CrackleInstruction.je(L0).description, "JE .L0")
        XCTAssertEqual(CrackleInstruction.jalr(L0).description, "JALR .L0")
        XCTAssertEqual(CrackleInstruction.enter.description, "ENTER")
        XCTAssertEqual(CrackleInstruction.leave.description, "LEAVE")
        XCTAssertEqual(CrackleInstruction.pushReturnAddress.description, "PUSH-RETURN-ADDRESS")
        XCTAssertEqual(CrackleInstruction.ret.description, "RET")
        XCTAssertEqual(CrackleInstruction.leafRet.description, "LEAF-RET")
        XCTAssertEqual(CrackleInstruction.hlt.description, "HLT")
        XCTAssertEqual(CrackleInstruction.peekPeripheral.description, "PEEK-PERIPHERAL")
        XCTAssertEqual(CrackleInstruction.pokePeripheral.description, "POKE-PERIPHERAL")
        XCTAssertEqual(CrackleInstruction.dup.description, "DUP")
        XCTAssertEqual(CrackleInstruction.dup16.description, "DUP16")
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
        XCTAssertEqual(CrackleInstruction.tac_ne(0xffff, 0xffff, 0xffff).description, "NE 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_lt(0xffff, 0xffff, 0xffff).description, "LT 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_gt(0xffff, 0xffff, 0xffff).description, "GT 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_le(0xffff, 0xffff, 0xffff).description, "LE 0xffff, 0xffff, 0xffff")
        XCTAssertEqual(CrackleInstruction.tac_ge(0xffff, 0xffff, 0xffff).description, "GE 0xffff, 0xffff, 0xffff")
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
