//
//  SnapToTackCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore

class SnapToTackCompilerTests: XCTestCase {
    func testNoErrorsOnInit() throws {
        let compiler = SnapToTackCompiler()
        XCTAssertEqual(compiler.errors.count, 0)
        XCTAssertEqual(compiler.hasError, false)
        XCTAssertEqual(compiler.instructions, [])
    }
    
    func testNoSymbolsOnInit() throws {
        let compiler = SnapToTackCompiler()
        XCTAssertEqual(compiler.globalSymbols, SymbolTable())
    }
}
