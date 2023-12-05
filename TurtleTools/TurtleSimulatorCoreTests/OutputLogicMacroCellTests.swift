//
//  OutputLogicMacroCellTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 4/5/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleSimulatorCore

class OutputLogicMacroCellTests: XCTestCase {
    typealias Input = OutputLogicMacroCell.Input
    
    func testActiveHighOutput() throws {
        let cell = OutputLogicMacroCell(oe: ProductTermFuseMap(fuseListBitmap: 0b11111111111111111111111111111111111111111111),
                                        productTermFuseMaps: [ProductTermFuseMap(fuseListBitmap: 0)],
                                        s0: 1,
                                        s1: 1)
        let result = cell.step(Input(inputs: Array<UInt>(repeating: 0, count: 24)))
        XCTAssertEqual(result, 0)
    }
    
    func testActiveLowOutput() throws {
        let cell = OutputLogicMacroCell(oe: ProductTermFuseMap(fuseListBitmap: 0b11111111111111111111111111111111111111111111),
                                        productTermFuseMaps: [ProductTermFuseMap(fuseListBitmap: 0)],
                                        s0: 0,
                                        s1: 1)
        let result = cell.step(Input(inputs: Array<UInt>(repeating: 0, count: 24)))
        XCTAssertEqual(result, 1)
    }
    
    func testDisableOutput() throws {
        let cell = OutputLogicMacroCell(oe: ProductTermFuseMap(fuseListBitmap: 0),
                                        productTermFuseMaps: [ProductTermFuseMap(fuseListBitmap: 0)],
                                        s0: 1,
                                        s1: 1)
        let result = cell.step(Input(inputs: Array<UInt>(repeating: 0, count: 24)))
        XCTAssertEqual(result, nil)
    }
    
    func testRegisteredOutput() throws {
        // Registered outputs change on the rising edge of the clock. (pin 1)
        let cell = OutputLogicMacroCell(oe: ProductTermFuseMap(fuseListBitmap: 0b11111111111111111111111111111111111111111111),
                                        productTermFuseMaps: [ProductTermFuseMap(fuseListBitmap: 0b11110111111111111111111111111111111111111111)],
                                        s0: 1,
                                        s1: 0)
        
        let step0 = cell.step(Input(inputs: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]))
        XCTAssertEqual(step0, 1)
        XCTAssertEqual(cell.flipFlopState, step0)
        
        let step1 = cell.step(Input(inputs: [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]))
        XCTAssertEqual(step1, 0)
        XCTAssertEqual(cell.flipFlopState, step1)
    }
    
    func testFlipFlopToggle() throws {
        // Configure the GAL so that the OLMC toggle its state on the clock.
        // Registered outputs change on the rising edge of the clock. (pin 1)
        let cell = OutputLogicMacroCell(oe: ProductTermFuseMap(fuseListBitmap: 0b11111111111111111111111111111111111111111111),
                                        productTermFuseMaps: [ProductTermFuseMap(fuseListBitmap: 0b11101111111111111111111111111111111111111111)],
                                        s0: 1,
                                        s1: 0)
        
        let step0 = cell.step(Input(inputs: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                    feedback: [cell.flipFlopState, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
        XCTAssertEqual(step0, 1)
        
        let step1 = cell.step(Input(inputs: [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                    feedback: [cell.flipFlopState, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
        XCTAssertEqual(step1, 0)
        
        let step2 = cell.step(Input(inputs: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                    feedback: [cell.flipFlopState, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
        XCTAssertEqual(step2, 0)
        
        let step3 = cell.step(Input(inputs: [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                    feedback: [cell.flipFlopState, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
        XCTAssertEqual(step3, 1)
        
        let step4 = cell.step(Input(inputs: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                    feedback: [cell.flipFlopState, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
        XCTAssertEqual(step4, 1)
        
        let step5 = cell.step(Input(inputs: [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                    feedback: [cell.flipFlopState, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
        XCTAssertEqual(step5, 0)
    }
    
    func testAsynchronousResetActiveHigh() throws {
        let cell = OutputLogicMacroCell(oe: ProductTermFuseMap(fuseListBitmap: 0b11111111111111111111111111111111111111111111),
                                        productTermFuseMaps: [ProductTermFuseMap(fuseListBitmap: 0b11110111111111111111111111111111111111111111)],
                                        s0: 1,
                                        s1: 0)
        let result = cell.step(Input(inputs: [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], ar: 1))
        XCTAssertEqual(result, 0)
        XCTAssertEqual(cell.flipFlopState, result)
    }
    
    func testAsynchronousResetActiveLow() throws {
        let cell = OutputLogicMacroCell(oe: ProductTermFuseMap(fuseListBitmap: 0b11111111111111111111111111111111111111111111),
                                        productTermFuseMaps: [ProductTermFuseMap(fuseListBitmap: 0b11110111111111111111111111111111111111111111)],
                                        s0: 0,
                                        s1: 0)
        let result = cell.step(Input(inputs: [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], ar: 1))
        XCTAssertEqual(result, 1)
        XCTAssertEqual(cell.flipFlopState, 0)
    }
    
    func testSynchronousPresetActiveHigh() throws {
        let cell = OutputLogicMacroCell(oe: ProductTermFuseMap(fuseListBitmap: 0b11111111111111111111111111111111111111111111),
                                        productTermFuseMaps: [ProductTermFuseMap(fuseListBitmap: 0b11110111111111111111111111111111111111111111)],
                                        s0: 1,
                                        s1: 0)
        
        let step0 = cell.step(Input(inputs: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], ar: 1))
        XCTAssertEqual(step0, 0)
        XCTAssertEqual(cell.flipFlopState, step0)
        
        let step1 = cell.step(Input(inputs: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], sp: 1))
        XCTAssertEqual(step1, 0)
        XCTAssertEqual(cell.flipFlopState, step1)
        
        let step2 = cell.step(Input(inputs: [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], sp: 1))
        XCTAssertEqual(step2, 1)
        XCTAssertEqual(cell.flipFlopState, step2)
    }
    
    func testSynchronousPresetActiveLow() throws {
        let cell = OutputLogicMacroCell(oe: ProductTermFuseMap(fuseListBitmap: 0b11111111111111111111111111111111111111111111),
                                        productTermFuseMaps: [ProductTermFuseMap(fuseListBitmap: 0b11110111111111111111111111111111111111111111)],
                                        s0: 0,
                                        s1: 0)
        
        let step0 = cell.step(Input(inputs: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], ar: 1))
        XCTAssertEqual(step0, 1)
        XCTAssertEqual(cell.flipFlopState, 0)
        
        let step1 = cell.step(Input(inputs: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], sp: 1))
        XCTAssertEqual(step1, 1)
        XCTAssertEqual(cell.flipFlopState, 0)
        
        let step2 = cell.step(Input(inputs: [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], sp: 1))
        XCTAssertEqual(step2, 0)
        XCTAssertEqual(cell.flipFlopState, 1)
    }
}
