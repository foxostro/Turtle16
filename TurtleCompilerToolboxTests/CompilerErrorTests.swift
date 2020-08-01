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
        let errors = [CompilerError(sourceAnchor: nil, message: "register cannot be used as a destination: `E'")]
        let omnibusError = CompilerError.makeOmnibusError(fileName: "foo.s", errors: errors)
        XCTAssertEqual(omnibusError.sourceAnchor, nil)
        XCTAssertEqual(omnibusError.message, "foo.s: error: register cannot be used as a destination: `E'\n1 error generated\n")
    }
    
    func testOmnibusErrorWithMultipleErrors() {
        let errors = [
            CompilerError(sourceAnchor: nil, message: "register cannot be used as a destination: `E'"),
            CompilerError(sourceAnchor: nil, message: "operand type mismatch: `MOV'")
        ]
        let omnibusError = CompilerError.makeOmnibusError(fileName: "foo.s", errors: errors)
        XCTAssertEqual(omnibusError.sourceAnchor, nil)
        XCTAssertEqual(omnibusError.message, "foo.s: error: register cannot be used as a destination: `E'\nfoo.s: error: operand type mismatch: `MOV'\n2 errors generated\n")
    }
}
