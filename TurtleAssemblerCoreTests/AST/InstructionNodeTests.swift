//
//  InstructionNodeTests.swift
//  TurtleAssemblerCoreTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleAssemblerCore

class InstructionNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let parameters = ParameterListNode(parameters: [
            TokenRegister(lineNumber: 0, lexeme: "", literal: RegisterName.A)
        ])
        XCTAssertNotEqual(InstructionNode(instruction: TokenIdentifier(lineNumber: 0, lexeme: ""), parameters: parameters), InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "NOP"), parameters: ParameterListNode(parameters: [])))
    }
    
    func testDoesNotEqualNodeWithDifferentDestination() {
        let identifier = TokenIdentifier(lineNumber: 0, lexeme: "")
        let a = ParameterListNode(parameters: [
            TokenRegister(lineNumber: 0, lexeme: "", literal: RegisterName.A)
        ])
        let b = ParameterListNode(parameters: [
            TokenRegister(lineNumber: 0, lexeme: "", literal: RegisterName.B)
        ])
        XCTAssertNotEqual(InstructionNode(instruction: identifier, parameters: a),
                          InstructionNode(instruction: identifier, parameters: b))
    }
}
