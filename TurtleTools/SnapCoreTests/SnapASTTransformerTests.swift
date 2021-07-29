//
//  SnapASTTransformerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapASTTransformerTests: XCTestCase {
    func testExample() throws {
        let transformer = SnapASTTransformer()
        let input = TopLevel(children: [CommentNode(string: "")])
        transformer.transform(input)
        let actual = transformer.ast
        let expectedGlobalSymbols = CompilerIntrinsicSymbolBinder().bindCompilerIntrinsics(symbols: SymbolTable())
        let expected = Block(symbols: expectedGlobalSymbols,
                             children: [CommentNode(string: "")])
        XCTAssertFalse(transformer.hasError)
        XCTAssertEqual(expected, actual)
    }
    
    func testExpectTopLevelNodeAtRoot() throws {
        let transformer = SnapASTTransformer()
        transformer.transform(CommentNode(string: ""))
        XCTAssertTrue(transformer.hasError)
    }
}
