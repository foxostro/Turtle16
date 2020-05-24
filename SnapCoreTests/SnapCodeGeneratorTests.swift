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
import TurtleSimulatorCore
import TurtleCore

class SnapCodeGeneratorTests: XCTestCase {
    let isVerboseLogging = false
    var kProgramPrologue = ""
    let kProgramEpilogue = "HLT"
    
    var microcodeGenerator: MicrocodeGenerator!
    
    func execute(instructions: [Instruction]) -> Computer {
        let computer = makeComputer()
        computer.provideInstructions(instructions)
        XCTAssertNoThrow(try computer.runUntilHalted())
        return computer
    }
    
    func makeComputer() -> Computer {
        let computer = Computer()
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        computer.provideMicrocode(microcode: microcodeGenerator.microcode)
        computer.logger = makeLogger()
        return computer
    }
    
    func makeLogger() -> Logger {
        return isVerboseLogging ? ConsoleLogger() : NullLogger()
    }
    
    override func setUp() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        
        kProgramPrologue = """
NOP
LI X, \((SnapCodeGenerator.kStackPointerAddressHi & 0xff00) >> 8)
LI Y, \((SnapCodeGenerator.kStackPointerAddressHi & 0x00ff))
LI M, \((SnapCodeGenerator.kStackPointerInitialValue & 0xff00) >> 8)
LI X, \((SnapCodeGenerator.kStackPointerAddressLo & 0xff00) >> 8)
LI Y, \((SnapCodeGenerator.kStackPointerAddressLo & 0x00ff))
LI M, \((SnapCodeGenerator.kStackPointerInitialValue & 0x00ff))
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
    
    func makeCodeGenerator(symbols: SymbolTable = [:]) -> SnapCodeGenerator {
        let assemblerBackEnd = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        let codeGenerator = SnapCodeGenerator(assemblerBackEnd: assemblerBackEnd)
        codeGenerator.symbols = symbols
        return codeGenerator
    }
    
    // Tacks the program epilogue and prologue onto the given assembly code.
    func makeExpectedProgram(_ userProgram: String) -> String {
        if userProgram == "" {
            return kProgramPrologue + "\n" + kProgramEpilogue
        } else {
            return kProgramPrologue + "\n" + userProgram + "\n" + kProgramEpilogue
        }
    }
    
    func testEmptyProgram() {
        let instructions = mustCompile(AbstractSyntaxTreeNode())
        XCTAssertEqual(disassemble(instructions), makeExpectedProgram(""))
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
    
    func testCompileConstantAssignment() {
        let ast = AbstractSyntaxTreeNode(children: [
            ConstantDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                expression: Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                                              left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                                              right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))))
        ])
        let codeGenerator = makeCodeGenerator()
        codeGenerator.compile(ast: ast, base: 0x0000)
        XCTAssertFalse(codeGenerator.hasError)
        XCTAssertEqual(codeGenerator.symbols["foo"], 2)
    }
    
    func testCompileConstantAssignmentReferencingAnotherConstant() {
        let ast = AbstractSyntaxTreeNode(children: [
            ConstantDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "bar"),
                                expression: Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                                              left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                                              right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))),
            ConstantDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                expression: Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                                              left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                                              right: Expression.Identifier(identifier: TokenIdentifier(lineNumber: 1, lexeme: "bar"))))
        ])
        let codeGenerator = makeCodeGenerator()
        codeGenerator.compile(ast: ast, base: 0x0000)
        XCTAssertFalse(codeGenerator.hasError)
        XCTAssertEqual(codeGenerator.symbols["bar"], Optional<Int>(2))
        XCTAssertEqual(codeGenerator.symbols["foo"], Optional<Int>(3))
    }
    
    func testEvalStatement_AdditionAndMultiplication() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "+", op: .plus),
                                     left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "4", literal: 4)),
                                     right: Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "*", op: .multiply),
                                                              left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "4", literal: 4)),
                                                              right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "4", literal: 4))))
        let ast = AbstractSyntaxTreeNode(children: [
            EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"),
                          expression: expr
            )
        ])
        let instructions = mustCompile(ast)
        let computer = execute(instructions: instructions)
        XCTAssertEqual(computer.cpuState.registerA.value, 20)
    }
    
    func testEvalStatement_Modulus() {
        let expr = Expression.Binary(op: TokenOperator(lineNumber: 1, lexeme: "%", op: .modulus),
                                     left: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "7", literal: 7)),
                                     right: Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "4", literal: 4)))
        let ast = AbstractSyntaxTreeNode(children: [
            EvalStatement(token: TokenEval(lineNumber: 1, lexeme: "eval"),
                          expression: expr
            )
        ])
        let instructions = mustCompile(ast)
        let computer = execute(instructions: instructions)
        XCTAssertEqual(computer.cpuState.registerA.value, 3)
    }
}
