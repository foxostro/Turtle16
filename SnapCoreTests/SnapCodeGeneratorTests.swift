//
//  SnapCodeGeneratorTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox
import TurtleCore

class SnapCodeGeneratorTests: XCTestCase {
    let kStackPointerAddressHi: UInt16 = 0x0000
    let kStackPointerAddressLo: UInt16 = 0x0001
    let kStackPointerInitialValue = 0x0000
    var kProgramPrologue = ""
    
    var microcodeGenerator: MicrocodeGenerator!
    
    override func setUp() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        
        kProgramPrologue = """
NOP
LI X, \((kStackPointerAddressHi & 0xff00) >> 8)
LI Y, \((kStackPointerAddressHi & 0x00ff))
LI M, \((kStackPointerInitialValue & 0xff00) >> 8)
LI X, \((kStackPointerAddressLo & 0xff00) >> 8)
LI Y, \((kStackPointerAddressLo & 0x00ff))
LI M, \((kStackPointerInitialValue & 0x00ff))
"""
    }
    
    func disassemble(_ instructions: [Instruction]) -> String {
        var result = ""
        let formatter = InstructionFormatter(microcodeGenerator: microcodeGenerator)
        if let instruction = instructions.first {
            result += formatter.makeInstructionWithDisassembly(instruction: instruction).disassembly ?? instruction.description
        }
        for instruction in instructions[1..<instructions.count] {
            result += "\n"
            result += formatter.makeInstructionWithDisassembly(instruction: instruction).disassembly ?? instruction.description
        }
        return result
    }
    
    func mustCompile(_ root: AbstractSyntaxTreeNode) -> [Instruction] {
        let codeGenerator = makeCodeGenerator()
        codeGenerator.compile(ast: root, base: 0x0000)
        if codeGenerator.hasError {
            XCTFail()
        }
        return codeGenerator.instructions
    }
    
    func mustFailToCompile(_ root: AbstractSyntaxTreeNode) -> [CompilerError] {
        let codeGenerator = makeCodeGenerator()
        codeGenerator.compile(ast: root, base: 0x0000)
        if !codeGenerator.hasError {
            XCTFail()
        }
        return codeGenerator.errors
    }
    
    func makeCodeGenerator(symbols: [String : Int] = [:]) -> SnapCodeGenerator {
        let assemblerBackEnd = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        let codeGenerator = SnapCodeGenerator(assemblerBackEnd: assemblerBackEnd)
        codeGenerator.symbols = symbols
        return codeGenerator
    }
    
    func testEmptyProgram() {
        let instructions = mustCompile(AbstractSyntaxTreeNode())
        XCTAssertEqual(disassemble(instructions), kProgramPrologue)
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
            ConstantDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                expression: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))),
            ConstantDeclaration(identifier: TokenIdentifier(lineNumber: 2, lexeme: "foo"),
                                expression: Expression.Literal(number: TokenNumber(lineNumber: 2, lexeme: "42", literal: 42))),
        ])
        let errors = mustFailToCompile(ast)
        XCTAssertEqual(errors.first?.message, "constant redefines existing symbol: `foo'")
    }
}
