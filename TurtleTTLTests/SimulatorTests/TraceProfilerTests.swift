//
//  TraceProfilerTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class TraceProfilerTests: XCTestCase {
    func testZeroHits() {
        let profiler = TraceProfiler()
        XCTAssertEqual(profiler.hits[0], nil)
        XCTAssertFalse(profiler.isHot(pc: 0))
    }
    
    func testFirstHit() {
        let profiler = TraceProfiler()
        XCTAssertFalse(profiler.hit(pc: 0))
        XCTAssertEqual(profiler.hits[0], Optional(1))
        XCTAssertFalse(profiler.isHot(pc: 0))
    }
    
    func testSecondHit() {
        let profiler = TraceProfiler()
        XCTAssertFalse(profiler.hit(pc: 0))
        XCTAssertFalse(profiler.hit(pc: 0))
        XCTAssertEqual(profiler.hits[0], Optional(2))
        XCTAssertFalse(profiler.isHot(pc: 0))
    }
    
    func testThirdHit() {
        let profiler = TraceProfiler()
        XCTAssertFalse(profiler.hit(pc: 0))
        XCTAssertFalse(profiler.hit(pc: 0))
        XCTAssertTrue(profiler.hit(pc: 0))
        XCTAssertEqual(profiler.hits[0], Optional(3))
        XCTAssertTrue(profiler.isHot(pc: 0))
    }
    
    func testReset() {
        let profiler = TraceProfiler()
        XCTAssertFalse(profiler.hit(pc: 0))
        XCTAssertFalse(profiler.hit(pc: 0))
        XCTAssertTrue(profiler.hit(pc: 0))
        profiler.reset()
        XCTAssertEqual(profiler.hits[0], nil)
        XCTAssertFalse(profiler.isHot(pc: 0))
    }
}
