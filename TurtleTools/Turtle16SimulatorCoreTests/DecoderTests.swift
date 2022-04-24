//
//  DecoderTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 4/23/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class DecoderTests: XCTestCase {
    fileprivate func doesSignalMatchReference(_ signal: Int) -> Bool {
        let logic = LogicalDecoder()
        let lookupTable = OpcodeDecoderROM()
        lookupTable.opcodeDecodeROM = DecoderGenerator().generate()
        for i in 0..<logic.kDecoderTableSize {
            let expected = (lookupTable.decode(i) >> signal) & 1
            let actual = (logic.decode(i) >> signal) & 1
            if expected != actual {
                return false
            }
        }
        return true
    }

    func testSignals() throws {
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.HLT))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.SelStoreOpA))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.SelStoreOpB))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.SelRightOpA))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.SelRightOpB))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.FI))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.C0))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.I0))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.I1))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.I2))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.RS0))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.RS1))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.J))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.JABS))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.MemLoad))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.MemStore))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.AssertStoreOp))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.WriteBackSrcFlag))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.WRL))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.WRH))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.WBEN))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.LeftOperandIsUnused))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.RightOperandIsUnused))
    }
}
