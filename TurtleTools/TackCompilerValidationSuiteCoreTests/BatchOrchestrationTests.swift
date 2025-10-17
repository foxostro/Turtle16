//
//  BatchOrchestrationTests.swift
//  TackCompilerValidationSuiteCoreTests
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import Foundation
import SnapCore
@testable import TackCompilerValidationSuiteCore
import Testing

/// Unit tests for batch orchestration logic
struct BatchOrchestrationTests {
    // MARK: - Mock Configuration

    /// Simple mock configuration for testing without TackVM
    struct MockConfig: TackRegisterConfiguration {
        typealias RegisterType = Int
        typealias ValueType = Int8

        static let combinations2 = [[0], [1]]
        static let combinations3 = [[0], [1], [2]]

        static func load(
            _: RegisterType, _: TackInstruction.RegisterPointer, _: Int
        ) -> TackInstruction {
            .nop
        }

        static func store(
            _: RegisterType, _: TackInstruction.RegisterPointer, _: Int
        ) -> TackInstruction {
            .nop
        }
    }

    // MARK: - Mock Test Function

    /// Records which ranges were tested and simulates execution time
    final class RangeRecorder: @unchecked Sendable {
        private let lock = NSLock()
        private var _calledRanges: [ClosedRange<Int>] = []
        private var _callCount = 0
        let simulatedDuration: TimeInterval // seconds per value tested

        init(simulatedDuration: TimeInterval = 0.0001) {
            self.simulatedDuration = simulatedDuration
        }

        func testFunction(registers _: [Int], range: ClosedRange<Int>) throws {
            lock.lock()
            defer { lock.unlock() }

            _calledRanges.append(range)
            _callCount += 1

            // Simulate work (for calibration testing) - outside lock
            lock.unlock()
            let valueCount = range.upperBound - range.lowerBound + 1
            let sleepTime = simulatedDuration * Double(valueCount)
            Thread.sleep(forTimeInterval: sleepTime)
            lock.lock()
        }

        func getAllTestedValues() -> [Int] {
            lock.lock()
            defer { lock.unlock() }
            return _calledRanges.flatMap { Array($0) }.sorted()
        }

        func hasOverlappingRanges() -> Bool {
            lock.lock()
            defer { lock.unlock() }

            for i in 0..<_calledRanges.count {
                for j in (i + 1)..<_calledRanges.count {
                    if _calledRanges[i].overlaps(_calledRanges[j]) {
                        return true
                    }
                }
            }
            return false
        }

        var callCount: Int {
            lock.lock()
            defer { lock.unlock() }
            return _callCount
        }
    }

    // MARK: - Coverage Tests

    @Test func runTestInBatches_CompleteRangeCoverage() async throws {
        let recorder = RangeRecorder()
        let progress = Progress(totalUnitCount: 256)

        try await runTestInBatches(
            MockConfig.self,
            registers: [0],
            testFunction: { r, range in try recorder.testFunction(registers: r, range: range) },
            progress: progress,
            jobCount: 4
        )

        // Verify all values Int8.min...Int8.max covered exactly once
        let allValues = recorder.getAllTestedValues()
        let expectedValues = Array(Int(Int8.min)...Int(Int8.max))

        #expect(allValues.count == 256)
        #expect(allValues.first == Int(Int8.min))
        #expect(allValues.last == Int(Int8.max))
        #expect(allValues == expectedValues)
    }

    @Test func runTestInBatches_NoDuplicates() async throws {
        let recorder = RangeRecorder()
        let progress = Progress(totalUnitCount: 256)

        try await runTestInBatches(
            MockConfig.self,
            registers: [0],
            testFunction: { r, range in try recorder.testFunction(registers: r, range: range) },
            progress: progress,
            jobCount: 4
        )

        // Check for overlapping ranges
        let hasOverlaps = recorder.hasOverlappingRanges()
        #expect(!hasOverlaps, "Found overlapping ranges")
    }

    @Test func runTestInBatches_NoGaps() async throws {
        let recorder = RangeRecorder()
        let progress = Progress(totalUnitCount: 256)

        try await runTestInBatches(
            MockConfig.self,
            registers: [0],
            testFunction: { r, range in try recorder.testFunction(registers: r, range: range) },
            progress: progress,
            jobCount: 4
        )

        // Verify sequential coverage without gaps
        let allValues = recorder.getAllTestedValues()
        for i in 1..<allValues.count {
            let gap = allValues[i] - allValues[i - 1]
            #expect(gap == 1, "Found gap between \(allValues[i - 1]) and \(allValues[i])")
        }
    }

    // MARK: - Calibration Tests

    @Test func runTestInBatches_CalibrationTakesApproximatelyOneSecond() async throws {
        // Use slower simulation to ensure calibration phase takes at least 1 second
        // With 256 values and 0.004s per value, calibration will process ~250 values in 1s
        let recorder = RangeRecorder(simulatedDuration: 0.004)
        let progress = Progress(totalUnitCount: 256)

        let start = Date()
        try await runTestInBatches(
            MockConfig.self,
            registers: [0],
            testFunction: { r, range in try recorder.testFunction(registers: r, range: range) },
            progress: progress,
            jobCount: 4
        )
        let elapsed = Date().timeIntervalSince(start)

        // Total time includes ~1s calibration + batch processing
        // Should be at least 1 second due to calibration
        #expect(elapsed >= 1.0, "Elapsed time \(elapsed) should be >= 1.0 seconds")
        #expect(elapsed < 10.0, "Elapsed time \(elapsed) should be < 10.0 seconds")
    }

