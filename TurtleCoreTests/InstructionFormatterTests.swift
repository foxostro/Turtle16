//
//  InstructionFormatterTests.swift
//  TurtleCoreTests
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleAssemblerCore
import TurtleCompilerToolbox

class InstructionFormatterTests: XCTestCase {
    let formatter = InstructionFormatter()
    
    private func assemble(_ line: String) -> Instruction {
        return try! tryAssemble(line)
    }
    
    private func tryAssemble(_ line: String) throws -> Instruction {
        let assembler = AssemblerFrontEnd()
        assembler.compile(line)
        if assembler.hasError {
            let error = CompilerError.makeOmnibusError(fileName: nil, errors: assembler.errors)
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
        let result = formatter.format(instruction: Instruction.makeNOP())
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
        let instruction = assemble("ADD A")
        let result = formatter.format(instruction: instruction)
        XCTAssertEqual(result, "ADD A")
    }
    
    func testFormatCMP() {
        let result = formatter.format(instruction: assemble("CMP"))
        XCTAssertEqual(result, "CMP")
    }
    
    func testFormatLIA() {
        let result = formatter.format(instruction: assemble("LI A, 1"))
        XCTAssertEqual(result, "LI A, 0x01")
    }
    
    func testFormatLIB() {
        let result = formatter.format(instruction: assemble("LI B, 1"))
        XCTAssertEqual(result, "LI B, 0x01")
    }
    
    func testFormatLID() {
        let result = formatter.format(instruction: assemble("LI D, 1"))
        XCTAssertEqual(result, "LI D, 0x01")
    }
    
    func testFormatLIX() {
        let result = formatter.format(instruction: assemble("LI X, 1"))
        XCTAssertEqual(result, "LI X, 0x01")
    }
    
    func testFormatLIY() {
        let result = formatter.format(instruction: assemble("LI Y, 1"))
        XCTAssertEqual(result, "LI Y, 0x01")
    }
    
    func testFormatLIU() {
        let result = formatter.format(instruction: assemble("LI U, 1"))
        XCTAssertEqual(result, "LI U, 0x01")
    }
    
    func testFormatLIV() {
        let result = formatter.format(instruction: assemble("LI V, 1"))
        XCTAssertEqual(result, "LI V, 0x01")
    }
    
    func testCreateNewInstructionWithDisassembly() {
        let result = formatter.makeInstructionWithDisassembly(instruction: assemble("NOP"))
        XCTAssertEqual(result.description, "NOP (0b00000000, 0b00000000)")
        XCTAssertEqual(result.disassembly, "NOP")
        XCTAssertEqual(result.opcode, 0)
        XCTAssertEqual(result.immediate, 0)
    }
}
