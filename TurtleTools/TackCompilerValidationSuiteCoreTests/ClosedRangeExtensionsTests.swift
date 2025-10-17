//
//  ClosedRangeExtensionsTests.swift
//  TackCompilerValidationSuiteCoreTests
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

@testable import TackCompilerValidationSuiteCore
import Testing

/// Unit tests for ClosedRange extension methods
struct ClosedRangeExtensionsTests {
    // MARK: - converted(to:) Tests

    // MARK: Basic Conversions

    @Test func convertInt64ToInt32_Success() {
        let range: ClosedRange<Int64> = 10...20
        let converted = range.converted(to: Int32.self)
        #expect(converted == 10...20)
    }

    @Test func convertInt32ToInt64_Success() {
        let range: ClosedRange<Int32> = 10...20
        let converted = range.converted(to: Int64.self)
        #expect(converted == 10...20)
    }

    @Test func convertInt64ToInt16_Success() {
        let range: ClosedRange<Int64> = 100...200
        let converted = range.converted(to: Int16.self)
        #expect(converted == 100...200)
    }

    @Test func convertInt8ToInt64_Success() {
        let range: ClosedRange<Int8> = -10...10
        let converted = range.converted(to: Int64.self)
        #expect(converted == -10...10)
    }

    @Test func convertUInt64ToUInt32_Success() {
        let range: ClosedRange<UInt64> = 100...200
        let converted = range.converted(to: UInt32.self)
        #expect(converted == 100...200)
    }

    @Test func convertUInt32ToUInt64_Success() {
        let range: ClosedRange<UInt32> = 100...200
        let converted = range.converted(to: UInt64.self)
        #expect(converted == 100...200)
    }

    // MARK: Signed to Unsigned Conversions

    @Test func convertNonNegativeInt64ToUInt32_Success() {
        let range: ClosedRange<Int64> = 0...100
        let converted = range.converted(to: UInt32.self)
        #expect(converted == 0...100)
    }

    @Test func convertNegativeInt64ToUInt32_Failure() {
        let range: ClosedRange<Int64> = -10...10
        let converted = range.converted(to: UInt32.self)
        #expect(converted == nil)
    }

    @Test func convertNegativeLowerBoundToUnsigned_Failure() {
        let range: ClosedRange<Int64> = -1...100
        let converted = range.converted(to: UInt64.self)
        #expect(converted == nil)
    }

    // MARK: Unsigned to Signed Conversions

    @Test func convertSmallUInt64ToInt32_Success() {
        let range: ClosedRange<UInt64> = 0...1000
        let converted = range.converted(to: Int32.self)
        #expect(converted == 0...1000)
    }

    @Test func convertLargeUInt64ToInt32_Failure() {
        let range: ClosedRange<UInt64> = 0...(UInt64(Int32.max) + 1)
        let converted = range.converted(to: Int32.self)
        #expect(converted == nil)
    }

    // MARK: Overflow Tests

    @Test func convertInt64OverflowingInt32_Failure() {
        let range: ClosedRange<Int64> = Int64(Int32.max) + 1...Int64(Int32.max) + 100
        let converted = range.converted(to: Int32.self)
        #expect(converted == nil)
    }

    @Test func convertInt64UnderflowingInt32_Failure() {
        let range: ClosedRange<Int64> = Int64(Int32.min) - 100...Int64(Int32.min) - 1
        let converted = range.converted(to: Int32.self)
        #expect(converted == nil)
    }

    @Test func convertLowerBoundOverflows_Failure() {
        let range: ClosedRange<Int64> = Int64(Int32.max) + 1...Int64(Int32.max) + 2
        let converted = range.converted(to: Int32.self)
        #expect(converted == nil)
    }

    @Test func convertUpperBoundOverflows_Failure() {
        let range: ClosedRange<Int64> = 0...Int64(Int32.max) + 1
        let converted = range.converted(to: Int32.self)
        #expect(converted == nil)
    }

    @Test func convertUInt64OverflowingUInt32_Failure() {
        let range: ClosedRange<UInt64> = (UInt64(UInt32.max) + 1)...(UInt64(UInt32.max) + 100)
        let converted = range.converted(to: UInt32.self)
        #expect(converted == nil)
    }

    // MARK: Boundary Value Tests

    @Test func convertInt32MaxRange() {
        let range: ClosedRange<Int64> = Int64(Int32.min)...Int64(Int32.max)
        let converted = range.converted(to: Int32.self)
        #expect(converted == Int32.min...Int32.max)
    }

    @Test func convertUInt32MaxRange() {
        let range: ClosedRange<UInt64> = UInt64(UInt32.min)...UInt64(UInt32.max)
        let converted = range.converted(to: UInt32.self)
        #expect(converted == UInt32.min...UInt32.max)
    }

