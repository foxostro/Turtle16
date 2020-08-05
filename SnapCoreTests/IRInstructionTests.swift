//
//  IRInstructionTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/4/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class IRInstructionTests: XCTestCase {
    func testDescription() {
        let L0 = ".L0"
        XCTAssertEqual(IRInstruction.push(0xff).description, "PUSH 0xff")
        XCTAssertEqual(IRInstruction.push16(0xffff).description, "PUSH16 0xffff")
        XCTAssertEqual(IRInstruction.pushsp.description, "PUSH-SP")
        XCTAssertEqual(IRInstruction.pop.description, "POP")
        XCTAssertEqual(IRInstruction.pop16.description, "POP16")
        XCTAssertEqual(IRInstruction.popn(42).description, "POPN 42")
        XCTAssertEqual(IRInstruction.eq.description, "EQ")
        XCTAssertEqual(IRInstruction.eq16.description, "EQ16")
        XCTAssertEqual(IRInstruction.ne.description, "NE")
        XCTAssertEqual(IRInstruction.ne16.description, "NE16")
        XCTAssertEqual(IRInstruction.lt.description, "LT")
        XCTAssertEqual(IRInstruction.lt16.description, "LT16")
        XCTAssertEqual(IRInstruction.gt.description, "GT")
        XCTAssertEqual(IRInstruction.gt16.description, "GT16")
        XCTAssertEqual(IRInstruction.le.description, "LE")
        XCTAssertEqual(IRInstruction.le16.description, "LE16")
        XCTAssertEqual(IRInstruction.ge.description, "GE")
        XCTAssertEqual(IRInstruction.ge16.description, "GE16")
        XCTAssertEqual(IRInstruction.add.description, "ADD")
        XCTAssertEqual(IRInstruction.add16.description, "ADD16")
        XCTAssertEqual(IRInstruction.sub.description, "SUB")
        XCTAssertEqual(IRInstruction.sub16.description, "SUB16")
        XCTAssertEqual(IRInstruction.mul.description, "MUL")
        XCTAssertEqual(IRInstruction.mul16.description, "MUL16")
        XCTAssertEqual(IRInstruction.div.description, "DIV")
        XCTAssertEqual(IRInstruction.div16.description, "DIV16")
        XCTAssertEqual(IRInstruction.mod.description, "MOD")
        XCTAssertEqual(IRInstruction.mod16.description, "MOD16")
        XCTAssertEqual(IRInstruction.load(0xffff).description, "LOAD 0xffff")
        XCTAssertEqual(IRInstruction.load16(0xffff).description, "LOAD16 0xffff")
        XCTAssertEqual(IRInstruction.store(0xffff).description, "STORE 0xffff")
        XCTAssertEqual(IRInstruction.store16(0xffff).description, "STORE16 0xffff")
        XCTAssertEqual(IRInstruction.loadIndirect.description, "LOAD-INDIRECT")
        XCTAssertEqual(IRInstruction.loadIndirect16.description, "LOAD-INDIRECT16")
        XCTAssertEqual(IRInstruction.loadIndirectN(42).description, "LOAD-INDIRECTN 42")
        XCTAssertEqual(IRInstruction.storeIndirect.description, "STORE-INDIRECT")
        XCTAssertEqual(IRInstruction.storeIndirect16.description, "STORE-INDIRECT16")
        XCTAssertEqual(IRInstruction.storeIndirectN(42).description, "STORE-INDIRECTN 42")
        XCTAssertEqual(IRInstruction.label(L0).description, ".L0:")
        XCTAssertEqual(IRInstruction.jmp(L0).description, "JMP .L0")
        XCTAssertEqual(IRInstruction.je(L0).description, "JE .L0")
        XCTAssertEqual(IRInstruction.jalr(L0).description, "JALR .L0")
        XCTAssertEqual(IRInstruction.enter.description, "ENTER")
        XCTAssertEqual(IRInstruction.leave.description, "LEAVE")
        XCTAssertEqual(IRInstruction.pushReturnAddress.description, "PUSH-RETURN-ADDRESS")
        XCTAssertEqual(IRInstruction.ret.description, "RET")
        XCTAssertEqual(IRInstruction.leafRet.description, "LEAF-RET")
        XCTAssertEqual(IRInstruction.hlt.description, "HLT")
        XCTAssertEqual(IRInstruction.peekPeripheral.description, "PEEK-PERIPHERAL")
        XCTAssertEqual(IRInstruction.pokePeripheral.description, "POKE-PERIPHERAL")
        XCTAssertEqual(IRInstruction.dup.description, "DUP")
        XCTAssertEqual(IRInstruction.dup16.description, "DUP16")
    }
    
    func testMakeListing_Empty() {
        let actual = IRInstruction.makeListing(instructions: [])
        XCTAssertEqual(actual, "\n")
    }
    
    func testMakeListing_Example() {
        let actual = IRInstruction.makeListing(instructions: [.push(0), .pop])
        XCTAssertEqual(actual, "PUSH 0x00\nPOP\n")
    }
}
