//
//  AssemblerTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 6/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleSimulatorCore
import XCTest

final class AssemblerTests: XCTestCase {
    func testExample() throws {
        let assembler = Assembler()
        assembler.compile(
            """
            XOR r0, r0, r0
            """
        )
        XCTAssertFalse(assembler.hasError)
        XCTAssertEqual(assembler.errors.count, 0)
        XCTAssertEqual(
            assembler.instructions,
            [
                0b01011000_00000000
            ]
        )
    }

    func testFibonacci() throws {
        let assembler = Assembler()
        assembler.compile(
            """
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
            """
        )
        XCTAssertFalse(assembler.hasError)
        XCTAssertEqual(assembler.errors.count, 0)
        XCTAssertEqual(
            assembler.instructions,
            [
                0b00100000_00000000,  // LI r0, 0
                0b00100001_00000001,  // LI r1, 1
                0b00100111_00000000,  // LI r7, 0
                0b00111010_00000100,  // ADD r2, r0, r1
                0b01110000_00100000,  // ADDI r0, r1, 0
                0b01110111_11100001,  // ADDI r7, r7, 1
                0b01110001_01000000,  // ADDI r1, r2, 0
                0b01101000_11101001,  // CMPI r7, 9
                0b11010111_11111001,  // BLT -7
                0b00001000_00000000  // HLT
            ]
        )
    }
}
