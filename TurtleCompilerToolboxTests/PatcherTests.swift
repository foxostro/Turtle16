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
        let resolver: (SourceAnchor?, String) throws -> Int = {(sourceAnchor: SourceAnchor?, identifier: String) in
            return 0
        }
        let patcher = Patcher(inputInstructions: [], resolver: resolver, actions: [], base: 0x0000)
        let output = try! patcher.patch()
        XCTAssertEqual([], output)
    }
    
    func testPatchWithNoChangesToInstructions() {
        let resolver: (SourceAnchor?, String) throws -> Int = {(sourceAnchor: SourceAnchor?, identifier: String) in
            return 0
        }
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              resolver: resolver,
                              actions: [],
                              base: 0x0000)
        let output = try! patcher.patch()
        XCTAssertEqual(inputInstructions, output)
    }
    
    func testPatchWithNoOpChangeToInstruction() {
        let symbols = ["" : 0]
        let resolver: (SourceAnchor?, String) throws -> Int = {(sourceAnchor: SourceAnchor?, identifier: String) in
            return symbols[identifier]!
        }
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let actions: [Patcher.Action] = [(index: 0, sourceAnchor: nil, symbol: "", shift: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              resolver: resolver,
                              actions: actions,
                              base: 0x0000)
        let output = try! patcher.patch()
        XCTAssertEqual(inputInstructions, output)
    }
    
    func testPatchWithChangeToInstruction() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let expected = [Instruction(opcode: 0, immediate: 255)]
        let symbols = ["" : 255]
        let resolver: (SourceAnchor?, String) throws -> Int = {(sourceAnchor: SourceAnchor?, identifier: String) in
            return symbols[identifier]!
        }
        let actions: [Patcher.Action] = [(index: 0, sourceAnchor: nil, symbol: "", shift: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              resolver: resolver,
                              actions: actions,
                              base: 0x0000)
        let actual = try! patcher.patch()
        XCTAssertEqual(expected, actual)
    }
    
    func testPatchWithChangeToInstructionAndShift() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let expected = [Instruction(opcode: 0, immediate: 255)]
        let symbols = ["" : 0xff00]
        let resolver: (SourceAnchor?, String) throws -> Int = {(sourceAnchor: SourceAnchor?, identifier: String) in
            return symbols[identifier]!
        }
        let actions: [Patcher.Action] = [(index: 0, sourceAnchor: nil, symbol: "", shift: 8)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              resolver: resolver,
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
        let symbols = ["a" : 10, "b" : 20, "c" : 30]
        let resolver: (SourceAnchor?, String) throws -> Int = {(sourceAnchor: SourceAnchor?, identifier: String) in
            return symbols[identifier]!
        }
        let actions: [Patcher.Action] = [(index: 0, sourceAnchor: nil, symbol: "a", shift: 0),
                                         (index: 1, sourceAnchor: nil, symbol: "b", shift: 0),
                                         (index: 2, sourceAnchor: nil, symbol: "c", shift: 0)]
        let patcher = Patcher(inputInstructions: inputInstructions,
                              resolver: resolver,
                              actions: actions,
                              base: 0x0000)
        let actual = try! patcher.patch()
        XCTAssertEqual(expected, actual)
    }
    
    func testPatchWithUnresolvedSymbol() {
        let inputInstructions = [Instruction(opcode: 0, immediate: 0)]
        let actions: [Patcher.Action] = [(index: 0, sourceAnchor: nil, symbol: "", shift: 0)]
        let resolver: (SourceAnchor?, String) throws -> Int = {(sourceAnchor: SourceAnchor?, identifier: String) in
            throw CompilerError(sourceAnchor: sourceAnchor, message: "use of unresolved identifier: `\(identifier)'")
        }
        let patcher = Patcher(inputInstructions: inputInstructions,
                              resolver: resolver,
                              actions: actions,
                              base: 0x0000)
        XCTAssertThrowsError(try patcher.patch()) {
            let error = $0 as? CompilerError
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.message, "use of unresolved identifier: `'")
        }
    }
}
