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
