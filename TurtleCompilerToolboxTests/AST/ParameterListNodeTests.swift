//
//  ParameterListNodeTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 10/23/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class ParameterListNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(ParameterListNode(parameters: []), InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "NOP"), parameters: ParameterListNode(parameters: [])))
    }
    
    func testTwoEmptyParameterListNodesAreEqual() {
        XCTAssertEqual(ParameterListNode(parameters: []),
                       ParameterListNode(parameters: []))
    }
    
    func testTwoParameterListNodesAreNotEqualWhenParametersAreDifferent() {
        XCTAssertNotEqual(ParameterListNode(parameters: [TokenNumber(lineNumber: 0, lexeme: "", literal: 1)]),
                          ParameterListNode(parameters: [TokenIdentifier(lineNumber: 0, lexeme: "")]))
    }
}
