//
//  SnapAbstractSyntaxTreeCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapAbstractSyntaxTreeCompilerTests: XCTestCase {
    func makeCompiler() -> SnapAbstractSyntaxTreeCompiler {
        return SnapAbstractSyntaxTreeCompiler(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL())
    }
    
    func testExample() throws {
        let compiler = makeCompiler()
        let result = try? compiler.compile(CommentNode(string: "foo"))
        XCTAssertEqual(result, CommentNode(string: "foo"))
    }
}
