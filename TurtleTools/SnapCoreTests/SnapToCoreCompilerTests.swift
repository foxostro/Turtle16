//
//  SnapToCoreCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapToCoreCompilerTests: XCTestCase {
    func testExample() throws {
        let globalEnvironment = GlobalEnvironment()
        let compiler = SnapToCoreCompiler(globalEnvironment: globalEnvironment)
        let input = TopLevel(children: [CommentNode(string: "")])
        compiler.compile(input)
        let actual = compiler.ast
        let expected = Block(symbols: SymbolTable(),
                             children: [CommentNode(string: "")])
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(expected, actual)
    }
    
    func testExpectTopLevelNodeAtRoot() throws {
        let globalEnvironment = GlobalEnvironment()
        let compiler = SnapToCoreCompiler(globalEnvironment: globalEnvironment)
        compiler.compile(CommentNode(string: ""))
        XCTAssertTrue(compiler.hasError)
    }
}
