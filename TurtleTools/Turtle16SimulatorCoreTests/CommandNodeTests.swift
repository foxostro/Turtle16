//
//  CommandNodeTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class CommandNodeTests: XCTestCase {
    func testEquality() {
        // Does not equal node of a different type.
        let parameters = ParameterList(parameters: [
            ParameterNumber(value: 0)
        ])
        XCTAssertNotEqual(InstructionNode(instruction: "",
                                      parameters: parameters),
                          InstructionNode(instruction: "NOP",
                                      parameters: ParameterList(parameters: [])))
        
        // Does not equal node with different parameters
        XCTAssertNotEqual(InstructionNode(instruction: "",
                                      parameters: ParameterList(parameters: [
                                        ParameterNumber(value: 0)
                                      ])),
                          InstructionNode(instruction: "",
                                      parameters: ParameterList(parameters: [
                                        ParameterNumber(value: 1)
                                      ])))
        
        // The nodes actually are the same
        XCTAssertEqual(InstructionNode(instruction: "",
                                   parameters: ParameterList(parameters: [
                                    ParameterNumber(value: 0)
                                   ])),
                       InstructionNode(instruction: "",
                                   parameters: ParameterList(parameters: [
                                    ParameterNumber(value: 0)
                                   ])))
    }
    
    func testHash() {
        XCTAssertEqual(InstructionNode(instruction: "",
                                   parameters: ParameterList(parameters: [
                                    ParameterNumber(value: 0)
                                   ])).hashValue,
                       InstructionNode(instruction: "",
                                   parameters: ParameterList(parameters: [
                                    ParameterNumber(value: 0)
                                   ])).hashValue)
    }
}
