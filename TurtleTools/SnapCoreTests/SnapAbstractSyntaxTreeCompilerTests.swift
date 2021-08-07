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
    fileprivate func makeCompiler() -> SnapAbstractSyntaxTreeCompiler {
        let globalEnvironment = GlobalEnvironment()
        let compiler = SnapAbstractSyntaxTreeCompiler(globalEnvironment: globalEnvironment)
        return compiler
    }
    
    func testExample() throws {
        let compiler = makeCompiler()
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
        let compiler = makeCompiler()
        compiler.compile(CommentNode(string: ""))
        XCTAssertTrue(compiler.hasError)
    }
}
