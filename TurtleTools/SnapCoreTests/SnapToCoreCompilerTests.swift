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
        let input = TopLevel(children: [CommentNode(string: "")])
        let expected = Block(symbols: SymbolTable(),
                             children: [CommentNode(string: "")])
        
        let actual = try SnapToCoreCompiler()
            .compile(input)
            .get()
        XCTAssertEqual(expected, actual)
    }
    
    func testExpectTopLevelNodeAtRoot() throws {
        let input = CommentNode(string: "")
        XCTAssertThrowsError(try SnapToCoreCompiler()
            .compile(input)
            .get())
    }
}
