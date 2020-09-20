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
        XCTAssertNotEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                              body: Block()),
                          AbstractSyntaxTreeNode())
    }
    
    func testDoesNotEqualNodeWithDifferentBody() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                              body: Block()),
                          FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                              body: Block(children: [Expression.LiteralInt(1)])))
    }
    
    func testDoesNotEqualNodeWithDifferentReturnType() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                              body: Block(sourceAnchor: nil)),
                          FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.bool), arguments: []),
                                              body: Block(sourceAnchor: nil)))
    }
    
    func testDoesNotEqualNodeWithDifferentArguments() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: [Expression.FunctionType.Argument(name: "foo", type: Expression.PrimitiveType(.u8))]),
                                              body: Block(sourceAnchor: nil)),
                          FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: [Expression.FunctionType.Argument(name: "bar", type: Expression.PrimitiveType(.u8))]),
                                              body: Block(sourceAnchor: nil)))
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                              body: Block(children: [Expression.LiteralInt(1)])),
                          FunctionDeclaration(identifier: Expression.Identifier("bar"),
                                              functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                              body: Block(children: [Expression.LiteralInt(1)])))
    }
    
    func testSame() {
        XCTAssertEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                           body: Block(children: [Expression.LiteralInt(1)])),
                       FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                           body: Block(children: [Expression.LiteralInt(1)])))
    }
    
    func testHash() {
        XCTAssertEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                           body: Block(children: [Expression.LiteralInt(1)])).hash,
                       FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: Expression.FunctionType(name: "foo", returnType: Expression.PrimitiveType(.u8), arguments: []),
                                           body: Block(children: [Expression.LiteralInt(1)])).hash)
    }
}
