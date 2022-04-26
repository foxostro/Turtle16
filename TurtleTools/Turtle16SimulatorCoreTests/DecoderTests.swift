//
//  DecoderTests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 4/23/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class ProgrammableLogicDecoderTests: XCTestCase {
    fileprivate func doesSignalMatchReference(_ signal: Int, _ actual: [UInt], _ expected: [UInt]) -> Bool {
        for i in 0..<actual.count {
            let expected = (expected[i] >> signal) & 1
            let actual = (actual[i] >> signal) & 1
            if expected != actual {
                return false
            }
        }
        return true
    }

    func testSignals() throws {
        let pld = ProgrammableLogicDecoder()
        var actual: [UInt] = Array<UInt>(repeating: 0, count: pld.count)
        for i in 0..<pld.count {
            actual[i] = pld.decode(i)
        }
        
        var expected: [UInt] = Array<UInt>(repeating: 0, count: pld.count)
        let reference = OpcodeDecoderROM()
        reference.opcodeDecodeROM = DecoderGenerator().generate()
        for i in 0..<pld.count {
            expected[i] = reference.decode(i)
        }
        
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.HLT, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.SelStoreOpA, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.SelStoreOpB, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.SelRightOpA, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.SelRightOpB, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.FI, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.C0, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.I0, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.I1, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.I2, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.RS0, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.RS1, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.J, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.JABS, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.MemLoad, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.MemStore, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.AssertStoreOp, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.WriteBackSrcFlag, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.WRL, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.WRH, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.WBEN, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.LeftOperandIsUnused, actual, expected))
        XCTAssertTrue(doesSignalMatchReference(DecoderGenerator.RightOperandIsUnused, actual, expected))
    }
}
