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
        let result = compiler.transform(CommentNode(string: ""))
        XCTAssertEqual(result, CommentNode(string: ""))
    }
    
    func testTurnTopLevelIntoBlock() throws {
        let compiler = SnapASTTransformerTopLevel()
        let result = compiler.transform(TopLevel(children: [CommentNode(string: "")]))
        XCTAssertEqual(result, Block(children: [CommentNode(string: "")]))
    }
}
