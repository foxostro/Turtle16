//
//  AssemblerTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 6/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleSimulatorCore

class AssemblerTests: XCTestCase {
    func testExample() throws {
        let assembler = Assembler()
        assembler.compile("""
XOR r0, r0, r0
""")
        XCTAssertFalse(assembler.hasError)
        XCTAssertEqual(assembler.errors.count, 0)
        XCTAssertEqual(assembler.instructions, [
            0b0101100000000000
        ])
    }
    
    func testFibonacci() throws {
        let assembler = Assembler()
        assembler.compile("""
LI r0, 0
LI r1, 1
LI r7, 0
loop:
ADD r2, r0, r1
ADDI r0, r1, 0
ADDI r7, r7, 1
ADDI r1, r2, 0
CMPI r7, 9
BLT loop
HLT
""")
        XCTAssertFalse(assembler.hasError)
        XCTAssertEqual(assembler.errors.count, 0)
        XCTAssertEqual(assembler.instructions, [
            0b0010000000000000, // LI r0, 0
            0b0010000100000001, // LI r1, 1
            0b0010011100000000, // LI r7, 0
            0b0011101000000100, // ADD r2, r0, r1
            0b0111000000100000, // ADDI r0, r1, 0
            0b0111011111100001, // ADDI r7, r7, 1
            0b0111000101000000, // ADDI r1, r2, 0
            0b0110100011101001, // CMPI r7, 9
            0b1101011111111001, // BLT -7
            0b0000100000000000, // HLT
        ])
    }
}
