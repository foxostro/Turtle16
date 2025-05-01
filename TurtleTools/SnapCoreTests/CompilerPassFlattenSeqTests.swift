//
//  CompilerPassFlattenSeqTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/27/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassFlattenSeqTests: XCTestCase {
    func testRemoveEmptySeqStatements() throws {
        let input = Seq(children: [])
        let compiler = CompilerPassFlattenSeq()
        let actual = try? compiler.visit(input)
        XCTAssertNil(actual)
    }

    func testSingleStatementSeqIsFlattened() throws {
        let input = Seq(children: [
            CommentNode(string: "")
        ])
        let expected = CommentNode(string: "")
        let compiler = CompilerPassFlattenSeq()
        let actual = try? compiler.visit(input)
        XCTAssertEqual(actual, expected)
    }

    func testNestedSeqStatementsAreFlattened() throws {
        let input = Seq(children: [
            Seq(children: [
                CommentNode(string: "a"),
                CommentNode(string: "b"),
            ]),
            CommentNode(string: "c"),
        ])
        let expected = Seq(children: [
            CommentNode(string: "a"),
            CommentNode(string: "b"),
            CommentNode(string: "c"),
        ])
        let compiler = CompilerPassFlattenSeq()
        let actual = try? compiler.visit(input)
        XCTAssertEqual(actual, expected)
    }

    func testNestedSeqStatementsAreFlattened_InBlock() throws {
        let input = Block(children: [
            Seq(children: [
                CommentNode(string: "a"),
                CommentNode(string: "b"),
            ]),
            CommentNode(string: "c"),
        ])
        let expected = Block(children: [
            CommentNode(string: "a"),
            CommentNode(string: "b"),
            CommentNode(string: "c"),
        ])
        let compiler = CompilerPassFlattenSeq()
        let actual = try? compiler.visit(input)
        XCTAssertEqual(actual, expected)
    }

    func testNestedSeqStatementsAreFlattened_InTopLevel() throws {
        let input = TopLevel(children: [
            Seq(children: [
                CommentNode(string: "a"),
                CommentNode(string: "b"),
            ]),
            CommentNode(string: "c"),
        ])
        let expected = TopLevel(children: [
            CommentNode(string: "a"),
            CommentNode(string: "b"),
            CommentNode(string: "c"),
        ])
        let compiler = CompilerPassFlattenSeq()
        let actual = try? compiler.visit(input)
        XCTAssertEqual(actual, expected)
    }
}
