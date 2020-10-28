//
//  CrackleDeadCodeEliminationOptimizationPassTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 10/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class CrackleDeadCodeEliminationOptimizationPassTests: XCTestCase {
    func optimize(_ instructions: [CrackleInstruction]) -> [CrackleInstruction] {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.unoptimizedProgram.instructions = instructions
        optimizer.unoptimizedProgram.mapCrackleInstructionToSource = Array<SourceAnchor?>.init(repeating: nil, count: instructions.count)
        optimizer.unoptimizedProgram.mapCrackleInstructionToSymbols = Array<SymbolTable?>.init(repeating: nil, count: instructions.count)
        optimizer.optimize()
        return optimizer.optimizedProgram.instructions
    }
    
    func testOptimizeEmptyBasicBlock() {
        let actual = optimize([])
        XCTAssertEqual(actual, [])
    }
    
    func testInstructionIsUnmodifiedIfWeCannotImproveIt() {
        let actual = optimize([
            .nop
        ])
        XCTAssertEqual(actual, [
            .nop
        ])
    }
    
    func testIfWeOverwriteMemoryWithoutUsingTheOlderValueThenDiscardTheEarlierStore() {
        let actual = optimize([
            .storeImmediate(0x1000, 0xab),
            .storeImmediate(0x1000, 0xcd)
        ])
        XCTAssertEqual(actual, [
            .nop,
            .storeImmediate(0x1000, 0xcd)
        ])
    }
    
    func testMeasureMemoryImpact_subi16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.memory[0x2000] = .dirty
        optimizer.memory[0x2001] = .dirty
        optimizer.updateStateOfMemory(.subi16(0x1000, 0x2000, 1))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
        XCTAssertEqual(optimizer.memory[0x2000], .clean)
        XCTAssertEqual(optimizer.memory[0x2001], .clean)
    }
    
    func testMeasureMemoryImpact_addi16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.memory[0x2000] = .dirty
        optimizer.memory[0x2001] = .dirty
        optimizer.updateStateOfMemory(.addi16(0x1000, 0x2000, 1))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
        XCTAssertEqual(optimizer.memory[0x2000], .clean)
        XCTAssertEqual(optimizer.memory[0x2001], .clean)
    }
    
    func testMeasureMemoryImpact_muli16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.memory[0x2000] = .dirty
        optimizer.memory[0x2001] = .dirty
        optimizer.updateStateOfMemory(.muli16(0x1000, 0x2000, 1))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
        XCTAssertEqual(optimizer.memory[0x2000], .clean)
        XCTAssertEqual(optimizer.memory[0x2001], .clean)
    }
    
    func testMeasureMemoryImpact_storeImmediate() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.updateStateOfMemory(.storeImmediate(0x1000, 0))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
    }
    
    func testMeasureMemoryImpact_storeImmediate16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.updateStateOfMemory(.storeImmediate16(0x1000, 0))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
    }
    
    func testMeasureMemoryImpact_storeImmediateBytes() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.updateStateOfMemory(.storeImmediateBytes(0x1000, [0,0]))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
    }
    
    func testMeasureMemoryImpact_storeImmediateBytesIndirect() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .dirty
        optimizer.memory[0x1001] = .dirty
        optimizer.updateStateOfMemory(.storeImmediateBytesIndirect(0x1000, [2]))
        XCTAssertTrue(optimizer.memory.allSatisfy {
            return $0 == .clean
        })
    }
    
    func testMeasureMemoryImpact_add() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .dirty
        optimizer.memory[0x1002] = .dirty
        optimizer.updateStateOfMemory(.add(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .clean)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
    }
    
    func testMeasureMemoryImpact_add16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.memory[0x1005] = .dirty
        optimizer.updateStateOfMemory(.add16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
        XCTAssertEqual(optimizer.memory[0x1005], .clean)
    }
    
    func testMeasureMemoryImpact_sub() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .dirty
        optimizer.memory[0x1002] = .dirty
        optimizer.updateStateOfMemory(.sub(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .clean)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
    }
    
    func testMeasureMemoryImpact_sub16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.memory[0x1005] = .dirty
        optimizer.updateStateOfMemory(.sub16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
        XCTAssertEqual(optimizer.memory[0x1005], .clean)
    }
    
    func testMeasureMemoryImpact_mul() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .dirty
        optimizer.memory[0x1002] = .dirty
        optimizer.updateStateOfMemory(.mul(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .clean)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
    }
    
    func testMeasureMemoryImpact_mul16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.memory[0x1005] = .dirty
        optimizer.updateStateOfMemory(.mul16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
        XCTAssertEqual(optimizer.memory[0x1005], .clean)
    }
    
    func testMeasureMemoryImpact_div() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .dirty
        optimizer.memory[0x1002] = .dirty
        optimizer.updateStateOfMemory(.div(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .clean)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
    }
    
    func testMeasureMemoryImpact_div16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.memory[0x1005] = .dirty
        optimizer.updateStateOfMemory(.div16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
        XCTAssertEqual(optimizer.memory[0x1005], .clean)
    }
    
    func testMeasureMemoryImpact_mod() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .dirty
        optimizer.memory[0x1002] = .dirty
        optimizer.updateStateOfMemory(.mod(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .clean)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
    }
    
    func testMeasureMemoryImpact_mod16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.memory[0x1005] = .dirty
        optimizer.updateStateOfMemory(.mod16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
        XCTAssertEqual(optimizer.memory[0x1005], .clean)
    }
    
    func testMeasureMemoryImpact_eq() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.updateStateOfMemory(.eq(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
    }
    
    func testMeasureMemoryImpact_eq16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.memory[0x1005] = .dirty
        optimizer.updateStateOfMemory(.eq16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
        XCTAssertEqual(optimizer.memory[0x1005], .clean)
    }
    
    func testMeasureMemoryImpact_ne() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.updateStateOfMemory(.ne(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
    }
    
    func testMeasureMemoryImpact_ne16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.memory[0x1005] = .dirty
        optimizer.updateStateOfMemory(.ne16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
        XCTAssertEqual(optimizer.memory[0x1005], .clean)
    }
    
    func testMeasureMemoryImpact_lt() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.updateStateOfMemory(.lt(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
    }
    
    func testMeasureMemoryImpact_lt16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.memory[0x1005] = .dirty
        optimizer.updateStateOfMemory(.lt16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
        XCTAssertEqual(optimizer.memory[0x1005], .clean)
    }
    
    func testMeasureMemoryImpact_gt() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.updateStateOfMemory(.gt(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
    }
    
    func testMeasureMemoryImpact_gt16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.memory[0x1005] = .dirty
        optimizer.updateStateOfMemory(.gt16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
        XCTAssertEqual(optimizer.memory[0x1005], .clean)
    }
    
    func testMeasureMemoryImpact_le() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.updateStateOfMemory(.le(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
    }
    
    func testMeasureMemoryImpact_le16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.memory[0x1005] = .dirty
        optimizer.updateStateOfMemory(.le16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
        XCTAssertEqual(optimizer.memory[0x1005], .clean)
    }
    
    func testMeasureMemoryImpact_ge() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.updateStateOfMemory(.ge(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
    }
    
    func testMeasureMemoryImpact_ge16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.memory[0x1005] = .dirty
        optimizer.updateStateOfMemory(.ge16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
        XCTAssertEqual(optimizer.memory[0x1005], .clean)
    }
    
    func testMeasureMemoryImpact_and() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.updateStateOfMemory(.and(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .clean)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
    }
    
    func testMeasureMemoryImpact_and16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.memory[0x1005] = .dirty
        optimizer.updateStateOfMemory(.and16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
        XCTAssertEqual(optimizer.memory[0x1005], .clean)
    }
    
    func testMeasureMemoryImpact_or() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.updateStateOfMemory(.or(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .clean)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
    }
    
    func testMeasureMemoryImpact_or16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.memory[0x1005] = .dirty
        optimizer.updateStateOfMemory(.or16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
        XCTAssertEqual(optimizer.memory[0x1005], .clean)
    }
    
    func testMeasureMemoryImpact_xor() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.updateStateOfMemory(.xor(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .clean)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
    }
    
    func testMeasureMemoryImpact_xor16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.memory[0x1005] = .dirty
        optimizer.updateStateOfMemory(.xor16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
        XCTAssertEqual(optimizer.memory[0x1005], .clean)
    }
    
    func testMeasureMemoryImpact_lsl() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.updateStateOfMemory(.lsl(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .clean)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
    }
    
    func testMeasureMemoryImpact_lsl16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.memory[0x1005] = .dirty
        optimizer.updateStateOfMemory(.lsl16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
        XCTAssertEqual(optimizer.memory[0x1005], .clean)
    }
    
    func testMeasureMemoryImpact_lsr() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.updateStateOfMemory(.lsr(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .clean)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
    }
    
    func testMeasureMemoryImpact_lsr16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.memory[0x1004] = .dirty
        optimizer.memory[0x1005] = .dirty
        optimizer.updateStateOfMemory(.lsr16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
        XCTAssertEqual(optimizer.memory[0x1004], .clean)
        XCTAssertEqual(optimizer.memory[0x1005], .clean)
    }
    
    func testMeasureMemoryImpact_neg() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.updateStateOfMemory(.neg(0x1000, 0x1002))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
    }
    
    func testMeasureMemoryImpact_neg16() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.updateStateOfMemory(.neg16(0x1000, 0x1002))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
    }
    
    func testMeasureMemoryImpact_not() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.updateStateOfMemory(.not(0x1000, 0x1002))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
    }
    
    func testMeasureMemoryImpact_copyWordZeroExtend() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.updateStateOfMemory(.copyWordZeroExtend(0x1000, 0x1002))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
    }
    
    func testMeasureMemoryImpact_copyWords() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.memory[0x1002] = .dirty
        optimizer.memory[0x1003] = .dirty
        optimizer.updateStateOfMemory(.copyWords(0x1000, 0x1002, 2))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
        XCTAssertEqual(optimizer.memory[0x1002], .clean)
        XCTAssertEqual(optimizer.memory[0x1003], .clean)
    }
    
    func testMeasureMemoryImpact_copyWordsIndirectSource() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.updateStateOfMemory(.copyWordsIndirectSource(0x1000, 0x1002, 2))
        XCTAssertTrue(optimizer.memory.allSatisfy {
            return $0 == .clean
        })
    }
    
    func testMeasureMemoryImpact_copyWordsIndirectDestination() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .dirty
        optimizer.memory[0x1001] = .dirty
        optimizer.updateStateOfMemory(.copyWordsIndirectDestination(0x1000, 0x1002, 2))
        XCTAssertTrue(optimizer.memory.allSatisfy {
            return $0 == .clean
        })
    }
    
    func testMeasureMemoryImpact_copyWordsIndirectDestinationIndirectSource() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .dirty
        optimizer.memory[0x1001] = .dirty
        optimizer.updateStateOfMemory(.copyWordsIndirectDestinationIndirectSource(0x1000, 0x1002, 2))
        XCTAssertTrue(optimizer.memory.allSatisfy {
            return $0 == .clean
        })
    }
    
    func testMeasureMemoryImpact_copyLabel() {
        let optimizer = CrackleDeadCodeEliminationOptimizationPass()
        optimizer.memory[0x1000] = .clean
        optimizer.memory[0x1001] = .clean
        optimizer.updateStateOfMemory(.copyLabel(0x1000, ""))
        XCTAssertEqual(optimizer.memory[0x1000], .dirty)
        XCTAssertEqual(optimizer.memory[0x1001], .dirty)
    }
}