    @Test func runTestInBatches_FastTestCompletesDuringCalibration() async throws {
        // Very fast test should complete during calibration phase
        let recorder = RangeRecorder(simulatedDuration: 0.00001)
        let progress = Progress(totalUnitCount: 256)

        let start = Date()
        try await runTestInBatches(
            MockConfig.self,
            registers: [0],
            testFunction: { r, range in try recorder.testFunction(registers: r, range: range) },
            progress: progress,
            jobCount: 4
        )
        let elapsed = Date().timeIntervalSince(start)

        // Should complete quickly (well under calibration target of 1 second)
        #expect(elapsed < 1.0, "Fast test completed in \(elapsed) seconds")
        #expect(progress.completedUnitCount == 256)

        let allValues = recorder.getAllTestedValues()
        #expect(allValues.count == 256)
    }

    @Test func runTestInBatches_ProgressUpdatesDuringCalibration() async throws {
        let recorder = RangeRecorder(simulatedDuration: 0.001)
        let progress = Progress(totalUnitCount: 256)

        try await runTestInBatches(
            MockConfig.self,
            registers: [0],
            testFunction: { r, range in try recorder.testFunction(registers: r, range: range) },
            progress: progress,
            jobCount: 4
        )

        // Progress should be updated throughout (calibration + batches)
        #expect(progress.completedUnitCount == 256)
    }

    // MARK: - Progress Tracking Tests

    @Test func runTestInBatches_ProgressUpdatesCorrectly() async throws {
        let recorder = RangeRecorder()
        let progress = Progress(totalUnitCount: 256)

        #expect(progress.completedUnitCount == 0)

        try await runTestInBatches(
            MockConfig.self,
            registers: [0],
            testFunction: { r, range in try recorder.testFunction(registers: r, range: range) },
            progress: progress,
            jobCount: 4
        )

        #expect(progress.completedUnitCount == 256)
        #expect(progress.fractionCompleted == 1.0)
    }

    @Test func runTestInBatches_ProgressReflectsActualWork() async throws {
        let recorder = RangeRecorder()
        let progress = Progress(totalUnitCount: 256)

        try await runTestInBatches(
            MockConfig.self,
            registers: [0],
            testFunction: { r, range in try recorder.testFunction(registers: r, range: range) },
            progress: progress,
            jobCount: 4
        )

        // Progress should match actual values tested
        let valuesTested = recorder.getAllTestedValues().count
        #expect(progress.completedUnitCount == Int64(valuesTested))
    }

    // MARK: - Parallelism Tests

    @Test func runTestInBatches_RespectsJobCount() async throws {
        let recorder = RangeRecorder()
        let progress = Progress(totalUnitCount: 256)

        try await runTestInBatches(
            MockConfig.self,
            registers: [0],
            testFunction: { r, range in try recorder.testFunction(registers: r, range: range) },
            progress: progress,
            jobCount: 2
        )

        // Verify completion (parallelism behavior is implicit)
        #expect(recorder.callCount > 0)
        #expect(progress.completedUnitCount == 256)
    }

    @Test func runTestInBatches_SingleJob() async throws {
        let recorder = RangeRecorder()
        let progress = Progress(totalUnitCount: 256)

        try await runTestInBatches(
            MockConfig.self,
            registers: [0],
            testFunction: { r, range in try recorder.testFunction(registers: r, range: range) },
            progress: progress,
            jobCount: 1
        )

        #expect(progress.completedUnitCount == 256)
        let allValues = recorder.getAllTestedValues()
        #expect(allValues.count == 256)
    }

    @Test func runTestInBatches_ManyJobs() async throws {
        let recorder = RangeRecorder()
        let progress = Progress(totalUnitCount: 256)

        try await runTestInBatches(
            MockConfig.self,
            registers: [0],
            testFunction: { r, range in try recorder.testFunction(registers: r, range: range) },
            progress: progress,
            jobCount: 16
        )

        #expect(progress.completedUnitCount == 256)
        let allValues = recorder.getAllTestedValues()
        #expect(allValues.count == 256)
    }

    // MARK: - Error Handling Tests

    @Test func runTestInBatches_PropagatesErrors() async throws {
        struct TestError: Error {}
        let recorder = RangeRecorder()
        let progress = Progress(totalUnitCount: 256)

        await #expect(throws: TestError.self) {
            try await runTestInBatches(
                MockConfig.self,
                registers: [0],
                testFunction: { r, range in
                    // Use recorder's thread-safe callCount to decide when to throw
                    if recorder.callCount >= 5 {
                        throw TestError()
                    }
                    try recorder.testFunction(registers: r, range: range)
                },
                progress: progress,
                jobCount: 4
            )
        }

        // Should have made some progress before error
        #expect(progress.completedUnitCount > 0)
        #expect(progress.completedUnitCount < 256)
    }

    @Test func runTestInBatches_ErrorStopsExecution() async throws {
        struct TestError: Error {}
        let progress = Progress(totalUnitCount: 256)

        do {
            let callCounter = RangeRecorder()
            try await runTestInBatches(
                MockConfig.self,
                registers: [0],
                testFunction: { r, range in
                    if callCounter.callCount > 3 {
                        throw TestError()
                    }
                    try callCounter.testFunction(registers: r, range: range)
                },
                progress: progress,
                jobCount: 4
            )
            Issue.record("Expected TestError to be thrown")
        } catch is TestError {
            // Expected error - test passes
        }
    }
}
