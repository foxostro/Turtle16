//
//  InstructionFormatterTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class InstructionFormatterTests: XCTestCase {
    let formatter = InstructionFormatter()
    
    fileprivate func assemble(_ line: String) -> Instruction {
        return try! tryAssemble(line)
    }
    
    fileprivate func tryAssemble(_ line: String) throws -> Instruction {
        let assembler = AssemblerFrontEnd()
        assembler.compile(line)
        if assembler.hasError {
            let error = assembler.makeOmnibusError(fileName: nil, errors: assembler.errors)
            throw error
        }
        let instructions = assembler.instructions
        let instruction = instructions[1]
        return instruction
    }
    
    func testFormatInvalidInstruction() {
        let result = formatter.format(instruction: Instruction(opcode: 255, immediate: 0))
        XCTAssertEqual(result, "UNKNOWN")
    }
    
    func testFormatNOP() {
        let result = formatter.format(instruction: Instruction())
        XCTAssertEqual(result, "NOP")
    }
    
    func testFormatHLT() {
        let result = formatter.format(instruction: assemble("HLT"))
        XCTAssertEqual(result, "HLT")
    }
    
    func testFormatMOV() {
        let result = formatter.format(instruction: assemble("MOV A, B"))
        XCTAssertEqual(result, "MOV A, B")
    }
    
    func testFormatADD() {
        let result = formatter.format(instruction: assemble("ADD A"))
        XCTAssertEqual(result, "ADD A")
    }
    
    func testFormatCMP() {
        let result = formatter.format(instruction: assemble("CMP"))
        XCTAssertEqual(result, "CMP")
    }
    
    func testFormatLIA() {
        let result = formatter.format(instruction: assemble("LI A, 1"))
        XCTAssertEqual(result, "LI A, 1")
    }
    
    func testFormatLIB() {
        let result = formatter.format(instruction: assemble("LI B, 1"))
        XCTAssertEqual(result, "LI B, 1")
    }
    
    func testFormatLID() {
        let result = formatter.format(instruction: assemble("LI D, 1"))
        XCTAssertEqual(result, "LI D, 1")
    }
    
    func testFormatLIX() {
        let result = formatter.format(instruction: assemble("LI X, 1"))
        XCTAssertEqual(result, "LI X, 1")
    }
    
    func testFormatLIY() {
        let result = formatter.format(instruction: assemble("LI Y, 1"))
        XCTAssertEqual(result, "LI Y, 1")
    }
    
    func testFormatLIU() {
        let result = formatter.format(instruction: assemble("LI U, 1"))
        XCTAssertEqual(result, "LI U, 1")
    }
    
    func testFormatLIV() {
        let result = formatter.format(instruction: assemble("LI V, 1"))
        XCTAssertEqual(result, "LI V, 1")
    }
    
    func testCreateNewInstructionWithDisassembly() {
        let result = formatter.makeInstructionWithDisassembly(instruction: assemble("NOP"))
        XCTAssertEqual(result.description, "NOP")
        XCTAssertEqual(result.disassembly, "NOP")
        XCTAssertEqual(result.opcode, 0)
        XCTAssertEqual(result.immediate, 0)
    }
}