    @Test func convertInt16MaxToInt32() {
        let range: ClosedRange<Int32> = Int32(Int16.min)...Int32(Int16.max)
        let converted = range.converted(to: Int16.self)
        #expect(converted == Int16.min...Int16.max)
    }

    @Test func convertInt8MaxToInt64() {
        let range: ClosedRange<Int64> = Int64(Int8.min)...Int64(Int8.max)
        let converted = range.converted(to: Int8.self)
        #expect(converted == Int8.min...Int8.max)
    }

    @Test func convertJustBelowInt32Max_Success() {
        let range: ClosedRange<Int64> = Int64(Int32.max) - 10...Int64(Int32.max)
        let converted = range.converted(to: Int32.self)
        #expect(converted == Int32.max - 10...Int32.max)
    }

    @Test func convertJustAboveInt32Max_Failure() {
        let range: ClosedRange<Int64> = Int64(Int32.max)...Int64(Int32.max) + 1
        let converted = range.converted(to: Int32.self)
        #expect(converted == nil)
    }

    // MARK: Single Element Ranges

    @Test func convertSingleElementRange_Success() {
        let range: ClosedRange<Int64> = 42...42
        let converted = range.converted(to: Int32.self)
        #expect(converted == 42...42)
    }

    @Test func convertSingleElementRangeOverflow_Failure() {
        let range: ClosedRange<Int64> = Int64(Int32.max) + 1...Int64(Int32.max) + 1
        let converted = range.converted(to: Int32.self)
        #expect(converted == nil)
    }

    @Test func convertZeroRange() {
        let range: ClosedRange<Int64> = 0...0
        let converted = range.converted(to: Int32.self)
        #expect(converted == 0...0)
    }

    // MARK: Edge Cases

    @Test func convertNegativeRange() {
        let range: ClosedRange<Int64> = -100 ... -50
        let converted = range.converted(to: Int32.self)
        #expect(converted == -100 ... -50)
    }

    @Test func convertMixedSignRange() {
        let range: ClosedRange<Int64> = -50...50
        let converted = range.converted(to: Int32.self)
        #expect(converted == -50...50)
    }

    // MARK: - batched(by:) Tests

    // MARK: Basic Batching

    @Test func batchSimpleRange() {
        let range: ClosedRange<Int> = 0...9
        let batches = range.batched(by: 3)
        #expect(batches == [0...2, 3...5, 6...8, 9...9])
    }

    @Test func batchEvenlyDivisibleRange() {
        let range: ClosedRange<Int> = 0...8
        let batches = range.batched(by: 3)
        #expect(batches == [0...2, 3...5, 6...8])
    }

    @Test func batchSingleElementRange() {
        let range: ClosedRange<Int> = 5...5
        let batches = range.batched(by: 3)
        #expect(batches == [5...5])
    }

    @Test func batchBySizeOne() {
        let range: ClosedRange<Int> = 0...4
        let batches = range.batched(by: 1)
        #expect(batches == [0...0, 1...1, 2...2, 3...3, 4...4])
    }

    @Test func batchByLargerThanRange() {
        let range: ClosedRange<Int> = 0...4
        let batches = range.batched(by: 10)
        #expect(batches == [0...4])
    }

    @Test func batchByExactRangeSize() {
        let range: ClosedRange<Int> = 0...9
        let batches = range.batched(by: 10)
        #expect(batches == [0...9])
    }

    // MARK: Negative and Mixed Sign Ranges

    @Test func batchNegativeRange() {
        let range: ClosedRange<Int> = -10 ... -1
        let batches = range.batched(by: 3)
        #expect(batches == [-10 ... -8, -7 ... -5, -4 ... -2, -1 ... -1])
    }

    @Test func batchMixedSignRange() {
        let range: ClosedRange<Int> = -5...5
        let batches = range.batched(by: 4)
        #expect(batches == [-5 ... -2, -1...2, 3...5])
    }

    @Test func batchRangeStartingAtNegative() {
        let range: ClosedRange<Int> = -3...2
        let batches = range.batched(by: 2)
        #expect(batches == [-3 ... -2, -1...0, 1...2])
    }

    // MARK: Large Batch Sizes

    @Test func batchLargeRange() {
        let range: ClosedRange<Int> = 0...99
        let batches = range.batched(by: 10)
        #expect(batches.count == 10)
        #expect(batches.first == 0...9)
        #expect(batches.last == 90...99)
    }

    @Test func batchLargeRangeUnevenDivision() {
        let range: ClosedRange<Int> = 0...99
        let batches = range.batched(by: 11)
        #expect(batches.count == 10)
        #expect(batches.first == 0...10)
        #expect(batches.last == 99...99)
    }

