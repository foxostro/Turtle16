//
//  PopBasicBlockPartitionerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 10/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class PopBasicBlockPartitionerTests: XCTestCase {
    func partition(_ instructions: [PopInstruction]) -> [PopBasicBlock] {
        let partitioner = PopBasicBlockPartitioner()
        partitioner.entireProgram = instructions
        partitioner.partition()
        return partitioner.allBasicBlocks
    }
    
    func testPartitionEmptyProgram() {
        let actual = partition([])
        XCTAssertEqual(actual, [])
    }
    
    func testPartitionRunWithNoBranchesOrLeaders() {
        let actual = partition([
            .add(.A)
        ])
        XCTAssertEqual(actual, [
            [.add(.A)]
        ])
    }
    
    func testPartitionRunStartingWithALeaderAndHavingNoBranches() {
        let actual = partition([
            .label(""),
            .add(.A)
        ])
        XCTAssertEqual(actual, [
            [
                .label(""),
                .add(.A)
            ]
        ])
    }
    
    func testPartitionRunWithALeaderInTheMiddleAndHavingNoBranches() {
        let actual = partition([
            .add(.A),
            .label(""),
            .add(.B)
        ])
        XCTAssertEqual(actual, [
            [
                .add(.A)
            ],
            [
                .label(""),
                .add(.B)
            ]
        ])
    }
    
    func testPartitionRunWithUnconditionalBranch() {
        let actual = partition([
            .add(.A),
            .label(""),
            .add(.B),
            .jmp(""),
            .add(.C)
        ])
        XCTAssertEqual(actual, [
            [
                .add(.A)
            ],
            [
                .label(""),
                .add(.B),
                .jmp("")
            ],
            [
                .add(.C)
            ]
        ])
    }
    
    func testJalrEndsABasicBlock() {
        let actual = partition([
            .add(.A),
            .label(""),
            .add(.B),
            .jalr(""),
            .add(.C)
        ])
        XCTAssertEqual(actual, [
            [
                .add(.A)
            ],
            [
                .label(""),
                .add(.B),
                .jalr("")
            ],
            [
                .add(.C)
            ]
        ])
    }
    
    func testHltEndsABasicBlock() {
        let actual = partition([
            .add(.A),
            .label(""),
            .add(.B),
            .hlt,
            .add(.C)
        ])
        XCTAssertEqual(actual, [
            [
                .add(.A)
            ],
            [
                .label(""),
                .add(.B),
                .hlt
            ],
            [
                .add(.C)
            ]
        ])
    }
}
