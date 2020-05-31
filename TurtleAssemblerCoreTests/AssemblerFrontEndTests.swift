//
//  AssemblerFrontEndTests.swift
//  TurtleAssemblerCoreTests
//
//  Created by Andrew Fox on 8/18/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleAssemblerCore
import TurtleCompilerToolbox

class AssemblerFrontEndTests: XCTestCase {
    func testCompileFailsDuringLexing() {
        let compiler = AssemblerFrontEnd()
        compiler.compile("@")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.line, Optional<Int>(1))
        XCTAssertEqual(compiler.errors.first?.message, Optional<String>("unexpected character: `@'"))
    }
    
    func testCompileFailsDuringParsing() {
        let compiler = AssemblerFrontEnd()
        compiler.compile(":")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.line, Optional<Int>(1))
        XCTAssertEqual(compiler.errors.first?.message, Optional<String>("unexpected end of input"))
    }
    
    func testCompileFailsDuringCodeGeneration() {
        let compiler = AssemblerFrontEnd()
        compiler.compile("LI B, foo")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.line, Optional<Int>(1))
        XCTAssertEqual(compiler.errors.first?.message, Optional<String>("use of unresolved identifier: `foo'"))
    }
    
    func testEnsureDisassemblyWorks() {
        let compiler = AssemblerFrontEnd()
        compiler.compile("")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions.count, 1)
        XCTAssertEqual(compiler.instructions.first?.disassembly, "NOP")
    }
}
