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
        XCTAssertNotEqual(FunctionDeclaration(sourceAnchor: nil,
                                              identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                              functionType: FunctionType(returnType: .u8, arguments: []),
                                              body: Block(sourceAnchor: nil, children: [])),
                          AbstractSyntaxTreeNode(sourceAnchor: nil))
    }
    
    func testDoesNotEqualNodeWithDifferentBody() {
        XCTAssertNotEqual(FunctionDeclaration(sourceAnchor: nil,
                                              identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                              functionType: FunctionType(returnType: .u8, arguments: []),
                                              body: Block(sourceAnchor: nil, children: [])),
                          FunctionDeclaration(sourceAnchor: nil,
                                              identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                              functionType: FunctionType(returnType: .u8, arguments: []),
                                              body: Block(sourceAnchor: nil, children: [Expression.LiteralWord(sourceAnchor: nil, value: 1)])))
    }
    
    func testDoesNotEqualNodeWithDifferentReturnType() {
        XCTAssertNotEqual(FunctionDeclaration(sourceAnchor: nil,
                                              identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                              functionType: FunctionType(returnType: .u8, arguments: []),
                                              body: Block(sourceAnchor: nil)),
                          FunctionDeclaration(sourceAnchor: nil,
                                              identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                              functionType: FunctionType(returnType: .bool, arguments: []),
                                              body: Block(sourceAnchor: nil)))
    }
    
    func testDoesNotEqualNodeWithDifferentArguments() {
        XCTAssertNotEqual(FunctionDeclaration(sourceAnchor: nil,
                                              identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                              functionType: FunctionType(returnType: .u8, arguments: [FunctionType.Argument(name: "foo", type: .u8)]),
                                              body: Block(sourceAnchor: nil)),
                          FunctionDeclaration(sourceAnchor: nil,
                                              identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                              functionType: FunctionType(returnType: .bool, arguments: [FunctionType.Argument(name: "bar", type: .u8)]),
                                              body: Block(sourceAnchor: nil)))
    }
    
    func testDoesNotEqualNodeWithDifferentIdentifier() {
        XCTAssertNotEqual(FunctionDeclaration(sourceAnchor: nil,
                                              identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                              functionType: FunctionType(returnType: .u8, arguments: []),
                                              body: Block(sourceAnchor: nil, children: [Expression.LiteralWord(sourceAnchor: nil, value: 1)])),
                          FunctionDeclaration(sourceAnchor: nil,
                                              identifier: Expression.Identifier(sourceAnchor: nil, identifier: "bar"),
                                              functionType: FunctionType(returnType: .u8, arguments: []),
                                              body: Block(sourceAnchor: nil, children: [Expression.LiteralWord(sourceAnchor: nil, value: 1)])))
    }
    
    func testSame() {
        XCTAssertEqual(FunctionDeclaration(sourceAnchor: nil,
                                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                           functionType: FunctionType(returnType: .u8, arguments: []),
                                           body: Block(sourceAnchor: nil, children: [Expression.LiteralWord(sourceAnchor: nil, value: 1)])),
                       FunctionDeclaration(sourceAnchor: nil,
                                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                           functionType: FunctionType(returnType: .u8, arguments: []),
                                           body: Block(sourceAnchor: nil, children: [Expression.LiteralWord(sourceAnchor: nil, value: 1)])))
    }
    
    func testHash() {
        XCTAssertEqual(FunctionDeclaration(sourceAnchor: nil,
                                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                           functionType: FunctionType(returnType: .u8, arguments: []),
                                           body: Block(sourceAnchor: nil, children: [Expression.LiteralWord(sourceAnchor: nil, value: 1)])).hash,
                       FunctionDeclaration(sourceAnchor: nil,
                                           identifier: Expression.Identifier(sourceAnchor: nil, identifier: "foo"),
                                           functionType: FunctionType(returnType: .u8, arguments: []),
                                           body: Block(sourceAnchor: nil, children: [Expression.LiteralWord(sourceAnchor: nil, value: 1)])).hash)
    }
}
