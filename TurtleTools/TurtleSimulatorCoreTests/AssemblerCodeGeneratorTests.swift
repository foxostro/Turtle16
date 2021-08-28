//
//  AssemblerCodeGeneratorTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleSimulatorCore

class AssemblerCodeGeneratorTests: XCTestCase {
    let aabb = TokenNumber(literal: 0xaabb)
    let tooLargeAddress = TokenNumber(literal: 0xffffffff)
    let negativeAddress = TokenNumber(literal: -1)
    
    var microcodeGenerator = MicrocodeGenerator()
    var nop: UInt8 = 0
    var hlt: UInt8 = 0
    
    override func setUp() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        nop = UInt8(microcodeGenerator.getOpcode(mnemonic: "NOP")!)
        hlt = UInt8(microcodeGenerator.getOpcode(mnemonic: "HLT")!)
    }
    
    func mustCompile(_ root: TopLevel) -> [Instruction] {
        let codeGenerator = makeCodeGenerator()
        codeGenerator.compile(ast: root, base: 0x0000)
        if codeGenerator.hasError {
            XCTFail()
        }
        return codeGenerator.instructions
    }
    
    func mustFailToCompile(_ root: TopLevel) -> [CompilerError] {
        let codeGenerator = makeCodeGenerator()
        codeGenerator.compile(ast: root, base: 0x0000)
        if !codeGenerator.hasError {
            XCTFail()
        }
        return codeGenerator.errors
    }
    
    func makeCodeGenerator(symbols: [String:Int] = [:]) -> AssemblerCodeGenerator {
        let assemblerBackEnd = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        let codeGenerator = AssemblerCodeGenerator(assemblerBackEnd: assemblerBackEnd)
        codeGenerator.symbols = symbols
        return codeGenerator
    }
    
    func testEmptyProgram() {
        let instructions = mustCompile(TopLevel(children: []))
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].opcode, nop)
    }
    
    func testNop() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: [])
        ])
        let instructions = mustCompile(ast)
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, nop)
    }
    
    func testHlt() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "HLT",
                            parameters: [])
        ])
        let instructions = mustCompile(ast)
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, hlt)
    }
    
    func testFailToCompileMOVWithNoOperands() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "MOV",
                            parameters: [])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToCompileMOVWithOneOperand() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "MOV",
                            parameters: [
                                ParameterRegister(value: .A)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToCompileMOVWithTooManyOperands() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "MOV",
                            parameters: [
                                ParameterRegister(value: .A),
                                ParameterRegister(value: .B),
                                ParameterRegister(value: .C),
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToCompileMOVWithNumberInFirstOperand() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "MOV",
                            parameters: [
                                ParameterNumber(value: 1),
                                ParameterRegister(value: .A)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToCompileMOVWithNumberInSecondOperand() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "MOV",
                            parameters: [
                                ParameterRegister(value: .A),
                                ParameterNumber(value: 1)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToCompileMOVWithInvalidDestinationRegisterE() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "MOV",
                            parameters: [
                                ParameterRegister(value: .E),
                                ParameterRegister(value: .A)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `E'")
    }

    func testFailToCompileMOVWithInvalidDestinationRegisterC() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "MOV",
                            parameters: [
                                ParameterRegister(value: .C),
                                ParameterRegister(value: .A)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `C'")
    }

    func testFailToCompileMOVWithInvalidSourceRegisterD() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "MOV",
                            parameters: [
                                ParameterRegister(value: .A),
                                ParameterRegister(value: .D)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a source: `D'")
    }
    
    func testMov() throws {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "MOV",
                            parameters: [
                                ParameterRegister(value: .D),
                                ParameterRegister(value: .A),
                            ])
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        
        XCTAssertEqual(controlWord.AO, .active)
        XCTAssertEqual(controlWord.DI, .active)
    }
    
    func testFailToCompileLIWithNoOperands() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "LI",
                            parameters: [])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToCompileLIWithOneOperand() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "LI",
                            parameters: [
                                ParameterNumber(value: 1)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToCompileLIWhereDestinationIsANumber() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "LI",
                            parameters: [
                                ParameterNumber(value: 1),
                                ParameterRegister(value: .A)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToCompileLIWhereSourceIsARegister() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "LI",
                            parameters: [
                                ParameterRegister(value: .B),
                                ParameterRegister(value: .A)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToCompileLIWithTooManyOperands() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "LI",
                            parameters: [
                                ParameterRegister(value: .A),
                                ParameterNumber(value: 1),
                                ParameterNumber(value: 1)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `LI'")
    }
    
    func testLoadImmediate() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "LI",
                            parameters: [
                                ParameterRegister(value: .D),
                                ParameterNumber(value: 42),
                            ])
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].immediate, 42)
        
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        
        XCTAssertEqual(controlWord.CO, .active)
        XCTAssertEqual(controlWord.DI, .active)
    }
    
    func testFailToCompileADDWithIdentifierOperand() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "ADD",
                            parameters: [
                                ParameterIdentifier(value: "label")
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `ADD'")
    }

    func testFailToCompileADDWithInvalidDestinationRegisterE() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "ADD",
                            parameters: [
                                ParameterRegister(value: .E)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `E'")
    }

    func testFailToCompileADDWithInvalidDestinationRegisterC() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "ADD",
                            parameters: [
                                ParameterRegister(value: .C)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `C'")
    }
    
    func testAdd() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "ADD",
                            parameters: [
                                ParameterRegister(value: .D)
                            ])
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        
        XCTAssertEqual(instructions[1].immediate, 0b1001)
        
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        
        XCTAssertEqual(controlWord.EO, .active)
        XCTAssertEqual(controlWord.DI, .active)
        XCTAssertEqual(controlWord.CarryIn, .inactive)
    }
    
    func testJmp() {
        let ast = TopLevel(children: [
            LabelDeclaration(identifier: "foo"),
            TurtleTTLInstructionNode(instruction: "LXY",
                            parameters: [
                                ParameterIdentifier(value: "foo")
                            ]),
            TurtleTTLInstructionNode(instruction: "JMP",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: [])])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 6)
        
        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)
        
        // Load the resolved label address into XY.
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 1)
        
        // The JMP command jumps to the address in the XY register pair.
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "JMP")!))
        
        // JMP must be followed by two NOPs. A jump does not clear the pipeline
        // so this is necessary to ensure correct operation.
        XCTAssertEqual(instructions[4].opcode, nop)
        XCTAssertEqual(instructions[5].opcode, nop)
    }
    
    func testForwardJmp() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "LXY",
                            parameters: [
                                ParameterIdentifier(value: "foo")
                            ]),
            TurtleTTLInstructionNode(instruction: "JMP",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: []),
            LabelDeclaration(identifier: "foo"),
            TurtleTTLInstructionNode(instruction: "HLT",
                            parameters: [])
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 7)
        
        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)
        
        // Load the resolved label address into XY.
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 6)
        
        // The JMP command jumps to the address in the XY register pair.
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "JMP")!))
        
        // JMP must be followed by two NOPs. A jump does not clear the pipeline
        // so this is necessary to ensure correct operation.
        XCTAssertEqual(instructions[4].opcode, nop)
        XCTAssertEqual(instructions[5].opcode, nop)
        
        // HLT halts the machine to stop it running.
        XCTAssertEqual(instructions[6].opcode, hlt)
    }
    
    func testJmpToAddressZero() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "LXY",
                            parameters: [
                                ParameterNumber(value: 0)
                            ]),
            TurtleTTLInstructionNode(instruction: "JMP",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: [])
        ])
        let instructions = mustCompile(ast)

        XCTAssertEqual(instructions.count, 6)

        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)

        // Load the resolved label address into XY.
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 0)

        // The JMP command jumps to the address in the XY register pair.
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "JMP")!))

        // JMP must be followed by two NOPs. A jump does not clear the pipeline
        // so this is necessary to ensure correct operation.
        XCTAssertEqual(instructions[4].opcode, nop)
        XCTAssertEqual(instructions[5].opcode, nop)
    }
    
    func testJmpToAddressNegative() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "LXY",
                            parameters: [
                                ParameterNumber(value: -1)
                            ]),
            TurtleTTLInstructionNode(instruction: "JMP",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: [])
        ])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.message, "invalid address: 0xffffffff")
    }
    
    func testJmpToAddressTooLarge() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "LXY",
                            parameters: [
                                ParameterNumber(value: 0x10000)
                            ]),
            TurtleTTLInstructionNode(instruction: "JMP",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: [])
        ])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.message, "invalid address: 0x10000")
    }
    
    func testJC() {
        let ast = TopLevel(children: [
            LabelDeclaration(identifier: "foo"),
            TurtleTTLInstructionNode(instruction: "LXY",
                            parameters: [
                                ParameterIdentifier(value: "foo")
                            ]),
            TurtleTTLInstructionNode(instruction: "JC",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: [])
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 6)
        
        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)
        
        // Load the resolved label address into XY.
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 1)
        
        // The JC command jumps to the address in the XY register pair, but only
        // if the carry flag is set.
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "JC")!))
        
        // JC must be followed by two NOPs. A jump does not clear the pipeline
        // so this is necessary to ensure correct operation.
        XCTAssertEqual(instructions[4].opcode, nop)
        XCTAssertEqual(instructions[5].opcode, nop)
    }
    
    func testJCToAddressZero() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "LXY",
                            parameters: [
                                ParameterNumber(value: 0)
                            ]),
            TurtleTTLInstructionNode(instruction: "JC",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: [])
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 6)
        
        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)
        
        // Load the resolved label address into XY.
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 0)
        
        // The JC command jumps to the address in the XY register pair.
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "JC")!))
        
        // JC must be followed by two NOPs. A jump does not clear the pipeline
        // so this is necessary to ensure correct operation.
        XCTAssertEqual(instructions[4].opcode, nop)
        XCTAssertEqual(instructions[5].opcode, nop)
    }
    
    func testJCToAddressNegative() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "LXY",
                            parameters: [
                                ParameterNumber(value: -1)
                            ]),
            TurtleTTLInstructionNode(instruction: "JC",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: [])
        ])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.message, "invalid address: 0xffffffff")
    }
    
    func testJCToAddressTooLarge() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "LXY",
                            parameters: [
                                ParameterNumber(value: 0x10000)
                            ]),
            TurtleTTLInstructionNode(instruction: "JC",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: []),
            TurtleTTLInstructionNode(instruction: "NOP",
                            parameters: [])
        ])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.message, "invalid address: 0x10000")
    }
    
    func testCMP() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "CMP",
                            parameters: [])
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "ALUwoC")!))
        XCTAssertEqual(instructions[1].immediate, 0b0110)
        
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        XCTAssertEqual(controlWord.FI, .active)
        XCTAssertEqual(controlWord.CarryIn, .inactive)
    }
    
    func testINUV() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "INUV",
                            parameters: [])
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "INUV")!))
        XCTAssertEqual(instructions[1].immediate, 0)
    }
    
    func testINXY() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "INXY",
                            parameters: [])
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "INXY")!))
        XCTAssertEqual(instructions[1].immediate, 0)
    }
    
    func testFailToCompileBLTWithNoOperands() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "BLT",
                            parameters: [])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `BLT'")
    }

    func testFailToCompileBLTWithOneOperand() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "BLT",
                            parameters: [
                                ParameterRegister(value: .A)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `BLT'")
    }

    func testFailToCompileBLTWithTooManyOperands() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "BLT",
                            parameters: [
                                ParameterRegister(value: .A),
                                ParameterRegister(value: .B),
                                ParameterRegister(value: .C),
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `BLT'")
    }

    func testFailToCompileBLTWithNumberInFirstOperand() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "BLT",
                            parameters: [
                                ParameterNumber(value: 1),
                                ParameterRegister(value: .A)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `BLT'")
    }

    func testFailToCompileBLTWithNumberInSecondOperand() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "BLT",
                            parameters: [
                                ParameterRegister(value: .A),
                                ParameterNumber(value: 1)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `BLT'")
    }

    func testFailToCompileBLTWithInvalidDestinationRegisterE() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "BLT",
                            parameters: [
                                ParameterRegister(value: .E),
                                ParameterRegister(value: .A)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `E'")
    }

    func testFailToCompileBLTWithInvalidDestinationRegisterC() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "BLT",
                            parameters: [
                                ParameterRegister(value: .C),
                                ParameterRegister(value: .A)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `C'")
    }

    func testFailToCompileBLTWithInvalidSourceRegisterD() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "BLT",
                            parameters: [
                                ParameterRegister(value: .A),
                                ParameterRegister(value: .D)
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a source: `D'")
    }
    
    func testBLT() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "BLT",
                            parameters: [
                                ParameterRegister(value: .P),
                                ParameterRegister(value: .M),
                            ])
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        
        XCTAssertEqual(controlWord.PI, .active)
        XCTAssertEqual(controlWord.MO, .active)
        XCTAssertEqual(controlWord.UVInc, .active)
        XCTAssertEqual(controlWord.XYInc, .active)
    }
    
    func testFailToCompileDueToRedefinitionOfLabel() {
        let ast = TopLevel(children: [
            LabelDeclaration(identifier: "foo"),
            LabelDeclaration(identifier: "foo")
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "label redefines existing symbol: `foo'")
    }
    
    func testFailToCompileDueToRedefinitionOfConstant() {
        let ast = TopLevel(children: [
            ConstantDeclaration(identifier: "foo", value: 1),
            ConstantDeclaration(identifier: "foo", value: 42),
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "constant redefines existing symbol: `foo'")
    }

    func testLICannotUseUndeclaredSymbolAsSource() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "LI",
                            parameters: [
                                ParameterRegister(value: .B),
                                ParameterIdentifier(value: "foo")
                            ])
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "use of unresolved identifier: `foo'")
    }
    
    func testLIWithConstantSource() {
        let ast = TopLevel(children: [
            ConstantDeclaration(identifier: "foo",
                                value: 42),
            TurtleTTLInstructionNode(instruction: "LI",
                            parameters: [
                                ParameterRegister(value: .B),
                                ParameterIdentifier(value: "foo")
                            ])
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].immediate, 42)
        
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        
        XCTAssertEqual(controlWord.CO, .active)
        XCTAssertEqual(controlWord.BI, .active)
    }
    
    func testDEA() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "DEA",
                            parameters: [
                                ParameterRegister(value: .D)
                            ])
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        
        XCTAssertEqual(instructions[1].immediate, 0b1111)
        
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        
        XCTAssertEqual(controlWord.EO, .active)
        XCTAssertEqual(controlWord.DI, .active)
        XCTAssertEqual(controlWord.CarryIn, .inactive)
    }
    
    func testDCA() {
        let ast = TopLevel(children: [
            TurtleTTLInstructionNode(instruction: "DCA",
                            parameters: [
                                ParameterRegister(value: .A)
                            ])
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        
        XCTAssertEqual(instructions[1].immediate, 0b1111)
        
        let controlWord0 = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        XCTAssertEqual(controlWord0.EO, .inactive)
        XCTAssertEqual(controlWord0.AI, .inactive)
        XCTAssertEqual(controlWord0.CarryIn, .inactive)
        
        let controlWord1 = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 1, equalFlag: 0)))
        XCTAssertEqual(controlWord1.EO, .active)
        XCTAssertEqual(controlWord1.AI, .active)
        XCTAssertEqual(controlWord1.CarryIn, .inactive)
    }
}
