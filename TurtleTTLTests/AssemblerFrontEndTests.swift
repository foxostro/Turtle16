//
//  AssemblerFrontEndTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/18/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class AssemblerFrontEndTests: XCTestCase {
    func testCompileEmptyProgramYieldsNOP() {
        let assembler = AssemblerFrontEnd(withText: "")
        let instructions = try! assembler.compile()
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0], Instruction())
    }
    
    // As a hardware requirement, every program has an implicit NOP as the first
    // instruction. Compiling a single NOP instruction yields a program composed
    // of two NOPs.
    func testCompileASingleNOPYieldsTwoNOPs() {
        let assembler = AssemblerFrontEnd(withText: "NOP")
        let instructions = try! assembler.compile()
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0], Instruction())
        XCTAssertEqual(instructions[1], Instruction())
    }
    
    // Compiling an invalid opcode results in an error.
    func testCompilingBogusOpcodeYieldsError() {
        let assembler = AssemblerFrontEnd(withText: "BOGUS")
        XCTAssertThrowsError(try assembler.compile())
    }
}
