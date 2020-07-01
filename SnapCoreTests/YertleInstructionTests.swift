//
//  YertleInstructionTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/4/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class YertleInstructionTests: XCTestCase {
    func testDescription() {
        let L0 = TokenIdentifier(lineNumber: -1, lexeme: ".L0")
        XCTAssertEqual(YertleInstruction.push(0xff).description, "PUSH 0xff")
        XCTAssertEqual(YertleInstruction.push16(0xffff).description, "PUSH16 0xffff")
        XCTAssertEqual(YertleInstruction.pop.description, "POP")
        XCTAssertEqual(YertleInstruction.pop16.description, "POP16")
        XCTAssertEqual(YertleInstruction.eq.description, "EQ")
        XCTAssertEqual(YertleInstruction.eq16.description, "EQ16")
        XCTAssertEqual(YertleInstruction.ne.description, "NE")
        XCTAssertEqual(YertleInstruction.ne16.description, "NE16")
        XCTAssertEqual(YertleInstruction.lt.description, "LT")
        XCTAssertEqual(YertleInstruction.lt16.description, "LT16")
        XCTAssertEqual(YertleInstruction.gt.description, "GT")
        XCTAssertEqual(YertleInstruction.gt16.description, "GT16")
        XCTAssertEqual(YertleInstruction.le.description, "LE")
        XCTAssertEqual(YertleInstruction.le16.description, "LE16")
        XCTAssertEqual(YertleInstruction.ge.description, "GE")
        XCTAssertEqual(YertleInstruction.ge16.description, "GE16")
        XCTAssertEqual(YertleInstruction.add.description, "ADD")
        XCTAssertEqual(YertleInstruction.add16.description, "ADD16")
        XCTAssertEqual(YertleInstruction.sub.description, "SUB")
        XCTAssertEqual(YertleInstruction.sub16.description, "SUB16")
        XCTAssertEqual(YertleInstruction.mul.description, "MUL")
        XCTAssertEqual(YertleInstruction.mul16.description, "MUL16")
        XCTAssertEqual(YertleInstruction.div.description, "DIV")
        XCTAssertEqual(YertleInstruction.div16.description, "DIV16")
        XCTAssertEqual(YertleInstruction.mod.description, "MOD")
        XCTAssertEqual(YertleInstruction.mod16.description, "MOD16")
        XCTAssertEqual(YertleInstruction.load(0xffff).description, "LOAD 0xffff")
        XCTAssertEqual(YertleInstruction.load16(0xffff).description, "LOAD16 0xffff")
        XCTAssertEqual(YertleInstruction.store(0xffff).description, "STORE 0xffff")
        XCTAssertEqual(YertleInstruction.store16(0xffff).description, "STORE16 0xffff")
        XCTAssertEqual(YertleInstruction.loadIndirect.description, "LOAD-INDIRECT")
        XCTAssertEqual(YertleInstruction.storeIndirect.description, "STORE-INDIRECT")
        XCTAssertEqual(YertleInstruction.label(L0).description, ".L0:")
        XCTAssertEqual(YertleInstruction.jmp(L0).description, "JMP .L0")
        XCTAssertEqual(YertleInstruction.je(L0).description, "JE .L0")
        XCTAssertEqual(YertleInstruction.jalr(L0).description, "JALR .L0")
        XCTAssertEqual(YertleInstruction.enter.description, "ENTER")
        XCTAssertEqual(YertleInstruction.leave.description, "LEAVE")
        XCTAssertEqual(YertleInstruction.pushReturnAddress.description, "PUSH-RETURN-ADDRESS")
        XCTAssertEqual(YertleInstruction.ret.description, "RET")
        XCTAssertEqual(YertleInstruction.leafRet.description, "LEAF-RET")
    }
    
    func testMakeListing_Empty() {
        let actual = YertleInstruction.makeListing(instructions: [])
        XCTAssertEqual(actual, "\n")
    }
    
    func testMakeListing_Example() {
        let actual = YertleInstruction.makeListing(instructions: [.push(0), .pop])
        XCTAssertEqual(actual, "PUSH 0x00\nPOP\n")
    }
}
