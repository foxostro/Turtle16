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

    fileprivate func printTruthTable(_ signal: Int) {
        // Print the truth table for a given signal with columns for the actual
        // and expected results, comparing the PLD instruction deocder against
        // the Opcode Decoder ROM reference implementation (which is easier to
        // change). If there are differences then the PLD HDL must be updated.
        // Do this by taking the reference output string and plugging it into a
        // tool like <https://www.dcode.fr/boolean-truth-table>. This can
        // take the string and generate minimized logic for generating that
        // boolean function. Port this to HDL and you're done.
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
        
        let bstr = {(_ count: Int, _ value: UInt) -> String in
            var result = String(value, radix: 2)
            if result.count < count {
                result = String(repeatElement("0", count: count - result.count)) + result
            }
            return result
        }
        
        var outputString: String = ""
        
        let row = {(_ index: UInt) in
            let expectedOutput = UInt((expected[Int(index)] >> signal) & 1)
            let actualOutput = UInt((actual[Int(index)] >> signal) & 1)
            let row = bstr(8, index)
            + "\t" + bstr(1, expectedOutput)
            + "\t" + bstr(1, actualOutput)
            + ((expectedOutput != actualOutput) ? "\tX" : "")
            print(row)
            outputString += bstr(1, expectedOutput)
        }
        
        print("ABCDEFGH\tEx\tAc")
        for a in [UInt(0), UInt(1)] {
            for b in [UInt(0), UInt(1)] {
                for c in [UInt(0), UInt(1)] {
                    for d in [UInt(0), UInt(1)] {
                        for e in [UInt(0), UInt(1)] {
                            for carry in [UInt(0), UInt(1)] {
                                for z in [UInt(0), UInt(1)] {
                                    for ovf in [UInt(0), UInt(1)] {
                                        let index = ovf
                                                  | (z << 1)
                                                  | (carry << 2)
                                                  | (e << 3)
                                                  | (d << 4)
                                                  | (c << 5)
                                                  | (b << 6)
                                                  | (a << 7)
                                        row(index)
                                    } // ovf
                                } // z
                            } // carry
                        } // e
                    } // d
                } // c
            } // b
        } // a
        print("reference: \(outputString)")
    }
    
    func testSignals() throws {
//        printTruthTable(DecoderGenerator.HLT)
        
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
