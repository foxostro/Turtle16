//
//  ConstantDeclarationTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/19/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class ConstantDeclarationTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        let one = Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        XCTAssertNotEqual(ConstantDeclaration(identifier: foo, expression: one), LabelDeclarationNode(identifier: foo))
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        let bar = TokenIdentifier(lineNumber: 2, lexeme: "bar")
        let one = Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        XCTAssertNotEqual(ConstantDeclaration(identifier: foo, expression: one),
                          ConstantDeclaration(identifier: bar, expression: one))
    }
    
    func testDoesNotEqualNodeWithDifferentNumber() {
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        let one = Expression.Literal(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        let two = Expression.Literal(number: TokenNumber(lineNumber: 2, lexeme: "2", literal: 2))
        XCTAssertNotEqual(ConstantDeclaration(identifier: foo, expression: one),
                          ConstantDeclaration(identifier: foo, expression: two))
    }
    
    func testNodesActuallyAreTheSame() {
        XCTAssertEqual(ConstantDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                           expression: Expression.Literal(number: TokenNumber(lineNumber: 1,
                                                                                              lexeme: "1",
                                                                                              literal: 1))),
                       ConstantDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                           expression: Expression.Literal(number: TokenNumber(lineNumber: 1,
                                                                                              lexeme: "1",
                                                                                              literal: 1))))
    }
    
    func testHash() {
//        XCTAssertEqual(ConstantDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
//                                           expression: Expression.Literal(number: TokenNumber(lineNumber: 1,
//                                                                                              lexeme: "1",
//                                                                                              literal: 1))).hashValue,
//                       ConstantDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
//                                           expression: Expression.Literal(number: TokenNumber(lineNumber: 1,
//                                                                                              lexeme: "1",
//                                                                                              literal: 1))).hashValue)
//        
        XCTAssertNotEqual(ConstantDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                           expression: Expression.Literal(number: TokenNumber(lineNumber: 1,
                                                                                              lexeme: "1",
                                                                                              literal: 1))).hashValue,
                       ConstantDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                           expression: Expression.Literal(number: TokenNumber(lineNumber: 1,
                                                                                              lexeme: "2",
                                                                                              literal: 2))).hashValue)
    }
}
