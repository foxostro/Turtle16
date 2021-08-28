//
//  InstructionNodeTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleSimulatorCore

class TurtleTTLInstructionNodeTests: XCTestCase {
    func testEquality() {
        // Does not equal node of a different type.
        let parameters = [
            ParameterRegister(value: RegisterName.A)
        ]
        XCTAssertNotEqual(TurtleTTLInstructionNode(instruction: "",
                                                   parameters: parameters),
                          TurtleTTLInstructionNode(instruction: "NOP",
                                                   parameters: []))
        
        // Does not equal node with different parameters
        XCTAssertNotEqual(TurtleTTLInstructionNode(instruction: "",
                                                   parameters: [
                                                    ParameterRegister(value: RegisterName.A)
                                                   ]),
                          TurtleTTLInstructionNode(instruction: "",
                                                   parameters: [
                                                    ParameterRegister(value: RegisterName.B)
                                                   ]))
        
        // The nodes actually are the same
        XCTAssertEqual(TurtleTTLInstructionNode(instruction: "",
                                                parameters: [
                                                    ParameterRegister(value: RegisterName.A)
                                                ]),
                       TurtleTTLInstructionNode(instruction: "",
                                                parameters: [
                                                        ParameterRegister(value: RegisterName.A)
                                                ]))
    }
    
    func testHash() {
        XCTAssertEqual(TurtleTTLInstructionNode(instruction: "",
                                                parameters: [
                                                    ParameterRegister(value: RegisterName.A)
                                                ]).hashValue,
                       TurtleTTLInstructionNode(instruction: "",
                                                parameters: [
                                                    ParameterRegister(value: RegisterName.A)
                                                ]).hashValue)
    }
}