    @Test func batchVeryLargeBatchSize() {
        let range: ClosedRange<Int> = 0...99
        let batches = range.batched(by: 1000)
        #expect(batches == [0...99])
    }

    // MARK: Edge Cases

    @Test func batchWithLastBatchSmaller() {
        let range: ClosedRange<Int> = 0...10
        let batches = range.batched(by: 3)
        #expect(batches == [0...2, 3...5, 6...8, 9...10])
        #expect(batches.last?.count == 2)
    }

    @Test func batchWithLastBatchSingleElement() {
        let range: ClosedRange<Int> = 0...10
        let batches = range.batched(by: 5)
        #expect(batches == [0...4, 5...9, 10...10])
        #expect(batches.last?.count == 1)
    }

    @Test func batchConsecutiveRanges() {
        let range: ClosedRange<Int> = 1...5
        let batches = range.batched(by: 2)
        #expect(batches == [1...2, 3...4, 5...5])

        // Verify no gaps between batches
        for i in 0..<batches.count - 1 {
            #expect(batches[i].upperBound + 1 == batches[i + 1].lowerBound)
        }
    }

    @Test func batchCoverageCompleteness() {
        let range: ClosedRange<Int> = 0...20
        let batches = range.batched(by: 7)

        // Verify all elements are covered
        var covered: Set<Int> = []
        for batch in batches {
            for value in batch {
                covered.insert(value)
            }
        }

        #expect(covered.count == range.count)
        #expect(covered.min() == range.lowerBound)
        #expect(covered.max() == range.upperBound)
    }

    // MARK: Different Integer Types

    @Test func batchInt8Range() {
        let range: ClosedRange<Int8> = 0...10
        let batches = range.batched(by: 3)
        #expect(batches == [0...2, 3...5, 6...8, 9...10])
    }

    @Test func batchInt16Range() {
        let range: ClosedRange<Int16> = -5...5
        let batches = range.batched(by: 3)
        #expect(batches == [-5 ... -3, -2...0, 1...3, 4...5])
    }

    @Test func batchInt32Range() {
        let range: ClosedRange<Int32> = 100...110
        let batches = range.batched(by: 4)
        #expect(batches == [100...103, 104...107, 108...110])
    }

    @Test func batchInt64Range() {
        let range: ClosedRange<Int64> = 1000...1015
        let batches = range.batched(by: 5)
        #expect(batches == [1000...1004, 1005...1009, 1010...1014, 1015...1015])
    }

    // MARK: Boundary Conditions

    @Test func batchNearInt8MaxBoundary() {
        let range: ClosedRange<Int8> = 120...127
        let batches = range.batched(by: 3)
        #expect(batches == [120...122, 123...125, 126...127])
    }

    @Test func batchNearInt8MinBoundary() {
        let range: ClosedRange<Int8> = -128 ... -120
        let batches = range.batched(by: 3)
        #expect(batches == [-128 ... -126, -125 ... -123, -122 ... -120])
    }

    @Test func batchFullInt8Range() {
        let range: ClosedRange<Int8> = Int8.min...Int8.max
        let batches = range.batched(by: 64)
        #expect(batches.count == 4)
        #expect(batches.first?.lowerBound == Int8.min)
        #expect(batches.last?.upperBound == Int8.max)
    }

    // MARK: Verification of Batch Properties

    @Test func batchesHaveCorrectSizes() {
        let range: ClosedRange<Int> = 0...100
        let batchSize = 7
        let batches = range.batched(by: batchSize)

        for (index, batch) in batches.enumerated() {
            if index < batches.count - 1 {
                // All batches except possibly the last should have batchSize elements
                #expect(batch.count == batchSize)
            } else {
                // Last batch can be smaller
                #expect(batch.count <= batchSize)
                #expect(batch.count > 0)
            }
        }
    }

    @Test func batchesAreContiguous() {
        let range: ClosedRange<Int> = 10...50
        let batches = range.batched(by: 6)

        for i in 0..<batches.count - 1 {
            // Each batch should end exactly one before the next begins
            #expect(batches[i].upperBound + 1 == batches[i + 1].lowerBound)
        }
    }

    @Test func batchesSpanEntireRange() {
        let range: ClosedRange<Int> = -20...20
        let batches = range.batched(by: 7)

        #expect(batches.first?.lowerBound == range.lowerBound)
        #expect(batches.last?.upperBound == range.upperBound)
    }

    @Test func batchedRangeTotalCount() {
        let range: ClosedRange<Int> = 0...99
        let batches = range.batched(by: 10)

        let totalElements = batches.reduce(0) { $0 + $1.count }
        #expect(totalElements == range.count)
    }
}
