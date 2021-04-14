//
//  FunctionDeclarationTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 6/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class FunctionDeclarationTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                              argumentNames: [],
                                              body: Block()),
                          AbstractSyntaxTreeNode())
    }
    
    func testDoesNotEqualNodeWithDifferentBody() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                              argumentNames: [],
                                              body: Block()),
                          FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                              argumentNames: [],
                                              body: Block(children: [Expression.LiteralInt(1)])))
    }
    
    func testDoesNotEqualNodeWithDifferentReturnType() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                              argumentNames: [],
                                              body: Block(sourceAnchor: nil)),
                          FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.bool), arguments: []),
                                              argumentNames: [],
                                              body: Block(sourceAnchor: nil)))
    }
    
    func testDoesNotEqualNodeWithDifferentArguments() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: [Expression.PrimitiveType(.u8)]),
                                              argumentNames: ["foo"],
                                              body: Block(sourceAnchor: nil)),
                          FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: [Expression.PrimitiveType(.u8)]),
                                              argumentNames: ["bar"],
                                              body: Block(sourceAnchor: nil)))
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                              argumentNames: [],
                                              body: Block(children: [Expression.LiteralInt(1)])),
                          FunctionDeclaration(identifier: Expression.Identifier("bar"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                              argumentNames: [],
                                              body: Block(children: [Expression.LiteralInt(1)])))
    }
    
    func testSame() {
        XCTAssertEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                           argumentNames: [],
                                           body: Block(children: [Expression.LiteralInt(1)])),
                       FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                           argumentNames: [],
                                           body: Block(children: [Expression.LiteralInt(1)])))
    }
    
    func testHash() {
        XCTAssertEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                           argumentNames: [],
                                           body: Block(children: [Expression.LiteralInt(1)])).hash,
                       FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                           argumentNames: [],
                                           body: Block(children: [Expression.LiteralInt(1)])).hash)
    }
}
