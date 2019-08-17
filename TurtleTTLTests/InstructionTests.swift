//
//  InstructionTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/15/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class InstructionTests: XCTestCase {
    func testInit_1() {
        let instruction = Instruction()
        XCTAssertEqual(instruction.opcode, 0)
        XCTAssertEqual(instruction.immediate, 0)
    }
    
    func testInit_2() {
        let instruction = Instruction(opcode: 1, immediate: 2)
        XCTAssertEqual(instruction.opcode, 1)
        XCTAssertEqual(instruction.immediate, 2)
    }
    
    func testInitWithNilString() {
        let instruction = Instruction("")
        XCTAssertNil(instruction)
    }
    
    func testInitWithZero() {
        let maybeInstruction = Instruction("{op=0b0, imm=0b0}")
        XCTAssertNotNil(maybeInstruction)
        XCTAssertEqual(maybeInstruction?.opcode, 0)
        XCTAssertEqual(maybeInstruction?.immediate, 0)
    }
    
    func testInitWithOneMatch() {
        XCTAssertNil(Instruction("{op=0b0, imm=0bXXXX}"))
    }
}
