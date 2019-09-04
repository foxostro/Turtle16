//
//  PatcherTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/29/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class PatcherTests: XCTestCase {
    func testPatchWithNoInstructions() {
        let patcher = Patcher(inputInstructions: [], symbols: [:], actions: [])
        let output = try! patcher.patch()
        XCTAssertEqual([], output)
    }
    
    func testPatchWithNoChangesToInstructions() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: [:],
                              actions: [])
        let output = try! patcher.patch()
        XCTAssertEqual(inputInstructions, output)
    }
    
    func testPatchWithNoOpChangeToInstruction() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let symbols: SymbolTable = ["" : 0]
        let symbol = TokenIdentifier(lineNumber: 0, lexeme: "")
        let actions: [Patcher.Action] = [(index: 0, symbol: symbol, shift: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: symbols,
                              actions: actions)
        let output = try! patcher.patch()
        XCTAssertEqual(inputInstructions, output)
    }
    
    func testPatchWithChangeToInstruction() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let expected = [Instruction(opcode: 0, immediate: 255)]
        let symbols: SymbolTable = ["" : 255]
        let symbol = TokenIdentifier(lineNumber: 0, lexeme: "")
        let actions: [Patcher.Action] = [(index: 0, symbol: symbol, shift: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: symbols,
                              actions: actions)
        let actual = try! patcher.patch()
        XCTAssertEqual(expected, actual)
    }
    
    func testPatchWithChangeToInstructionAndShift() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let expected = [Instruction(opcode: 0, immediate: 255)]
        let symbols: SymbolTable = ["" : 0xff00]
        let symbol = TokenIdentifier(lineNumber: 0, lexeme: "")
        let actions: [Patcher.Action] = [(index: 0, symbol: symbol, shift: 8)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: symbols,
                              actions: actions)
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
        let symbols: SymbolTable = ["a" : 10,
                                    "b" : 20,
                                    "c" : 30]
        let actions: [Patcher.Action] = [(index: 0, symbol: TokenIdentifier(lineNumber: 1, lexeme: "a"), shift: 0),
                                         (index: 1, symbol: TokenIdentifier(lineNumber: 2, lexeme: "b"), shift: 0),
                                         (index: 2, symbol: TokenIdentifier(lineNumber: 3, lexeme: "c"), shift: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: symbols,
                              actions: actions)
        let actual = try! patcher.patch()
        XCTAssertEqual(expected, actual)
    }
    
    func testPatchWithUnresolvedSymbol() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let actions: [Patcher.Action] = [(index: 0, symbol: TokenIdentifier(lineNumber: 0, lexeme: ""), shift: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: [:],
                              actions: actions)
        XCTAssertThrowsError(try patcher.patch()) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.message, "unrecognized symbol name: `'")
        }
    }
}
