//
//  CompilerErrorTests.swift
//  TurtleCompilerToolboxTests
//
//  Created by Andrew Fox on 5/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCompilerToolbox

class CompilerErrorTests: XCTestCase {
    func testOmnibusErrorWithNoErrors() {
        let error = CompilerError.makeOmnibusError(fileName: nil, errors: [])
        XCTAssertEqual(error.sourceAnchor, nil)
        XCTAssertEqual(error.message, "0 errors generated\n")
    }
    
    func testOmnibusErrorWithOneError() {
        let errors = [CompilerError(message: "register cannot be used as a destination: `E'")]
        let omnibusError = CompilerError.makeOmnibusError(fileName: "foo.s", errors: errors)
        XCTAssertEqual(omnibusError.sourceAnchor, nil)
        XCTAssertEqual(omnibusError.message, """
foo.s: register cannot be used as a destination: `E'
1 error generated

""")
    }
    
    func testOmnibusErrorWithMultipleErrors() {
        let errors = [
            CompilerError(message: "register cannot be used as a destination: `E'"),
            CompilerError(message: "operand type mismatch: `MOV'")
        ]
        let omnibusError = CompilerError.makeOmnibusError(fileName: "foo.s", errors: errors)
        XCTAssertEqual(omnibusError.sourceAnchor, nil)
        XCTAssertEqual(omnibusError.message, """
foo.s: register cannot be used as a destination: `E'
foo.s: operand type mismatch: `MOV'
2 errors generated

""")
    }
    
    func testOmnibusErrorWithContext_1() {
        let text = """
LI E, 1
"""
        let lineMapper = SourceLineRangeMapper(text: text)
        let error = CompilerError(sourceAnchor: lineMapper.anchor(3, 4),
                                  message: "register cannot be used as a destination: `E'")
        let omnibusError = CompilerError.makeOmnibusError(fileName: "foo.s", errors: [error])
        XCTAssertEqual(omnibusError.message, """
foo.s:1: register cannot be used as a destination: `E'
\tLI E, 1
\t   ^
1 error generated

""")
    }
    
    func testOmnibusErrorWithContext_2() {
        let text = """
let foo: u8 = 0x1000
"""
        let lineMapper = SourceLineRangeMapper(text: text)
        let error = CompilerError(sourceAnchor: lineMapper.anchor(14, 20),
                                  message: "integer literal `0x1000' overflows when stored into `u16'")
        let omnibusError = CompilerError.makeOmnibusError(fileName: "foo.s", errors: [error])
        XCTAssertEqual(omnibusError.message, """
foo.s:1: integer literal `0x1000' overflows when stored into `u16'
\tlet foo: u8 = 0x1000
\t              ^~~~~~
1 error generated

""")
    }
}
