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
    
    func testLinkWithNoChangesToInstructions() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: [:],
                              actions: [])
        let output = try! patcher.patch()
        XCTAssertEqual(inputInstructions, output)
    }
    
    func testLinkWithNoOpChangeToInstruction() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let symbols: SymbolTable = ["" : 0]
        let actions: [Patcher.Action] = [(index: 0, symbol: "", shift: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: symbols,
                              actions: actions)
        let output = try! patcher.patch()
        XCTAssertEqual(inputInstructions, output)
    }
    
    func testLinkWithChangeToInstruction() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let expected = [Instruction(opcode: 0, immediate: 255)]
        let symbols: SymbolTable = ["" : 255]
        let actions: [Patcher.Action] = [(index: 0, symbol: "", shift: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: symbols,
                              actions: actions)
        let actual = try! patcher.patch()
        XCTAssertEqual(expected, actual)
    }
    
    func testLinkWithChangeToInstructionAndShift() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let expected = [Instruction(opcode: 0, immediate: 255)]
        let symbols: SymbolTable = ["" : 0xff00]
        let actions: [Patcher.Action] = [(index: 0, symbol: "", shift: 8)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: symbols,
                              actions: actions)
        let actual = try! patcher.patch()
        XCTAssertEqual(expected, actual)
    }
    
    func testLinkWithChangeToAFewInstructions() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0),
                                 Instruction(opcode: 1, immediate: 0),
                                 Instruction(opcode: 2, immediate: 0)]
        let expected = [Instruction(opcode: 0, immediate: 10),
                        Instruction(opcode: 1, immediate: 20),
                        Instruction(opcode: 2, immediate: 30)]
        let symbols: SymbolTable = ["a" : 10,
                                    "b" : 20,
                                    "c" : 30]
        let actions: [Patcher.Action] = [(index: 0, symbol: "a", shift: 0),
                                         (index: 1, symbol: "b", shift: 0),
                                         (index: 2, symbol: "c", shift: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: symbols,
                              actions: actions)
        let actual = try! patcher.patch()
        XCTAssertEqual(expected, actual)
    }
    
    func testLinkWithUnresolvedSymbol() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let actions: [Patcher.Action] = [(index: 0, symbol: "", shift: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              symbols: [:],
                              actions: actions)
        XCTAssertThrowsError(try patcher.patch()) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.message, "unresolved symbol: `'")
        }
    }
}
