//
//  ATF22V10Tests.swift
//  Turtle16SimulatorCoreTests
//
//  Created by Andrew Fox on 4/5/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import Turtle16SimulatorCore

class ATF22V10Tests: XCTestCase {
    func testCorrectNumberOfProductTermsPerOLMC() throws {
        let gal = ATF22V10(fuseList: Array<UInt>(repeating: 1, count: 5892))
        XCTAssertEqual(gal.outputLogicMacroCells.count, 10)
        XCTAssertEqual(gal.outputLogicMacroCells[0].productTermFuseMaps.count, 8)
        XCTAssertEqual(gal.outputLogicMacroCells[1].productTermFuseMaps.count, 10)
        XCTAssertEqual(gal.outputLogicMacroCells[2].productTermFuseMaps.count, 12)
        XCTAssertEqual(gal.outputLogicMacroCells[3].productTermFuseMaps.count, 14)
        XCTAssertEqual(gal.outputLogicMacroCells[4].productTermFuseMaps.count, 16)
        XCTAssertEqual(gal.outputLogicMacroCells[5].productTermFuseMaps.count, 16)
        XCTAssertEqual(gal.outputLogicMacroCells[6].productTermFuseMaps.count, 14)
        XCTAssertEqual(gal.outputLogicMacroCells[7].productTermFuseMaps.count, 12)
        XCTAssertEqual(gal.outputLogicMacroCells[8].productTermFuseMaps.count, 10)
        XCTAssertEqual(gal.outputLogicMacroCells[9].productTermFuseMaps.count, 8)
    }
    
