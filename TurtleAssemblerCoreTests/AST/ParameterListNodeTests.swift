//
//  ParameterListNodeTests.swift
//  TurtleAssemblerCoreTests
//
//  Created by Andrew Fox on 10/23/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleAssemblerCore
import TurtleCompilerToolbox

class ParameterListNodeTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        // Does not equal a node of a different type.
        XCTAssertNotEqual(ParameterListNode(parameters: []),
                          InstructionNode(instruction: TokenIdentifier(lineNumber: 1, lexeme: "NOP"),
                                          parameters: ParameterListNode(parameters: [])))
        
        // Does not equal a node with different parameters (RegisterName case)
        XCTAssertNotEqual(ParameterListNode(parameters: [RegisterName.A]),
                          ParameterListNode(parameters: [RegisterName.B]))
                          
        // Does equal a node with same parameters (RegisterName case)
        XCTAssertEqual(ParameterListNode(parameters: [RegisterName.B]),
                       ParameterListNode(parameters: [RegisterName.B]))
                          
        // Does not equal a node with different parameters (NSObject case)
        XCTAssertNotEqual(ParameterListNode(parameters: [TokenNumber(lineNumber: 0, lexeme: "", literal: 1)]),
                          ParameterListNode(parameters: [TokenIdentifier(lineNumber: 0, lexeme: "")]))
                          
        // Does equal a node with same parameters (NSObject case)
        XCTAssertEqual(ParameterListNode(parameters: [TokenNumber(lineNumber: 0, lexeme: "", literal: 1)]),
                       ParameterListNode(parameters: [TokenNumber(lineNumber: 0, lexeme: "", literal: 1)]))
        
        // Two empty parameter lists are equal.
        XCTAssertEqual(ParameterListNode(parameters: []),
                       ParameterListNode(parameters: []))
    }
    
    func testHash() {
        XCTAssertEqual(ParameterListNode(parameters: []).hashValue,
                       ParameterListNode(parameters: []).hashValue)
        XCTAssertEqual(ParameterListNode(parameters: [TokenNumber(lineNumber: 0, lexeme: "", literal: 1)]).hashValue,
                       ParameterListNode(parameters: [TokenNumber(lineNumber: 0, lexeme: "", literal: 1)]).hashValue)
        XCTAssertEqual(ParameterListNode(parameters: [RegisterName.B]).hashValue,
                       ParameterListNode(parameters: [RegisterName.B]).hashValue)
    }
}
