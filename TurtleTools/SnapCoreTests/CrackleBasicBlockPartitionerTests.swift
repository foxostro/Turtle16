//
//  CrackleBasicBlockPartitionerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 10/27/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class CrackleBasicBlockPartitionerTests: XCTestCase {
    func partition(_ instructions: [CrackleInstruction]) -> [[CrackleInstruction]] {
        let partitioner = CrackleBasicBlockPartitioner()
        partitioner.entireProgram.instructions = instructions
        partitioner.entireProgram.mapCrackleInstructionToSource = Array<SourceAnchor?>.init(repeating: nil, count: instructions.count)
        partitioner.entireProgram.mapCrackleInstructionToSymbols = Array<SymbolTable?>.init(repeating: nil, count: instructions.count)
        partitioner.partition()
        return partitioner.allBasicBlocks.map({
            $0.instructions
        })
    }
    
    func testPartitionEmptyProgram() {
        let actual = partition([])
        XCTAssertEqual(actual, [])
    }
    
    func testPartitionRunWithNoBranchesOrLeaders() {
        let actual = partition([
            .add(0, 0, 0)
        ])
        XCTAssertEqual(actual, [
            [.add(0, 0, 0)]
        ])
    }
    
    func testPartitionRunStartingWithALeaderAndHavingNoBranches() {
        let actual = partition([
            .label(""),
            .add(0, 0, 0)
        ])
        XCTAssertEqual(actual, [
            [
                .label(""),
                .add(0, 0, 0)
            ]
        ])
    }
    
    func testPartitionRunWithALeaderInTheMiddleAndHavingNoBranches() {
        let actual = partition([
            .add(0, 0, 0),
            .label(""),
            .add(1, 1, 1)
        ])
        XCTAssertEqual(actual, [
            [
                .add(0, 0, 0)
            ],
            [
                .label(""),
                .add(1, 1, 1)
            ]
        ])
    }
    
    func testPartitionRunWithUnconditionalBranch() {
        let actual = partition([
            .add(0, 0, 0),
            .label(""),
            .add(1, 1, 1),
            .jmp(""),
            .add(2, 2, 2)
        ])
        XCTAssertEqual(actual, [
            [
                .add(0, 0, 0)
            ],
            [
                .label(""),
                .add(1, 1, 1),
                .jmp("")
            ],
            [
                .add(2, 2, 2)
            ]
        ])
    }
    
    func testJalrEndsABasicBlock() {
        let actual = partition([
            .add(0, 0, 0),
            .label(""),
            .add(1, 1, 1),
            .jalr(""),
            .add(2, 2, 2)
        ])
        XCTAssertEqual(actual, [
            [
                .add(0, 0, 0)
            ],
            [
                .label(""),
                .add(1, 1, 1),
                .jalr("")
            ],
            [
                .add(2, 2, 2)
            ]
        ])
    }
    
    func testIndirectJalrEndsABasicBlock() {
        let actual = partition([
            .add(0, 0, 0),
            .label(""),
            .add(1, 1, 1),
            .indirectJalr(0),
            .add(2, 2, 2)
        ])
        XCTAssertEqual(actual, [
            [
                .add(0, 0, 0)
            ],
            [
                .label(""),
                .add(1, 1, 1),
                .indirectJalr(0)
            ],
            [
                .add(2, 2, 2)
            ]
        ])
    }
    
    func testJzEndsABasicBlock() {
        let actual = partition([
            .add(0, 0, 0),
            .label(""),
            .add(1, 1, 1),
            .jz("", 0),
            .add(2, 2, 2)
        ])
        XCTAssertEqual(actual, [
            [
                .add(0, 0, 0)
            ],
            [
                .label(""),
                .add(1, 1, 1),
                .jz("", 0)
            ],
            [
                .add(2, 2, 2)
            ]
        ])
    }
    
    func testJnzEndsABasicBlock() {
        let actual = partition([
            .add(0, 0, 0),
            .label(""),
            .add(1, 1, 1),
            .jnz("", 0),
            .add(2, 2, 2)
        ])
        XCTAssertEqual(actual, [
            [
                .add(0, 0, 0)
            ],
            [
                .label(""),
                .add(1, 1, 1),
                .jnz("", 0)
            ],
            [
                .add(2, 2, 2)
            ]
        ])
    }
    
    func testHltEndsABasicBlock() {
        let actual = partition([
            .add(0, 0, 0),
            .label(""),
            .add(1, 1, 1),
            .hlt,
            .add(2, 2, 2)
        ])
        XCTAssertEqual(actual, [
            [
                .add(0, 0, 0)
            ],
            [
                .label(""),
                .add(1, 1, 1),
                .hlt
            ],
            [
                .add(2, 2, 2)
            ]
        ])
    }
    
    func testRetEndsABasicBlock() {
        let actual = partition([
            .add(0, 0, 0),
            .label(""),
            .add(1, 1, 1),
            .ret,
            .add(2, 2, 2)
        ])
        XCTAssertEqual(actual, [
            [
                .add(0, 0, 0)
            ],
            [
                .label(""),
                .add(1, 1, 1),
                .ret
            ],
            [
                .add(2, 2, 2)
            ]
        ])
    }
    
    func testLeafRetEndsABasicBlock() {
        let actual = partition([
            .add(0, 0, 0),
            .label(""),
            .add(1, 1, 1),
            .leafRet,
            .add(2, 2, 2)
        ])
        XCTAssertEqual(actual, [
            [
                .add(0, 0, 0)
            ],
            [
                .label(""),
                .add(1, 1, 1),
                .leafRet
            ],
            [
                .add(2, 2, 2)
            ]
        ])
    }
}
