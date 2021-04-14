//
//  ParameterListTests.swift
//  TurtleCoreTests
//
//  Created by Andrew Fox on 10/23/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore

class ParameterListTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        // Does not equal a node of a different type.
        XCTAssertNotEqual(ParameterList(parameters: []),
                          InstructionNode(instruction: "NOP",
                                          parameters: ParameterList(parameters: [])))
        
        // Does not equal a node with different parameters
        XCTAssertNotEqual(ParameterList(parameters: [ParameterNumber(value: 0)]),
                          ParameterList(parameters: [ParameterNumber(value: 1)]))
                          
        // Does equal a node with same parameters
        XCTAssertEqual(ParameterList(parameters: [ParameterNumber(value: 1)]),
                       ParameterList(parameters: [ParameterNumber(value: 1)]))
        
        // Two empty parameter lists are equal.
        XCTAssertEqual(ParameterList(parameters: []),
                       ParameterList(parameters: []))
    }
    
    func testHash() {
        XCTAssertEqual(ParameterList(parameters: []).hashValue,
                       ParameterList(parameters: []).hashValue)
        XCTAssertEqual(ParameterList(parameters: [ParameterNumber(value: 1)]).hashValue,
                       ParameterList(parameters: [ParameterNumber(value: 1)]).hashValue)
    }
}
