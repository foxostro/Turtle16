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
    var assembler = AssemblerFrontEnd()
    
    override func setUp() {
        assembler = AssemblerFrontEnd()
    }
    
    func testCompileEmptyProgramYieldsNOP() {
        let instructions = try! assembler.compile("")
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0], Instruction())
    }
    
    // As a hardware requirement, every program has an implicit NOP as the first
    // instruction. Compiling a single NOP instruction yields a program composed
    // of two NOPs.
    func testCompileASingleNOPYieldsTwoNOPs() {
        let instructions = try! assembler.compile("NOP")
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0], Instruction())
        XCTAssertEqual(instructions[1], Instruction())
    }
    
    // Compiling an invalid opcode results in an error.
    func testCompilingBogusOpcodeYieldsError() {
        XCTAssertThrowsError(try assembler.compile("BOGUS\n")) { e in
            let error = e as! AssemblerFrontEnd.AssemblerFrontEndError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "no such instruction: `BOGUS'")
        }
    }
    
    func testCompileTwoNOPsYieldsProgramWithThreeNOPs() {
        let instructions = try! assembler.compile("NOP\nNOP\n")
        XCTAssertEqual(instructions.count, 3)
        XCTAssertEqual(instructions[0], Instruction())
        XCTAssertEqual(instructions[1], Instruction())
        XCTAssertEqual(instructions[2], Instruction())
    }
    
    func testCompilerIgnoresComments() {
        let instructions = try! assembler.compile("// comment")
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0], Instruction())
    }
    
    func testCompilerIgnoresCommentsAfterOpcodesToo() {
        let instructions = try! assembler.compile("NOP  // do nothing\n")
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0], Instruction())
        XCTAssertEqual(instructions[1], Instruction())
    }
    
    func testOpcodesAreCaseInsensitive() {
        let a = try! assembler.compile("nop")
        let b = try! assembler.compile("NOP")
        XCTAssertEqual(a, b)
    }
    
    func testNOPAcceptsNoOperands() {
        XCTAssertThrowsError(try AssemblerFrontEnd().compile("NOP $1\n")) { e in
            let error = e as! AssemblerFrontEnd.AssemblerFrontEndError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "instruction takes no operands: `NOP'")
        }
    }
    
    func testCMPCompiles() {
        let instructions = try! assembler.compile("CMP")
        XCTAssertEqual(instructions.count, 2)
        
        let cmpOpcode = makeMicrocodeGenerator().getOpcode(withMnemonic: "ALU")!
        let kALUControlForCMP = 0b010110
        let cmpInstruction = Instruction(opcode: cmpOpcode, immediate: kALUControlForCMP)
        XCTAssertEqual(instructions[1], cmpInstruction)
    }
    
    func makeMicrocodeGenerator() -> MicrocodeGenerator {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        return microcodeGenerator
    }
    
    func testCMPAcceptsNoOperands() {
        XCTAssertThrowsError(try AssemblerFrontEnd().compile("CMP $1")) { e in
            let error = e as! AssemblerFrontEnd.AssemblerFrontEndError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "instruction takes no operands: `CMP'")
        }
    }
    
    func testHLTCompiles() {
        let instructions = try! assembler.compile("HLT")
        XCTAssertEqual(instructions.count, 2)
        
        let hltOpcode = makeMicrocodeGenerator().getOpcode(withMnemonic: "HLT")!
        let hltInstruction = Instruction(opcode: hltOpcode, immediate: 0)
        XCTAssertEqual(instructions[1], hltInstruction)
    }
    
    func testHLTAcceptsNoOperands() {
        XCTAssertThrowsError(try AssemblerFrontEnd().compile("HLT $1")) { e in
            let error = e as! AssemblerFrontEnd.AssemblerFrontEndError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "instruction takes no operands: `HLT'")
        }
    }
}
