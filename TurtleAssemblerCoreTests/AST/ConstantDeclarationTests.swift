//
//  ConstantDeclarationTests.swift
//  TurtleAssemblerCoreTests
//
//  Created by Andrew Fox on 5/16/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleAssemblerCore
import TurtleCompilerToolbox

class ConstantDeclarationTests: XCTestCase {
    func testEquality() {
        // Does not equality node of another type.
        XCTAssertNotEqual(ConstantDeclaration(sourceAnchor: nil,
                                                  identifier: "foo",
                                                  value: 1),
                          AbstractSyntaxTreeNode(sourceAnchor: nil))
        
        
        // Does not equal node with a different identifier.
        XCTAssertNotEqual(ConstantDeclaration(sourceAnchor: nil,
                                                  identifier: "foo",
                                                  value: 1),
                          ConstantDeclaration(sourceAnchor: nil,
                                                  identifier: "bar",
                                                  value: 1))
        
        // Does not equal node with a different number
        XCTAssertNotEqual(ConstantDeclaration(sourceAnchor: nil,
                                                  identifier: "foo",
                                                  value: 1),
                          ConstantDeclaration(sourceAnchor: nil,
                                                  identifier: "foo",
                                                  value: 2))
        
        // The two nodes actually are equal
        XCTAssertEqual(ConstantDeclaration(sourceAnchor: nil,
                                               identifier: "foo",
                                               value: 1),
                       ConstantDeclaration(sourceAnchor: nil,
                                               identifier: "foo",
                                               value: 1))
    }
    
    func testHash() {
        XCTAssertEqual(ConstantDeclaration(sourceAnchor: nil,
                                               identifier: "foo",
                                               value: 1).hashValue,
                       ConstantDeclaration(sourceAnchor: nil,
                                               identifier: "foo",
                                               value: 1).hashValue)
    }
}
