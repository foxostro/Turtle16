//
//  ConstantDeclarationNodeTests.swift
//  TurtleAssemblerCoreTests
//
//  Created by Andrew Fox on 5/16/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleAssemblerCore
import TurtleCompilerToolbox

class ConstantDeclarationNodeTests: XCTestCase {
    func testEquality() {
        // Does not equality node of another type.
        XCTAssertNotEqual(ConstantDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                                  number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                          AbstractSyntaxTreeNode())
        
        
        // Does not equal node with a different identifier.
        XCTAssertNotEqual(ConstantDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                                  number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                          ConstantDeclarationNode(identifier: TokenIdentifier(lineNumber: 2, lexeme: "bar"),
                                                  number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
        
        // Does not equal node with a different number
        XCTAssertNotEqual(ConstantDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                                  number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                          ConstantDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                                  number: TokenNumber(lineNumber: 2, lexeme: "2", literal: 2)))
        
        // The two nodes actually are equal
        XCTAssertEqual(ConstantDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                               number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                       ConstantDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                               number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
    }
    
    func testHash() {
        XCTAssertEqual(ConstantDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                               number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)).hashValue,
                       ConstantDeclarationNode(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                               number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)).hashValue)
    }
}
