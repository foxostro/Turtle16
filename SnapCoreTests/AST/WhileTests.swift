//
//  WhileTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class WhileTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(While(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                body: AbstractSyntaxTreeNode()),
                          AbstractSyntaxTreeNode())
    }
    
    func testDoesNotEqualNodeWithDifferentCondition() {
        XCTAssertNotEqual(While(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                 body: AbstractSyntaxTreeNode()),
                          While(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)),
                          body: AbstractSyntaxTreeNode()))
    }
    
    func testDoesNotEqualNodeWithDifferentBody() {
        XCTAssertNotEqual(While(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                body: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))),
                          While(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                                body: AbstractSyntaxTreeNode()))
    }
    
    func testSame() {
        XCTAssertEqual(While(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                             body: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))),
                       While(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                             body: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))))
    }
    
    func testHash() {
        XCTAssertEqual(While(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                             body: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))).hash,
                       While(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                             body: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1))).hash)
    }
    
    func testGetters() {
        let stmt = While(condition: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)),
                         body: Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)))
        XCTAssertEqual(stmt.condition, Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "1", literal: 1)))
        XCTAssertEqual(stmt.body, Expression.LiteralWord(number: TokenNumber(lineNumber: 1, lexeme: "2", literal: 2)))
    }
}
