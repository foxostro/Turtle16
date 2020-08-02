//
//  ParameterListTests.swift
//  TurtleAssemblerCoreTests
//
//  Created by Andrew Fox on 10/23/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleAssemblerCore
import TurtleCompilerToolbox

class ParameterListTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        // Does not equal a node of a different type.
        XCTAssertNotEqual(ParameterList(parameters: []),
                          InstructionNode(instruction: "NOP",
                                          parameters: ParameterList(parameters: [])))
        
        // Does not equal a node with different parameters
        XCTAssertNotEqual(ParameterList(parameters: [ParameterRegister(value: RegisterName.A)]),
                          ParameterList(parameters: [ParameterRegister(value: RegisterName.B)]))
                          
        // Does equal a node with same parameters
        XCTAssertEqual(ParameterList(parameters: [ParameterRegister(value: RegisterName.B)]),
                       ParameterList(parameters: [ParameterRegister(value: RegisterName.B)]))
        
        // Two empty parameter lists are equal.
        XCTAssertEqual(ParameterList(parameters: []),
                       ParameterList(parameters: []))
    }
    
    func testHash() {
        XCTAssertEqual(ParameterList(parameters: []).hashValue,
                       ParameterList(parameters: []).hashValue)
        XCTAssertEqual(ParameterList(parameters: [ParameterNumber(value: 1)]).hashValue,
                       ParameterList(parameters: [ParameterNumber(value: 1)]).hashValue)
        XCTAssertEqual(ParameterList(parameters: [ParameterRegister(value: RegisterName.B)]).hashValue,
                       ParameterList(parameters: [ParameterRegister(value: RegisterName.B)]).hashValue)
    }
}
