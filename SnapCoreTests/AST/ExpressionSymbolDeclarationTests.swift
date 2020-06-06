//
//  ExpressionSymbolDeclaration.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/19/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class ExpressionSymbolDeclarationTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        let one = Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        XCTAssertNotEqual(ExpressionSymbolDeclaration(identifier: foo, expression: one), LabelDeclarationNode(identifier: foo))
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        let bar = TokenIdentifier(lineNumber: 2, lexeme: "bar")
        let one = Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        XCTAssertNotEqual(ExpressionSymbolDeclaration(identifier: foo, expression: one),
                          ExpressionSymbolDeclaration(identifier: bar, expression: one))
    }
    
    func testDoesNotEqualNodeWithDifferentNumber() {
        let foo = TokenIdentifier(lineNumber: 1, lexeme: "foo")
        let one = Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))
        let two = Expression.LiteralWord(number: TokenNumber(lineNumber: 2, lexeme: "2", literal: 2))
        XCTAssertNotEqual(ExpressionSymbolDeclaration(identifier: foo, expression: one),
                          ExpressionSymbolDeclaration(identifier: foo, expression: two))
    }
    
    func testNodesActuallyAreTheSame() {
        XCTAssertEqual(ExpressionSymbolDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                                   expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1,
                                                                                                          lexeme: "1",
                                                                                                          literal: 1))),
                       ExpressionSymbolDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                                   expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1,
                                                                                                          lexeme: "1",
                                                                                                          literal: 1))))
    }
    
    func testHash() {
        XCTAssertNotEqual(ExpressionSymbolDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                                      expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1,
                                                                                                             lexeme: "1",
                                                                                                             literal: 1))).hashValue,
                          ExpressionSymbolDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                                      expression: Expression.LiteralWord(number: TokenNumber(lineNumber: 1,
                                                                                                             lexeme: "2",
                                                                                                             literal: 2))).hashValue)
    }
}
