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
        let globalEnvironment = GlobalEnvironment()
        let compiler = SnapAbstractSyntaxTreeCompiler(globalEnvironment: globalEnvironment)
        let input = TopLevel(children: [CommentNode(string: "")])
        compiler.compile(input)
        let actual = compiler.ast
        let expectedGlobalSymbols = SymbolTable()
            .withCompilerIntrinsics(globalEnvironment.memoryLayoutStrategy)
        let expected = Block(symbols: expectedGlobalSymbols,
                             children: [CommentNode(string: "")])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(expected, actual)
    }
    
    func testExpectTopLevelNodeAtRoot() throws {
        let globalEnvironment = GlobalEnvironment()
        let compiler = SnapAbstractSyntaxTreeCompiler(globalEnvironment: globalEnvironment)
        compiler.compile(CommentNode(string: ""))
        XCTAssertTrue(compiler.hasError)
    }
}
