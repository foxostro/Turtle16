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

class PrintLogger: NSObject, Logger {
    public func append(_ format: String, _ args: CVarArg...) {
        let message = String(format:format, arguments:args)
        print(message)
    }
}

class AssemblerCompilerTests: XCTestCase {
    fileprivate func makeDebugger(instructions: [UInt16]) -> DebugConsole {
        let cpu = SchematicLevelCPUModel()
        let computer = Turtle16Computer(cpu)
        cpu.store = {(value: UInt16, addr: MemoryAddress) in
            computer.ram[addr.value] = value
        }
        cpu.load = {(addr: MemoryAddress) in
            return computer.ram[addr.value]
        }
        computer.instructions = instructions
        computer.reset()
        let debugger = DebugConsole(computer: computer)
        return debugger
    }
    
    fileprivate func disassemble(_ instructions: [UInt16]) -> String {
        let disassembler = Disassembler()
        disassembler.shouldUseConventionalRegisterNames = true
        let result = disassembler.disassembleToText(instructions)
        return result
    }
    
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
            InstructionNode(instruction: "NOP", parameters: [ParameterNumber(0)])
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
            InstructionNode(instruction: "HLT", parameters: [ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects zero operands: `HLT'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLOADExpectsTwoOrThreeOperands_1() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LOAD", parameters: [ParameterIdentifier("r0")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects two or three operands: `LOAD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLOADExpectsFirstOperandToBeAnIdentifier() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LOAD", parameters: [ParameterNumber(0), ParameterIdentifier("r0"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `LOAD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLOADExpectsFirstOperandToBeTheDestination() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LOAD", parameters: [ParameterIdentifier("a"), ParameterIdentifier("r0"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `LOAD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLOADExpectsSecondOperandToBeTheSourceAddress() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LOAD", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("a"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be the register containing the source address: `LOAD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLOADExpectsThirdOperandToBeAnImmediateValueOffset() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LOAD", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r1"), ParameterIdentifier("r2")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the optional third operand to be an immediate value offset: `LOAD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLOADExpectsOffsetToBeLessThanFifteen() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LOAD", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r1"), ParameterNumber(16)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "offset exceeds positive limit of 15: `16'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileLOAD_1() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LOAD", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r1"), ParameterNumber(1)])
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0001000000100001
        ])
    }
    
