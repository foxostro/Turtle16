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
        let parameters = ParameterList(parameters: [
            ParameterRegister(value: RegisterName.A)
        ])
        XCTAssertNotEqual(InstructionNode(instruction: "",
                                          parameters: parameters),
                          InstructionNode(instruction: "NOP",
                                          parameters: ParameterList(parameters: [])))
        
        // Does not equal node with different parameters
        XCTAssertNotEqual(InstructionNode(instruction: "",
                                          parameters: ParameterList(parameters: [
                                            ParameterRegister(value: RegisterName.A)
                                          ])),
                          InstructionNode(instruction: "",
                                          parameters: ParameterList(parameters: [
                                            ParameterRegister(value: RegisterName.B)
                                          ])))
        
        // The nodes actually are the same
        XCTAssertEqual(InstructionNode(instruction: "",
                                       parameters: ParameterList(parameters: [
                                         ParameterRegister(value: RegisterName.A)
                                       ])),
                       InstructionNode(instruction: "",
                                       parameters: ParameterList(parameters: [
                                        ParameterRegister(value: RegisterName.A)
                                       ])))
    }
    
    func testHash() {
        XCTAssertEqual(InstructionNode(instruction: "",
                                       parameters: ParameterList(parameters: [
                                         ParameterRegister(value: RegisterName.A)
                                       ])).hashValue,
                       InstructionNode(instruction: "",
                                       parameters: ParameterList(parameters: [
                                         ParameterRegister(value: RegisterName.A)
                                       ])).hashValue)
    }
}
