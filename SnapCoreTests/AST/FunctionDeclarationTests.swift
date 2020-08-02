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
                                              functionType: FunctionType(returnType: .u8, arguments: []),
                                              body: Block()),
                          AbstractSyntaxTreeNode())
    }
    
    func testDoesNotEqualNodeWithDifferentBody() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: FunctionType(returnType: .u8, arguments: []),
                                              body: Block()),
                          FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: FunctionType(returnType: .u8, arguments: []),
                                              body: Block(children: [Expression.LiteralInt(1)])))
    }
    
    func testDoesNotEqualNodeWithDifferentReturnType() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: FunctionType(returnType: .u8, arguments: []),
                                              body: Block(sourceAnchor: nil)),
                          FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: FunctionType(returnType: .bool, arguments: []),
                                              body: Block(sourceAnchor: nil)))
    }
    
    func testDoesNotEqualNodeWithDifferentArguments() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "foo", type: .u8)]),
                                              body: Block(sourceAnchor: nil)),
                          FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: FunctionType(returnType: .bool, arguments: [FunctionType.Argument(name: "bar", type: .u8)]),
                                              body: Block(sourceAnchor: nil)))
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                              functionType: FunctionType(returnType: .u8, arguments: []),
                                              body: Block(children: [Expression.LiteralInt(1)])),
                          FunctionDeclaration(identifier: Expression.Identifier("bar"),
                                              functionType: FunctionType(returnType: .u8, arguments: []),
                                              body: Block(children: [Expression.LiteralInt(1)])))
    }
    
    func testSame() {
        XCTAssertEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: FunctionType(returnType: .u8, arguments: []),
                                           body: Block(children: [Expression.LiteralInt(1)])),
                       FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: FunctionType(returnType: .u8, arguments: []),
                                           body: Block(children: [Expression.LiteralInt(1)])))
    }
    
    func testHash() {
        XCTAssertEqual(FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: FunctionType(returnType: .u8, arguments: []),
                                           body: Block(children: [Expression.LiteralInt(1)])).hash,
                       FunctionDeclaration(identifier: Expression.Identifier("foo"),
                                           functionType: FunctionType(returnType: .u8, arguments: []),
                                           body: Block(children: [Expression.LiteralInt(1)])).hash)
    }
}
