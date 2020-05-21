//
//  InstructionNodeTests.swift
//  TurtleAssemblerCoreTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleAssemblerCore
import TurtleCompilerToolbox

class InstructionNodeTests: XCTestCase {
    func testEquality() {
        // Does not equal node of a different type.
        let parameters = ParameterListNode(parameters: [
            TokenRegister(lineNumber: 0, lexeme: "", literal: RegisterName.A)
        ])
        XCTAssertNotEqual(InstructionNode(instruction: TokenIdentifier(lineNumber: 0, lexeme: ""), parameters: parameters), InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "NOP"), parameters: ParameterListNode(parameters: [])))
        
        // Does not equal node with different parameters
        XCTAssertNotEqual(InstructionNode(instruction: TokenIdentifier(lineNumber: 0, lexeme: ""),
                                          parameters: ParameterListNode(parameters: [
                                            TokenRegister(lineNumber: 0, lexeme: "", literal: RegisterName.A)
                                          ])),
                          InstructionNode(instruction: TokenIdentifier(lineNumber: 0, lexeme: ""),
                                          parameters: ParameterListNode(parameters: [
                                            TokenRegister(lineNumber:0, lexeme: "", literal: RegisterName.B)
                                          ])))
        
        // Does not equal node with a different token
        XCTAssertNotEqual(InstructionNode(instruction: TokenIdentifier(lineNumber: 0, lexeme: ""),
                                          parameters: ParameterListNode(parameters: [
                                            TokenRegister(lineNumber: 0, lexeme: "", literal: RegisterName.A)
                                          ])),
                          InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: ""),
                                          parameters: ParameterListNode(parameters: [
                                            TokenRegister(lineNumber:0, lexeme: "", literal: RegisterName.A)
                                          ])))
        
        // The nodes actually are the same
        XCTAssertEqual(InstructionNode(instruction: TokenIdentifier(lineNumber: 0, lexeme: ""),
                                       parameters: ParameterListNode(parameters: [
                                         TokenRegister(lineNumber: 0, lexeme: "", literal: RegisterName.A)
                                       ])),
                                       InstructionNode(instruction: TokenIdentifier(lineNumber: 0, lexeme: ""),
                                                       parameters: ParameterListNode(parameters: [
                                                         TokenRegister(lineNumber:0, lexeme: "", literal: RegisterName.A)
                                                       ])))
    }
    
    func testHash() {
        XCTAssertEqual(InstructionNode(instruction: TokenIdentifier(lineNumber: 0, lexeme: ""),
                                       parameters: ParameterListNode(parameters: [
                                         TokenRegister(lineNumber: 0, lexeme: "", literal: RegisterName.A)
                                       ])).hashValue,
                       InstructionNode(instruction: TokenIdentifier(lineNumber: 0, lexeme: ""),
                                       parameters: ParameterListNode(parameters: [
                                         TokenRegister(lineNumber:0, lexeme: "", literal: RegisterName.A)
                                       ])).hashValue)
    }
}
