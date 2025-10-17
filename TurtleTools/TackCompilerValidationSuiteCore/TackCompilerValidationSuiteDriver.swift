//
//  TackCompilerValidationSuiteDriver.swift
//  TackCompilerValidationSuiteCore
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import ArgumentParser
import Foundation
import Logging
import SnapCore

@available(macOS 10.15, *)
public struct TackCompilerValidationSuiteDriver: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        abstract: "Exhaustive testing of Tack instructions",
        discussion: """
            Runs exhaustive tests on all arithmetic and bitwise Tack instructions.
            Tests all possible input combinations for 8-bit and 16-bit operations.
            Execution aborts on the first failure.
            """
    )

    @Flag(
        name: .long,
        help: "List all available test names"
    )
    var listTests = false

    @Option(
        name: .shortAndLong,
        help: "Number of concurrent jobs to use (0 or negative = auto-detect processor count, default: 0)"
    )
    var jobs: Int = 0 // Default to auto-detect

    @Option(
        name: .long,
        help: "Log level (trace, debug, info, notice, warning, error, critical). Default: warning"
    )
    var logLevel: String?

    @Argument(
        help: """
            Test names or patterns to run. Supports glob-style wildcards:
              * = zero or more characters (e.g., tack*W for all 16-bit tests)
              ? = exactly one character (e.g., tackADD? for tackADDB and tackADDW)
            Examples: tackADDB, tack*B, *ADD*, tackADD?
            Omit to run all tests.
            """
    )
    var testNames: [String] = []

    public init() {}

    public mutating func run() async throws {
        // Configure logger based on log level option
        let level: Logger.Level
        if let logLevelStr = logLevel?.lowercased() {
            switch logLevelStr {
            case "trace":
                level = .trace
            case "debug":
                level = .debug
            case "info":
                level = .info
            case "notice":
                level = .notice
            case "warning":
                level = .warning
            case "error":
                level = .error
            case "critical":
                level = .critical
            default:
                throw ValidationError(
                    "Invalid log level: \(logLevelStr). Valid levels: trace, debug, info, notice, warning, error, critical"
                )
            }
        } else {
            level = .warning // Default to warning
        }
        TestLogger.logger.logLevel = level

        if listTests {
            TestRunner.printAvailableTests()
        }
        else {
            let actualJobs = jobs <= 0
                ? ProcessInfo.processInfo.processorCount
                : jobs

            try await TestRunner.runTests(testFilters: testNames, jobCount: actualJobs)
        }
    }
}
