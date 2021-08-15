//
//  SnapAbstractSyntaxTreeCompilerImplPassTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class SnapAbstractSyntaxTreeCompilerImplPassTests: XCTestCase {
    func makeCompiler() -> SnapAbstractSyntaxTreeCompilerImplPass {
        return SnapAbstractSyntaxTreeCompilerImplPass(memoryLayoutStrategy: MemoryLayoutStrategyTurtleTTL(),
                                                      globalEnvironment: GlobalEnvironment())
    }
    
    func testExample() throws {
        let compiler = makeCompiler()
        let result = try? compiler.compile(CommentNode(string: "foo"))
        XCTAssertEqual(result, CommentNode(string: "foo"))
    }
}
