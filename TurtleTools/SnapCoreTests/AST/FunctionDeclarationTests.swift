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

final class FunctionDeclarationTests: XCTestCase {
    func testDoesNotEqualAnotherNodeType() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Identifier("foo"),
                                              functionType: FunctionType(name: "foo", returnType: PrimitiveType(.u8), arguments: []),
                                              argumentNames: [],
                                              body: Block()),
                          CommentNode(string: ""))
    }
    
    func testDoesNotEqualNodeWithDifferentBody() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Identifier("foo"),
                                              functionType: FunctionType(name: "foo", returnType: PrimitiveType(.u8), arguments: []),
                                              argumentNames: [],
                                              body: Block()),
                          FunctionDeclaration(identifier: Identifier("foo"),
                                              functionType: FunctionType(name: "foo", returnType: PrimitiveType(.u8), arguments: []),
                                              argumentNames: [],
                                              body: Block(children: [LiteralInt(1)])))
    }
    
    func testDoesNotEqualNodeWithDifferentReturnType() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Identifier("foo"),
                                              functionType: FunctionType(name: "foo", returnType: PrimitiveType(.u8), arguments: []),
                                              argumentNames: [],
                                              body: Block(sourceAnchor: nil)),
                          FunctionDeclaration(identifier: Identifier("foo"),
                                              functionType: FunctionType(name: "foo", returnType: PrimitiveType(.bool), arguments: []),
                                              argumentNames: [],
                                              body: Block(sourceAnchor: nil)))
    }
    
    func testDoesNotEqualNodeWithDifferentArguments() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Identifier("foo"),
                                              functionType: FunctionType(name: "foo", returnType: PrimitiveType(.u8), arguments: [PrimitiveType(.u8)]),
                                              argumentNames: ["foo"],
                                              body: Block(sourceAnchor: nil)),
                          FunctionDeclaration(identifier: Identifier("foo"),
                                              functionType: FunctionType(name: "foo", returnType: PrimitiveType(.u8), arguments: [PrimitiveType(.u8)]),
                                              argumentNames: ["bar"],
                                              body: Block(sourceAnchor: nil)))
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        XCTAssertNotEqual(FunctionDeclaration(identifier: Identifier("foo"),
                                              functionType: FunctionType(name: "foo", returnType: PrimitiveType(.u8), arguments: []),
                                              argumentNames: [],
                                              body: Block(children: [LiteralInt(1)])),
                          FunctionDeclaration(identifier: Identifier("bar"),
                                              functionType: FunctionType(name: "foo", returnType: PrimitiveType(.u8), arguments: []),
                                              argumentNames: [],
                                              body: Block(children: [LiteralInt(1)])))
    }
    
    func testSame() {
        XCTAssertEqual(FunctionDeclaration(identifier: Identifier("foo"),
                                           functionType: FunctionType(name: "foo", returnType: PrimitiveType(.u8), arguments: []),
                                           argumentNames: [],
                                           body: Block(children: [LiteralInt(1)])),
                       FunctionDeclaration(identifier: Identifier("foo"),
                                           functionType: FunctionType(name: "foo", returnType: PrimitiveType(.u8), arguments: []),
                                           argumentNames: [],
                                           body: Block(children: [LiteralInt(1)])))
    }
    
    func testHash() {
        XCTAssertEqual(FunctionDeclaration(identifier: Identifier("foo"),
                                           functionType: FunctionType(name: "foo", returnType: PrimitiveType(.u8), arguments: []),
                                           argumentNames: [],
                                           body: Block(children: [LiteralInt(1)])).hashValue,
                       FunctionDeclaration(identifier: Identifier("foo"),
                                           functionType: FunctionType(name: "foo", returnType: PrimitiveType(.u8), arguments: []),
                                           argumentNames: [],
                                           body: Block(children: [LiteralInt(1)])).hashValue)
    }
}
