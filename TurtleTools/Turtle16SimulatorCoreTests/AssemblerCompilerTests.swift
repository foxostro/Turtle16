//
//  AssemblerCompilerTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 5/26/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import Turtle16SimulatorCore

class AssemblerCompilerTests: XCTestCase {
    func testCompileEmptyAST() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileUnknownInstruction() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "unknown instruction")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileOneNOP() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "NOP")
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0x0000
        ])
    }
    
    func testCompileTwoNOPs() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "NOP"),
            InstructionNode(instruction: "NOP")
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0x0000,
            0x0000
        ])
    }
    
    func testNOPExpectsZeroOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "NOP", parameters: ParameterList(parameters: [ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects zero operands: `NOP'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileHLT() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "HLT")
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0x0800
        ])
    }
    
    func testHLTExpectsZeroOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "HLT", parameters: ParameterList(parameters: [ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects zero operands: `HLT'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLOADExpectsTwoOrThreeOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LOAD", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects two or three operands: `LOAD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLOADExpectsFirstOperandToBeAnIdentifier() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LOAD", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `LOAD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLOADExpectsFirstOperandToBeTheDestination() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LOAD", parameters: ParameterList(parameters: [ParameterIdentifier(value: "a"), ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `LOAD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLOADExpectsSecondOperandToBeTheSourceAddress() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LOAD", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "a"), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be the register containing the source address: `LOAD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLOADExpectsThirdOperandToBeAnImmediateValueOffset() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LOAD", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r1"), ParameterIdentifier(value: "r2")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the optional third operand to be an immediate value offset: `LOAD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLOADExpectsOffsetToBeLessThanFifteen() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LOAD", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r1"), ParameterNumber(value: 16)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "offset exceeds positive limit of 15: `16'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileLOAD() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LOAD", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r1"), ParameterNumber(value: 1)]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0001000000100001
        ])
    }
    
    func testSTOREExpectsTwoOrThreeOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "STORE", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects two or three operands: `STORE'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSTOREExpectsFirstOperandToBeAnIdentifier() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "STORE", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the register containing the destination address: `STORE'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSTOREExpectsFirstOperandToBeTheDestinationAddressRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "STORE", parameters: ParameterList(parameters: [ParameterIdentifier(value: "a"), ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the register containing the destination address: `STORE'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSTOREExpectsSecondOperandToBeTheSource() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "STORE", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "a"), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be the source register: `STORE'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSTOREExpectsThirdOperandToBeAnImmediateValueOffset() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "STORE", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r1"), ParameterIdentifier(value: "r2")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the optional third operand to be an immediate value offset: `STORE'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileSTORE() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "STORE", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r1"), ParameterNumber(value: 1)]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0001100000100001
        ])
    }
    
    func testLIExpectsTwoOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LI")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects two operands: `LI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLIExpectsFirstOperandToBeTheDestinationAddressRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "a"), ParameterIdentifier(value: "a")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `LI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLIExpectsSecondOperandToBeAnImmediateValue() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "a")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be an immediate value: `LI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileLI() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: -1)]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0010000011111111
        ])
    }
    
    func testLIUExpectsTwoOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LIU")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects two operands: `LIU'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLIUExpectsFirstOperandToBeTheDestinationAddressRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LIU", parameters: ParameterList(parameters: [ParameterIdentifier(value: "a"), ParameterIdentifier(value: "a")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `LIU'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLIUExpectsSecondOperandToBeAnImmediateValue() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LIU", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "a")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be an immediate value: `LIU'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileLIU() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LIU", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 255)]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0010000011111111
        ])
    }
    
    func testLUIExpectsTwoOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LUI")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects two operands: `LUI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLUIExpectsFirstOperandToBeTheDestinationAddressRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LUI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "a"), ParameterIdentifier(value: "a")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `LUI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLUIExpectsSecondOperandToBeAnImmediateValue() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LUI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "a")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be an immediate value: `LUI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileLUI() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LUI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 255)]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0010100011111111
        ])
    }
    
    func testCMPExpectsTwoOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "CMP")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects two operands: `CMP'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCMPExpectsFirstOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "CMP", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be a register containing the left operand: `CMP'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCMPExpectsSecondOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "CMP", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the right operand: `CMP'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileCMP() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "CMP", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0011000000000000
        ])
    }
    
    func testADDExpectsThreeOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADD")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects three operands: `ADD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testADDExpectsFirstOperandToBeTheDestination() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADD", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `ADD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testADDExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADD", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `ADD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testADDExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADD", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be a register containing the right operand: `ADD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileADD() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADD", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0011100000000000
        ])
    }
    
    func testSUBExpectsThreeOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SUB")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects three operands: `SUB'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSUBExpectsFirstOperandToBeTheDestination() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SUB", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `SUB'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSUBExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SUB", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `SUB'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSUBExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SUB", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be a register containing the right operand: `SUB'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileSUB() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SUB", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0100000000000000
        ])
    }
    
    func testANDExpectsThreeOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "AND")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects three operands: `AND'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testANDExpectsFirstOperandToBeTheDestination() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "AND", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `AND'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testANDExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "AND", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `AND'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testANDExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "AND", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be a register containing the right operand: `AND'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileAND() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "AND", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0100100000000000
        ])
    }
    
    func testORExpectsThreeOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "OR")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects three operands: `OR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testORExpectsFirstOperandToBeTheDestination() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "OR", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `OR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testORExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "OR", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `OR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testORExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "OR", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be a register containing the right operand: `OR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileOR() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "OR", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0101000000000000
        ])
    }
    
    func testXORExpectsThreeOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "XOR")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects three operands: `XOR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testXORExpectsFirstOperandToBeTheDestination() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "XOR", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `XOR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testXORExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "XOR", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `XOR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testXORExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "XOR", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be a register containing the right operand: `XOR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileXOR() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "XOR", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0101100000000000
        ])
    }
    
    func testNOTExpectsTwoOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "NOT")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects two operands: `NOT'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testNOTExpectsFirstOperandToBeTheDestination() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "NOT", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `NOT'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testNOTExpectsSecondOperandToBeTheSourceRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "NOT", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be the source register: `NOT'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileNOT() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "NOT", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0110000000000000
        ])
    }
    
    func testCMPIExpectsTwoOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "CMPI")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects two operands: `CMPI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCMPIExpectsFirstOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "CMPI", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be a register containing the left operand: `CMPI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCMPIExpectsSecondOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "CMPI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be an immediate value: `CMPI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileCMPI() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "CMPI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0110100000000000
        ])
    }
    
    func testADDIExpectsThreeOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADDI")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects three operands: `ADDI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testADDIExpectsFirstOperandToBeTheDestination() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADDI", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `ADDI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testADDIExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADDI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `ADDI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testADDIExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADDI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be an immediate value: `ADDI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileADDI() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADDI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0111000000000000
        ])
    }
    
    func testSUBIExpectsThreeOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SUBI")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects three operands: `SUBI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSUBIExpectsFirstOperandToBeTheDestination() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SUBI", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `SUBI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSUBIExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SUBI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `SUBI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSUBIExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SUBI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be an immediate value: `SUBI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileSUBI() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SUBI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0111100000000000
        ])
    }
    
    func testANDIExpectsThreeOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ANDI")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects three operands: `ANDI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testANDIExpectsFirstOperandToBeTheDestination() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ANDI", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `ANDI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testANDIExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ANDI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `ANDI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testANDIExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ANDI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be an immediate value: `ANDI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileANDI() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ANDI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1000000000000000
        ])
    }
    
    func testORIExpectsThreeOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ORI")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects three operands: `ORI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testORIExpectsFirstOperandToBeTheDestination() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ORI", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `ORI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testORIExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ORI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `ORI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testORIExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ORI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be an immediate value: `ORI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileORI() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ORI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1000100000000000
        ])
    }
    
    func testXORIExpectsThreeOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "XORI")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects three operands: `XORI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testXORIExpectsFirstOperandToBeTheDestination() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "XORI", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `XORI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testXORIExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "XORI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `XORI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testXORIExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "XORI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be an immediate value: `XORI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileXORI() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "XORI", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1001000000000000
        ])
    }
    
    func testJMPExpectsOneOperand() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JMP")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects one operand: `JMP'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testJMPExpectsTheFirstOperandToBeLabelIdentifier() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JMP", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be a label identifier: `JMP'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileJMPWithUndefinedLabel() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JMP", parameters: ParameterList(parameters: [ParameterIdentifier(value: "foo")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `foo'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileJMPWithLabel_ForwardJump() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JMP", parameters: ParameterList(parameters: [ParameterIdentifier(value: "foo")])),
            LabelDeclaration(identifier: "foo"),
            InstructionNode(instruction: "HLT")
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1010011111111111,
            0b0000100000000000
        ])
    }
    
    func testCompileJMPWithLabel_BackwardJump() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            LabelDeclaration(identifier: "foo"),
            InstructionNode(instruction: "NOP"),
            InstructionNode(instruction: "NOP"),
            InstructionNode(instruction: "JMP", parameters: ParameterList(parameters: [ParameterIdentifier(value: "foo")]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0000000000000000,
            0b0000000000000000,
            0b1010011111111100
        ])
    }
    
    func testJRExpectsOneOrTwoOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JR")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects one or two operands: `JR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testJRExpectsFirstOperandToBeTheDestinationAddress() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JR", parameters: ParameterList(parameters: [ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the register containing the destination address: `JR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testJRExpectsSecondOperandToBeAnImmediateValueOffset() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JR", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the optional second operand to be an immediate value: `JR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileJR() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JR", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: -1)]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1010100000011111
        ])
    }
    
    func testJALRExpectsTwoOrThreeOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JALR")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects two or three operands: `JALR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testJALRExpectsFirstOperandToBeTheLinkRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JALR", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the link register: `JALR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testJALRExpectsSecondOperandToBeTheDestinationAddress() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JALR", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "a")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be the register containing the destination address: `JALR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testJALRExpectsThirdOperandToBeAnImmediateValueOffset() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JALR", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the optional third operand to be an immediate value offset: `JALR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileJALR() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JALR", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r7"), ParameterIdentifier(value: "r0"), ParameterNumber(value: -1)]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1011011100011111
        ])
    }
    
    func testBEQExpectsOneOperand() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "BEQ")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects one operand: `BEQ'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testBEQExpectsFirstOperandToBeLabelIdentifier() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "BEQ", parameters: ParameterList(parameters: [ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be a label identifier: `BEQ'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileBEQ() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            LabelDeclaration(identifier: "foo"),
            InstructionNode(instruction: "BEQ", parameters: ParameterList(parameters: [ParameterIdentifier(value: "foo")]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1100011111111110
        ])
    }
    
    func testBNEExpectsOneOperand() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "BNE")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects one operand: `BNE'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testBNEExpectsFirstOperandToBeLabelIdentifier() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "BNE", parameters: ParameterList(parameters: [ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be a label identifier: `BNE'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileBNE() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            LabelDeclaration(identifier: "foo"),
            InstructionNode(instruction: "BNE", parameters: ParameterList(parameters: [ParameterIdentifier(value: "foo")]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1100111111111110
        ])
    }
    
    func testBLTExpectsOneOperand() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "BLT")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects one operand: `BLT'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testBLTExpectsFirstOperandToBeLabelIdentifier() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "BLT", parameters: ParameterList(parameters: [ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be a label identifier: `BLT'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileBLT() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            LabelDeclaration(identifier: "foo"),
            InstructionNode(instruction: "BLT", parameters: ParameterList(parameters: [ParameterIdentifier(value: "foo")]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1101011111111110
        ])
    }
    
    func testBGEExpectsOneOperand() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "BGE")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects one operand: `BGE'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testBGEExpectsFirstOperandToBeLabelIdentifier() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "BGE", parameters: ParameterList(parameters: [ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be a label identifier: `BGE'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileBGE() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            LabelDeclaration(identifier: "foo"),
            InstructionNode(instruction: "BGE", parameters: ParameterList(parameters: [ParameterIdentifier(value: "foo")]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1101111111111110
        ])
    }
    
    func testBLTUExpectsOneOperand() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "BLTU")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects one operand: `BLTU'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testBLTUExpectsFirstOperandToBeLabelIdentifier() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "BLTU", parameters: ParameterList(parameters: [ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be a label identifier: `BLTU'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileBLTU() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            LabelDeclaration(identifier: "foo"),
            InstructionNode(instruction: "BLTU", parameters: ParameterList(parameters: [ParameterIdentifier(value: "foo")]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1110011111111110
        ])
    }
    
    func testBGEUExpectsOneOperand() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "BGEU")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects one operand: `BGEU'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testBGEUExpectsFirstOperandToBeLabelIdentifier() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "BGEU", parameters: ParameterList(parameters: [ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be a label identifier: `BGEU'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileBGEU() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            LabelDeclaration(identifier: "foo"),
            InstructionNode(instruction: "BGEU", parameters: ParameterList(parameters: [ParameterIdentifier(value: "foo")]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1110111111111110
        ])
    }
    
    func testADCExpectsThreeOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADC")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects three operands: `ADC'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testADCExpectsFirstOperandToBeTheDestination() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADC", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `ADC'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testADCExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADC", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `ADC'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testADCExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADC", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be a register containing the right operand: `ADC'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileADC() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADC", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1111000000000000
        ])
    }
    
    func testSBCExpectsThreeOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SBC")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects three operands: `SBC'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSBCExpectsFirstOperandToBeTheDestination() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SBC", parameters: ParameterList(parameters: [ParameterNumber(value: 0), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `SBC'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSBCExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SBC", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterNumber(value: 0), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `SBC'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSBCExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SBC", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterNumber(value: 0)]))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be a register containing the right operand: `SBC'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileSBC() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SBC", parameters: ParameterList(parameters: [ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0"), ParameterIdentifier(value: "r0")]))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1111100000000000
        ])
    }
}
