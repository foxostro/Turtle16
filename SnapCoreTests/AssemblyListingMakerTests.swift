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
        compiler.shouldEnableOptimizations = false
        compiler.compile(snapSource)
        let listing = AssemblyListingMaker.makeListing(base, compiler.instructions, compiler.programDebugInfo)
        return listing
    }
    
    func testMakeListing_Empty() {
        let actual = AssemblyListingMaker.makeListing(0, [], nil)
        XCTAssertEqual(actual, "")
    }
    
    func testMakeListing_VarDeclStmt() {
        let actual = makeListing(snapSource: """
let a = 42
""")
        print(actual)
        XCTAssertTrue(actual.hasPrefix("""
NOP
LI UV, 0x00
LI M, 0x00
INUV
LI M, 0x00
INUV
LI M, 0x00
INUV
LI M, 0x00

# ##############################################################################
# 1:
# let a = 42

# STORE-IMMEDIATE16 0x0010, 0x0110
LI U, 0x00
LI V, 0x0f
BLTI M, 0x01
BLTI M, 0x10

# STORE-IMMEDIATE 0x0012, 0x2a
LI U, 0x00
LI V, 0x12
LI M, 0x2a

# COPY-ID 0x0010, 0x0012, 1
LI U, 0x00
LI V, 0x10
MOV X, M
INUV
MOV Y, M
LI U, 0x00
LI V, 0x12
MOV A, M
MOV U, X
MOV V, Y
MOV M, A

# ##############################################################################
HLT
"""))
    }
}
