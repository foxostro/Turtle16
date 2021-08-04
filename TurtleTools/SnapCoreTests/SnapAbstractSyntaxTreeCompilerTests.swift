//
//  SnapAbstractSyntaxTreeCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapAbstractSyntaxTreeCompilerTests: XCTestCase {
    func testExample() throws {
        let compiler = SnapAbstractSyntaxTreeCompiler()
        let input = TopLevel(children: [CommentNode(string: "")])
        compiler.compile(input)
        let actual = compiler.ast
        let expectedGlobalSymbols = CompilerIntrinsicSymbolBinder().bindCompilerIntrinsics(symbols: SymbolTable())
        let expected = Block(symbols: expectedGlobalSymbols,
                             children: [CommentNode(string: "")])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(expected, actual)
    }
    
    func testExpectTopLevelNodeAtRoot() throws {
        let compiler = SnapAbstractSyntaxTreeCompiler()
        compiler.compile(CommentNode(string: ""))
        XCTAssertTrue(compiler.hasError)
    }
}
