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
        let parameters = ParameterList(sourceAnchor: nil, parameters: [
            ParameterRegister(sourceAnchor: nil, value: RegisterName.A)
        ])
        XCTAssertNotEqual(InstructionNode(sourceAnchor: nil,
                                          instruction: "",
                                          parameters: parameters),
                          InstructionNode(sourceAnchor: nil,
                                          instruction: "NOP",
                                          parameters: ParameterList(sourceAnchor: nil, parameters: [])))
        
        // Does not equal node with different parameters
        XCTAssertNotEqual(InstructionNode(sourceAnchor: nil,
                                          instruction: "",
                                          parameters: ParameterList(sourceAnchor: nil, parameters: [
                                            ParameterRegister(sourceAnchor: nil, value: RegisterName.A)
                                          ])),
                          InstructionNode(sourceAnchor: nil,
                                          instruction: "",
                                          parameters: ParameterList(sourceAnchor: nil, parameters: [
                                            ParameterRegister(sourceAnchor: nil, value: RegisterName.B)
                                          ])))
        
        // The nodes actually are the same
        XCTAssertEqual(InstructionNode(sourceAnchor: nil,
                                       instruction: "",
                                       parameters: ParameterList(sourceAnchor: nil, parameters: [
                                         ParameterRegister(sourceAnchor: nil, value: RegisterName.A)
                                       ])),
                       InstructionNode(sourceAnchor: nil,
                                       instruction: "",
                                       parameters: ParameterList(sourceAnchor: nil, parameters: [
                                        ParameterRegister(sourceAnchor: nil, value: RegisterName.A)
                                       ])))
    }
    
    func testHash() {
        XCTAssertEqual(InstructionNode(sourceAnchor: nil,
                                       instruction: "",
                                       parameters: ParameterList(sourceAnchor: nil, parameters: [
                                         ParameterRegister(sourceAnchor: nil, value: RegisterName.A)
                                       ])).hashValue,
                       InstructionNode(sourceAnchor: nil,
                                       instruction: "",
                                       parameters: ParameterList(sourceAnchor: nil, parameters: [
                                         ParameterRegister(sourceAnchor: nil, value: RegisterName.A)
                                       ])).hashValue)
    }
}
