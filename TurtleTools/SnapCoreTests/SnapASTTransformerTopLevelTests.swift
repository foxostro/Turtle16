//
//  SnapASTTransformerTopLevelTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapASTTransformerTopLevelTests: XCTestCase {
    func testPassThroughUnrecognizedNodes() throws {
        let compiler = SnapASTTransformerTopLevel()
        let result = try? compiler.compile(CommentNode(string: ""))
        XCTAssertEqual(result, CommentNode(string: ""))
    }
    
    func testTurnTopLevelIntoBlock() throws {
        let compiler = SnapASTTransformerTopLevel()
        let result = try? compiler.compile(TopLevel(children: [CommentNode(string: "")]))
        let expectedGlobalSymbols = CompilerIntrinsicSymbolBinder().bindCompilerIntrinsics(symbols: SymbolTable())
        let expected = Block(symbols: expectedGlobalSymbols,
                             children: [CommentNode(string: "")])
        XCTAssertEqual(result, expected)
    }
}
