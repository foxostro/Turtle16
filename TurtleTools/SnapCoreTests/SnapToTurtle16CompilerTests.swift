//
//  SnapToTurtle16CompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 11/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import Turtle16SimulatorCore

class SnapToTurtle16CompilerTests: XCTestCase {
    func testEmptyProgram() throws {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: "")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(Disassembler().disassembleToText(compiler.instructions), """
            NOP
            HLT
            """)
    }
    
    func testSimpleProgram() throws {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
let a = 1
""")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(Disassembler().disassembleToText(compiler.instructions), """
            NOP
            LI r0, 16
            LUI r0, 1
            LI r1, 1
            STORE r0, r1, 0
            NOP
            HLT
            """)
    }
    
    func testFunctionDefinition() throws {
        let compiler = SnapToTurtle16Compiler()
        compiler.compile(program: """
func foo() {
    let a = 1
}
""")
        XCTAssertFalse(compiler.hasError)
        XCTAssertEqual(AssemblerListingMaker().makeListing(try compiler.assembly.get()), """
            NOP
            NOP
            HLT
            foo:
            ENTER 1
            SUBI r0, r7, 1
            LI r1, 1
            STORE r0, r1
            LEAVE
            RET
            """)
    }
}