    func testTwoInputAND() throws {
        // Make sure we can setup the ATF22V10 to emulate a two-input AND gate.
        
        var fuseList = Array<UInt>(repeating: 1, count: 5892)
        
        // Set up the first product term with two terms in it.
        fuseList[88] = 0
        fuseList[92] = 0
        
        // Disable the other product terms.
        for i in 132..<440 {
            fuseList[i] = 0
        }
        
        let gal = ATF22V10(fuseList: fuseList)
        
        let truthTable = [
            // a    b    y
            [  0,   0,   0],
            [  0,   1,   0],
            [  1,   0,   0],
            [  1,   1,   1]
        ]
        for row in truthTable {
            let a = UInt(row[0])
            let b = UInt(row[1])
            let y = UInt(row[2])
            let output = gal.step(inputs: [0, a, b, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
            XCTAssertEqual(output[0], y)
        }
    }
    
    func testTwoInputAND_UsingIOPinsForInput() throws {
        // Make sure we can setup the ATF22V10 to emulate a two-input AND gate
        // using two of the I/O pins in an input configuration to do it.
        
        var fuseList = Array<UInt>(repeating: 1, count: 5892)
        
        // Set up the first product term with two terms in it.
        fuseList[90] = 0
        fuseList[94] = 0
        
        // Disable the other product terms.
        for i in 132..<440 {
            fuseList[i] = 0
        }
        
        let gal = ATF22V10(fuseList: fuseList)
        
        let truthTable = [
            // a    b    y
            [  0,   0,   0],
            [  0,   1,   0],
            [  1,   0,   0],
            [  1,   1,   1]
        ]
        for row in truthTable {
            let a = UInt(row[0])
            let b = UInt(row[1])
            let y = UInt(row[2])
            let output = gal.step(inputs: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, b, a])
            XCTAssertEqual(output[0], y)
        }
    }
    
    func testFlipFlopToggle() throws {
        // Configure the GAL so that an OLMC toggle its state on the clock.
        // Registered outputs change on the rising edge of the clock. (pin 1)
        
        var fuseList = Array<UInt>(repeating: 1, count: 5892)
        
        // One product term for the first OLMC: The inverted feedback bit from the first OLMC.
        fuseList[90] = 0
        
        // Disable the other product terms.
        for i in 132..<440 {
            fuseList[i] = 0
        }
        
        // Configure the first OLMC for Active-High, Registered operation
        fuseList[5808] = 1
        fuseList[5809] = 0
        
        let gal = ATF22V10(fuseList: fuseList)
        
        let step0 = gal.step(inputs: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
        XCTAssertEqual(step0[0], 1)
        let step1 = gal.step(inputs: [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
        XCTAssertEqual(step1[0], 0)
        let step2 = gal.step(inputs: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
        XCTAssertEqual(step2[0], 0)
        let step3 = gal.step(inputs: [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
        XCTAssertEqual(step3[0], 1)
    }
    
    func testSimpleJEDECFile_Inverter() throws {
        let maker = FuseListMaker()
        let parser = JEDECFuseFileParser(maker)
        parser.parse("""
Used Program:   GALasm 2.1
GAL-Assembler:  GALasm 2.1
Device:         GAL22V10

*F0
*G0
*QF5892
*L0044 11111111111111111111111111111111111111111111
*L0088 11111011111111111111111111111111111111111111
*L5808 11000000000000000000
*L5828 0111010001100101011100110111010000000000000000000000000000000000
*C0df2
""")
        let gal = ATF22V10(fuseList: maker.fuseList)
        
        var results: [[UInt?]] = []
        
        results.append(gal.step(inputs: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]))
        results.append(gal.step(inputs: [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]))
    }
    
    func testSimpleJEDECFile_TestAgainstConstant() throws {
        let maker = FuseListMaker()
        let parser = JEDECFuseFileParser(maker)
        parser.parse("""
Used Program:   GALasm 2.1
GAL-Assembler:  GALasm 2.1
Device:         GAL22V10

*F0
*G0
*QF5892
*L0924 11111111111111111111111111111111111111111111
*L0968 11111111111111111111111111111111101111111111
*L1012 11111111111111111111111111111011111111111111
*L1056 11111111111111111111111101111111111111111111
*L1100 11111111111111111111011111111111111111111111
*L1144 11111111111111111011111111111111111111111111
*L1188 11111111111101111111111111111111111111111111
*L1232 11111111011111111111111111111111111111111111
*L1276 11110111111111111111111111111111111111111111
*L5808 00001100000000000000
*L5828 0111010001100101011100110111010000000000000000000000000000000000
*C34fe
""")
        let gal = ATF22V10(fuseList: maker.fuseList)
        
        var results: [[UInt?]] = []
        
        for i in 0..<0b100000000 {
            let d7 = (UInt(i) >> 7) & 1
            let d6 = (UInt(i) >> 6) & 1
            let d5 = (UInt(i) >> 5) & 1
            let d4 = (UInt(i) >> 4) & 1
            let d3 = (UInt(i) >> 3) & 1
            let d2 = (UInt(i) >> 2) & 1
            let d1 = (UInt(i) >> 1) & 1
            let d0 =  UInt(i) & 1
            results.append(gal.step(inputs: [0, 0, d0, d1, d2, d3, d4, d5, d6, d7, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]))
        }
        
        XCTAssertTrue(doesExactlyOneIndexMatch(results, 0b100000000, 0b11001000, 2))
    }
    
    fileprivate func doesExactlyOneIndexMatch(_ results: [[UInt?]], _ count: Int, _ matchingIndex: Int, _ resultIndex: Int) -> Bool {
        if results[matchingIndex][resultIndex] != 0 {
            return false
        }
        for i in 0..<count {
            if i != matchingIndex {
                if results[i][resultIndex] == 0 {
                    return false
                }
            }
        }
        return true
    }
    
    func testSimpleJEDECFile_TestAgainstMultipleConstants() throws {
        let maker = FuseListMaker()
        let parser = JEDECFuseFileParser(maker)
        parser.parse("""
Used Program:   GALasm 2.1
GAL-Assembler:  GALasm 2.1
Device:         GAL22V10

*F0
*G0
*QF5892
*L0924 11111111111111111111111111111111111111111111
*L0968 11111111111111111111111111111111101111111111
*L1012 11111111111111111111111111111011111111111111
*L1056 11111111111111111111111101111111111111111111
*L1100 11111111111111111111011111111111111111111111
*L1144 11111111111111111011111111111111111111111111
*L1188 11111111111101111111111111111111111111111111
*L1232 11111111011111111111111111111111111111111111
*L1276 11110111111111111111111111111111111111111111
*L1496 11111111111111111111111111111111111111111111
*L1540 11111111111111111111111111111111101111111111
*L1584 11111111111111111111111111111011111111111111
*L1628 11111111111111111111111101111111111111111111
*L1672 11111111111111111111101111111111111111111111
*L1716 11111111111111110111111111111111111111111111
*L1760 11111111111101111111111111111111111111111111
*L1804 11111111101111111111111111111111111111111111
*L1848 11110111111111111111111111111111111111111111
*L2156 11111111111111111111111111111111111111111111
*L2200 11111111111111111111111111111111101111111111
*L2244 11111111111111111111111111111011111111111111
*L2288 11111111111111111111111110111111111111111111
*L2332 11111111111111111111101111111111111111111111
*L2376 11111111111111110111111111111111111111111111
*L2420 11111111111101111111111111111111111111111111
*L2464 11111111101111111111111111111111111111111111
*L2508 11110111111111111111111111111111111111111111
*L2904 11111111111111111111111111111111111111111111
*L2948 11111111111111111111111111111111111110111111
*L2992 11111111111111111111111111111111011111111111
*L3036 11111111111111111111111111110111111111111111
*L3080 11111111111111111111111101111111111111111111
*L3124 11111111111111111111011111111111111111111111
*L3168 11111111111111111011111111111111111111111111
*L3212 11111111111101111111111111111111111111111111
*L3256 11111111011111111111111111111111111111111111
*L3300 11110111111111111111111111111111111111111111
*L3652 11111111111111111111111111111111111111111111
*L3696 11111111111111111111111111111111111110111111
*L3740 11111111111111111111111111111111011111111111
*L3784 11111111111111111111111111110111111111111111
*L3828 11111111111111111111111101111111111111111111
*L3872 11111111111111111111011111111111111111111111
*L3916 11111111111111111011111111111111111111111111
*L3960 11111111111101111111111111111111111111111111
*L4004 11111111011111111111111111111111111111111111
*L4048 11111011111111111111111111111111111111111111
*L5808 00001111111111000000
*L5828 0111010001100101011100110111010000000000000000000000000000000000
*C10494
""")
        let gal = ATF22V10(fuseList: maker.fuseList)
        
        var results: [[UInt?]] = []
        
        for i in 0..<0b1000000000 {
            let d8 = (UInt(i) >> 8) & 1
            let d7 = (UInt(i) >> 7) & 1
            let d6 = (UInt(i) >> 6) & 1
            let d5 = (UInt(i) >> 5) & 1
            let d4 = (UInt(i) >> 4) & 1
            let d3 = (UInt(i) >> 3) & 1
            let d2 = (UInt(i) >> 2) & 1
            let d1 = (UInt(i) >> 1) & 1
            let d0 =  UInt(i) & 1
            results.append(gal.step(inputs: [0, 0, d0, d1, d2, d3, d4, d5, d6, d7, d8, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]))
        }
        
        XCTAssertTrue(doesExactlyOneIndexMatch(results, 0b100000000, 0b11001000, 2))
        XCTAssertTrue(doesExactlyOneIndexMatch(results, 0b100000000, 0b11010010, 3))
        XCTAssertTrue(doesExactlyOneIndexMatch(results, 0b100000000, 0b11110010, 4))
        XCTAssertTrue(doesExactlyOneIndexMatch(results, 0b1000000000, 0b100001000, 5))
        XCTAssertTrue(doesExactlyOneIndexMatch(results, 0b1000000000, 0b100001001, 6))
    }
    
    func testFlipFlopToggle_UsingRealJEDECFile() throws {
        let maker = FuseListMaker()
        let parser = JEDECFuseFileParser(maker)
        parser.parse("""
Used Program:   GALasm 2.1
GAL-Assembler:  GALasm 2.1
Device:         GAL22V10

*F0
*G0
*QF5892
*L0924 11111111111111111111111111111111111111111111
*L0968 11111111110111011111111111111111111111111111
*L1496 11111111111111111111111111111111111111111111
*L1540 11110111111111111111111111111111111111111111
*L5808 00001011000000000000
*L5828 0111010001100101011100110111010000000000000000000000000000000000
*C198f
""")
        let gal = ATF22V10(fuseList: maker.fuseList)
        
        var results: [[UInt?]] = []
        
        results.append(gal.step(inputs: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]))
        results.append(gal.step(inputs: [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]))
        results.append(gal.step(inputs: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]))
        results.append(gal.step(inputs: [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]))
        results.append(gal.step(inputs: [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]))
        results.append(gal.step(inputs: [0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]))
        results.append(gal.step(inputs: [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]))
        results.append(gal.step(inputs: [0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]))
        
        let generateLineDiagram = {(index: Int) in
            results.map({ (row) -> String in
                row[index] == 0 ? "_" : "#"
            }).joined()
        }
        
        XCTAssertEqual(generateLineDiagram(2), "#____##_")
        XCTAssertEqual(generateLineDiagram(3), "____####")
    }
    
    func testRealVGAHorizontalControl() throws {
        // The VGA control logic interprets a count which has been provided as
        // input. When the count reaches a certain value, the hsync output goes
        // low. When it reaches another value, the output goes high again. This
        // generate a repeating negative pulse. Ditto hblank.
        let maker = FuseListMaker()
        let parser = JEDECFuseFileParser(maker)
        parser.parse("""
Used Program:   GALasm 2.1
GAL-Assembler:  GALasm 2.1
Device:         GAL22V10

*F0
*G0
*QF5892
*L0044 11111111111111111111111111111111111111111111
*L0088 11101111111111011111111111111111111111111111
*L0132 11111111111111111110111111111111111111111111
*L0440 11111111111111111111111111111111111111111111
*L0484 11111110110111111111111111111111111111111111
*L0528 11111111111111111111111011111111111111111111
*L0924 11111111111111111111111111111111111111111111
*L0968 11111111111111111111111111111111101111111111
*L1012 11111111111111111111111111111011111111111111
*L1056 11111111111111111111111101111111111111111111
*L1100 11111111111111111111011111111111111111111111
*L1144 11111111111111111011111111111111111111111111
*L1188 11111111111101111111111111111111111111111111
*L1232 11111111011111111111111111111111111111111111
*L1276 11110111111111111111111111111111111111111111
*L1496 11111111111111111111111111111111111111111111
*L1540 11111111111111111111111111111111101111111111
*L1584 11111111111111111111111111111011111111111111
*L1628 11111111111111111111111101111111111111111111
*L1672 11111111111111111111101111111111111111111111
*L1716 11111111111111110111111111111111111111111111
*L1760 11111111111101111111111111111111111111111111
*L1804 11111111101111111111111111111111111111111111
*L1848 11110111111111111111111111111111111111111111
*L2156 11111111111111111111111111111111111111111111
*L2200 11111111111111111111111111111111101111111111
*L2244 11111111111111111111111111111011111111111111
*L2288 11111111111111111111111110111111111111111111
*L2332 11111111111111111111101111111111111111111111
*L2376 11111111111111110111111111111111111111111111
*L2420 11111111111101111111111111111111111111111111
*L2464 11111111101111111111111111111111111111111111
*L2508 11110111111111111111111111111111111111111111
*L2904 11111111111111111111111111111111111111111111
*L2948 11111111111111111111111111111111111110111111
*L2992 11111111111111111111111111111111011111111111
*L3036 11111111111111111111111111110111111111111111
*L3080 11111111111111111111111101111111111111111111
*L3124 11111111111111111111011111111111111111111111
*L3168 11111111111111111011111111111111111111111111
*L3212 11111111111101111111111111111111111111111111
*L3256 11111111011111111111111111111111111111111111
*L3300 11110111111111111111111111111111111111111111
*L3652 11111111111111111111111111111111111111111111
*L3696 11111111111111111111111111111111111110111111
*L3740 11111111111111111111111111111111011111111111
*L3784 11111111111111111111111111110111111111111111
*L3828 11111111111111111111111101111111111111111111
*L3872 11111111111111111111011111111111111111111111
*L3916 11111111111111111011111111111111111111111111
*L3960 11111111111101111111111111111111111111111111
*L4004 11111111011111111111111111111111111111111111
*L4048 11111011111111111111111111111111111111111111
*L5808 10101111111111000000
*L5828 0111011001100111011000010110001101110100011011000101111101101000
*C1254b
""")
        let gal = ATF22V10(fuseList: maker.fuseList)
        
        var results: [[UInt?]] = []
        
        for i in 0...0b100001000 {
            let d8 = (UInt(i) >> 8) & 1
            let d7 = (UInt(i) >> 7) & 1
            let d6 = (UInt(i) >> 6) & 1
            let d5 = (UInt(i) >> 5) & 1
            let d4 = (UInt(i) >> 4) & 1
            let d3 = (UInt(i) >> 3) & 1
            let d2 = (UInt(i) >> 2) & 1
            let d1 = (UInt(i) >> 1) & 1
            let d0 =  UInt(i) & 1
            _ = gal.step(inputs: [0, 0, d0, d1, d2, d3, d4, d5, d6, d7, d8, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
            results.append(gal.step(inputs: [0, 1, d0, d1, d2, d3, d4, d5, d6, d7, d8, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]))
        }
        
        XCTAssertTrue(doesExactlyOneIndexMatch(results, 0b100001000, 0b011001000, 2))
        XCTAssertTrue(doesExactlyOneIndexMatch(results, 0b100001000, 0b011010010, 3))
        XCTAssertTrue(doesExactlyOneIndexMatch(results, 0b100001000, 0b011110010, 4))
        XCTAssertTrue(doesExactlyOneIndexMatch(results, 0b100001000, 0b100001000, 5))
        
        let generateLineDiagram = {(index: Int) in
            results[0...264].map({ (row) -> String in
                row[index] == 0 ? "_" : "#"
            }).joined()
        }
        
        let hsync = generateLineDiagram(0)
        let hblank = generateLineDiagram(1)
        
        XCTAssertEqual(hsync, "##################################################################################################################################################################################################################________________________________#######################")
        XCTAssertEqual(hblank, "########################################################################################################################################################################################################________________________________________________________________#")
    }
}
