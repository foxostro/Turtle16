//
//  ConstantDeclarationTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 5/16/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleSimulatorCore

class ConstantDeclarationTests: XCTestCase {
    func testEquality() {
        // Does not equality node of another type.
        XCTAssertNotEqual(ConstantDeclaration(identifier: "foo",
                                              value: 1),
                          AbstractSyntaxTreeNode())
        
        
        // Does not equal node with a different identifier.
        XCTAssertNotEqual(ConstantDeclaration(identifier: "foo",
                                              value: 1),
                          ConstantDeclaration(identifier: "bar",
                                              value: 1))
        
        // Does not equal node with a different number
        XCTAssertNotEqual(ConstantDeclaration(identifier: "foo",
                                              value: 1),
                          ConstantDeclaration(identifier: "foo",
                                              value: 2))
        
        // The two nodes actually are equal
        XCTAssertEqual(ConstantDeclaration(identifier: "foo",
                                           value: 1),
                       ConstantDeclaration(identifier: "foo",
                                           value: 1))
    }
    
    func testHash() {
        XCTAssertEqual(ConstantDeclaration(identifier: "foo",
                                           value: 1).hashValue,
                       ConstantDeclaration(identifier: "foo",
                                           value: 1).hashValue)
    }
}
