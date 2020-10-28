//
//  CrackleConstantPropagationOptimizationPassTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 10/26/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

class CrackleConstantPropagationOptimizationPassTests: XCTestCase {
    func optimize(_ instructions: [CrackleInstruction]) -> [CrackleInstruction] {
        let optimizer = CrackleConstantPropagationOptimizationPass()
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
    
    func testIfWeKnowAMemoryAddressContainsAValueThenDontSetItAgain() {
        let actual = optimize([
            .storeImmediate(0x1000, 0xff),
            .storeImmediate(0x1000, 0xff)
        ])
        XCTAssertEqual(actual, [
            .storeImmediate(0x1000, 0xff),
            .nop
        ])
    }
    
    func testSubi16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let _ = local.rewrite(.subi16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
    }
    
    func testSubi16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0x01
        local.memory[0x1003] = 0x00
        let optimized = local.rewrite(.subi16(0x1000, 0x1002, 1))
        XCTAssertEqual(optimized, .storeImmediate16(0x1000, 0x00ff))
        XCTAssertEqual(local.memory[0x1000], 0x00)
        XCTAssertEqual(local.memory[0x1001], 0xff)
    }
    
    func testSubi16_SometimesWeOptimizeItAwayEntirely() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0x00
        local.memory[0x1001] = 0xff
        local.memory[0x1002] = 0x01
        local.memory[0x1003] = 0x00
        let optimized = local.rewrite(.subi16(0x1000, 0x1002, 1))
        XCTAssertEqual(optimized, .nop)
        XCTAssertEqual(local.memory[0x1000], 0x00)
        XCTAssertEqual(local.memory[0x1001], 0xff)
    }
    
    func testAddi16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let _ = local.rewrite(.addi16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
    }
    
    func testAddi16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0x01
        local.memory[0x1003] = 0x00
        let optimized = local.rewrite(.addi16(0x1000, 0x1002, 1))
        XCTAssertEqual(optimized, .storeImmediate16(0x1000, 0x0101))
        XCTAssertEqual(local.memory[0x1000], 0x01)
        XCTAssertEqual(local.memory[0x1001], 0x01)
    }
    
    func testMuli16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let _ = local.rewrite(.muli16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
    }
    
    func testMuli16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0x01
        local.memory[0x1003] = 0x00
        let optimized = local.rewrite(.muli16(0x1000, 0x1002, 2))
        XCTAssertEqual(optimized, .storeImmediate16(0x1000, 0x0200))
        XCTAssertEqual(local.memory[0x1000], 0x02)
        XCTAssertEqual(local.memory[0x1001], 0x00)
    }
    
    func testStoreImmediateSetsMemoryToAKnownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        let _ = local.rewrite(.storeImmediate(0x1000, 0xff))
        XCTAssertEqual(local.memory[0x1000], 0xff)
    }
    
    func testStoreImmediate16SetsMemoryToAKnownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        let _ = local.rewrite(.storeImmediate16(0x1000, 0xabcd))
        XCTAssertEqual(local.memory[0x1000], 0xab)
        XCTAssertEqual(local.memory[0x1001], 0xcd)
    }
    
    func testStoreImmediateBytesSetsMemoryToAKnownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        let _ = local.rewrite(.storeImmediateBytes(0x1000, [0xab, 0xcd, 0xef]))
        XCTAssertEqual(local.memory[0x1000], 0xab)
        XCTAssertEqual(local.memory[0x1001], 0xcd)
        XCTAssertEqual(local.memory[0x1002], 0xef)
    }
    
    func testStoreImmediateBytesMayBeCompiledAwayIfTheBytesAreAlreadyThere() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        local.memory[0x1002] = 0xef
        let optimized = local.rewrite(.storeImmediateBytes(0x1000, [0xab, 0xcd, 0xef]))
        XCTAssertEqual(optimized, .nop)
        XCTAssertEqual(local.memory[0x1000], 0xab)
        XCTAssertEqual(local.memory[0x1001], 0xcd)
        XCTAssertEqual(local.memory[0x1002], 0xef)
    }
    
    func testAddSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.add(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testAdd_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x01
        local.memory[0x1002] = 0x02
        let optimized = local.rewrite(.add(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x03))
        XCTAssertEqual(local.memory[0x1000], 0x03)
    }
    
    func testSubSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.sub(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testSub_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x02
        local.memory[0x1002] = 0x01
        let optimized = local.rewrite(.sub(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x01))
        XCTAssertEqual(local.memory[0x1000], 0x01)
    }
    
    func testMulSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.mul(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testMul_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x02
        local.memory[0x1002] = 0x02
        let optimized = local.rewrite(.mul(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x04))
        XCTAssertEqual(local.memory[0x1000], 0x04)
    }
    
    func testDivSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.div(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testDiv_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x02
        local.memory[0x1002] = 0x02
        let optimized = local.rewrite(.div(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x01))
        XCTAssertEqual(local.memory[0x1000], 0x01)
    }
    
    func testModSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.mod(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testMod_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x04
        local.memory[0x1002] = 0x02
        let optimized = local.rewrite(.mod(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x00))
        XCTAssertEqual(local.memory[0x1000], 0x00)
    }
    
    func testEqSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.eq(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testEq_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x02
        local.memory[0x1002] = 0x02
        let optimized = local.rewrite(.eq(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x01))
        XCTAssertEqual(local.memory[0x1000], 0x01)
    }
    
    func testEq16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.eq16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testEq16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0xff
        local.memory[0x1003] = 0xff
        local.memory[0x1004] = 0xff
        local.memory[0x1005] = 0xff
        let optimized = local.rewrite(.eq16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x01))
        XCTAssertEqual(local.memory[0x1000], 0x01)
    }
    
    func testNeSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.ne(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testNe_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x02
        local.memory[0x1002] = 0x02
        let optimized = local.rewrite(.ne(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x00))
        XCTAssertEqual(local.memory[0x1000], 0x00)
    }
    
    func testNe16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.ne16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testNe16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0xff
        local.memory[0x1003] = 0xff
        local.memory[0x1004] = 0xff
        local.memory[0x1005] = 0xff
        let optimized = local.rewrite(.ne16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x00))
        XCTAssertEqual(local.memory[0x1000], 0x00)
    }
    
    func testLtSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.lt(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testLt_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x01
        local.memory[0x1002] = 0x02
        let optimized = local.rewrite(.lt(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x01))
        XCTAssertEqual(local.memory[0x1000], 0x01)
    }
    
    func testLt16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.lt16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testLt16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0x00
        local.memory[0x1003] = 0x00
        local.memory[0x1004] = 0xff
        local.memory[0x1005] = 0xff
        let optimized = local.rewrite(.lt16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x01))
        XCTAssertEqual(local.memory[0x1000], 0x01)
    }
    
    func testGtSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.gt(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testGt_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x01
        local.memory[0x1002] = 0x02
        let optimized = local.rewrite(.gt(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x00))
        XCTAssertEqual(local.memory[0x1000], 0x00)
    }
    
    func testGt16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.gt16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testGt16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0x00
        local.memory[0x1003] = 0x00
        local.memory[0x1004] = 0xff
        local.memory[0x1005] = 0xff
        let optimized = local.rewrite(.gt16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x00))
        XCTAssertEqual(local.memory[0x1000], 0x00)
    }
    
    func testLeSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.le(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testLe_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x01
        local.memory[0x1002] = 0x02
        let optimized = local.rewrite(.le(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x01))
        XCTAssertEqual(local.memory[0x1000], 0x01)
    }
    
    func testLe16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.le16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testLe16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0x00
        local.memory[0x1003] = 0x00
        local.memory[0x1004] = 0xff
        local.memory[0x1005] = 0xff
        let optimized = local.rewrite(.le16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x01))
        XCTAssertEqual(local.memory[0x1000], 0x01)
    }
    
    func testGeSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.ge(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testGe_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x01
        local.memory[0x1002] = 0x02
        let optimized = local.rewrite(.ge(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x00))
        XCTAssertEqual(local.memory[0x1000], 0x00)
    }
    
    func testGe16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.ge16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testGe16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0x00
        local.memory[0x1003] = 0x00
        local.memory[0x1004] = 0xff
        local.memory[0x1005] = 0xff
        let optimized = local.rewrite(.ge16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x00))
        XCTAssertEqual(local.memory[0x1000], 0x00)
    }
    
    func testAndSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.and(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testAnd_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x03
        local.memory[0x1002] = 0x01
        let optimized = local.rewrite(.and(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x01))
        XCTAssertEqual(local.memory[0x1000], 0x01)
    }
    
    func testOrSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.or(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testOr_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x02
        local.memory[0x1002] = 0x01
        let optimized = local.rewrite(.or(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x03))
        XCTAssertEqual(local.memory[0x1000], 0x03)
    }
    
    func testXorSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.xor(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testXor_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x02
        local.memory[0x1002] = 0x02
        let optimized = local.rewrite(.xor(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x00))
        XCTAssertEqual(local.memory[0x1000], 0x00)
    }
    
    func testLslSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.lsl(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testLsl_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x01
        local.memory[0x1002] = 0x02
        let optimized = local.rewrite(.lsl(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x04))
        XCTAssertEqual(local.memory[0x1000], 0x04)
    }
    
    func testLsrSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.lsr(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testLsr_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x04
        local.memory[0x1002] = 0x02
        let optimized = local.rewrite(.lsr(0x1000, 0x1001, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x01))
        XCTAssertEqual(local.memory[0x1000], 0x01)
    }
    
    func testNegSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.neg(0x1000, 0x1002))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testNeg_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x00
        let optimized = local.rewrite(.neg(0x1000, 0x1001))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0xff))
        XCTAssertEqual(local.memory[0x1000], 0xff)
    }
    
    func testNotSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        let _ = local.rewrite(.not(0x1000, 0x1002))
        XCTAssertEqual(local.memory[0x1000], nil)
    }
    
    func testNot_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1001] = 0x01
        let optimized = local.rewrite(.not(0x1000, 0x1001))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x00))
        XCTAssertEqual(local.memory[0x1000], 0x00)
    }
    
    func testAdd16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let _ = local.rewrite(.add16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
    }
    
    func testAdd16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0x00
        local.memory[0x1003] = 0xff
        local.memory[0x1004] = 0x00
        local.memory[0x1005] = 0x01
        let optimized = local.rewrite(.add16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimized, .storeImmediate16(0x1000, 0x0100))
        XCTAssertEqual(local.memory[0x1000], 0x01)
        XCTAssertEqual(local.memory[0x1001], 0x00)
    }
    
    func testSub16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let _ = local.rewrite(.sub16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
    }
    
    func testSub16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0x01
        local.memory[0x1003] = 0x00
        local.memory[0x1004] = 0x00
        local.memory[0x1005] = 0x01
        let optimized = local.rewrite(.sub16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimized, .storeImmediate16(0x1000, 0x00ff))
        XCTAssertEqual(local.memory[0x1000], 0x00)
        XCTAssertEqual(local.memory[0x1001], 0xff)
    }
    
    func testMul16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let _ = local.rewrite(.mul16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
    }
    
    func testMul16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0x01
        local.memory[0x1003] = 0x00
        local.memory[0x1004] = 0x00
        local.memory[0x1005] = 0x02
        let optimized = local.rewrite(.mul16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimized, .storeImmediate16(0x1000, 0x0200))
        XCTAssertEqual(local.memory[0x1000], 0x02)
        XCTAssertEqual(local.memory[0x1001], 0x00)
    }
    
    func testDiv16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let _ = local.rewrite(.div16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
    }
    
    func testDiv16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0x02
        local.memory[0x1003] = 0x00
        local.memory[0x1004] = 0x00
        local.memory[0x1005] = 0x02
        let optimized = local.rewrite(.div16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimized, .storeImmediate16(0x1000, 0x0100))
        XCTAssertEqual(local.memory[0x1000], 0x01)
        XCTAssertEqual(local.memory[0x1001], 0x00)
    }
    
    func testMod16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let _ = local.rewrite(.mod16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
    }
    
    func testMod16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0x01
        local.memory[0x1003] = 0x00
        local.memory[0x1004] = 0x00
        local.memory[0x1005] = 0x02
        let optimized = local.rewrite(.mod16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimized, .storeImmediate16(0x1000, 0x0000))
        XCTAssertEqual(local.memory[0x1000], 0x00)
        XCTAssertEqual(local.memory[0x1001], 0x00)
    }
    
    func testAnd16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let _ = local.rewrite(.and16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
    }
    
    func testAnd16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0b10101010
        local.memory[0x1003] = 0b10101010
        local.memory[0x1004] = 0b11001100
        local.memory[0x1005] = 0b11001100
        let optimized = local.rewrite(.and16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimized, .storeImmediate16(0x1000, 0b1000100010001000))
        XCTAssertEqual(local.memory[0x1000], 0b10001000)
        XCTAssertEqual(local.memory[0x1001], 0b10001000)
    }
    
    func testOr16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let _ = local.rewrite(.or16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
    }
    
    func testOr16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0b10101010
        local.memory[0x1003] = 0b10101010
        local.memory[0x1004] = 0b11001100
        local.memory[0x1005] = 0b11001100
        let optimized = local.rewrite(.or16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimized, .storeImmediate16(0x1000, 0b1110111011101110))
        XCTAssertEqual(local.memory[0x1000], 0b11101110)
        XCTAssertEqual(local.memory[0x1001], 0b11101110)
    }
    
    func testXor16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let _ = local.rewrite(.xor16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
    }
    
    func testXor16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0b10101010
        local.memory[0x1003] = 0b10101010
        local.memory[0x1004] = 0b11001100
        local.memory[0x1005] = 0b11001100
        let optimized = local.rewrite(.xor16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimized, .storeImmediate16(0x1000, 0b0110011001100110))
        XCTAssertEqual(local.memory[0x1000], 0b01100110)
        XCTAssertEqual(local.memory[0x1001], 0b01100110)
    }
    
    func testLsl16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let _ = local.rewrite(.lsl16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
    }
    
    func testLsl16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0x01
        local.memory[0x1003] = 0x00
        local.memory[0x1004] = 0x00
        local.memory[0x1005] = 0x01
        let optimized = local.rewrite(.lsl16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimized, .storeImmediate16(0x1000, 0x0200))
        XCTAssertEqual(local.memory[0x1000], 0x02)
        XCTAssertEqual(local.memory[0x1001], 0x00)
    }
    
    func testLsr16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let _ = local.rewrite(.lsr16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
    }
    
    func testLsr16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0x02
        local.memory[0x1003] = 0x00
        local.memory[0x1004] = 0x00
        local.memory[0x1005] = 0x01
        let optimized = local.rewrite(.lsr16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(optimized, .storeImmediate16(0x1000, 0x0100))
        XCTAssertEqual(local.memory[0x1000], 0x01)
        XCTAssertEqual(local.memory[0x1001], 0x00)
    }
    
    func testNeg16SetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let _ = local.rewrite(.neg16(0x1000, 0x1002))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
    }
    
    func testNeg16_SometimesWeCanKnowTheResultStatically() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1002] = 0xff
        local.memory[0x1003] = 0xff
        let optimized = local.rewrite(.neg16(0x1000, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate16(0x1000, 0))
        XCTAssertEqual(local.memory[0x1000], 0)
        XCTAssertEqual(local.memory[0x1001], 0)
    }
    
    func testCopyWordZeroExtendSetsHighByteToZeroAndLowByteMayBeUnknown() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let _ = local.rewrite(.copyWordZeroExtend(0x1000, 0x1002))
        XCTAssertEqual(local.memory[0x1000], 0)
        XCTAssertEqual(local.memory[0x1001], nil)
    }
    
    func testCopyWordZeroExtendSetsHighByteToZeroAndWeMightKnowTheValueOfTheLowByte() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        local.memory[0x1002] = 0xef
        let _ = local.rewrite(.copyWordZeroExtend(0x1000, 0x1002))
        XCTAssertEqual(local.memory[0x1000], 0x00)
        XCTAssertEqual(local.memory[0x1001], 0xef)
    }
    
    func testCopyWordZeroExtendMayBeCompiledAwayIfWeKnowTheValueIsAlreadyThere() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0x00
        local.memory[0x1001] = 0xff
        local.memory[0x1002] = 0xff
        let optimized = local.rewrite(.copyWordZeroExtend(0x1000, 0x1002))
        XCTAssertEqual(optimized, .nop)
    }
    
    func testCopyWordZeroExtendWillBeReplacedIfHighByteIsAlreadyThere() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0x00
        local.memory[0x1001] = nil
        local.memory[0x1002] = 0xff
        let optimized = local.rewrite(.copyWordZeroExtend(0x1000, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1001, 0xff))
    }
    
    func testCopyWordZeroExtendWillBeReplacedIfLowByteIsAlreadyThere() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = nil
        local.memory[0x1001] = 0xff
        local.memory[0x1002] = 0xff
        let optimized = local.rewrite(.copyWordZeroExtend(0x1000, 0x1002))
        XCTAssertEqual(optimized, .storeImmediate(0x1000, 0x00))
    }
    
    func testCopyWordsMayMakeARangeOfMemoryHaveUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        local.memory[0x1002] = 0xef
        local.memory[0x1003] = 0x12
        let _ = local.rewrite(.copyWords(0x1000, 0x2000, 3))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
        XCTAssertEqual(local.memory[0x1002], nil)
        XCTAssertEqual(local.memory[0x1003], 0x12)
    }
    
    func testCopyWordsMayBeRemovedIfTheValueIsAlreadyPresent() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        local.memory[0x1002] = 0xef
        local.memory[0x2000] = 0xab
        local.memory[0x2001] = 0xcd
        local.memory[0x2002] = 0xef
        let optimized = local.rewrite(.copyWords(0x1000, 0x2000, 3))
        XCTAssertEqual(optimized, .nop)
    }
    
    func testCopyWordsIndirectSourceMayMakeARangeOfMemoryHaveUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        local.memory[0x1002] = 0xef
        local.memory[0x1003] = 0x12
        let _ = local.rewrite(.copyWordsIndirectSource(0x1000, 0x2000, 3))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
        XCTAssertEqual(local.memory[0x1002], nil)
        XCTAssertEqual(local.memory[0x1003], 0x12)
    }
    
    func testCopyWordsIndirectSourceMayBeRewrittenIfWeCanDetermineTheSourceAddress() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x2000] = 0x10
        local.memory[0x2001] = 0x04
        let optimized = local.rewrite(.copyWordsIndirectSource(0x1000, 0x2000, 3))
        XCTAssertEqual(optimized, .copyWords(0x1000, 0x1004, 3))
    }
    
    func testCopyWordsIndirectDestinationMayInvalidateAllOfMemoryIfWeCannotDetermineTheDestinationAddress() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x2000] = 0xab
        local.memory[0x2001] = 0xcd
        let _ = local.rewrite(.copyWordsIndirectDestination(0x3000, 0x2000, 3))
        XCTAssertTrue(local.memory.allSatisfy({$0 == nil}))
    }
    
    func testCopyWordsIndirectDestinationMayBeRewrittenIfWeCanDetermineTheDestinationAddress() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x3000] = 0xab
        local.memory[0x3001] = 0xcd
        let optimized = local.rewrite(.copyWordsIndirectDestination(0x3000, 0x2000, 3))
        XCTAssertEqual(optimized, .copyWords(0xabcd, 0x2000, 3))
    }
    
    func testCopyWordsIDISMayInvalidateAllOfMemoryIfWeCannotDetermineTheDestinationAddress() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x2000] = 0xab
        local.memory[0x2001] = 0xcd
        let _ = local.rewrite(.copyWordsIndirectDestinationIndirectSource(0x3000, 0x2000, 3))
        XCTAssertTrue(local.memory.allSatisfy({$0 == nil}))
    }
    
    func testCopyWordsIDISMayBeRewrittenIfWeCanDetermineTheSourceAddress() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x2000] = 0x10
        local.memory[0x2001] = 0x04
        let optimized = local.rewrite(.copyWordsIndirectDestinationIndirectSource(0x1000, 0x2000, 3))
        XCTAssertEqual(optimized, .copyWordsIndirectDestination(0x1000, 0x1004, 3))
    }
    
    func testCopyWordsIDISMayBeRewrittenIfWeCanDetermineTheDestinationAddress() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let optimized = local.rewrite(.copyWordsIndirectDestinationIndirectSource(0x1000, 0x2000, 3))
        XCTAssertEqual(optimized, .copyWordsIndirectSource(0xabcd, 0x2000, 3))
    }
    
    func testCopyLabelSetsMemoryToAnUnknownValue() {
        let local = CrackleConstantPropagationOptimizationPass()
        local.memory[0x1000] = 0xab
        local.memory[0x1001] = 0xcd
        let _ = local.rewrite(.add16(0x1000, 0x1002, 0x1004))
        XCTAssertEqual(local.memory[0x1000], nil)
        XCTAssertEqual(local.memory[0x1001], nil)
    }
}
