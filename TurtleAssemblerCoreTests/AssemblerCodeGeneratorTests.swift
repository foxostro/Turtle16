//
//  AssemblerCodeGeneratorTests.swift
//  TurtleAssemblerCoreTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleAssemblerCore
import TurtleCompilerToolbox

class AssemblerCodeGeneratorTests: XCTestCase {
    let aabb = TokenNumber(sourceAnchor: nil, literal: 0xaabb)
    let tooLargeAddress = TokenNumber(sourceAnchor: nil, literal: 0xffffffff)
    let negativeAddress = TokenNumber(sourceAnchor: nil, literal: -1)
    
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
        let instructions = mustCompile(TopLevel(sourceAnchor: nil, children: []))
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].opcode, nop)
    }
    
    func testNop() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))
        ])
        let instructions = mustCompile(ast)
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, nop)
    }
    
    func testHlt() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "HLT",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))
        ])
        let instructions = mustCompile(ast)
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, hlt)
    }
    
    func testFailToCompileMOVWithNoOperands() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "MOV",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToCompileMOVWithOneOperand() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "MOV",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToCompileMOVWithTooManyOperands() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "MOV",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .A),
                                ParameterRegister(sourceAnchor: nil, value: .B),
                                ParameterRegister(sourceAnchor: nil, value: .C),
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToCompileMOVWithNumberInFirstOperand() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "MOV",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterNumber(sourceAnchor: nil, value: 1),
                                ParameterRegister(sourceAnchor: nil, value: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToCompileMOVWithNumberInSecondOperand() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "MOV",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .A),
                                ParameterNumber(sourceAnchor: nil, value: 1)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToCompileMOVWithInvalidDestinationRegisterE() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "MOV",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .E),
                                ParameterRegister(sourceAnchor: nil, value: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `E'")
    }

    func testFailToCompileMOVWithInvalidDestinationRegisterC() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "MOV",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .C),
                                ParameterRegister(sourceAnchor: nil, value: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `C'")
    }

    func testFailToCompileMOVWithInvalidSourceRegisterD() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "MOV",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .A),
                                ParameterRegister(sourceAnchor: nil, value: .D)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a source: `D'")
    }
    
    func testMov() throws {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "MOV",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .D),
                                ParameterRegister(sourceAnchor: nil, value: .A),
                            ]))
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        
        XCTAssertEqual(controlWord.AO, .active)
        XCTAssertEqual(controlWord.DI, .active)
    }
    
    func testFailToCompileLIWithNoOperands() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "LI",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToCompileLIWithOneOperand() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "LI",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterNumber(sourceAnchor: nil, value: 1)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToCompileLIWhereDestinationIsANumber() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil, instruction: "LI",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterNumber(sourceAnchor: nil, value: 1),
                                ParameterRegister(sourceAnchor: nil, value: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToCompileLIWhereSourceIsARegister() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "LI",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .B),
                                ParameterRegister(sourceAnchor: nil, value: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToCompileLIWithTooManyOperands() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "LI",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .A),
                                ParameterNumber(sourceAnchor: nil, value: 1),
                                ParameterNumber(sourceAnchor: nil, value: 1)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `LI'")
    }
    
    func testLoadImmediate() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "LI",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .D),
                                ParameterNumber(sourceAnchor: nil, value: 42),
                            ]))
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "ADD",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterIdentifier(sourceAnchor: nil, value: "label")
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `ADD'")
    }

    func testFailToCompileADDWithInvalidDestinationRegisterE() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "ADD",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .E)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `E'")
    }

    func testFailToCompileADDWithInvalidDestinationRegisterC() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "ADD",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .C)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `C'")
    }
    
    func testAdd() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "ADD",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .D)
                            ]))
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            LabelDeclaration(sourceAnchor: nil, identifier: "foo"),
            InstructionNode(sourceAnchor: nil,
                            instruction: "LXY",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterIdentifier(sourceAnchor: nil, value: "foo")
                            ])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "JMP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))])
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "LXY",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterIdentifier(sourceAnchor: nil, value: "foo")
                            ])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "JMP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            LabelDeclaration(sourceAnchor: nil,
                                 identifier: "foo"),
            InstructionNode(sourceAnchor: nil,
                            instruction: "HLT",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "LXY",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterNumber(sourceAnchor: nil, value: 0)
                            ])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "JMP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "LXY",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterNumber(sourceAnchor: nil, value: -1)
                            ])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "JMP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))
        ])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.message, "invalid address: 0xffffffff")
    }
    
    func testJmpToAddressTooLarge() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "LXY",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterNumber(sourceAnchor: nil, value: 0x10000)
                            ])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "JMP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))
        ])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.message, "invalid address: 0x10000")
    }
    
    func testJC() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            LabelDeclaration(sourceAnchor: nil, identifier: "foo"),
            InstructionNode(sourceAnchor: nil,
                            instruction: "LXY",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterIdentifier(sourceAnchor: nil, value: "foo")
                            ])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "JC",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "LXY",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterNumber(sourceAnchor: nil, value: 0)
                            ])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "JC",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "LXY",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterNumber(sourceAnchor: nil, value: -1)
                            ])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "JC",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))
        ])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.message, "invalid address: 0xffffffff")
    }
    
    func testJCToAddressTooLarge() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "LXY",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterNumber(sourceAnchor: nil, value: 0x10000)
                            ])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "JC",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [])),
            InstructionNode(sourceAnchor: nil,
                            instruction: "NOP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))
        ])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.message, "invalid address: 0x10000")
    }
    
    func testCMP() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "CMP",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "INUV",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "INUV")!))
        XCTAssertEqual(instructions[1].immediate, 0)
    }
    
    func testINXY() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "INXY",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(mnemonic: "INXY")!))
        XCTAssertEqual(instructions[1].immediate, 0)
    }
    
    func testFailToCompileBLTWithNoOperands() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "BLT",
                            parameters: ParameterList(sourceAnchor: nil, parameters: []))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `BLT'")
    }

    func testFailToCompileBLTWithOneOperand() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "BLT",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `BLT'")
    }

    func testFailToCompileBLTWithTooManyOperands() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "BLT",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .A),
                                ParameterRegister(sourceAnchor: nil, value: .B),
                                ParameterRegister(sourceAnchor: nil, value: .C),
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `BLT'")
    }

    func testFailToCompileBLTWithNumberInFirstOperand() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "BLT",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterNumber(sourceAnchor: nil, value: 1),
                                ParameterRegister(sourceAnchor: nil, value: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `BLT'")
    }

    func testFailToCompileBLTWithNumberInSecondOperand() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "BLT",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .A),
                                ParameterNumber(sourceAnchor: nil, value: 1)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `BLT'")
    }

    func testFailToCompileBLTWithInvalidDestinationRegisterE() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "BLT",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .E),
                                ParameterRegister(sourceAnchor: nil, value: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `E'")
    }

    func testFailToCompileBLTWithInvalidDestinationRegisterC() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "BLT",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .C),
                                ParameterRegister(sourceAnchor: nil, value: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `C'")
    }

    func testFailToCompileBLTWithInvalidSourceRegisterD() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "BLT",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .A),
                                ParameterRegister(sourceAnchor: nil, value: .D)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a source: `D'")
    }
    
    func testBLT() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "BLT",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .P),
                                ParameterRegister(sourceAnchor: nil, value: .M),
                            ]))
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            LabelDeclaration(sourceAnchor: nil, identifier: "foo"),
            LabelDeclaration(sourceAnchor: nil, identifier: "foo")
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "label redefines existing symbol: `foo'")
    }
    
    func testFailToCompileDueToRedefinitionOfConstant() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            ConstantDeclaration(sourceAnchor: nil,
                                    identifier: "foo",
                                    value: 1),
            ConstantDeclaration(sourceAnchor: nil,
                                    identifier: "foo",
                                    value: 42),
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "constant redefines existing symbol: `foo'")
    }

    func testLICannotUseUndeclaredSymbolAsSource() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "LI",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .B),
                                ParameterIdentifier(sourceAnchor: nil, value: "foo")
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "use of unresolved identifier: `foo'")
    }
    
    func testLIWithConstantSource() {
        let ast = TopLevel(sourceAnchor: nil, children: [
            ConstantDeclaration(sourceAnchor: nil,
                                identifier: "foo",
                                value: 42),
            InstructionNode(sourceAnchor: nil,
                            instruction: "LI",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .B),
                                ParameterIdentifier(sourceAnchor: nil, value: "foo")
                            ]))
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "DEA",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .D)
                            ]))
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
        let ast = TopLevel(sourceAnchor: nil, children: [
            InstructionNode(sourceAnchor: nil,
                            instruction: "DCA",
                            parameters: ParameterList(sourceAnchor: nil, parameters: [
                                ParameterRegister(sourceAnchor: nil, value: .A)
                            ]))
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
