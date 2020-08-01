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
        XCTAssertNotEqual(ParameterList(sourceAnchor: nil, parameters: []),
                          InstructionNode(sourceAnchor: nil,
                                          instruction: "NOP",
                                          parameters: ParameterList(sourceAnchor: nil, parameters: [])))
        
        // Does not equal a node with different parameters
        XCTAssertNotEqual(ParameterList(sourceAnchor: nil, parameters: [ParameterRegister(sourceAnchor: nil, value: RegisterName.A)]),
                          ParameterList(sourceAnchor: nil, parameters: [ParameterRegister(sourceAnchor: nil, value: RegisterName.B)]))
                          
        // Does equal a node with same parameters
        XCTAssertEqual(ParameterList(sourceAnchor: nil, parameters: [ParameterRegister(sourceAnchor: nil, value: RegisterName.B)]),
                       ParameterList(sourceAnchor: nil, parameters: [ParameterRegister(sourceAnchor: nil, value: RegisterName.B)]))
        
        // Two empty parameter lists are equal.
        XCTAssertEqual(ParameterList(sourceAnchor: nil, parameters: []),
                       ParameterList(sourceAnchor: nil, parameters: []))
    }
    
    func testHash() {
        XCTAssertEqual(ParameterList(sourceAnchor: nil, parameters: []).hashValue,
                       ParameterList(sourceAnchor: nil, parameters: []).hashValue)
        XCTAssertEqual(ParameterList(sourceAnchor: nil, parameters: [ParameterNumber(sourceAnchor: nil, value: 1)]).hashValue,
                       ParameterList(sourceAnchor: nil, parameters: [ParameterNumber(sourceAnchor: nil, value: 1)]).hashValue)
        XCTAssertEqual(ParameterList(sourceAnchor: nil, parameters: [ParameterRegister(sourceAnchor: nil, value: RegisterName.B)]).hashValue,
                       ParameterList(sourceAnchor: nil, parameters: [ParameterRegister(sourceAnchor: nil, value: RegisterName.B)]).hashValue)
    }
}
