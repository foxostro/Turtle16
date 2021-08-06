//
//  SnapASTTransformerBaseTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/4/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapASTTransformerBaseTests: XCTestCase {
    func testRemoveEmptySeqStatements() throws {
        let input = Seq(children: [])
        let compiler = SnapASTTransformerBase()
        let actual = try? compiler.compile(input)
        XCTAssertNil(actual)
    }
    
    func testSingleStatementSeqIsFlattened() throws {
        let input = Seq(children: [
            CommentNode(string: "")
        ])
        let expected = CommentNode(string: "")
        let compiler = SnapASTTransformerBase()
        let actual = try? compiler.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testNestedSeqStatementsAreFlattened() throws {
        let input = Seq(children: [
            Seq(children: [
                CommentNode(string: "a"),
                CommentNode(string: "b")
            ]),
            CommentNode(string: "c")
        ])
        let expected = Seq(children: [
            CommentNode(string: "a"),
            CommentNode(string: "b"),
            CommentNode(string: "c")
        ])
        let compiler = SnapASTTransformerBase()
        let actual = try? compiler.compile(input)
        XCTAssertEqual(actual, expected)
    }
}
