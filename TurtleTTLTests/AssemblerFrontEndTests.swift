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
        let instructions = try! AssemblerFrontEnd().compile("")
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0], Instruction())
    }
    
    // As a hardware requirement, every program has an implicit NOP as the first
    // instruction. Compiling a single NOP instruction yields a program composed
    // of two NOPs.
    func testCompileASingleNOPYieldsTwoNOPs() {
        let instructions = try! AssemblerFrontEnd().compile("NOP")
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0], Instruction())
        XCTAssertEqual(instructions[1], Instruction())
    }
    
    // Compiling an invalid opcode results in an error.
    func testCompilingBogusOpcodeYieldsError() {
        XCTAssertThrowsError(try AssemblerFrontEnd().compile("BOGUS\n")) { e in
            let error = e as! AssemblerFrontEnd.AssemblerFrontEndError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "Unrecognized opcode: BOGUS")
        }
    }
    
    func testCompileTwoNOPsYieldsProgramWithThreeNOPs() {
        let instructions = try! AssemblerFrontEnd().compile("NOP\nNOP\n")
        XCTAssertEqual(instructions.count, 3)
        XCTAssertEqual(instructions[0], Instruction())
        XCTAssertEqual(instructions[1], Instruction())
        XCTAssertEqual(instructions[2], Instruction())
    }
}
