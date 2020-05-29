//
//  PatcherTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 8/29/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox
import TurtleCore

class PatcherTests: XCTestCase {
    func testPatchWithNoInstructions() {
        let patcher = Patcher(inputInstructions: [], symbols: SymbolTable(), actions: [], base: 0x0000)
        let output = try! patcher.patch()
        XCTAssertEqual([], output)
    }
    
    func testPatchWithNoChangesToInstructions() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: SymbolTable(),
                              actions: [],
                              base: 0x0000)
        let output = try! patcher.patch()
        XCTAssertEqual(inputInstructions, output)
    }
    
    func testPatchWithNoOpChangeToInstruction() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let symbols = SymbolTable(["" : .constantAddress(SymbolConstantAddress(identifier: "", value: 0))])
        let symbol = TokenIdentifier(lineNumber: 0, lexeme: "")
        let actions: [Patcher.Action] = [(index: 0, symbol: symbol, shift: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: symbols,
                              actions: actions,
                              base: 0x0000)
        let output = try! patcher.patch()
        XCTAssertEqual(inputInstructions, output)
    }
    
    func testPatchWithChangeToInstruction() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let expected = [Instruction(opcode: 0, immediate: 255)]
        let symbols = SymbolTable(["" : .constantAddress(SymbolConstantAddress(identifier: "", value: 255))])
        let symbol = TokenIdentifier(lineNumber: 0, lexeme: "")
        let actions: [Patcher.Action] = [(index: 0, symbol: symbol, shift: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: symbols,
                              actions: actions,
                              base: 0x0000)
        let actual = try! patcher.patch()
        XCTAssertEqual(expected, actual)
    }
    
    func testPatchWithChangeToInstructionAndShift() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let expected = [Instruction(opcode: 0, immediate: 255)]
        let symbols = SymbolTable(["" : .constantAddress(SymbolConstantAddress(identifier: "", value: 0xff00))])
        let symbol = TokenIdentifier(lineNumber: 0, lexeme: "")
        let actions: [Patcher.Action] = [(index: 0, symbol: symbol, shift: 8)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: symbols,
                              actions: actions,
                              base: 0x0000)
        let actual = try! patcher.patch()
        XCTAssertEqual(expected, actual)
    }
    
    func testPatchWithChangeToAFewInstructions() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0),
                                 Instruction(opcode: 1, immediate: 0),
                                 Instruction(opcode: 2, immediate: 0)]
        let expected = [Instruction(opcode: 0, immediate: 10),
                        Instruction(opcode: 1, immediate: 20),
                        Instruction(opcode: 2, immediate: 30)]
        let symbols = SymbolTable(["a" : .constantAddress(SymbolConstantAddress(identifier: "a", value: 10)),
                                   "b" : .constantAddress(SymbolConstantAddress(identifier: "b", value: 20)),
                                   "c" : .constantAddress(SymbolConstantAddress(identifier: "c", value: 30))])
        let actions: [Patcher.Action] = [(index: 0, symbol: TokenIdentifier(lineNumber: 1, lexeme: "a"), shift: 0),
                                         (index: 1, symbol: TokenIdentifier(lineNumber: 2, lexeme: "b"), shift: 0),
                                         (index: 2, symbol: TokenIdentifier(lineNumber: 3, lexeme: "c"), shift: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: symbols,
                              actions: actions,
                              base: 0x0000)
        let actual = try! patcher.patch()
        XCTAssertEqual(expected, actual)
    }
    
    func testPatchWithUnresolvedSymbol() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let actions: [Patcher.Action] = [(index: 0, symbol: TokenIdentifier(lineNumber: 0, lexeme: ""), shift: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: SymbolTable(),
                              actions: actions,
                              base: 0x0000)
        XCTAssertThrowsError(try patcher.patch()) {
            let error = $0 as? CompilerError
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.message, "use of unresolved identifier: `'")
        }
    }
}
