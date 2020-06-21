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
        XCTAssertNotEqual(FunctionDeclaration(returnType: .u8, arguments: [], body: Block()),
                          AbstractSyntaxTreeNode())
    }
    
    func testDoesNotEqualNodeWithDifferentBody() {
        XCTAssertNotEqual(FunctionDeclaration(returnType: .u8, arguments: [], body: Block()),
                          FunctionDeclaration(returnType: .u8, arguments: [], body: Block(children: [ExprUtils.makeLiteralWord(value: 1)])))
    }
    
    func testDoesNotEqualNodeWithDifferentReturnType() {
        XCTAssertNotEqual(FunctionDeclaration(returnType: .u8, arguments: [], body: Block()),
                          FunctionDeclaration(returnType: .bool, arguments: [], body: Block()))
    }
    
    func testDoesNotEqualNodeWithDifferentArguments() {
        XCTAssertNotEqual(FunctionDeclaration(returnType: .u8,
                                              arguments: [FunctionDeclaration.Argument(name: "foo", type: .u8)],
                                              body: Block()),
                          FunctionDeclaration(returnType: .bool,
                                              arguments: [FunctionDeclaration.Argument(name: "bar", type: .u8)],
                                              body: Block()))
    }
    
    func testSame() {
        XCTAssertEqual(FunctionDeclaration(returnType: .u8, arguments: [], body: Block(children: [ExprUtils.makeLiteralWord(value: 1)])),
                       FunctionDeclaration(returnType: .u8, arguments: [], body: Block(children: [ExprUtils.makeLiteralWord(value: 1)])))
    }
    
    func testHash() {
        XCTAssertEqual(FunctionDeclaration(returnType: .u8, arguments: [], body: Block(children: [ExprUtils.makeLiteralWord(value: 1)])).hash,
                       FunctionDeclaration(returnType: .u8, arguments: [], body: Block(children: [ExprUtils.makeLiteralWord(value: 1)])).hash)
    }
}
