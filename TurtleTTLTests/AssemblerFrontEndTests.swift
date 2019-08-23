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
    
    func testCompilingBogusOpcodeYieldsError() {
        XCTAssertThrowsError(try assembler.compile("BOGUS")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "no such instruction: `BOGUS'")
        }
    }
    
    func testCompilingBogusOpcodeWithNewlineYieldsError() {
        XCTAssertThrowsError(try assembler.compile("BOGUS\n")) { e in
            let error = e as! AssemblerError
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
    
    func testCompilerIgnoresHashCommentsToo() {
        let instructions = try! assembler.compile("# comment")
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0], Instruction())
    }
    
    func testNOPAcceptsNoOperands() {
        XCTAssertThrowsError(try AssemblerFrontEnd().compile("NOP $1\n")) { e in
            let error = e as! AssemblerError
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
            let error = e as! AssemblerError
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
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "instruction takes no operands: `HLT'")
        }
    }
    
    func testDuplicateLabelDeclaration() {
        XCTAssertThrowsError(try assembler.compile("label:\nlabel:")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 2)
            XCTAssertEqual(error.message, "duplicate label: `label'")
        }
    }
    
    func testParseLabelNameIsANumber() {
        XCTAssertThrowsError(try assembler.compile("123:")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.message, "unexpected end of input")
        }
    }
    
    func testParseLabelNameIsAKeyword() {
        XCTAssertThrowsError(try assembler.compile("NOP:")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.message, "instruction takes no operands: `NOP'")
        }
    }
    
    func testParseExtraneousColon() {
        XCTAssertThrowsError(try assembler.compile(":")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.message, "unexpected end of input")
        }
    }
    
    func testFailToCompileJMPWithZeroOperands() {
        XCTAssertThrowsError(try assembler.compile("JMP")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `JMP'")
        }
    }
    
    func testFailToCompileJMPWithUndeclaredLabel() {
        XCTAssertThrowsError(try assembler.compile("JMP label")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "unrecognized symbol name: `label'")
        }
    }
    
    func testJMPCompiles() {
        let instructions = try! assembler.compile("label:\nJMP label")
        
        XCTAssertEqual(instructions.count, 6)
        
        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        let nop: UInt8 = 0
        XCTAssertEqual(instructions[0].opcode, nop)
        
        // Load the resolved label address into XY.
        let microcodeGenerator = makeMicrocodeGenerator()
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 1)
        
        // The JMP command jumps to the address in the XY register pair.
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "JMP")!))
        
        // JMP must be followed by two NOPs. A jump does not clear the pipeline
        // so this is necessary to ensure correct operation.
        XCTAssertEqual(instructions[4].opcode, nop)
        XCTAssertEqual(instructions[5].opcode, nop)
    }
    
    func testJMPToAddressCompiles() {
        let instructions = try! assembler.compile("JMP 0x0000")
        
        XCTAssertEqual(instructions.count, 6)
        
        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        let nop: UInt8 = 0
        XCTAssertEqual(instructions[0].opcode, nop)
        
        // Load the resolved label address into XY.
        let microcodeGenerator = makeMicrocodeGenerator()
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 0)
        
        // The JMP command jumps to the address in the XY register pair.
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "JMP")!))
        
        // JMP must be followed by two NOPs. A jump does not clear the pipeline
        // so this is necessary to ensure correct operation.
        XCTAssertEqual(instructions[4].opcode, nop)
        XCTAssertEqual(instructions[5].opcode, nop)
    }
    
    func testFailToCompileJCWithZeroOperands() {
        XCTAssertThrowsError(try assembler.compile("JC")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `JC'")
        }
    }
    
    func testFailToCompileJCWithUndeclaredLabel() {
        XCTAssertThrowsError(try assembler.compile("JC label")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "unrecognized symbol name: `label'")
        }
    }
    
    func testJCCompiles() {
        let instructions = try! assembler.compile("label:\nJC label")
        
        XCTAssertEqual(instructions.count, 6)
        
        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        let nop: UInt8 = 0
        XCTAssertEqual(instructions[0].opcode, nop)
        
        // Load the resolved label address into XY.
        let microcodeGenerator = makeMicrocodeGenerator()
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 1)
        
        // The JC command jumps to the address in the XY register pair.
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "JC")!))
        
        // JC must be followed by two NOPs. A jump does not clear the pipeline
        // so this is necessary to ensure correct operation.
        XCTAssertEqual(instructions[4].opcode, nop)
        XCTAssertEqual(instructions[5].opcode, nop)
    }
    
    func testJCToAddressCompiles() {
        let instructions = try! assembler.compile("JC 0x0000")
        
        XCTAssertEqual(instructions.count, 6)
        
        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        let nop: UInt8 = 0
        XCTAssertEqual(instructions[0].opcode, nop)
        
        // Load the resolved label address into XY.
        let microcodeGenerator = makeMicrocodeGenerator()
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 0)
        
        // The JC command jumps to the address in the XY register pair.
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "JC")!))
        
        // JC must be followed by two NOPs. A jump does not clear the pipeline
        // so this is necessary to ensure correct operation.
        XCTAssertEqual(instructions[4].opcode, nop)
        XCTAssertEqual(instructions[5].opcode, nop)
    }
    
    func testFailToCompileADDWithZeroOperands() {
        XCTAssertThrowsError(try assembler.compile("ADD")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `ADD'")
        }
    }
    
    func testFailToCompileADDWithIdentifierOperand() {
        XCTAssertThrowsError(try assembler.compile("ADD label")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `ADD'")
        }
    }
    
    func testCompileADDWithRegisterOperand() {
        let instructions = try! assembler.compile("ADD D")
        
        XCTAssertEqual(instructions.count, 2)
        let nop: UInt8 = 0
        XCTAssertEqual(instructions[0].opcode, nop)
        
        XCTAssertEqual(instructions[1].immediate, 0b011001)
        
        let microcodeGenerator = makeMicrocodeGenerator()
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        
        XCTAssertEqual(controlWord.EO, false)
        XCTAssertEqual(controlWord.DI, false)
    }
    
    func testFailToCompileADDWithInvalidDestinationRegisterE() {
        XCTAssertThrowsError(try assembler.compile("ADD E")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "register cannot be used as a destination: `E'")
        }
    }
    
    func testFailToCompileADDWithInvalidDestinationRegisterC() {
        XCTAssertThrowsError(try assembler.compile("ADD C")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "register cannot be used as a destination: `C'")
        }
    }
    
    func testFailToCompileLIWithNoOperands() {
        XCTAssertThrowsError(try assembler.compile("LI")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `LI'")
        }
    }
    
    func testFailToCompileLIWithOneOperand() {
        XCTAssertThrowsError(try assembler.compile("LI $1")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `LI'")
        }
    }
    
    func testFailToCompileLIWhichIsMissingTheCommaOperand() {
        XCTAssertThrowsError(try assembler.compile("LI A $1")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `LI'")
        }
    }
    
    func testFailToCompileLIWithBadComma() {
        XCTAssertThrowsError(try assembler.compile("LI,")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `LI'")
        }
    }
    
    func testFailToCompileLIWhereDestinationIsANumber() {
        // TODO: Better error message here
        XCTAssertThrowsError(try assembler.compile("LI $1, A")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `LI'")
        }
    }
    
    func testFailToCompileLIWhereSourceIsARegister() {
        // TODO: Better error message here
        XCTAssertThrowsError(try assembler.compile("LI B, A")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `LI'")
        }
    }
    
    func testFailToCompileLIWithTooManyOperands() {
        // TODO: Better error message here
        XCTAssertThrowsError(try assembler.compile("LI A, $1, B")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `LI'")
        }
    }
    
    func testCompileValidLI() {
        let instructions = try! assembler.compile("LI D, 42")
        
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, 0)
        XCTAssertEqual(instructions[1].immediate, 42)
        
        let microcodeGenerator = makeMicrocodeGenerator()
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        
        XCTAssertEqual(controlWord.CO, false)
        XCTAssertEqual(controlWord.DI, false)
    }
    
    func testFailToCompileLIWithTooBigNumber() {
        XCTAssertThrowsError(try assembler.compile("LI D, 10000000")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "immediate value is not between 0 and 255: `10000000'")
        }
    }
    
    func testFailToCompileMOVWithNoOperands() {
        // TODO: Better error message here
        XCTAssertThrowsError(try assembler.compile("MOV")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `MOV'")
        }
    }
    
    func testFailToCompileMOVWithOneOperand() {
        // TODO: Better error message here
        XCTAssertThrowsError(try assembler.compile("MOV A")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `MOV'")
        }
    }
    
    func testFailToCompileMOVWithTooManyOperands() {
        // TODO: Better error message here
        XCTAssertThrowsError(try assembler.compile("MOV A, B, C")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `MOV'")
        }
    }
    
    func testFailToCompileMOVWithNumberInFirstOperand() {
        // TODO: Better error message here
        XCTAssertThrowsError(try assembler.compile("MOV $1, A")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `MOV'")
        }
    }
    
    func testFailToCompileMOVWithNumberInSecondOperand() {
        // TODO: Better error message here
        XCTAssertThrowsError(try assembler.compile("MOV A, $1")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "operand type mismatch: `MOV'")
        }
    }
    
    func testFailToCompileMOVWithInvalidDestinationRegisterE() {
        XCTAssertThrowsError(try assembler.compile("MOV E, A")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "register cannot be used as a destination: `E'")
        }
    }
    
    func testFailToCompileMOVWithInvalidDestinationRegisterC() {
        XCTAssertThrowsError(try assembler.compile("MOV C, A")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "register cannot be used as a destination: `C'")
        }
    }
    
    func testFailToCompileMOVWithInvalidSourceRegisterD() {
        XCTAssertThrowsError(try assembler.compile("MOV A, D")) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.message, "register cannot be used as a source: `D'")
        }
    }
    
    func testCompileValidMOV() {
        let instructions = try! assembler.compile("MOV D, A")
        
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, 0)
        
        let microcodeGenerator = makeMicrocodeGenerator()
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        
        XCTAssertEqual(controlWord.AO, false)
        XCTAssertEqual(controlWord.DI, false)
    }
}
