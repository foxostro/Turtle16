//
//  FunctionDeclarationTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCompilerToolbox

class FunctionDeclarationTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                              returnType: .u8,
                                              arguments: [],
                                              body: Block()),
                          AbstractSyntaxTreeNode())
    }
    
    func testDoesNotEqualNodeWithDifferentBody() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                              returnType: .u8,
                                              arguments: [],
                                              body: Block()),
                          FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                              returnType: .u8,
                                              arguments: [],
                                              body: Block(children: [ExprUtils.makeLiteralWord(value: 1)])))
    }
    
    func testDoesNotEqualNodeWithDifferentReturnType() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                              returnType: .u8,
                                              arguments: [],
                                              body: Block()),
                          FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                              returnType: .bool,
                                              arguments: [],
                                              body: Block()))
    }
    
    func testDoesNotEqualNodeWithDifferentArguments() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                              returnType: .u8,
                                              arguments: [FunctionDeclaration.Argument(name: "foo", type: .u8)],
                                              body: Block()),
                          FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                              returnType: .bool,
                                              arguments: [FunctionDeclaration.Argument(name: "bar", type: .u8)],
                                              body: Block()))
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                              returnType: .u8,
                                              arguments: [],
                                              body: Block(children: [ExprUtils.makeLiteralWord(value: 1)])),
                          FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "bar"),
                                              returnType: .u8,
                                              arguments: [],
                                              body: Block(children: [ExprUtils.makeLiteralWord(value: 1)])))
    }
    
    func testSame() {
        XCTAssertEqual(FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                           returnType: .u8,
                                           arguments: [],
                                           body: Block(children: [ExprUtils.makeLiteralWord(value: 1)])),
                       FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                           returnType: .u8,
                                           arguments: [],
                                           body: Block(children: [ExprUtils.makeLiteralWord(value: 1)])))
    }
    
    func testHash() {
        XCTAssertEqual(FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                           returnType: .u8,
                                           arguments: [],
                                           body: Block(children: [ExprUtils.makeLiteralWord(value: 1)])).hash,
                       FunctionDeclaration(identifier: TokenIdentifier(lineNumber: 1, lexeme: "foo"),
                                           returnType: .u8,
                                           arguments: [],
                                           body: Block(children: [ExprUtils.makeLiteralWord(value: 1)])).hash)
    }
}
