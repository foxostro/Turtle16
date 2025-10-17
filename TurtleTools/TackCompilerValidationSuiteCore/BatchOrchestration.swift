//
//  BatchOrchestration.swift
//  TackCompilerValidationSuiteCore
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import Foundation
import Logging

/// Runs a test function in batches with controlled parallelism and adaptive batch sizing
func runTestInBatches<Config: TackRegisterConfiguration>(
    _: Config.Type,
    registers: [Config.RegisterType],
    testFunction: @escaping @Sendable ([Config.RegisterType], ClosedRange<Int>) throws -> Void,
    progress: Progress,
    jobCount: Int
) async throws {
    let totalIterations = Int(Config.ValueType.max) - Int(Config.ValueType.min) + 1

    // Phase 1: Calibration - run a small batch, measuring how long it takes to complete
    TestLogger.logger.debug("Starting calibration phase", metadata: [
        "registers": "\(registers)",
        "total_iterations": "\(totalIterations)"
    ])

    // Run the test for one value in the range repeatedly, until 1s has elapsed, or the test is
    // actually completed. Count the number of iterations this took. If the test was not completed
    // then we can use this count along with the actual elapsed time to determine a good batch size.
    var currentValue = Int(Config.ValueType.min)
    var calibrationIterations = 0
    let calibrationStart = Date()
    var calibrationElapsed = TimeInterval()
    while calibrationElapsed < 1.0 {
        try testFunction(registers, currentValue...currentValue)
        calibrationElapsed = Date().timeIntervalSince(calibrationStart)
        calibrationIterations += 1
        currentValue = currentValue + 1
        progress.completedUnitCount += 1

        // Check if calibration completed the entire test
        guard currentValue <= Config.ValueType.max else {
            TestLogger.logger.debug("Test completed during calibration", metadata: [
                "elapsed": "\(String(format: "%.3f", calibrationElapsed))",
                "iterations": "\(calibrationIterations)"
            ])
            return
        }
    }

    // Compute a good batch size, aiming for each batch to complete in much less than one second.
    let iterationsPerSecond = Double(calibrationIterations) / calibrationElapsed
    let targetBatchDuration = 0.1 // seconds
    let batchSize = min(max(Int(iterationsPerSecond * targetBatchDuration), 1), totalIterations)

    TestLogger.logger.debug("Calibration complete", metadata: [
        "elapsed": "\(String(format: "%.3f", calibrationElapsed))",
        "calibration_iterations": "\(calibrationIterations)",
        "iterations_per_sec": "\(String(format: "%.0f", iterationsPerSecond))",
        "computed_batch_size": "\(batchSize)"
    ])

    // Split the remaining work into batches, and split batches into waves, where the batches in
    // each wave are processed in parallel in a task. The number of tasks in flight at any given
    // time is limited by the wave size.
    let waves = (currentValue...Int(Config.ValueType.max))
        .batched(by: batchSize)
        .unfold(by: jobCount)
    for waveBatches in waves {
        try await withThrowingTaskGroup(of: ClosedRange<Int>.self) { group in
            // Start a task for each batch in the wave.
            for batchRange in waveBatches {
                group.addTask {
                    try testFunction(registers, batchRange)
                    return batchRange
                }
            }

            // Wait for all tasks in this wave to complete before starting the next wave.
            for try await batchRange in group {
                let batchIterations = batchRange.upperBound - batchRange.lowerBound + 1
                progress.completedUnitCount += Int64(batchIterations)
                TestLogger.logger.trace(
                    "Batch completed",
                    metadata: [
                        "batchRange": "\(batchRange)",
                        "registers": "\(registers)",
                        "progress": "\(progress.completedUnitCount)/\(progress.totalUnitCount)",
                        "percent": "\(String(format: "%.2f", progress.fractionCompleted * 100.0))%"
                    ]
                )
            }
        } // withThrowingTaskGroup

        TestLogger.logger.trace(
            "Wave completed",
            metadata: [
                "waveBatches": "\(waveBatches)",
                "registers": "\(registers)",
                "progress": "\(progress.completedUnitCount)/\(progress.totalUnitCount)",
                "percent": "\(String(format: "%.2f", progress.fractionCompleted * 100.0))%"
            ]
        )
    } // for waveBatches in waves

    TestLogger.logger.debug("All batches completed", metadata: [
        "registers": "\(registers)"
    ])
}
