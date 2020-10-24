//
//  AssemblyListingMakerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 10/23/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore

class AssemblyListingMakerTests: XCTestCase {
    fileprivate func makeListing(snapSource: String) -> String {
        let base = 0
        let compiler = SnapCompiler()
        compiler.compile(snapSource)
        let listing = AssemblyListingMaker.makeListing(base, compiler.instructions, compiler.programDebugInfo)
        return listing
    }
    
    func testMakeListing_Empty() {
        let actual = AssemblyListingMaker.makeListing(0, [], nil)
        XCTAssertEqual(actual, "")
    }
    
    func testMakeListing_EmptyProgram() {
        let actual = makeListing(snapSource: "")
        XCTAssertEqual(actual, """
NOP
LI U, 0
LI V, 0
LI M, 0
INUV
LI M, 0
INUV
LI M, 0
INUV
LI M, 0
HLT
""")
    }
    
    func testMakeListing_VarDeclStmt() {
        let actual = makeListing(snapSource: """
let a = 42
""")
        XCTAssertEqual(actual, """
NOP
LI U, 0
LI V, 0
LI M, 0
INUV
LI M, 0
INUV
LI M, 0
INUV
LI M, 0

# ##############################################################################
# let a = 42

# STORE-IMMEDIATE16 0x0010, 0x0110
LI U, 0
LI V, 16
LI M, 1
LI U, 0
LI V, 17
LI M, 16

# STORE-IMMEDIATE 0x0012, 0x2a
LI U, 0
LI V, 18
LI M, 42

# COPY-ID 0x0010, 0x0012, 1
LI U, 0
LI V, 16
MOV X, M
INUV
MOV Y, M
LI U, 0
LI V, 18
MOV A, M
MOV U, X
MOV V, Y
MOV M, A
HLT
""")
    }
}
