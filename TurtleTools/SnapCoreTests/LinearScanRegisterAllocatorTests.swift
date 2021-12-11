//
//  LinearScanRegisterAllocatorTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 12/6/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore

class LinearScanRegisterAllocatorTests: XCTestCase {
    func testEmptyInput() throws {
        let actual = LinearScanRegisterAllocator.allocate(numRegisters: 0, liveIntervals: [])
        XCTAssertEqual(actual, [])
    }
    
    func testDoNotModifyRangesWithExistingAllocations1() throws {
        let actual = LinearScanRegisterAllocator.allocate(numRegisters: 4, liveIntervals: [
            LiveInterval(range: 0..<Int.max, virtualRegisterName: "vr0", physicalRegisterName: "r5")
        ])
        XCTAssertEqual(actual, [
            LiveInterval(range: 0..<Int.max, virtualRegisterName: "vr0", physicalRegisterName: "r5")
        ])
    }
    
    func testDoNotModifyRangesWithExistingAllocations2() throws {
        let actual = LinearScanRegisterAllocator.allocate(numRegisters: 4, liveIntervals: [
            LiveInterval(range: 0..<Int.max, virtualRegisterName: "vr0", physicalRegisterName: "ra")
        ])
        XCTAssertEqual(actual, [
            LiveInterval(range: 0..<Int.max, virtualRegisterName: "vr0", physicalRegisterName: "ra")
        ])
    }
    
    func testOneLiveInterval() throws {
        let actual = LinearScanRegisterAllocator.allocate(numRegisters: 4, liveIntervals: [
            LiveInterval(range: 0..<Int.max, virtualRegisterName: "vr100", physicalRegisterName: nil)
        ])
        XCTAssertEqual(actual, [
            LiveInterval(range: 0..<Int.max, virtualRegisterName: "vr100", physicalRegisterName: "r0")
        ])
    }
    
    func testMultipleLiveIntervalNoOverlap() throws {
        let actual = LinearScanRegisterAllocator.allocate(numRegisters: 4, liveIntervals: [
            LiveInterval(range: 0..<1, virtualRegisterName: "vr100", physicalRegisterName: nil),
            LiveInterval(range: 1..<2, virtualRegisterName: "vr300", physicalRegisterName: nil),
            LiveInterval(range: 2..<3, virtualRegisterName: "vr200", physicalRegisterName: nil)
        ])
        XCTAssertEqual(actual, [
            LiveInterval(range: 0..<1, virtualRegisterName: "vr100", physicalRegisterName: "r0"),
            LiveInterval(range: 1..<2, virtualRegisterName: "vr300", physicalRegisterName: "r0"),
            LiveInterval(range: 2..<3, virtualRegisterName: "vr200", physicalRegisterName: "r0")
        ])
    }
    
    func testMultipleOverlappingLiveIntervalsNoSpills() throws {
        let actual = LinearScanRegisterAllocator.allocate(numRegisters: 4, liveIntervals: [
            LiveInterval(range: 0..<1, virtualRegisterName: "vr0", physicalRegisterName: nil),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr1", physicalRegisterName: nil),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr2", physicalRegisterName: nil),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr3", physicalRegisterName: nil)
        ])
        XCTAssertEqual(actual, [
            LiveInterval(range: 0..<1, virtualRegisterName: "vr0", physicalRegisterName: "r0"),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr1", physicalRegisterName: "r1"),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr2", physicalRegisterName: "r2"),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr3", physicalRegisterName: "r3")
        ])
    }
    
    func testSpillOne() throws {
        let actual = LinearScanRegisterAllocator.allocate(numRegisters: 4, liveIntervals: [
            LiveInterval(range: 0..<1, virtualRegisterName: "vr0", physicalRegisterName: nil),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr1", physicalRegisterName: nil),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr2", physicalRegisterName: nil),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr3", physicalRegisterName: nil),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr4", physicalRegisterName: nil)
        ])
        XCTAssertEqual(actual, [
            LiveInterval(range: 0..<1, virtualRegisterName: "vr0", physicalRegisterName: "r0"),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr1", physicalRegisterName: "r1"),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr2", physicalRegisterName: "r2"),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr3", physicalRegisterName: "r3"),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr4", physicalRegisterName:  nil, spillSlot: 0)
        ])
    }
    
    func testOldIntervalsExpireAndFreeUpRegisters() throws {
        let actual = LinearScanRegisterAllocator.allocate(numRegisters: 4, liveIntervals: [
            LiveInterval(range: 0..<3, virtualRegisterName: "vr0", physicalRegisterName: nil),
            LiveInterval(range: 0..<3, virtualRegisterName: "vr1", physicalRegisterName: nil),
            LiveInterval(range: 0..<3, virtualRegisterName: "vr2", physicalRegisterName: nil),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr3", physicalRegisterName: nil),
            LiveInterval(range: 1..<2, virtualRegisterName: "vr4", physicalRegisterName: nil)
        ])
        XCTAssertEqual(actual, [
            LiveInterval(range: 0..<3, virtualRegisterName: "vr0", physicalRegisterName: "r0"),
            LiveInterval(range: 0..<3, virtualRegisterName: "vr1", physicalRegisterName: "r1"),
            LiveInterval(range: 0..<3, virtualRegisterName: "vr2", physicalRegisterName: "r2"),
            LiveInterval(range: 0..<1, virtualRegisterName: "vr3", physicalRegisterName: "r3"),
            LiveInterval(range: 1..<2, virtualRegisterName: "vr4", physicalRegisterName: "r3")
        ])
    }
    
    func testSpillTheIntervalWhichExpiresLast() throws {
        let actual = LinearScanRegisterAllocator.allocate(numRegisters: 4, liveIntervals: [
            LiveInterval(range: 0..<3, virtualRegisterName: "vr0", physicalRegisterName: nil),
            LiveInterval(range: 0..<3, virtualRegisterName: "vr1", physicalRegisterName: nil),
            LiveInterval(range: 0..<3, virtualRegisterName: "vr2", physicalRegisterName: nil),
            LiveInterval(range: 0..<3, virtualRegisterName: "vr3", physicalRegisterName: nil),
            LiveInterval(range: 1..<2, virtualRegisterName: "vr4", physicalRegisterName: nil)
        ])
        XCTAssertEqual(actual, [
            LiveInterval(range: 0..<3, virtualRegisterName: "vr0", physicalRegisterName: "r0"),
            LiveInterval(range: 0..<3, virtualRegisterName: "vr1", physicalRegisterName: "r1"),
            LiveInterval(range: 0..<3, virtualRegisterName: "vr2", physicalRegisterName: "r2"),
            LiveInterval(range: 0..<3, virtualRegisterName: "vr3", physicalRegisterName:  nil, spillSlot: 0),
            LiveInterval(range: 1..<2, virtualRegisterName: "vr4", physicalRegisterName: "r3")
        ])
    }
    
    func testZeroRegisters() throws {
        let actual = LinearScanRegisterAllocator.allocate(numRegisters: 0, liveIntervals: [
            LiveInterval(range: 0..<Int.max, virtualRegisterName: "vr100", physicalRegisterName: nil),
            LiveInterval(range: 0..<Int.max, virtualRegisterName: "vr101", physicalRegisterName: nil)
        ])
        XCTAssertEqual(actual, [
            LiveInterval(range: 0..<Int.max, virtualRegisterName: "vr100", physicalRegisterName: nil, spillSlot: 0),
            LiveInterval(range: 0..<Int.max, virtualRegisterName: "vr101", physicalRegisterName: nil, spillSlot: 1)
        ])
    }
}
