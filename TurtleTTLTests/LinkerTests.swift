//
//  LinkerTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 8/29/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class LinkerTests: XCTestCase {
    func testLinkWithNoInstructions() {
        let linker = Linker(inputInstructions: [], symbols: [:], actions: [])
        let output = try! linker.link()
        XCTAssertEqual([], output)
    }
    
    func testLinkWithNoChangesToInstructions() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let linker = Linker(inputInstructions: inputInstructions,
                            symbols: [:],
                            actions: [])
        let output = try! linker.link()
        XCTAssertEqual(inputInstructions, output)
    }
    
    func testLinkWithNoOpChangeToInstruction() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let symbols: SymbolTable = ["" : 0]
        let actions: [Linker.Action] = [(index: 0, symbol: "")]
        let linker = Linker(inputInstructions: inputInstructions,
                            symbols: symbols,
                            actions: actions)
        let output = try! linker.link()
        XCTAssertEqual(inputInstructions, output)
    }
    
    func testLinkWithChangeToInstruction() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let expected = [Instruction(opcode: 0, immediate: 255)]
        let symbols: SymbolTable = ["" : 255]
        let actions: [Linker.Action] = [(index: 0, symbol: "")]
        let linker = Linker(inputInstructions: inputInstructions,
                            symbols: symbols,
                            actions: actions)
        let actual = try! linker.link()
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
        let actions: [Linker.Action] = [(index: 0, symbol: "a"),
                                        (index: 1, symbol: "b"),
                                        (index: 2, symbol: "c")]
        let linker = Linker(inputInstructions: inputInstructions,
                            symbols: symbols,
                            actions: actions)
        let actual = try! linker.link()
        XCTAssertEqual(expected, actual)
    }
    
    func testLinkWithUnresolvedSymbol() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let actions: [Linker.Action] = [(index: 0, symbol: "")]
        let linker = Linker(inputInstructions: inputInstructions,
                            symbols: [:],
                            actions: actions)
        XCTAssertThrowsError(try linker.link()) { e in
            let error = e as! AssemblerError
            XCTAssertEqual(error.message, "unresolved symbol: `'")
        }
    }
}
