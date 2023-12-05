//
//  DecoderTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 4/23/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleSimulatorCore

class ProgrammableLogicDecoderTests: XCTestCase {
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
        let reference = OpcodeDecoderROM()
        reference.opcodeDecodeROM = DecoderGenerator().generate()
        
        let bstr = {(_ count: Int, _ value: UInt) -> String in
            var result = String(value, radix: 2)
            if result.count < count {
                result = String(repeatElement("0", count: count - result.count)) + result
            }
            return result
        }
        
        var expectedString: String = ""
        var actualString: String = ""
        
        let nbits = Int(log2(Double(pld.count)))
        
        print("#\tABCDEFGHI\tEx\tAc")
        for index in 0..<pld.count {
            let expected = reference.decode(index)
            let expectedOutput = (expected >> signal) & 1
            
            let actual = pld.decode(index)
            let actualOutput = (actual >> signal) & 1
            
            let row = "\(index)\t"
                    + bstr(nbits, UInt(index))
                    + "\t" + bstr(1, expectedOutput)
                    + "\t" + bstr(1, actualOutput)
                    + ((expectedOutput != actualOutput) ? "\tX" : "")
            print(row)
            
            expectedString += bstr(1, expectedOutput)
            actualString += bstr(1, actualOutput)
        }
        print("actualString: \(actualString)")
        print("expectedString: \(expectedString)")
    }
    
    fileprivate func doesSignalMatchReference(_ name: String, _ signal: Int, _ actual: [UInt], _ expected: [UInt]) -> Bool {
        for i in 0..<actual.count {
            let expected = (expected[i] >> signal) & 1
            let actual = (actual[i] >> signal) & 1
            if expected != actual {
                print("Signal \(name) does not match reference:")
                printTruthTable(signal)
                return false
            }
        }
        return true
    }
    
    func testSignals() throws {
        let pld = ProgrammableLogicDecoder()
        var actual = Array<UInt>(repeating: 0, count: pld.count)
        for i in 0..<pld.count {
            actual[i] = pld.decode(i)
        }
        
        var expected = Array<UInt>(repeating: 0, count: pld.count)
        let reference = OpcodeDecoderROM()
        reference.opcodeDecodeROM = DecoderGenerator().generate()
        for i in 0..<pld.count {
            expected[i] = reference.decode(i)
        }
        
        XCTAssertEqual(reference.count, pld.count)
        XCTAssertTrue(doesSignalMatchReference("HLT", DecoderGenerator.HLT, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("SelStoreOpA", DecoderGenerator.SelStoreOpA, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("SelStoreOpB", DecoderGenerator.SelStoreOpB, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("SelRightOpA", DecoderGenerator.SelRightOpA, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("SelRightOpB", DecoderGenerator.SelRightOpB, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("FI", DecoderGenerator.FI, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("C0", DecoderGenerator.C0, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("I0", DecoderGenerator.I0, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("I1", DecoderGenerator.I1, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("I2", DecoderGenerator.I2, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("RS0", DecoderGenerator.RS0, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("RS1", DecoderGenerator.RS1, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("J", DecoderGenerator.J, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("JABS", DecoderGenerator.JABS, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("MemLoad", DecoderGenerator.MemLoad, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("MemStore", DecoderGenerator.MemStore, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("AssertStoreOp", DecoderGenerator.AssertStoreOp, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("WriteBackSrcFlag", DecoderGenerator.WriteBackSrcFlag, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("WRL", DecoderGenerator.WRL, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("WRH", DecoderGenerator.WRH, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("WBEN", DecoderGenerator.WBEN, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("LeftOperandIsUnused",  DecoderGenerator.LeftOperandIsUnused, actual, expected))
        XCTAssertTrue(doesSignalMatchReference("RightOperandIsUnused", DecoderGenerator.RightOperandIsUnused, actual, expected))
    }
}
