//
//  AssemblerCodeGenPassTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleTTL

class AssemblerCodeGenPassTests: XCTestCase {
    let aabb = TokenNumber(lineNumber: 1, lexeme: "0xaabb", literal: 0xaabb)
    let tooLargeAddress = TokenNumber(lineNumber: 1, lexeme: "0xffffffff", literal: 0xffffffff)
    let negativeAddress = TokenNumber(lineNumber: 1, lexeme: "-1", literal: -1)
    
    var microcodeGenerator = MicrocodeGenerator()
    var nop: UInt8 = 0
    var hlt: UInt8 = 0
    
    func makeBackEnd(symbols: [String : Int] = [:]) -> AssemblerCodeGenPass {
        let codeGen = CodeGenerator(microcodeGenerator: microcodeGenerator)
        let compiler = AssemblerCodeGenPass(codeGenerator: codeGen)
        compiler.symbols = symbols
        return compiler
    }
    
    override func setUp() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        nop = UInt8(microcodeGenerator.getOpcode(withMnemonic: "NOP")!)
        hlt = UInt8(microcodeGenerator.getOpcode(withMnemonic: "HLT")!)
    }
    
    func mustCompile(_ root: AbstractSyntaxTreeNode) -> [Instruction] {
        let compiler = makeBackEnd()
        compiler.compile(ast: root, base: 0x0000)
        assert(!compiler.hasError)
        return compiler.instructions
    }
    
    func mustFailToCompile(_ root: AbstractSyntaxTreeNode) -> [AssemblerError] {
        let compiler = makeBackEnd()
        compiler.compile(ast: root, base: 0x0000)
        assert(compiler.hasError)
        return compiler.errors
    }
    
    func testEmptyProgram() {
        let instructions = mustCompile(AbstractSyntaxTreeNode())
        XCTAssertEqual(instructions.count, 1)
        XCTAssertEqual(instructions[0].opcode, nop)
    }
    
    func testNop() {
        let ast = AbstractSyntaxTreeNode(children: [InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "NOP"), parameters: ParameterListNode(parameters: []))])
        let instructions = mustCompile(ast)
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, nop)
    }
    
    func testHlt() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 0, lexeme: "HLT"),
                            parameters: ParameterListNode(parameters: []))
        ])
        let instructions = mustCompile(ast)
        XCTAssertEqual(instructions.count, 2)
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, hlt)
    }
    
    func testFailToCompileMOVWithNoOperands() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "MOV"),
                            parameters: ParameterListNode(parameters: []))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToCompileMOVWithOneOperand() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "MOV"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToCompileMOVWithTooManyOperands() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "MOV"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A),
                                TokenRegister(lineNumber: 1, lexeme: "B", literal: .B),
                                TokenRegister(lineNumber: 1, lexeme: "C", literal: .C),
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToCompileMOVWithNumberInFirstOperand() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "MOV"),
                            parameters: ParameterListNode(parameters: [
                                TokenNumber(lineNumber: 1, lexeme: "$1", literal: 1),
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToCompileMOVWithNumberInSecondOperand() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "MOV"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A),
                                TokenNumber(lineNumber: 1, lexeme: "$1", literal: 1)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `MOV'")
    }

    func testFailToCompileMOVWithInvalidDestinationRegisterE() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "MOV"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "E", literal: .E),
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `E'")
    }

    func testFailToCompileMOVWithInvalidDestinationRegisterC() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "MOV"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "C", literal: .C),
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `C'")
    }

    func testFailToCompileMOVWithInvalidSourceRegisterD() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "MOV"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A),
                                TokenRegister(lineNumber: 1, lexeme: "D", literal: .D)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a source: `D'")
    }
    
    func testMov() throws {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "MOV"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "D", literal: .D),
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A),
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
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "LI"),
                            parameters: ParameterListNode(parameters: []))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToCompileLIWithOneOperand() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "LI"),
                            parameters: ParameterListNode(parameters: [
                                TokenNumber(lineNumber: 1, lexeme: "$1", literal: 1)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToCompileLIWhereDestinationIsANumber() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "LI"),
                            parameters: ParameterListNode(parameters: [
                                TokenNumber(lineNumber: 1, lexeme: "$1", literal: 1),
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToCompileLIWhereSourceIsARegister() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "LI"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "B", literal: .B),
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `LI'")
    }

    func testFailToCompileLIWithTooManyOperands() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "LI"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A),
                                TokenNumber(lineNumber: 1, lexeme: "$1", literal: 1),
                                TokenNumber(lineNumber: 1, lexeme: "$1", literal: 1)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `LI'")
    }
    
    func testLoadImmediate() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "LI"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "D", literal: .D),
                                TokenNumber(lineNumber: 1, lexeme: "42", literal: 42),
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
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "ADD"),
                    parameters: ParameterListNode(parameters: [
                        TokenIdentifier(lineNumber: 1, lexeme: "label")
                    ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `ADD'")
    }

    func testFailToCompileADDWithInvalidDestinationRegisterE() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "ADD"),
                    parameters: ParameterListNode(parameters: [
                        TokenRegister(lineNumber: 1, lexeme: "E", literal: .E)
                    ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `E'")
    }

    func testFailToCompileADDWithInvalidDestinationRegisterC() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "ADD"),
                    parameters: ParameterListNode(parameters: [
                        TokenRegister(lineNumber: 1, lexeme: "C", literal: .C)
                    ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `C'")
    }
    
    func testAdd() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 0, lexeme: "ADD"),
                    parameters: ParameterListNode(parameters: [
                        TokenRegister(lineNumber: 0, lexeme: "", literal: RegisterName.D)
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
        let ast = AbstractSyntaxTreeNode(children: [
            LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 2, lexeme: "LXY"),
                            parameters: ParameterListNode(parameters: [TokenIdentifier(lineNumber: 2, lexeme: "foo")])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 3, lexeme: "JMP"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 4, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 5, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: []))])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 6)
        
        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)
        
        // Load the resolved label address into XY.
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
    
    func testForwardJmp() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "LXY"),
                            parameters: ParameterListNode(parameters: [TokenIdentifier(lineNumber: 1, lexeme: "foo")])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 2, lexeme: "JMP"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 3, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 4, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: [])),
            LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 5, lexeme: "foo")),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 6, lexeme: "HLT"),
                            parameters: ParameterListNode(parameters: []))
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 7)
        
        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)
        
        // Load the resolved label address into XY.
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 6)
        
        // The JMP command jumps to the address in the XY register pair.
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "JMP")!))
        
        // JMP must be followed by two NOPs. A jump does not clear the pipeline
        // so this is necessary to ensure correct operation.
        XCTAssertEqual(instructions[4].opcode, nop)
        XCTAssertEqual(instructions[5].opcode, nop)
        
        // HLT halts the machine to stop it running.
        XCTAssertEqual(instructions[6].opcode, hlt)
    }
    
    func testJmpToAddressZero() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "LXY"),
                            parameters: ParameterListNode(parameters: [TokenNumber(lineNumber: 1, lexeme: "0", literal: 0)])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 2, lexeme: "JMP"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 3, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 4, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: []))
        ])
        let instructions = mustCompile(ast)

        XCTAssertEqual(instructions.count, 6)

        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)

        // Load the resolved label address into XY.
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
    
    func testJmpToAddressNegative() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "LXY"),
                            parameters: ParameterListNode(parameters: [TokenNumber(lineNumber: 1, lexeme: "-1", literal: -1)])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 2, lexeme: "JMP"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 3, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 4, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: []))
        ])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.message, "invalid address: 0xffffffff")
    }
    
    func testJmpToAddressTooLarge() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "LXY"),
                            parameters: ParameterListNode(parameters: [TokenNumber(lineNumber: 1, lexeme: "0x10000", literal: 0x10000)])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 2, lexeme: "JMP"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 3, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 4, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: []))
        ])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.message, "invalid address: 0x10000")
    }
    
    func testJC() {
        let ast = AbstractSyntaxTreeNode(children: [
            LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 2, lexeme: "LXY"),
                            parameters: ParameterListNode(parameters: [TokenIdentifier(lineNumber: 2, lexeme: "foo")])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 3, lexeme: "JC"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 4, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 5, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: []))
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 6)
        
        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)
        
        // Load the resolved label address into XY.
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV X, C")!))
        XCTAssertEqual(instructions[1].immediate, 0)
        XCTAssertEqual(instructions[2].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "MOV Y, C")!))
        XCTAssertEqual(instructions[2].immediate, 1)
        
        // The JC command jumps to the address in the XY register pair, but only
        // if the carry flag is set.
        XCTAssertEqual(instructions[3].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "JC")!))
        
        // JC must be followed by two NOPs. A jump does not clear the pipeline
        // so this is necessary to ensure correct operation.
        XCTAssertEqual(instructions[4].opcode, nop)
        XCTAssertEqual(instructions[5].opcode, nop)
    }
    
    func testJCToAddressZero() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "LXY"),
                            parameters: ParameterListNode(parameters: [TokenNumber(lineNumber: 1, lexeme: "0", literal: 0)])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 2, lexeme: "JC"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 3, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 4, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: []))
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 6)
        
        // The first instruction in memory must be a NOP. Without this, CPU
        // reset does not work.
        XCTAssertEqual(instructions[0].opcode, nop)
        
        // Load the resolved label address into XY.
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
    
    func testJCToAddressNegative() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "LXY"),
            parameters: ParameterListNode(parameters: [TokenNumber(lineNumber: 1, lexeme: "-1", literal: -1)])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 2, lexeme: "JC"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 3, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 4, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: []))
        ])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.message, "invalid address: 0xffffffff")
    }
    
    func testJCToAddressTooLarge() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "LXY"),
            parameters: ParameterListNode(parameters: [TokenNumber(lineNumber: 1, lexeme: "0x10000", literal: 0x10000)])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 2, lexeme: "JC"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 3, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: [])),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 4, lexeme: "NOP"),
                            parameters: ParameterListNode(parameters: []))
        ])
        let errors = mustFailToCompile(ast)
        let error = errors.first!
        XCTAssertEqual(error.message, "invalid address: 0x10000")
    }
    
    func testCMP() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 0, lexeme: "CMP"),
                            parameters: ParameterListNode(parameters: []))
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "ALU")!))
        XCTAssertEqual(instructions[1].immediate, 0b0110)
        
        let controlWord = ControlWord(withValue: UInt(microcodeGenerator.microcode.load(opcode: Int(instructions[1].opcode), carryFlag: 0, equalFlag: 0)))
        XCTAssertEqual(controlWord.FI, .active)
        XCTAssertEqual(controlWord.CarryIn, .inactive)
    }
    
    func testINUV() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "INUV"),
                            parameters: ParameterListNode(parameters: []))
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "INUV")!))
        XCTAssertEqual(instructions[1].immediate, 0)
    }
    
    func testINXY() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "INXY"),
                            parameters: ParameterListNode(parameters: []))
        ])
        let instructions = mustCompile(ast)
        
        XCTAssertEqual(instructions.count, 2)
        
        XCTAssertEqual(instructions[0].opcode, nop)
        XCTAssertEqual(instructions[1].opcode, UInt8(microcodeGenerator.getOpcode(withMnemonic: "INXY")!))
        XCTAssertEqual(instructions[1].immediate, 0)
    }
    
    func testFailToCompileBLTWithNoOperands() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "BLT"),
                            parameters: ParameterListNode(parameters: []))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `BLT'")
    }

    func testFailToCompileBLTWithOneOperand() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "BLT"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `BLT'")
    }

    func testFailToCompileBLTWithTooManyOperands() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "BLT"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A),
                                TokenRegister(lineNumber: 1, lexeme: "B", literal: .B),
                                TokenRegister(lineNumber: 1, lexeme: "C", literal: .C),
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `BLT'")
    }

    func testFailToCompileBLTWithNumberInFirstOperand() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "BLT"),
                            parameters: ParameterListNode(parameters: [
                                TokenNumber(lineNumber: 1, lexeme: "$1", literal: 1),
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `BLT'")
    }

    func testFailToCompileBLTWithNumberInSecondOperand() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "BLT"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A),
                                TokenNumber(lineNumber: 1, lexeme: "$1", literal: 1)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "operand type mismatch: `BLT'")
    }

    func testFailToCompileBLTWithInvalidDestinationRegisterE() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "BLT"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "E", literal: .E),
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `E'")
    }

    func testFailToCompileBLTWithInvalidDestinationRegisterC() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "BLT"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "C", literal: .C),
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a destination: `C'")
    }

    func testFailToCompileBLTWithInvalidSourceRegisterD() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "BLT"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "A", literal: .A),
                                TokenRegister(lineNumber: 1, lexeme: "D", literal: .D)
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "register cannot be used as a source: `D'")
    }
    
    func testBLT() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "BLT"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "P", literal: .P),
                                TokenRegister(lineNumber: 1, lexeme: "M", literal: .M),
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
        let ast = AbstractSyntaxTreeNode(children: [
            LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo")),
            LabelDeclarationNode(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "label redefines existing symbol: `foo'")
    }
    
    func testFailToCompileDueToRedefinitionOfConstant() {
        let ast = AbstractSyntaxTreeNode(children: [
            ConstantDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                    number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
            ConstantDeclarationNode(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                                    number: TokenNumber(lineNumber: 2, lexeme: "42", literal: 42)),
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "constant redefines existing symbol: `foo'")
    }

    func testLICannotUseUndeclaredSymbolAsSource() {
        let ast = AbstractSyntaxTreeNode(children: [
            InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "LI"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 1, lexeme: "B", literal: .B),
                                TokenIdentifier(lineNumber: 1, lexeme: "foo")
                            ]))
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.line, 1)
        XCTAssertEqual(errors.first?.message, "use of undeclared identifier: `foo'")
    }
    
    func testLIWithConstantSource() {
        let ast = AbstractSyntaxTreeNode(children: [
            ConstantDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                    number: TokenNumber(lineNumber: 1, lexeme: "42", literal: 42)),
            InstructionNode(instruction: TokenIdentifier(lineNumber: 2, lexeme: "LI"),
                            parameters: ParameterListNode(parameters: [
                                TokenRegister(lineNumber: 2, lexeme: "B", literal: .B),
                                TokenIdentifier(lineNumber: 2, lexeme: "foo")
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
}
