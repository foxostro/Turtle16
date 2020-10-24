//
//  CrackleInstructionListingMakerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 10/23/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore

class CrackleInstructionListingMakerTests: XCTestCase {
    fileprivate func makeListing(snapSource: String) -> String {
        let compiler = SnapCompiler()
        compiler.compile(snapSource)
        let listing = CrackleInstructionListingMaker.makeListing(instructions: compiler.ir, programDebugInfo:  compiler.programDebugInfo)
        return listing
    }
    
    func testMakeEmptyListing() {
        let actual = CrackleInstructionListingMaker.makeListing(instructions: [], programDebugInfo: nil)
        XCTAssertEqual(actual, "")
    }
    
    func testMakeEmptyListing_EmptyProgram() {
        let actual = makeListing(snapSource: "")
        XCTAssertEqual(actual, "")
    }
    
    func testPushPop() {
        let actual = CrackleInstructionListingMaker.makeListing(instructions: [.push(0xaa), .pop], programDebugInfo:  nil)
        XCTAssertEqual(actual, "PUSH 0xaa\nPOP")
    }
    
    func testMakeList_VarDeclStmt() {
        let actual = makeListing(snapSource: "let a = 42")
        XCTAssertEqual(actual, """
# let a = 42
STORE-IMMEDIATE16 0x0010, 0x0110
STORE-IMMEDIATE 0x0012, 0x2a
COPY-ID 0x0010, 0x0012, 1
""")
    }
    
    func testMakeList_TwoVarDeclStmts() {
        let actual = makeListing(snapSource: "let a = 42\nlet b = 13")
        XCTAssertEqual(actual, """
# let a = 42
STORE-IMMEDIATE16 0x0010, 0x0110
STORE-IMMEDIATE 0x0012, 0x2a
COPY-ID 0x0010, 0x0012, 1

# let b = 13
STORE-IMMEDIATE16 0x0010, 0x0111
STORE-IMMEDIATE 0x0012, 0x0d
COPY-ID 0x0010, 0x0012, 1
""")
    }
}
