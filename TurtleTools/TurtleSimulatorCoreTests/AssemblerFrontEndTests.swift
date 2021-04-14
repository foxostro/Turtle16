//
//  AssemblerFrontEndTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 8/18/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import TurtleSimulatorCore

class AssemblerFrontEndTests: XCTestCase {
    func testCompileFailsDuringLexing() {
        let compiler = AssemblerFrontEnd()
        compiler.compile("@")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "unexpected character: `@'")
    }
    
    func testCompileFailsDuringParsing() {
        let compiler = AssemblerFrontEnd()
        compiler.compile(":")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "unexpected end of input")
    }
    
    func testCompileFailsDuringCodeGeneration() {
        let compiler = AssemblerFrontEnd()
        compiler.compile("LI B, foo")
        XCTAssertTrue(compiler.hasError)
        XCTAssertEqual(compiler.errors.count, 1)
        XCTAssertEqual(compiler.errors.first?.sourceAnchor?.lineNumbers, 0..<1)
        XCTAssertEqual(compiler.errors.first?.message, "use of unresolved identifier: `foo'")
    }
    
    func testEnsureDisassemblyWorks() {
        let compiler = AssemblerFrontEnd()
        compiler.compile("")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(compiler.instructions.count, 1)
        XCTAssertEqual(compiler.instructions.first?.disassembly, "NOP")
    }
}