    func testCompileLOAD_2() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LOAD", parameters: [
                ParameterIdentifier("r0"),
                ParameterIdentifier("r1")
            ])
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0001000000100000
        ])
    }
    
    func testSTOREExpectsTwoOrThreeOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "STORE", parameters: [ParameterIdentifier("r0")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects two or three operands: `STORE'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSTOREExpectsFirstOperandToBeAnIdentifier() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "STORE", parameters: [ParameterNumber(0), ParameterIdentifier("r0"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the register containing the destination address: `STORE'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSTOREExpectsFirstOperandToBeTheDestinationAddressRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "STORE", parameters: [ParameterIdentifier("a"), ParameterIdentifier("r0"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the register containing the destination address: `STORE'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSTOREExpectsSecondOperandToBeTheSource() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "STORE", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("a"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be the source register: `STORE'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSTOREExpectsThirdOperandToBeAnImmediateValueOffset() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "STORE", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r1"), ParameterIdentifier("r2")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the optional third operand to be an immediate value offset: `STORE'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileSTORE_1() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "STORE", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r1"), ParameterNumber(1)])
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0001100000100001
        ])
    }
    
    func testCompileSTORE_2() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "STORE", parameters: [
                ParameterIdentifier("r0"),
                ParameterIdentifier("r1")
            ])
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0001100000100000
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
            InstructionNode(instruction: "LI", parameters: [ParameterIdentifier("a"), ParameterIdentifier("a")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `LI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLIExpectsSecondOperandToBeAnImmediateValue() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LI", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("a")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be an immediate value: `LI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileLI() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LI", parameters: [ParameterIdentifier("r0"), ParameterNumber(-1)])
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
            InstructionNode(instruction: "LIU", parameters: [ParameterIdentifier("a"), ParameterIdentifier("a")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `LIU'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLIUExpectsSecondOperandToBeAnImmediateValue() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LIU", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("a")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be an immediate value: `LIU'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileLIU() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LIU", parameters: [ParameterIdentifier("r0"), ParameterNumber(255)])
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
            InstructionNode(instruction: "LUI", parameters: [ParameterIdentifier("a"), ParameterIdentifier("a")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `LUI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLUIExpectsSecondOperandToBeAnImmediateValue() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LUI", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("a")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be an immediate value: `LUI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileLUI() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LUI", parameters: [ParameterIdentifier("r0"), ParameterNumber(255)])
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
            InstructionNode(instruction: "CMP", parameters: [ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be a register containing the left operand: `CMP'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCMPExpectsSecondOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "CMP", parameters: [ParameterIdentifier("r0"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the right operand: `CMP'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileCMP() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "CMP", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0")])
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
            InstructionNode(instruction: "ADD", parameters: [ParameterNumber(0), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `ADD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testADDExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADD", parameters: [ParameterIdentifier("r0"), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `ADD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testADDExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADD", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be a register containing the right operand: `ADD'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileADD() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADD", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterIdentifier("r0")])
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
            InstructionNode(instruction: "SUB", parameters: [ParameterNumber(0), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `SUB'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSUBExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SUB", parameters: [ParameterIdentifier("r0"), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `SUB'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSUBExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SUB", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be a register containing the right operand: `SUB'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileSUB() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SUB", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterIdentifier("r0")])
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
            InstructionNode(instruction: "AND", parameters: [ParameterNumber(0), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `AND'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testANDExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "AND", parameters: [ParameterIdentifier("r0"), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `AND'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testANDExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "AND", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be a register containing the right operand: `AND'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileAND() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "AND", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterIdentifier("r0")])
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
            InstructionNode(instruction: "OR", parameters: [ParameterNumber(0), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `OR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testORExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "OR", parameters: [ParameterIdentifier("r0"), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `OR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testORExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "OR", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be a register containing the right operand: `OR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileOR() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "OR", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterIdentifier("r0")])
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
            InstructionNode(instruction: "XOR", parameters: [ParameterNumber(0), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `XOR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testXORExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "XOR", parameters: [ParameterIdentifier("r0"), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `XOR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testXORExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "XOR", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be a register containing the right operand: `XOR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileXOR() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "XOR", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterIdentifier("r0")])
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
            InstructionNode(instruction: "NOT", parameters: [ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `NOT'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testNOTExpectsSecondOperandToBeTheSourceRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "NOT", parameters: [ParameterIdentifier("r0"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be the source register: `NOT'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileNOT() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "NOT", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0")])
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
            InstructionNode(instruction: "CMPI", parameters: [ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be a register containing the left operand: `CMPI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCMPIExpectsSecondOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "CMPI", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be an immediate value: `CMPI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileCMPI() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "CMPI", parameters: [ParameterIdentifier("r0"), ParameterNumber(0)])
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
            InstructionNode(instruction: "ADDI", parameters: [ParameterNumber(0), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `ADDI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testADDIExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADDI", parameters: [ParameterIdentifier("r0"), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `ADDI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testADDIExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADDI", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterIdentifier("r0")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be an immediate value: `ADDI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileADDI() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADDI", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterNumber(0)])
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
            InstructionNode(instruction: "SUBI", parameters: [ParameterNumber(0), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `SUBI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSUBIExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SUBI", parameters: [ParameterIdentifier("r0"), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `SUBI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSUBIExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SUBI", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterIdentifier("r0")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be an immediate value: `SUBI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileSUBI() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SUBI", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterNumber(0)])
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
            InstructionNode(instruction: "ANDI", parameters: [ParameterNumber(0), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `ANDI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testANDIExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ANDI", parameters: [ParameterIdentifier("r0"), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `ANDI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testANDIExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ANDI", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterIdentifier("r0")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be an immediate value: `ANDI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileANDI() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ANDI", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterNumber(0)])
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
            InstructionNode(instruction: "ORI", parameters: [ParameterNumber(0), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `ORI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testORIExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ORI", parameters: [ParameterIdentifier("r0"), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `ORI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testORIExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ORI", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterIdentifier("r0")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be an immediate value: `ORI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileORI() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ORI", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterNumber(0)])
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
            InstructionNode(instruction: "XORI", parameters: [ParameterNumber(0), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `XORI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testXORIExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "XORI", parameters: [ParameterIdentifier("r0"), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `XORI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testXORIExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "XORI", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterIdentifier("r0")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be an immediate value: `XORI'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileXORI() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "XORI", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterNumber(0)])
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
            InstructionNode(instruction: "JMP", parameters: [ParameterIdentifier("r0")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be a label identifier: `JMP'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileJMPWithUndefinedLabel() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JMP", parameters: [ParameterIdentifier("foo")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `foo'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileJMPWithLabel_ForwardJump() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JMP", parameters: [ParameterIdentifier("foo")]),
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
            InstructionNode(instruction: "JMP", parameters: [ParameterIdentifier("foo")])
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
            InstructionNode(instruction: "JR", parameters: [ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the register containing the destination address: `JR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testJRExpectsSecondOperandToBeAnImmediateValueOffset() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JR", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the optional second operand to be an immediate value: `JR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileJR() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JR", parameters: [ParameterIdentifier("r0"), ParameterNumber(-1)])
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
            InstructionNode(instruction: "JALR", parameters: [ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the link register: `JALR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testJALRExpectsSecondOperandToBeTheDestinationAddress() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JALR", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("a")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be the register containing the destination address: `JALR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testJALRExpectsThirdOperandToBeAnImmediateValueOffset() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JALR", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterIdentifier("r0")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the optional third operand to be an immediate value offset: `JALR'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileJALR() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "JALR", parameters: [ParameterIdentifier("r7"), ParameterIdentifier("r0"), ParameterNumber(-1)])
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
            InstructionNode(instruction: "BEQ", parameters: [ParameterNumber(0)])
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
            InstructionNode(instruction: "BEQ", parameters: [ParameterIdentifier("foo")])
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
            InstructionNode(instruction: "BNE", parameters: [ParameterNumber(0)])
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
            InstructionNode(instruction: "BNE", parameters: [ParameterIdentifier("foo")])
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
            InstructionNode(instruction: "BLT", parameters: [ParameterNumber(0)])
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
            InstructionNode(instruction: "BLT", parameters: [ParameterIdentifier("foo")])
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1101011111111110
        ])
    }
    
    func testBGTExpectsOneOperand() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "BGT")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects one operand: `BGT'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testBGTExpectsFirstOperandToBeLabelIdentifier() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "BGT", parameters: [ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be a label identifier: `BGT'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileBGT() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            LabelDeclaration(identifier: "foo"),
            InstructionNode(instruction: "BGT", parameters: [ParameterIdentifier("foo")])
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
            InstructionNode(instruction: "BLTU", parameters: [ParameterNumber(0)])
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
            InstructionNode(instruction: "BLTU", parameters: [ParameterIdentifier("foo")])
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1110011111111110
        ])
    }
    
    func testBGTUExpectsOneOperand() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "BGTU")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects one operand: `BGTU'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testBGTUExpectsFirstOperandToBeLabelIdentifier() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "BGTU", parameters: [ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be a label identifier: `BGTU'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileBGTU() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            LabelDeclaration(identifier: "foo"),
            InstructionNode(instruction: "BGTU", parameters: [ParameterIdentifier("foo")])
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
            InstructionNode(instruction: "ADC", parameters: [ParameterNumber(0), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `ADC'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testADCExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADC", parameters: [ParameterIdentifier("r0"), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `ADC'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testADCExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADC", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be a register containing the right operand: `ADC'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileADC() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ADC", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterIdentifier("r0")])
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
            InstructionNode(instruction: "SBC", parameters: [ParameterNumber(0), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `SBC'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSBCExpectsSecondOperandToBeTheLeftOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SBC", parameters: [ParameterIdentifier("r0"), ParameterNumber(0), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a register containing the left operand: `SBC'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testSBCExpectsThirdOperandToBeTheRightOperandRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SBC", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the third operand to be a register containing the right operand: `SBC'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileSBC() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "SBC", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterIdentifier("r0")])
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b1111100000000000
        ])
    }
    
    func testLAExpectsTwoOperands() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LA")
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects two operands: `LA'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLAExpectsFirstOperandToBeTheDestinationAddressRegister() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LA", parameters: [ParameterIdentifier("a"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the first operand to be the destination register: `LA'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testLAExpectsSecondOperandToBeAnIdentifier() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LA", parameters: [ParameterIdentifier("r0"), ParameterNumber(0)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the second operand to be a label identifier: `LA'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileLAWithUndefinedLabel() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LA", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("foo")])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `foo'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileLA() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LA", parameters: [ParameterIdentifier("r0"), ParameterIdentifier("foo")]),
            LabelDeclaration(identifier: "foo"),
            InstructionNode(instruction: "HLT")
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.instructions, [
            0b0010000000000010, // LI
            0b0010100000000000, // LUI
            0b0000100000000000  // HLT
        ])
        XCTAssertEqual(disassemble(compiler.instructions), """
            LI r0, 2
            LUI r0, 0
            HLT
            """)
    }
    
    func testCompileCALL() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "CALL", parameters: [ParameterIdentifier("foo")]),
            LabelDeclaration(identifier: "foo"),
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(disassemble(compiler.instructions), """
            LI ra, 3
            LUI ra, 0
            JALR ra, ra, 0
            """)
    }
    
    func testCompileCALLPTR() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "CALLPTR", parameters: [ParameterIdentifier("r1")])
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(disassemble(compiler.instructions), """
            JALR ra, r1, 0
            """)
    }
    
    func testCompileENTER_no_parameter() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ENTER")
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(disassemble(compiler.instructions), """
            SUBI sp, sp, 7
            STORE r0, sp, 6
            STORE r1, sp, 5
            STORE r2, sp, 4
            STORE r3, sp, 3
            STORE r4, sp, 2
            STORE ra, sp, 1
            STORE fp, sp, 0
            ADDI fp, sp, 0
            """)
    }
    
    func testCompileENTER_too_many_parameters() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ENTER", parameters: [ParameterNumber(0), ParameterNumber(1)])
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects zero or one operands: `ENTER'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileENTER_parameter_must_be_number() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ENTER", parameter: ParameterIdentifier(""))
        ])
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.message, "instruction expects the operand to be the size: `ENTER'")
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testCompileENTER_0() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ENTER", parameter: ParameterNumber(0))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(disassemble(compiler.instructions), """
            SUBI sp, sp, 7
            STORE r0, sp, 6
            STORE r1, sp, 5
            STORE r2, sp, 4
            STORE r3, sp, 3
            STORE r4, sp, 2
            STORE ra, sp, 1
            STORE fp, sp, 0
            ADDI fp, sp, 0
            """)
    }
    
    func testCompileENTER_1() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "ENTER", parameter: ParameterNumber(1))
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(disassemble(compiler.instructions), """
            SUBI sp, sp, 7
            STORE r0, sp, 6
            STORE r1, sp, 5
            STORE r2, sp, 4
            STORE r3, sp, 3
            STORE r4, sp, 2
            STORE ra, sp, 1
            STORE fp, sp, 0
            ADDI fp, sp, 0
            SUBI sp, sp, 1
            """)
    }
    
    func testCompileLEAVE() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "LEAVE")
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(disassemble(compiler.instructions), """
            ADDI sp, fp, 0
            LOAD r0, sp, 6
            LOAD r1, sp, 5
            LOAD r2, sp, 4
            LOAD r3, sp, 3
            LOAD r4, sp, 2
            LOAD ra, sp, 1
            LOAD fp, sp, 0
            ADDI sp, sp, 7
            """)
    }
    
    func test_ENTER_writes_registers_to_memory() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "NOP"),
            InstructionNode(instruction: "ENTER", parameter: ParameterNumber(8)),
            InstructionNode(instruction: "NOP"),
            InstructionNode(instruction: "HLT")
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        let debugger = makeDebugger(instructions: compiler.instructions)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 1000)
        debugger.computer.setRegister(1, 1001)
        debugger.computer.setRegister(2, 1002)
        debugger.computer.setRegister(3, 1003)
        debugger.computer.setRegister(4, 1004)
        debugger.computer.setRegister(5, 1005)
        debugger.computer.setRegister(6, 0)
        debugger.computer.setRegister(7, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 1000)
        XCTAssertEqual(debugger.computer.getRegister(1), 1001)
        XCTAssertEqual(debugger.computer.getRegister(2), 1002)
        XCTAssertEqual(debugger.computer.getRegister(3), 1003)
        XCTAssertEqual(debugger.computer.getRegister(4), 1004)
        XCTAssertEqual(debugger.computer.getRegister(5), 1005)
        XCTAssertEqual(debugger.computer.getRegister(6), 0xfff1)
        XCTAssertEqual(debugger.computer.getRegister(7), 0xfff9)
        XCTAssertEqual(debugger.computer.ram[0xffff], 1000) // r0
        XCTAssertEqual(debugger.computer.ram[0xfffe], 1001) // r1
        XCTAssertEqual(debugger.computer.ram[0xfffd], 1002) // r2
        XCTAssertEqual(debugger.computer.ram[0xfffc], 1003) // r3
        XCTAssertEqual(debugger.computer.ram[0xfffb], 1004) // r4
        XCTAssertEqual(debugger.computer.ram[0xfffa], 1005) // r5
        XCTAssertEqual(debugger.computer.ram[0xfff9], 42)   // fp
    }
    
    func test_LEAVE_pops_registers_from_memory() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "NOP"),
            InstructionNode(instruction: "LEAVE"),
            InstructionNode(instruction: "NOP"),
            InstructionNode(instruction: "HLT")
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        let debugger = makeDebugger(instructions: compiler.instructions)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 0)
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(3, 0)
        debugger.computer.setRegister(4, 0)
        debugger.computer.setRegister(5, 0)
        debugger.computer.setRegister(6, 0xfff9)
        debugger.computer.setRegister(7, 0xfff9)
        debugger.computer.ram[0xffff] = 1000 // r0
        debugger.computer.ram[0xfffe] = 1001 // r1
        debugger.computer.ram[0xfffd] = 1002 // r2
        debugger.computer.ram[0xfffc] = 1003 // r3
        debugger.computer.ram[0xfffb] = 1004 // r4
        debugger.computer.ram[0xfffa] = 1005 // r5
        debugger.computer.ram[0xfff9] = 42   // fp
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 1000)
        XCTAssertEqual(debugger.computer.getRegister(1), 1001)
        XCTAssertEqual(debugger.computer.getRegister(2), 1002)
        XCTAssertEqual(debugger.computer.getRegister(3), 1003)
        XCTAssertEqual(debugger.computer.getRegister(4), 1004)
        XCTAssertEqual(debugger.computer.getRegister(5), 1005)
        XCTAssertEqual(debugger.computer.getRegister(6), 0)
        XCTAssertEqual(debugger.computer.getRegister(7), 42)
    }
    
    func test_ENTER_then_LEAVE_restores_prev_state() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "NOP"),
            InstructionNode(instruction: "ENTER", parameter: ParameterNumber(8)),
            InstructionNode(instruction: "LEAVE"),
            InstructionNode(instruction: "NOP"),
            InstructionNode(instruction: "HLT")
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        let debugger = makeDebugger(instructions: compiler.instructions)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 1000)
        debugger.computer.setRegister(1, 1001)
        debugger.computer.setRegister(2, 1002)
        debugger.computer.setRegister(3, 1003)
        debugger.computer.setRegister(4, 1004)
        debugger.computer.setRegister(5, 1005)
        debugger.computer.setRegister(6, 0)
        debugger.computer.setRegister(7, 0)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 1000)
        XCTAssertEqual(debugger.computer.getRegister(1), 1001)
        XCTAssertEqual(debugger.computer.getRegister(2), 1002)
        XCTAssertEqual(debugger.computer.getRegister(3), 1003)
        XCTAssertEqual(debugger.computer.getRegister(4), 1004)
        XCTAssertEqual(debugger.computer.getRegister(5), 1005)
        XCTAssertEqual(debugger.computer.getRegister(6), 0)
        XCTAssertEqual(debugger.computer.getRegister(7), 0)
    }
    
    func testCompileRET() throws {
        let compiler = AssemblerCompiler()
        compiler.compile(ast: [
            InstructionNode(instruction: "RET")
        ])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(disassemble(compiler.instructions), """
            JR ra, 0
            """)
    }
}
